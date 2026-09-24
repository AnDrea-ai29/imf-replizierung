# Regionale Effektanalyse: erkennt auffaellige Regionen und Laender automatisch
# Ziel: regionale Muster, Ausreisser und Subgroup-Modelle systematisch pruefen
# Nutzung: region-Variable aus final_data_panel_ALL.csv ODER eigene
# Regionszuordnung (region_def) fuer beliebige Regionsgruppen.

library(tidyverse)
library(fixest)

analyze_regions <- function(data,
                           iso_col = "ISO3",
                           year_col = "Year",
                           outcome = "avgcondtype_all",
                           treatment = "unsc3",
                           resource_var = "resource_dep",
                           controls = c("XDebtGNI", "DebtServGNI", "ResXDebt"),
                           region_col = "region",
                           region_def = NULL,
                           min_region_n = 3,
                           quantile_cut = 0.75) {

  # 1) Region erzeugen: vorhandene Spalte nutzen oder aus region_def ableiten
  if (!is.null(region_def)) {
    # region_def: benannte Liste, z.B. list(SSA = c("AGO", ...), ECA = c(...), ...)
    region_lookup <- unlist(lapply(names(region_def), function(r) {
      setNames(rep(r, length(region_def[[r]])), region_def[[r]])
    }))
    data <- data %>%
      mutate(!!sym(region_col) := ifelse(!!sym(iso_col) %in% names(region_lookup),
                                         region_lookup[!!sym(iso_col)], "Other"))
  }
  if (!region_col %in% names(data)) {
    stop("Keine Region-Spalte vorhanden und kein region_def uebergeben.")
  }

  # 2) Deskriptive Regionsuebersicht
  region_summary <- data %>%
    group_by(.data[[region_col]]) %>%
    summarise(
      n_countries = n_distinct(!!sym(iso_col)),
      avg_cond = mean(.data[[outcome]], na.rm = TRUE),
      avg_resource = mean(.data[[resource_var]], na.rm = TRUE),
      unsc_share = mean(.data[[treatment]], na.rm = TRUE),
      .groups = "drop"
    )

  # 3) Laendersummary
  country_summary <- data %>%
    group_by(!!sym(iso_col), .data[[region_col]]) %>%
    summarise(
      avg_cond = mean(.data[[outcome]], na.rm = TRUE),
      avg_resource = mean(.data[[resource_var]], na.rm = TRUE),
      unsc_share = mean(.data[[treatment]], na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(avg_resource))

  # 4) Auffaellige Laender identifizieren
  outlier_threshold <- quantile(country_summary$avg_resource, quantile_cut, na.rm = TRUE)
  outlier_countries <- country_summary %>%
    filter(avg_resource >= outlier_threshold)

  # 5) Globales Modell mit Region-Interaktion
  formula_global <- as.formula(
    paste0(
      outcome, " ~ ", treatment, " * ", resource_var, " * ", region_col, " + ",
      paste(controls, collapse = " + "),
      " | ", iso_col, " + ", year_col
    )
  )

  model_global <- feols(
    formula_global,
    data = data,
    vcov = "hetero"
  )

  # 6) Regionenspezifische Modelle
  region_models <- lapply(unique(data[[region_col]]), function(r) {
    subset_data <- data %>% filter(.data[[region_col]] == r)
    if (n_distinct(subset_data[[iso_col]]) < min_region_n) return(NULL)

    formula_subset <- as.formula(
      paste0(
        outcome, " ~ ", treatment, " * ", resource_var, " + ",
        paste(controls, collapse = " + "),
        " | ", iso_col, " + ", year_col
      )
    )

    m <- tryCatch(
      feols(formula_subset, data = subset_data, vcov = "hetero"),
      error = function(e) {
        message("Region ", r, ": Submodell nicht schaetzbar (", conditionMessage(e), ")")
        NULL
      }
    )
    if (is.null(m)) return(NULL)
    list(region = r, model = m)
  })
  region_models <- Filter(Negate(is.null), region_models)
  names(region_models) <- sapply(region_models, function(x) x$region)

  # 7) Ergebnisliste zurueckgeben
  result <- list(
    region_summary = region_summary,
    country_summary = country_summary,
    outlier_countries = outlier_countries,
    model_global = model_global,
    region_models = region_models
  )

  return(result)
}

# Beispiel-Verwendung (region-Spalte liegt im Panel bereits vor):
#
# global_data <- read.csv("data/processed/final_data_panel_ALL.csv",
#                         stringsAsFactors = FALSE)
#
# result <- analyze_regions(global_data)
#
# print(result$region_summary)
# print(result$outlier_countries)
# summary(result$model_global)
# for (r in names(result$region_models)) {
#   cat("\n=== Region:", r, "===\n")
#   print(summary(result$region_models[[r]]$model))
# }
#
# Alternative: eigene Regionsgruppen definieren, z.B.
# region_def <- list(
#   SSA  = c("AGO", "BEN", "BFA", ...),
#   MENA = c("EGY", "IRQ", "JOR", "SDN", "TUN", "YEM"),
#   ECA  = c("ALB", "ARM", "BGR", ...)
# )
# result <- analyze_regions(global_data, region_def = region_def)
