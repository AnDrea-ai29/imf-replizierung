#' =============================================================================
#' IMF-Konditionalität Replizierung + Erweiterung (10-Tage-Plan)
#' Fokus: 20 SSA-Länder (2002-2025)
#' =============================================================================
#' Skript: Phase-3_SSA_only.R
#' Datum: 20. September 2026
#' Autor: [Dein Name]
#' Status: Tag 4 - Replizierung (H1: 2002-2008)
#' =============================================================================

# 0. ARBEITSVERZEICHNIS SETZEN -------------------------------------------------
setwd("C:/Users/HP/io/imf-replizierung")

# 1. PAKETE LADEN -----------------------------------------------------------------
# Installiere fehlende Pakete: install.packages(c("tidyverse", "plm", "fixest", "lmtest", "stargazer", "sandwich", "ggplot2"))

# Basis-Pakete
library(tidyverse)   # Datenmanipulation (dplyr, tidyr, ggplot2)
library(readr)        # CSV-Import

# Oekonometrie-Pakete
library(plm)         # Panelmodelle (plm, pgmm)
library(fixest)      # Schnelle Panelmodelle (feols, fepois)
library(lmtest)      # Hypothesentests (bptest, waldtest)
library(sandwich)    # Robuste Standardfehler

# Ausgabe-Pakete
library(stargazer)   # Regressionstabellen
library(ggplot2)     # Grafiken

# 2. DATEN LADEN ---------------------------------------------------------------
print("Lade final_data_ssa_mea.csv...")
data <- read_csv2("data/processed/final_data_ssa_mea.csv")

# Pruefe, ob Daten geladen wurden
if (nrow(data) == 0) {
  stop("FEHLER: Keine Daten in final_data_ssa_mea.csv gefunden!")
}

# 3. DATENPRUEFUNG ---------------------------------------------------------------
print(paste("Anzahl Beobachtungen:", nrow(data)))
print(paste("Anzahl Laender:", length(unique(data$ISO3))))
print(paste("Zeitraum:", min(data$Year, na.rm = TRUE), "-", max(data$Year, na.rm = TRUE)))

# Pruefe auf fehlende Werte
print("\nFehlende Werte pro Variable:")
print(colSums(is.na(data)))

# Pruefe, ob alle 20 SSA-Laender vorhanden sind
expected_countries <- c("AGO", "CAF", "CMR", "COM", "CPV", "GAB", "GHA", "GIN", "KEN", "LSO", 
                        "MDG", "MOZ", "MRT", "MWI", "RWA", "SLE", "SLV", "TZA", "UGA", "ZMB")
actual_countries <- unique(data$ISO3)
missing_countries <- setdiff(expected_countries, actual_countries)

if (length(missing_countries) > 0) {
  warning(paste("FEHLENDE LAENDER:", paste(missing_countries, collapse = ", ")))
} else {
  print("OK: Alle 20 SSA-Laender vorhanden")
}

# 4. VARIABLEN VORBEREITEN ----------------------------------------------------
# Benenne Variablen um (falls noetig)
data <- data %>%
  rename(
    country = ISO3,
    year = Year,
    avgcond = avgcondtype_all,
    nrcond = nrcondtype_all,
    debt_gni = XDebtGNI,
    debt_serv = DebtServGNI,
    res_debt = ResXDebt,
    fuel_export = FuelExportPct,
    mineral_export = MineralExportPct,
    unsc_member = unsc3
  )

# Ersetze NAs in Kontrollvariablen durch 0 (falls sinnvoll)
data <- data %>%
  mutate(
    debt_gni = ifelse(is.na(debt_gni), 0, debt_gni),
    debt_serv = ifelse(is.na(debt_serv), 0, debt_serv),
    res_debt = ifelse(is.na(res_debt), 0, res_debt),
    fuel_export = ifelse(is.na(fuel_export), 0, fuel_export),
    mineral_export = ifelse(is.na(mineral_export), 0, mineral_export)
  )

# Erstelle kombinierten Rohstoffindex (fuer spaetere Modelle)
data <- data %>%
  mutate(
    resource_dep = fuel_export + mineral_export
  )

# 5. MODELL SPEZIFIZIEREN (H1: Replizierung 2002-2008) -----------------------------
# Hypothese H1: UNSC-Mitgliedschaft reduziert IMF-Konditionalitaet
# Modell: avgcond ~ unsc_member + debt_gni + debt_serv + res_debt

# Filtere Daten fuer Replizierungszeitraum (2002-2008)
repl_data <- data %>%
  filter(year >= 2002 & year <= 2008) %>%
  drop_na(avgcond, unsc_member, debt_gni, debt_serv, res_debt)

print(paste("\nReplizierungsdaten (2002-2008):"))
print(paste("Anzahl Beobachtungen:", nrow(repl_data)))
print(paste("Anzahl Laender:", length(unique(repl_data$country))))

# 6. MODELL SCHAETZEN (Panelmodell mit Fixed Effects) --------------------------
# Methode 1: fixest (schneller, empfehlen fuer grosse Panels)
print("\n=== H1: Replizierung (2002-2008) ===")
model_h1 <- feols(
  avgcond ~ unsc_member + debt_gni + debt_serv + res_debt | country + year,
  data = repl_data,
  vcov = "hetero"  # Robuste Standardfehler
)

# Ergebnis anzeigen
summary(model_h1)

# Methode 2: plm (klassisch, fuer Validierung)
print("\n=== Validierung mit plm ===")
model_h1_plm <- plm(
  avgcond ~ unsc_member + debt_gni + debt_serv + res_debt,
  data = repl_data,
  index = c("country", "year"),
  model = "within",
  effect = "twoways"
)
summary(model_h1_plm)

# 7. HYPOTHESENTEST (H1) -------------------------------------------------------
# Teste, ob unsc_member signifikant negativ ist
print("\n=== Hypothesentest H1 ===")
# Coefficient test mit fixest
coeftest_h1 <- summary(model_h1)
unsc_coef <- coeftest_h1$estimate["unsc_member"]
unsc_se <- coeftest_h1$std.error["unsc_member"]
unsc_pval <- coeftest_h1$p.value["unsc_member"]

print(paste("unsc_member Koeffizient:", round(unsc_coef, 4)))
print(paste("Standardfehler:", round(unsc_se, 4)))
print(paste("p-Wert:", round(unsc_pval, 4)))

if (unsc_coef < 0 && unsc_pval < 0.05) {
  print("OK: H1 BESTAETIGT: UNSC-Mitgliedschaft reduziert Konditionalitaet (signifikant negativ)")
} else if (unsc_coef < 0 && unsc_pval >= 0.05) {
  print("WARNUNG: H1 TEILWEISE: UNSC-Effekt negativ, aber nicht signifikant")
} else if (unsc_coef >= 0) {
  print("FEHLER: H1 ABGELEHNT: UNSC-Effekt nicht negativ")
}

# 8. ROBUSTHEITSCHECKS ----------------------------------------------------------
# 8.1 Heteroskedastizitaetstest (Breusch-Pagan)
print("\n=== Robustheitscheck: Heteroskedastizitaet ===")
bptest_result <- bptest(avgcond ~ unsc_member + debt_gni + debt_serv + res_debt, 
                        data = repl_data)
print(bptest_result)

# 8.2 Year-Fixed Effects Check
print("\n=== Robustheitscheck: Year-FE ===")
model_h1_yeare <- feols(
  avgcond ~ unsc_member + debt_gni + debt_serv + res_debt | country + year,
  data = repl_data,
  vcov = "hetero"
)
summary(model_h1_yeare)

# 9. ERGEBNISSE SPEICHERN -------------------------------------------------------
# Erstelle results-Verzeichnis
if (!dir.exists("results")) {
  dir.create("results")
}
if (!dir.exists("results/models")) {
  dir.create("results/models")
}
if (!dir.exists("results/tables")) {
  dir.create("results/tables")
}
if (!dir.exists("results/figures")) {
  dir.create("results/figures")
}

# Speichere Modell
saveRDS(model_h1, "results/models/model_h1_repl.rds")
saveRDS(model_h1_plm, "results/models/model_h1_repl_plm.rds")

# Speichere Validierungsergebnisse
validation_results <- data.frame(
  Modell = c("feols", "plm"),
  unsc_coef = c(coeftest_h1$estimate["unsc_member"], summary(model_h1_plm)$coefficients["unsc_member", "Estimate"]),
  unsc_se = c(coeftest_h1$std.error["unsc_member"], summary(model_h1_plm)$coefficients["unsc_member", "Std. Error"]),
  unsc_pval = c(coeftest_h1$p.value["unsc_member"], summary(model_h1_plm)$coefficients["unsc_member", "Pr(>|t|)"]),
  n_obs = c(nrow(repl_data), nrow(repl_data)),
  n_countries = c(length(unique(repl_data$country)), length(unique(repl_data$country)))
)

write.csv(validation_results, "results/tables/validation_h1.csv", row.names = FALSE)

# 10. ERGEBNISTABELLE ERSTELLEN (fuer Anhang) --------------------------------
print("\n=== Ergebnistabelle H1 ===")
stargazer::stargazer(
  model_h1,
  model_h1_plm,
  title = "H1: UNSC-Effekt auf IMF-Konditionalitaet (2002-2008)",
  dep.var.labels = "Durchschnittliche IMF-Bedingungen",
  covariate.labels = c("UNSC-Mitglied (t oder t-1)", "Externe Schuld (% BNE)", 
                       "Schuldenbedienung (% BNE)", "Devisenreserven (% Schuld)"),
  model.numbers = FALSE,
  column.labels = c("fixest", "plm"),
  notes = "Standardfehler in Klammern; *** p<0.01, ** p<0.05, * p<0.1",
  out = "results/tables/table_h1.txt",
  type = "text"
)

# 11. GRAFIK ERSTELLEN (UNSC-Effekt) -------------------------------------------
# Berechne durchschnittliche Konditionalitaet nach UNSC-Status
plot_data <- repl_data %>%
  group_by(country, year, unsc_member) %>%
  summarise(avg_cond = mean(avgcond, na.rm = TRUE), .groups = "drop")

# Boxplot
png("results/figures/boxplot_unsc_h1.png", width = 1000, height = 600)
ggplot(plot_data, aes(x = factor(unsc_member), y = avg_cond, fill = factor(unsc_member))) +
  geom_boxplot() +
  labs(
    title = "IMF-Konditionalitaet nach UNSC-Mitgliedschaft (2002-2008)",
    x = "UNSC-Mitglied (0 = Nein, 1 = Ja)",
    y = "Durchschnittliche IMF-Bedingungen (avgcondtype_all)",
    fill = "UNSC-Mitglied"
  ) +
  theme_minimal() +
  theme(legend.position = "top")
dev.off()

# 12. ZUSAMMENFASSUNG ------------------------------------------------------------
print("\n===========================================================================")
print("ZUSAMMENFASSUNG TAG 4 (H1 Replizierung)")
print("===========================================================================")
print(paste("OK: Daten geladen:", nrow(data), "Beobachtungen"))
print(paste("OK: Replizierungszeitraum: 2002-2008 (", nrow(repl_data), "Beobachtungen)"))
print(paste("OK: Modell geschaetzt: avgcond ~ unsc_member + Kontrollen"))
print(paste("OK: UNSC-Koeffizient (feols):", round(unsc_coef, 4)))
print(paste("OK: p-Wert:", round(unsc_pval, 4)))
print("\nErgebnisse gespeichert in:")
print("  - results/models/model_h1_repl.rds")
print("  - results/models/model_h1_repl_plm.rds")
print("  - results/tables/validation_h1.csv")
print("  - results/tables/table_h1.txt")
print("  - results/figures/boxplot_unsc_h1.png")
print("\nNAECHSTER SCHRITT: Tag 5 - Erweiterung (H2-H4, 2008-2025)")
print("===========================================================================")
