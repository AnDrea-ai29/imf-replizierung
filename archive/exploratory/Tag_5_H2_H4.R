#' =============================================================================
#' TAG 5: ERWEITERUNG (H2–H4) – INTERAKTION UND INHALTSANALYSE
#' =============================================================================
#' Fokus: 20 SSA-Länder (2002–2025)
#' Daten: final_data_with_wdi.csv + data_with_cond_types.csv
#' =============================================================================

# 0. ARBEITSVERZEICHNIS SETZEN -----------------------------------------------
setwd("C:/Users/HP/io/imf-replizierung/")

# 1. PAKETE LADEN -----------------------------------------------------------
library(tidyverse)   # Datenmanipulation
library(fixest)      # Panelmodelle (feols)
library(lmtest)     # Hypothesentests (bptest)
library(stargazer)  # Regressionstabellen

# 2. DATEN LADEN -----------------------------------------------------------
# Die frühere Pipeline hat final_data_with_wdi.csv nicht mehr erzeugt. Die
# aktuellen verarbeiteten Datensätze liegen unter final_data_panel_SSA.csv bzw.
# data_with_cond_types.csv; diese werden hier kompatibel geladen.
final_data_with_wdi <- NULL
candidate_files <- c(
  "data/processed/final_data_with_wdi.csv",
  "data/processed/final_data_panel_SSA.csv",
  "data/processed/final_data_ssa_mea.csv"
)

for (f in candidate_files) {
  if (file.exists(f)) {
    final_data_with_wdi <- read.csv(f, stringsAsFactors = FALSE)
    break
  }
}

if (is.null(final_data_with_wdi)) {
  stop("Keine passende Daten-Datei gefunden. Bitte final_data_panel_SSA.csv oder final_data_with_wdi.csv erzeugen.")
}

# Kompatibilität mit alten Variablennamen
if (!"resource_dep" %in% names(final_data_with_wdi)) {
  if ("Rohstoffabhängigkeit" %in% names(final_data_with_wdi)) {
    final_data_with_wdi <- final_data_with_wdi %>% rename(resource_dep = Rohstoffabhängigkeit)
  } else if (all(c("FuelExportPct", "MineralExportPct") %in% names(final_data_with_wdi))) {
    final_data_with_wdi <- final_data_with_wdi %>%
      mutate(resource_dep = FuelExportPct + MineralExportPct)
  } else {
    stop("Die Rohstoffabhängigkeit ist in keinem erwarteten Format vorhanden.")
  }
}

# Inhaltsanalyse-Daten (aus Tag 3)
if (!file.exists("data/processed/data_with_cond_types.csv")) {
  stop("data_with_cond_types.csv fehlt. Bitte den Datensatz aus der Datenvorbereitung erzeugen.")
} else {
  data_with_cond_types <- read.csv("data/processed/data_with_cond_types.csv", stringsAsFactors = FALSE)
}

if (!"resource_dep" %in% names(data_with_cond_types)) {
  if ("Rohstoffabhängigkeit" %in% names(data_with_cond_types)) {
    data_with_cond_types <- data_with_cond_types %>% rename(resource_dep = Rohstoffabhängigkeit)
  } else if (all(c("FuelExportPct", "MineralExportPct") %in% names(data_with_cond_types))) {
    data_with_cond_types <- data_with_cond_types %>%
      mutate(resource_dep = FuelExportPct + MineralExportPct)
  } else {
    stop("resource_dep fehlt in data_with_cond_types.csv und kann nicht rekonstruiert werden.")
  }
}

# 3. DATENPRÜFUNG -----------------------------------------------------------
print("=== Datenprüfung ===")
print(paste("Anzahl Beobachtungen:", nrow(final_data_with_wdi)))
print(paste("Anzahl Länder:", length(unique(final_data_with_wdi$ISO3))))
print(paste("Zeitraum:", min(final_data_with_wdi$Year, na.rm = TRUE), "-", max(final_data_with_wdi$Year, na.rm = TRUE)))

# Prüfe UNSC-Länder
print("\n=== UNSC-Länder ===")
print(unique(final_data_with_wdi$ISO3[final_data_with_wdi$unsc3 == 1]))

# Prüfe Rohstoffabhängigkeit
print("\n=== Rohstoffabhängigkeit (Beispiel) ===")
print(final_data_with_wdi %>%
       filter(ISO3 %in% c("AGO", "GHA", "NGA")) %>%
       select(ISO3, Year, resource_dep) %>%
       head(10))

# 4. MODELL H1 (REPLIZIERUNG) -----------------------------------------------
# H1 basiert auf dem verarbeiteten Bedingungen-Datensatz, weil der annualisierte
# Panel-Datensatz für die FE-Schätzung zu wenig Beobachtungen enthält.
repl_data <- data_with_cond_types %>%
  filter(Year >= 2002 & Year <= 2008) %>%
  drop_na(avgcondtype_all, unsc3, XDebtGNI, DebtServGNI, ResXDebt)

print("\n=== H1: Replizierung (2002–2008) ===")
model_h1 <- feols(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = repl_data,
  vcov = "hetero"
)
summary(model_h1)

# Validierung: Koeffizient von unsc3
unsc_coef_h1 <- coef(model_h1)["unsc3"]
unsc_se_h1 <- sqrt(diag(vcov(model_h1)))["unsc3"]
unsc_pval_h1 <- 2 * pnorm(abs(unsc_coef_h1 / unsc_se_h1), lower.tail = FALSE)
print(paste("\nH1-Ergebnis:"))
print(paste("unsc3-Koeffizient:", round(unsc_coef_h1, 4)))
print(paste("p-Wert:", round(unsc_pval_h1, 4)))

# 5. MODELLE H2–H4 (ERWEITERUNG 2008–2025) -----------------------------
ext_data <- data_with_cond_types %>%
  filter(Year >= 2008 & Year <= 2025) %>%
  drop_na(avgcondtype_all, unsc3, resource_dep, XDebtGNI, DebtServGNI, ResXDebt)

# H2: Länder mit hoher Rohstoffabhängigkeit haben verstärkten UNSC-Effekt
print("\n=== H2: UNSC × Rohstoffabhängigkeit ===")
model_h2 <- feols(
  avgcondtype_all ~ unsc3 * resource_dep + XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = ext_data,
  vcov = "hetero"
)
summary(model_h2)

# H3: Rohstoffabhängigkeit verstärkt UNSC-Effekt (alternative Spezifikation)
print("\n=== H3: UNSC-Effekt in rohstoffreichen Ländern ===")
model_h3 <- feols(
  avgcondtype_all ~ unsc3 + unsc3:resource_dep + XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = ext_data,
  vcov = "hetero"
)
summary(model_h3)

# H4: Inhaltsanalyse (rohstoff-spezifische Bedingungen)
print("\n=== H4: UNSC-Effekt auf rohstoff-spezifische Bedingungen ===")
model_h4 <- feols(
  rohstoff_cond_share ~ unsc3 * resource_dep + XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = data_with_cond_types,
  vcov = "hetero"
)
summary(model_h4)

# 6. ERGEBNISSE SPEICHERN ---------------------------------------------------
# Verzeichnisse erstellen
if (!dir.exists("results")) dir.create("results")
if (!dir.exists("results/models")) dir.create("results/models")
if (!dir.exists("results/tables")) dir.create("results/tables")

# Modelle speichern
saveRDS(model_h1, "results/models/model_h1.rds")
saveRDS(model_h2, "results/models/model_h2.rds")
saveRDS(model_h3, "results/models/model_h3.rds")
saveRDS(model_h4, "results/models/model_h4.rds")

# 7. ERGEBNISTABELLE ERSTELLEN --------------------------------------------
# Koeffizienten aller Modelle
results_table <- tibble(
  Modell = c("H1 (Replizierung)", "H2", "H3", "H4"),
  unsc_coef = c(
    coef(model_h1)["unsc3"],
    coef(model_h2)["unsc3"],
    coef(model_h3)["unsc3"],
    coef(model_h4)["unsc3"]
  ),
  unsc_resource_coef = c(
    NA_real_,
    coef(model_h2)["unsc3:resource_dep"],
    coef(model_h3)["unsc3:resource_dep"],
    coef(model_h4)["unsc3:resource_dep"]
  ),
  p_unsc = c(
    unsc_pval_h1,
    summary(model_h2)$coeftable["unsc3", "Pr(>|t|)"],
    summary(model_h3)$coeftable["unsc3", "Pr(>|t|)"],
    summary(model_h4)$coeftable["unsc3", "Pr(>|t|)"]
  ),
  p_interaction = c(
    NA_real_,
    summary(model_h2)$coeftable["unsc3:resource_dep", "Pr(>|t|)"],
    summary(model_h3)$coeftable["unsc3:resource_dep", "Pr(>|t|)"],
    summary(model_h4)$coeftable["unsc3:resource_dep", "Pr(>|t|)"]
  )
)

write.csv(results_table, "results/tables/results_h1_h4.csv", row.names = FALSE)

# 8. ZUSAMMENFASSUNG --------------------------------------------------------
print("\n===========================================================================")
print("ZUSAMMENFASSUNG TAG 5 (H2–H4)")
print("===========================================================================")
print("H1 (Replizierung):")
print(paste("  - unsc3-Koeffizient:", round(unsc_coef_h1, 4)))
print(paste("  - p-Wert:", round(unsc_pval_h1, 4)))
print("\nH2–H4 (Erweiterung):")
print("  - Interaktionsterm (unsc3:resource_dep) sollte negativ sein")
print("  - Prüfe Koeffizienten in den Modell-Zusammenfassungen")
print("\nErgebnisse gespeichert in:")
print("  - results/models/model_h*.rds")
print("  - results/tables/results_h1_h4.csv")
print("\nNÄCHSTER SCHRITT: Tag 6 – Robustheitschecks + Interpretation")
print("===========================================================================")
