# Exploratory association between IMF conditionality and later changes in
# resource-export dependence. This is descriptive, not a causal design.

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(dplyr)
})

panel_path <- "data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
controls_path <- "data/processed/controls_wdi_1990_2025.csv"
analysis_start <- 1992L
analysis_end <- 2023L
horizon <- 3L

if (!file.exists(panel_path)) {
  stop("Phase-B-Panel fehlt. Bitte zuerst ",
       "build_phase_b_identical_measurement.R ausfuehren: ", panel_path)
}
if (!file.exists(controls_path)) {
  stop("WDI-Kontrollpanel fehlt. Bitte zuerst build_controls_wdi.R ausfuehren: ",
       controls_path)
}

panel <- read.csv(panel_path, stringsAsFactors = FALSE)
controls_data <- read.csv(controls_path, stringsAsFactors = FALSE)
required_panel <- c("ISO3", "Year", "country", "avgcondtype_count")
required_controls <- c("ISO3", "Year", "resource_dep")
if (!all(required_panel %in% names(panel))) {
  stop("Variablen fehlen im Phase-B-Panel: ",
       paste(setdiff(required_panel, names(panel)), collapse = ", "))
}
if (!all(required_controls %in% names(controls_data))) {
  stop("Variablen fehlen im WDI-Kontrollpanel: ",
       paste(setdiff(required_controls, names(controls_data)), collapse = ", "))
}
if (anyDuplicated(panel[c("ISO3", "Year")])) {
  stop("Phase-B-Panel enthaelt doppelte ISO3-Jahr-Schluessel.")
}
if (anyDuplicated(controls_data[c("ISO3", "Year")])) {
  stop("WDI-Kontrollpanel enthaelt doppelte ISO3-Jahr-Schluessel.")
}

resource_by_year <- controls_data %>%
  select(ISO3, Year, resource_dep)
baseline_resource <- resource_by_year %>%
  rename(resource_dep_t = resource_dep)
followup_resource <- resource_by_year %>%
  transmute(
    ISO3,
    Year = Year - horizon,
    resource_dep_t_plus_horizon = resource_dep
  )

matched <- panel %>%
  filter(Year >= analysis_start, Year <= analysis_end - horizon) %>%
  select(ISO3, Year, country, avgcondtype_count) %>%
  left_join(baseline_resource, by = c("ISO3", "Year")) %>%
  left_join(followup_resource, by = c("ISO3", "Year")) %>%
  mutate(
    outcome_year = Year + horizon,
    resource_dep_change_pp = resource_dep_t_plus_horizon - resource_dep_t
  ) %>%
  filter(complete.cases(
    avgcondtype_count, resource_dep_t, resource_dep_t_plus_horizon
  ))

if (nrow(matched) < 3L ||
    length(unique(matched$avgcondtype_count)) < 2L ||
    length(unique(matched$resource_dep_change_pp)) < 2L) {
  stop("Zu wenige oder keine variierenden vollstaendigen Beobachtungen fuer ",
       "die explorative Auswertung.")
}

summary <- data.frame(
  Analyse = "Konditionalitaet im Bewilligungsjahr und Rohstoffabhaengigkeit t+3 minus t",
  Horizont_Jahre = horizon,
  n_programm_landjahre = nrow(matched),
  n_laender = n_distinct(matched$ISO3),
  Jahr_von = min(matched$Year),
  letztes_startjahr = max(matched$Year),
  letztes_ergebnisjahr = max(matched$outcome_year),
  mittlere_konditionalitaet_pro_quartal = mean(matched$avgcondtype_count),
  mittlere_rohstoffabhaengigkeit_zu_t = mean(matched$resource_dep_t),
  mittlere_veraenderung_rohstoffabhaengigkeit_pp =
    mean(matched$resource_dep_change_pp),
  median_veraenderung_rohstoffabhaengigkeit_pp =
    median(matched$resource_dep_change_pp),
  spearman_rho = cor(
    matched$avgcondtype_count,
    matched$resource_dep_change_pp,
    method = "spearman"
  ),
  stringsAsFactors = FALSE
)

output_dir <- "results/phase_b/exploration"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(
  matched,
  file.path(output_dir, "h4_conditionality_resource_change_3y.csv"),
  row.names = FALSE,
  na = ""
)
write.csv(
  summary,
  file.path(output_dir, "h4_conditionality_resource_change_3y_summary.csv"),
  row.names = FALSE,
  na = ""
)

png(
  file.path(output_dir, "h4_conditionality_resource_change_3y.png"),
  width = 1200,
  height = 800,
  res = 140
)
plot(
  matched$avgcondtype_count,
  matched$resource_dep_change_pp,
  xlab = "IMF-Auflagen pro Quartal im Programm-Bewilligungsjahr",
  ylab = "Veraenderung der Rohstoffexportabhaengigkeit t bis t+3 (Prozentpunkte)",
  main = "Konditionalitaet und spaetere Rohstoffexportabhaengigkeit",
  pch = 19,
  col = grDevices::adjustcolor("steelblue4", alpha.f = 0.55)
)
abline(
  lm(resource_dep_change_pp ~ avgcondtype_count, data = matched),
  col = "firebrick",
  lwd = 2
)
legend(
  "topright",
  legend = paste("Deskriptiv; kein kausaler Effekt. Spearman rho =",
                 round(summary$spearman_rho, 2)),
  bty = "n"
)
dev.off()

cat(
  "Explorative Auswertung:", nrow(matched), "Programm-Land-Jahre in",
  n_distinct(matched$ISO3), "Laendern; Startjahre",
  min(matched$Year), "-", max(matched$Year),
  "; Ergebnisjahre bis", max(matched$outcome_year), "\n"
)
cat("Spearman rho:", round(summary$spearman_rho, 3), "\n")
cat("Ausgaben in:", output_dir, "\n")
cat(
  "Nur Programm-Land-Jahre mit vollstaendigen WDI-Werten zu t und t+3; ",
  "deskriptiver Zusammenhang, keine Kontrollgruppe und keine kausale ",
  "Identifikation.\n",
  sep = ""
)
