# Deskriptive Zusatzanalyse (explorativ, keine Inferenz): Verteilung der als
# rohstoff- bzw. stabilisierungsrelevant klassifizierten MONA-Bedingungen
# nach Quartilen der Rohstoffexportabhaengigkeit (resource_dep).
#
# Warum nur deskriptiv (Begruendung siehe README, Abschnitt Phase-B-Messung):
# - Die Klassifikation ist eine deterministische Textregel mit bekannter
#   Unsicherheit (417 historische Zeilen ohne areadescription werden nach
#   "kein Textsignal = 0" als 0 kodiert); sie traegt keinen confirmatorischen
#   Test (fruehere H4 wurde deshalb aus dem Hypothesenpfad genommen).
# - Arrangement-Typen sind potenzielle Mediator-/Post-Treatment-Variablen
#   und werden nicht als Kontrollen verwendet (auch nicht im Original).
#
# Datenbasis: data/processed/phase_b_h4_panel_1992_2025.csv
# (Klassifikationsversion: phase-a-definition-aligned-v1; dieselbe MONA-
# Zeilen- und Quartalsregel wie das aktive Phase-B-Panel.)
#
# Output:
#   results/phase_b/exploration/komposition_ressourcen_quartile.csv
#   results/phase_b/exploration/komposition_ressourcen_quartile_unsc3.csv

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages(library(dplyr))

panel_path <- "data/processed/phase_b_h4_panel_1992_2025.csv"
if (!file.exists(panel_path)) {
  stop("H4-Klassifikationspanel fehlt: ", panel_path)
}

d <- read.csv(panel_path, stringsAsFactors = FALSE) %>%
  filter(Year >= 1992, Year <= 2023) %>%
  filter(!is.na(resource_dep)) %>%
  arrange(ISO3, Year)

if (nrow(d) == 0) stop("Keine Beobachtungen mit resource_dep im Zeitraum 1992-2023.")

# Quartile der Rohstoffabhaengigkeit innerhalb der Analysestichprobe
breaks <- quantile(d$resource_dep, probs = c(0, 0.25, 0.5, 0.75, 1),
                   na.rm = TRUE, type = 7)
d$rd_quartile <- cut(
  d$resource_dep,
  breaks = breaks,
  include.lowest = TRUE,
  labels = c("Q1 (niedrigste 25%)", "Q2", "Q3", "Q4 (hoechste 25%)")
)

cat("Quartilsgrenzen resource_dep (% Warenexporte):\n")
print(round(breaks, 2))
cat("\nStichprobe:", nrow(d), "Land-Jahre aus",
    length(unique(d$ISO3)), "Laendern, Jahre",
    min(d$Year), "-", max(d$Year), "\n\n")

# Kennzahlen je Quartil: gezogene Bedingungen, Klassifikationsanteile
summary_quartile <- d %>%
  group_by(rd_quartile) %>%
  summarise(
    n_land_jahre = n(),
    n_laender = n_distinct(ISO3),
    resource_dep_min = min(resource_dep),
    resource_dep_max = max(resource_dep),
    bedingungen_gesamt = sum(nrcondtype_all_h4),
    bedingungen_mittel = mean(nrcondtype_all_h4),
    rohstoff_gesamt = sum(rohstoff_cond),
    rohstoff_mittel = mean(rohstoff_cond),
    rohstoff_anteil_gewichtet = sum(rohstoff_cond) / sum(nrcondtype_all_h4),
    rohstoff_anteil_mittel = mean(rohstoff_cond_share),
    stabil_gesamt = sum(stabil_cond),
    stabil_mittel = mean(stabil_cond),
    stabil_anteil_gewichtet = sum(stabil_cond) / sum(nrcondtype_all_h4),
    stabil_anteil_mittel = mean(stabil_cond_share),
    .groups = "drop"
  )

# Deskriptiver Querschnitt Quartil x unsc3 (kein Hypothesentest)
summary_quartile_unsc3 <- d %>%
  group_by(rd_quartile, unsc3) %>%
  summarise(
    n_land_jahre = n(),
    bedingungen_gesamt = sum(nrcondtype_all_h4),
    rohstoff_gesamt = sum(rohstoff_cond),
    rohstoff_anteil_gewichtet = sum(rohstoff_cond) / sum(nrcondtype_all_h4),
    stabil_anteil_gewichtet = sum(stabil_cond) / sum(nrcondtype_all_h4),
    .groups = "drop"
  )

dir.create("results/phase_b/exploration", recursive = TRUE, showWarnings = FALSE)
write.csv(summary_quartile,
          "results/phase_b/exploration/komposition_ressourcen_quartile.csv",
          row.names = FALSE)
write.csv(summary_quartile_unsc3,
          "results/phase_b/exploration/komposition_ressourcen_quartile_unsc3.csv",
          row.names = FALSE)

cat("=== Anteil klassifizierter Bedingungen nach resource_dep-Quartil ===\n")
print(as.data.frame(summary_quartile), row.names = FALSE, digits = 3)
cat("\n=== Quartil x unsc3 (deskriptiv) ===\n")
print(as.data.frame(summary_quartile_unsc3), row.names = FALSE, digits = 3)
cat("\nCaveats: Textregel-Klassifikation (417 historische Zeilen ohne Text = 0),\n")
cat("rein deskriptiv, keine Inferenz; resource_dep-NA ausgeschlossen.\n")
cat("\nOutput: results/phase_b/exploration/komposition_ressourcen_quartile.csv\n")
cat("        results/phase_b/exploration/komposition_ressourcen_quartile_unsc3.csv\n")
