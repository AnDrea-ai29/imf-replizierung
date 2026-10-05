# Confirmatory H1/H2 models on the Phase-B MONA panel, 1992-2023, with the
# full DSV control set and nrquarterssmpl duration control.
# H3 and the exploratory former-H4 analysis are handled separately.

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(dplyr)
  library(fixest)
})

panel_path <- "data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
controls_path <- "data/processed/controls_wdi_1990_2025.csv"
if (!file.exists(panel_path)) {
  stop("Einheitliches Phase-B-Panel fehlt. Bitte zuerst ",
       "build_phase_b_identical_measurement.R ausfuehren: ", panel_path)
}
if (!file.exists(controls_path)) stop("Kontrollpanel fehlt: ", controls_path)

panel <- read.csv(panel_path, stringsAsFactors = FALSE)
controls_data <- read.csv(controls_path, stringsAsFactors = FALSE)
analysis_start <- 1992L
analysis_end <- 2023L
required_panel <- c(
  "ISO3", "Year", "avgcondtype_count", "unsc3", "resource_dep",
  "FuelExportPct", "MineralExportPct",
  "nrquarterssmpl", "legelec_l", "XDebtGNI", "DebtServGNI", "ResXDebt",
  "ExtBalGDP", "GFCFGDP", "USaidGDP", "imf_conc_gdp", "imf_noconc_gdp",
  "UseIMFCredGDP", "UseIMFCredit", "nomGDP"
)
required_controls <- c("ISO3", "Year", "ExportGDP")
if (!all(required_panel %in% names(panel))) {
  stop("Variablen fehlen im globalen Panel: ",
       paste(setdiff(required_panel, names(panel)), collapse = ", "))
}
if (!all(required_controls %in% names(controls_data))) {
  stop("Variablen fehlen im Kontrollpanel: ",
       paste(setdiff(required_controls, names(controls_data)), collapse = ", "))
}
if (anyDuplicated(panel[c("ISO3", "Year")])) {
  stop("Globales Panel enthaelt doppelte ISO3-Jahr-Schluessel.")
}
if (anyDuplicated(controls_data[c("ISO3", "Year")])) {
  stop("Kontrollpanel enthaelt doppelte ISO3-Jahr-Schluessel.")
}

flow_controls <- c(
  "nrquarterssmpl", "legelec_l", "XDebtGNI", "DebtServGNI", "ResXDebt",
  "ExtBalGDP", "GFCFGDP", "USaidGDP", "imf_conc_gdp", "imf_noconc_gdp"
)
stock_controls <- c(
  "nrquarterssmpl", "legelec_l", "XDebtGNI", "DebtServGNI", "ResXDebt",
  "ExtBalGDP", "GFCFGDP", "USaidGDP", "UseIMFCredGDP"
)
reported_stock_controls <- sub(
  "UseIMFCredGDP", "UseIMFCredGDP_reported", stock_controls, fixed = TRUE
)
controls <- flow_controls
panel$UseIMFCredGDP_reported <- with(
  panel,
  ifelse(
    !is.na(UseIMFCredit) & !is.na(nomGDP) & nomGDP > 0,
    100 * UseIMFCredit / nomGDP,
    NA_real_
  )
)
d <- panel %>%
  filter(Year >= analysis_start, Year <= analysis_end)

if (nrow(d) == 0) stop("Keine Beobachtungen im Analysezeitraum 1992-2023.")
if (min(d$Year) != analysis_start || max(d$Year) != analysis_end) {
  stop("Das Phase-B-Panel deckt nicht den vollstaendigen Zeitraum 1992-2023 ab.")
}

fit_model <- function(dat, outcome, measure = NULL, label,
                      controls_used = controls) {
  needed <- c(outcome, "unsc3", controls_used, "ISO3", "Year", measure)
  needed <- unique(needed[!is.na(needed)])
  sample <- dat %>% filter(complete.cases(across(all_of(needed))))
  if (nrow(sample) == 0) stop("Keine Complete Cases fuer ", label)

  rhs <- if (is.null(measure)) {
    paste("unsc3 +", paste(controls_used, collapse = " + "))
  } else {
    paste("unsc3 *", measure, "+", paste(controls_used, collapse = " + "))
  }
  model <- feols(
    as.formula(paste(outcome, "~", rhs, "| ISO3 + Year")),
    data = sample,
    vcov = "hetero"
  )

  terms <- if (is.null(measure)) {
    c("unsc3")
  } else {
    c("unsc3", measure, paste0("unsc3:", measure))
  }
  tab <- coeftable(model)
  extract <- function(term, column) {
    if (term %in% rownames(tab)) unname(tab[term, column]) else NA_real_
  }
  focal <- if (is.null(measure)) "unsc3" else paste0("unsc3:", measure)
  coefficient <- extract(focal, "Estimate")
  standard_error <- extract(focal, "Std. Error")
  p_value <- extract(focal, "Pr(>|t|)")
  model_status <- if (is.finite(coefficient) &&
                      is.finite(standard_error) &&
                      is.finite(p_value)) {
    "geschaetzt"
  } else {
    "Inferenz nicht berechenbar (kleines oder kollineares Sample)"
  }
  data.frame(
    Spezifikation = label,
    Modelltyp = "Vollmodell: Länder- und Jahres-FE",
    AV = outcome,
    Mass = if (is.null(measure)) NA_character_ else measure,
    Fokus_Term = focal,
    Koeffizient = if (is.finite(coefficient)) coefficient else NA_real_,
    Standardfehler = if (is.finite(standard_error)) standard_error else NA_real_,
    p_Wert = if (is.finite(p_value)) p_value else NA_real_,
    n_obs = nobs(model),
    n_obs_pre_fe = nrow(sample),
    n_laender = n_distinct(sample$ISO3),
    n_unsc3 = sum(sample$unsc3 == 1),
    n_unsc3_laender = n_distinct(sample$ISO3[sample$unsc3 == 1]),
    Jahr_von = min(sample$Year),
    Jahr_bis = max(sample$Year),
    Status = model_status,
    stringsAsFactors = FALSE
  )
}

results <- list(
  H1_count = fit_model(
    d, "avgcondtype_count",
    label = "H1 Hauptmodell: Bedingungen pro Quartal"
  ),
  H2_count = fit_model(
    d, "avgcondtype_count", "resource_dep",
    "H2 Hauptmodell: Rohstoffsumme"
  ),
  H2_fuel = fit_model(
    d, "avgcondtype_count", "FuelExportPct",
    "H2 Robustheit: Fuel-Exporte"
  ),
  H2_mineral = fit_model(
    d, "avgcondtype_count", "MineralExportPct",
    "H2 Robustheit: Mineral-Exporte"
  ),
  H2_placebo = fit_model(
    d, "avgcondtype_count", "ExportGDP",
    "H2 Placebo: gesamte Exporte"
  )
)

results[["H1_imf_stock"]] <- fit_model(
  d, "avgcondtype_count",
  label = "H1 Robustheit: IMF-Kreditbestand statt Nettoflüsse",
  controls_used = stock_controls
)
results[["H2_imf_stock"]] <- fit_model(
  d, "avgcondtype_count", "resource_dep",
  "H2 Robustheit: IMF-Kreditbestand statt Nettoflüsse",
  controls_used = stock_controls
)
results[["H1_imf_stock_reported"]] <- fit_model(
  d, "avgcondtype_count",
  label = "H1 Robustheit: berichteter IMF-Kreditbestand, fehlend ausgeschlossen",
  controls_used = reported_stock_controls
)
results[["H2_imf_stock_reported"]] <- fit_model(
  d, "avgcondtype_count", "resource_dep",
  "H2 Robustheit: berichteter IMF-Kreditbestand, fehlend ausgeschlossen",
  controls_used = reported_stock_controls
)
# Directly comparable H1/H2 specification ladder:
# DSV baseline controls only duration; the full model adds all nine controls.
fit_comparison_fe <- function(dat, outcome, measure = NULL,
                              controls_used, fixed_effects, label) {
  needed <- unique(c(
    outcome, "unsc3", controls_used, "ISO3", "Year", measure
  ))
  sample <- dat %>% filter(complete.cases(across(all_of(needed))))
  if (nrow(sample) == 0) stop("Keine Complete Cases fuer ", label)

  rhs <- if (is.null(measure)) {
    paste("unsc3", paste(controls_used, collapse = " + "), sep = " + ")
  } else {
    paste("unsc3 *", measure, "+", paste(controls_used, collapse = " + "))
  }
  model <- feols(
    as.formula(paste(outcome, "~", rhs, "|", fixed_effects)),
    data = sample,
    vcov = "hetero"
  )
  focal <- if (is.null(measure)) "unsc3" else paste0("unsc3:", measure)
  tab <- coeftable(model)
  estimate <- if (focal %in% rownames(tab)) unname(tab[focal, "Estimate"]) else NA_real_
  standard_error <- if (focal %in% rownames(tab)) unname(tab[focal, "Std. Error"]) else NA_real_
  p_value <- if (focal %in% rownames(tab)) unname(tab[focal, "Pr(>|t|)"]) else NA_real_

  data.frame(
    Spezifikation = label,
    Modelltyp = if (identical(fixed_effects, "ISO3")) {
      "Länder-FE"
    } else {
      "Länder- und Jahres-FE"
    },
    AV = outcome,
    Mass = if (is.null(measure)) NA_character_ else measure,
    Fokus_Term = focal,
    Koeffizient = estimate,
    Standardfehler = standard_error,
    p_Wert = p_value,
    n_obs = nobs(model),
    n_obs_pre_fe = nrow(sample),
    n_laender = n_distinct(sample$ISO3),
    n_unsc3 = sum(sample$unsc3 == 1),
    n_unsc3_laender = n_distinct(sample$ISO3[sample$unsc3 == 1]),
    Jahr_von = min(sample$Year),
    Jahr_bis = max(sample$Year),
    Status = if (is.finite(estimate) && is.finite(standard_error) &&
                 is.finite(p_value)) "geschaetzt" else "Term nicht schaetzbar",
    stringsAsFactors = FALSE
  )
}

fit_dsv_gls <- function(dat, outcome, measure = NULL,
                        controls_used, label) {
  needed <- unique(c(
    outcome, "unsc3", controls_used, "ISO3", "Year", measure
  ))
  sample <- dat %>% filter(complete.cases(across(all_of(needed))))
  if (nrow(sample) == 0) stop("Keine Complete Cases fuer ", label)

  sample <- sample %>%
    group_by(ISO3) %>%
    filter(n() > 1) %>%
    ungroup()
  if (nrow(sample) == 0) stop("Keine nicht-singleton Beobachtungen fuer ", label)

  rhs <- if (is.null(measure)) {
    paste("unsc3", paste(controls_used, collapse = " + "), sep = " + ")
  } else {
    paste("unsc3 *", measure, "+", paste(controls_used, collapse = " + "))
  }
  regressors <- model.matrix(as.formula(paste("~", rhs)), data = sample)
  country_effects <- model.matrix(~ 0 + factor(ISO3), data = sample)
  design <- cbind(country_effects, regressors)
  response <- sample[[outcome]]
  initial <- lm.fit(design, response)
  residual_variance <- tapply(
    initial$residuals, sample$ISO3,
    function(residual) mean(residual^2)
  )
  if (any(!is.finite(residual_variance)) || any(residual_variance <= 0)) {
    stop("DSV-GLS kann nicht geschaetzt werden: nichtpositive Laendervarianz in ",
         label)
  }

  weights <- as.numeric(1 / sqrt(
    residual_variance[as.character(sample$ISO3)]
  ))
  weighted_design <- sweep(design, 1, weights, `*`)
  weighted_response <- response * weights
  qr_design <- qr(weighted_design)
  keep <- sort(qr_design$pivot[seq_len(qr_design$rank)])
  reduced_design <- weighted_design[, keep, drop = FALSE]
  column_names <- colnames(reduced_design)
  estimate_vector <- solve(
    crossprod(reduced_design),
    crossprod(reduced_design, weighted_response)
  )
  names(estimate_vector) <- column_names
  variance_matrix <- solve(crossprod(reduced_design))
  df <- nrow(sample) - length(estimate_vector)
  if (df <= 0) stop("DSV-GLS hat keine positiven Residualfreiheitsgrade: ", label)
  correction <- nrow(sample) / df
  standard_errors <- sqrt(diag(variance_matrix) * correction)
  names(standard_errors) <- column_names
  t_value <- estimate_vector / standard_errors
  p_values <- 2 * pt(abs(t_value), df = df, lower.tail = FALSE)
  names(p_values) <- column_names
  focal <- if (is.null(measure)) "unsc3" else paste0("unsc3:", measure)
  if (!focal %in% column_names) {
    estimate <- standard_error <- p_value <- NA_real_
  } else {
    estimate <- unname(estimate_vector[[focal]])
    standard_error <- unname(standard_errors[[focal]])
    p_value <- unname(p_values[[focal]])
  }

  data.frame(
    Spezifikation = label,
    Modelltyp = "DSV-nahes GLS: Länderheteroskedastizität",
    AV = outcome,
    Mass = if (is.null(measure)) NA_character_ else measure,
    Fokus_Term = focal,
    Koeffizient = estimate,
    Standardfehler = standard_error,
    p_Wert = p_value,
    n_obs = nrow(sample),
    n_obs_pre_fe = nrow(sample),
    n_laender = n_distinct(sample$ISO3),
    n_unsc3 = sum(sample$unsc3 == 1),
    n_unsc3_laender = n_distinct(sample$ISO3[sample$unsc3 == 1]),
    Jahr_von = min(sample$Year),
    Jahr_bis = max(sample$Year),
    Status = if (is.finite(estimate) && is.finite(standard_error) &&
                 is.finite(p_value)) "geschaetzt" else "Term nicht schaetzbar",
    stringsAsFactors = FALSE
  )
}

baseline_controls <- "nrquarterssmpl"
full_controls <- controls
comparison_results <- list()
for (hypothesis in list(
  list(name = "H1", outcome = "avgcondtype_count", measure = NULL),
  list(name = "H2", outcome = "avgcondtype_count", measure = "resource_dep")
)) {
  comparison_results[[paste0(hypothesis$name, "_baseline_country_fe")]] <-
    fit_comparison_fe(
      d, hypothesis$outcome, hypothesis$measure, baseline_controls, "ISO3",
      paste0(hypothesis$name, " Basismodell: Länder-FE, nur nrquarterssmpl")
    )
  comparison_results[[paste0(hypothesis$name, "_full_country_fe")]] <-
    fit_comparison_fe(
      d, hypothesis$outcome, hypothesis$measure, full_controls, "ISO3",
      paste0(hypothesis$name, " Vollmodell: Länder-FE, DSV-Kontrollen")
    )
  comparison_results[[paste0(hypothesis$name, "_full_two_way_fe")]] <-
    fit_comparison_fe(
      d, hypothesis$outcome, hypothesis$measure, full_controls, "ISO3 + Year",
      paste0(hypothesis$name, " Vollmodell: Länder- und Jahres-FE")
    )
  comparison_results[[paste0(hypothesis$name, "_full_gls")]] <-
    fit_dsv_gls(
      d, hypothesis$outcome, hypothesis$measure, full_controls,
      paste0(hypothesis$name, " Vollmodell: DSV-nahes GLS")
    )
}
comparison_table <- bind_rows(comparison_results)
dir.create("results/phase_b/tables", recursive = TRUE, showWarnings = FALSE)
write.csv(
  comparison_table,
  "results/phase_b/tables/phase_b_modellvergleich.csv",
  row.names = FALSE
)
results <- c(results, comparison_results)

complete_primary <- d %>%
  filter(complete.cases(across(all_of(c(
    "avgcondtype_count", "unsc3", "resource_dep", controls, "ISO3", "Year"
  )))))
if (nrow(complete_primary) == 0) {
  stop("Keine vollstaendigen Beobachtungen fuer das H2-Hauptmodell mit DSV-Kontrollen.")
}
limits <- quantile(complete_primary$resource_dep, c(0.01, 0.99), na.rm = TRUE)
d$resource_dep_winsor <- pmin(
  pmax(d$resource_dep, limits[[1]]),
  limits[[2]]
)
results[["H2_winsor"]] <- fit_model(
  d, "avgcondtype_count", "resource_dep_winsor",
  "H2 Robustheit: Rohstoffsumme winsorisiert (1./99. Perzentil)"
)

for (window in list(
  list(label = "1992-2008", years = 1992:2008),
  list(label = "2009-2023", years = 2009:2023)
)) {
  results[[paste0("H2_", window$label)]] <- fit_model(
    filter(d, Year %in% window$years),
    "avgcondtype_count", "resource_dep",
    paste0("H2 Robustheit: Zeitraum ", window$label)
  )
}

results_table <- bind_rows(results)
dir.create("results/phase_b/models", recursive = TRUE, showWarnings = FALSE)
write.csv(results_table, "results/phase_b/tables/phase_b_hypothesen_robustheit.csv",
          row.names = FALSE)

# Leave-one-country-out sensitivity for the primary H2 interaction.
full_model <- feols(
  avgcondtype_count ~ unsc3 * resource_dep +
    nrquarterssmpl + legelec_l + XDebtGNI + DebtServGNI + ResXDebt +
    ExtBalGDP + GFCFGDP + USaidGDP + imf_conc_gdp + imf_noconc_gdp |
    ISO3 + Year,
  data = complete_primary,
  vcov = "hetero"
)
full_term <- "unsc3:resource_dep"
if (!full_term %in% names(coef(full_model))) {
  stop("H2-Interaktion ist im vollstaendigen Sample nicht schaetzbar.")
}
full_coef <- unname(coef(full_model)[[full_term]])
loo <- lapply(sort(unique(complete_primary$ISO3)), function(country) {
  sample <- complete_primary %>% filter(ISO3 != .env$country)
  model <- feols(
    avgcondtype_count ~ unsc3 * resource_dep +
      nrquarterssmpl + legelec_l + XDebtGNI + DebtServGNI + ResXDebt +
      ExtBalGDP + GFCFGDP + USaidGDP + imf_conc_gdp + imf_noconc_gdp |
      ISO3 + Year,
    data = sample,
    vcov = "hetero"
  )
  estimated <- full_term %in% names(coef(model))
  data.frame(
    ausgeschlossenes_land = country,
    interaktion_vollsample = full_coef,
    interaktion_ohne_land = if (estimated) unname(coef(model)[[full_term]]) else NA_real_,
    veraenderung = if (estimated) unname(coef(model)[[full_term]]) - full_coef else NA_real_,
    n_obs = nobs(model),
    n_unsc3 = sum(sample$unsc3 == 1),
    status = if (estimated) "geschaetzt" else "Interaktion nicht geschaetzt",
    stringsAsFactors = FALSE
  )
})
loo_table <- bind_rows(loo) %>% arrange(desc(abs(veraenderung)))
write.csv(loo_table, "results/phase_b/tables/phase_b_h2_leave_one_country_out.csv",
          row.names = FALSE)
saveRDS(full_model, "results/phase_b/models/phase_b_h2_main.rds")

cat("Phase B: einheitlich gemessenes MONA-Panel, Analysezeitraum 1992-2023\n")
cat("Quelle 1992-2008: historische DSV-MONA-Zeilen; Quelle 2009-2023: Combined_ISO\n")
cat("H1/H2 verwenden den DSV-Kontrollsatz: nrquarterssmpl plus alle neun DSV-Kontrollen.\n")
cat("Phase B nutzt weiterhin Laender- und Jahres-Fixed-Effects.\n")
cat("H1/H2-Zaehlauswertung nutzt auf beiden Quellen dieselbe MONA-Zeilen- und Quartalsregel.\n")
cat("\nH1/H2: Spezifikationsvergleich\n")
print(
  comparison_table %>%
    select(Spezifikation, Modelltyp, Koeffizient, Standardfehler, p_Wert,
           n_obs, Jahr_von, Jahr_bis),
  row.names = FALSE,
  digits = 4
)
cat("H1/H2 und Robustheit:\n")
print(results_table, row.names = FALSE, digits = 4)
cat("\nH2 Leave-one-country-out, groesste Aenderungen:\n")
print(head(loo_table, 10), row.names = FALSE, digits = 4)
cat("\nOutputs:\n")
cat("- results/phase_b/tables/phase_b_hypothesen_robustheit.csv\n")
cat("- results/phase_b/tables/phase_b_modellvergleich.csv\n")
cat("- results/phase_b/tables/phase_b_h2_leave_one_country_out.csv\n")
cat("- results/phase_b/models/phase_b_h2_main.rds\n")
cat("H3 ist explorativ; Laenderprofile separat mit",
    "phase_b_h3_exploration.R erstellen.\n")
cat("Die explorative Analyse zur frueheren H4 separat mit",
    "phase_b_h4_exploration.R ausfuehren.\n")
