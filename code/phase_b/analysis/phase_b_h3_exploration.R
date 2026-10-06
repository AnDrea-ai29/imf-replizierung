# Descriptive country profiles for exploratory H3 development.
# This script does not assign regions or perform confirmatory H3 tests.

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(dplyr)
})

panel_path <- "data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
if (!file.exists(panel_path)) {
  stop("Phase-B-Panel fehlt. Bitte zuerst ",
       "build_phase_b_identical_measurement.R ausfuehren: ", panel_path)
}

panel <- read.csv(panel_path, stringsAsFactors = FALSE)
required <- c(
  "ISO3", "Year", "country", "avgcondtype_count", "unsc3",
  "resource_dep", "source"
)
if (!all(required %in% names(panel))) {
  stop("Phase-B-Panel enthaelt nicht alle H3-Profilvariablen: ",
       paste(setdiff(required, names(panel)), collapse = ", "))
}
if (anyDuplicated(panel[c("ISO3", "Year")])) {
  stop("Phase-B-Panel enthaelt doppelte ISO3-Jahr-Schluessel.")
}

panel <- panel %>%
  filter(Year >= 1992, Year <= 2023) %>%
  mutate(unsc3 = as.integer(unsc3))
if (nrow(panel) == 0) stop("Keine Beobachtungen im H3-Zeitraum 1992-2023.")
if (anyNA(panel$unsc3) || any(!panel$unsc3 %in% c(0L, 1L))) {
  stop("unsc3 muss im H3-Panel vollständig als 0/1 vorliegen.")
}

mean_or_na <- function(x) {
  if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
}
years_or_na <- function(year, treated) {
  years <- sort(unique(year[treated == 1L]))
  if (length(years) == 0L) NA_character_ else paste(years, collapse = ";")
}

profiles <- panel %>%
  group_by(ISO3) %>%
  summarise(
    country = first(country),
    n_country_years = n(),
    year_from = min(Year),
    year_to = max(Year),
    n_unsc3_years = sum(unsc3 == 1L),
    unsc3_years = years_or_na(Year, unsc3),
    mean_avgcondtype_count = mean_or_na(avgcondtype_count),
    mean_count_unsc3 = mean_or_na(avgcondtype_count[unsc3 == 1L]),
    mean_count_non_unsc3 = mean_or_na(avgcondtype_count[unsc3 == 0L]),
    descriptive_unsc3_gap = if (
      any(unsc3 == 1L & !is.na(avgcondtype_count)) &&
      any(unsc3 == 0L & !is.na(avgcondtype_count))
    ) {
      mean(avgcondtype_count[unsc3 == 1L], na.rm = TRUE) -
        mean(avgcondtype_count[unsc3 == 0L], na.rm = TRUE)
    } else {
      NA_real_
    },
    n_resource_dep = sum(!is.na(resource_dep)),
    mean_resource_dep = mean_or_na(resource_dep),
    n_historical_years = sum(source == "historical_DSV_MONA"),
    n_modern_years = sum(source == "current_Combined_ISO"),
    .groups = "drop"
  ) %>%
  arrange(ISO3)

output_dir <- "results/phase_b/exploration"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_path <- file.path(output_dir, "h3_country_profiles.csv")
write.csv(profiles, output_path, row.names = FALSE, na = "")

cat(
  "Explorative H3-Laenderprofile:", nrow(profiles), "Laender |",
  nrow(panel), "Land-Jahre | Zeitraum",
  min(panel$Year), "-", max(panel$Year), "\n"
)
cat("Ausgabe:", output_path, "\n")
cat(
  "Deskriptive UNSC-Luecken sind keine kausalen Schaetzungen. ",
  "Es werden weder Ausreisser automatisch markiert noch Regionen zugeordnet ",
  "oder inferenzielle H3-Tests ausgefuehrt.\n",
  sep = ""
)

# ---------------------------------------------------------------------------
# Vergleichsansicht (sortierte Ansicht der deskriptiven UNSC-Luecken):
# Laender mit beobachteter Zaehl-AV in UNSC-Jahren, sortiert nach
# Konditionalitaet in UNSC-Jahren; Nicht-UNSC-Jahre als Vergleichsspalte.
# Hinweis: positive Luecken spiegeln v.a. die Epochenverschiebung (Post-2008-
# Konditionalitaet), da UNSC-Fenster mit Programmen stark ungleich ueber die
# Zeit verteilt sind. Rein deskriptiv (explorativ), keine Inferenz.
# ---------------------------------------------------------------------------
vergleich <- panel %>%
  filter(!is.na(avgcondtype_count)) %>%
  group_by(ISO3) %>%
  summarise(
    country = first(country),
    n_obs_unsc3 = sum(unsc3 == 1L & !is.na(avgcondtype_count)),
    mean_count_unsc3 = mean_or_na(avgcondtype_count[unsc3 == 1L]),
    n_obs_non_unsc3 = sum(unsc3 == 0L & !is.na(avgcondtype_count)),
    mean_count_non_unsc3 = mean_or_na(avgcondtype_count[unsc3 == 0L]),
    descriptive_unsc3_gap = if (n_obs_unsc3 > 0L && n_obs_non_unsc3 > 0L) {
      mean_count_unsc3 - mean_count_non_unsc3
    } else {
      NA_real_
    },
    .groups = "drop"
  ) %>%
  filter(n_obs_unsc3 > 0L) %>%
  arrange(desc(mean_count_unsc3))

vergleich_path <- file.path(output_dir, "h3_vergleichsansicht.csv")
write.csv(vergleich, vergleich_path, row.names = FALSE, na = "")

cat("\nVergleichsansicht (sortiert nach Konditionalitaet in UNSC-Jahren):\n")
print(
  head(vergleich[, c("ISO3", "country", "n_obs_unsc3", "mean_count_unsc3",
                     "n_obs_non_unsc3", "mean_count_non_unsc3",
                     "descriptive_unsc3_gap")], 10),
  digits = 3, row.names = FALSE
)
cat("Ausgabe:", vergleich_path, "\n")
