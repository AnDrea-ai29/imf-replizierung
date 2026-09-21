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
# Finaler Datensatz mit WDI (aus Tag 4)
final_data_with_wdi <- read.csv("data/processed/final_data_with_wdi.csv")

# Inhaltsanalyse-Daten (aus Tag 3)
# Falls nicht vorhanden: 
if (!file.exists("data/processed/data_with_cond_types.csv")) {
  # Alternative: Daten direkt aus MONA laden
  mona_full <- read.csv("data/raw/mona/Combined_ISO.xlsx")
  ssa_countries <- c("AGO", "CAF", "CMR", "COM", "CPV", "GAB", "GHA", "GIN", "KEN", "LSO",
                     "MDG", "MOZ", "MRT", "MWI", "RWA", "SLE", "SLV", "TZA", "UGA", "ZMB")
  
  # Economic Codes für Klassifizierung
  rohstoff_codes <- c("RC100", "RC200", "EN100", "EN200", "FB030", "FB040")
  stabil_codes <- c("FB010", "FB020", "FB050", "MC100", "MC200", "DB100", "DB200")
  
  mona_conditions <- mona_full %>%
    filter(iso_3ltr %in% ssa_countries) %>%
    rename(ISO3 = iso_3ltr, Year = `Approval Year`) %>%
    mutate(
      cond_type = case_when(
        `Economic Code` %in% rohstoff_codes ~ "rohstoff",
        `Economic Code` %in% stabil_codes ~ "stabil",
        TRUE ~ "sonstige"
      )
    )
  
  cond_summary <- mona_conditions %>%
    group_by(ISO3, Year) %>%
    summarise(
      total_cond = n(),
      rohstoff_cond = sum(cond_type == "rohstoff"),
      stabil_cond = sum(cond_type == "stabil"),
      sonstige_cond = sum(cond_type == "sonstige"),
      rohstoff_cond_share = ifelse(total_cond > 0, rohstoff_cond / total_cond, 0),
      stabil_cond_share = ifelse(total_cond > 0, stabil_cond / total_cond, 0),
      .groups = "drop"
    )
  
  data_with_cond_types <- merge(
    final_data_with_wdi,
    cond_summary,
    by = c("ISO3", "Year"),
    all.x = TRUE
  )
  write.csv(data_with_cond_types, "data/processed/data_with_cond_types.csv", row.names = FALSE)
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
# Nur 2002–2008 für H1
repl_data <- final_data_with_wdi %>%
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
ext_data <- final_data_with_wdi %>%
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
results_table <- data.frame(
  Modell = c("H1 (Replizierung)", "H2", "H3", "H4"),
  unsc_coef = c(
    coef(model_h1)["unsc3"],
    coef(model_h2)["unsc3"],
    coef(model_h3)["unsc3"],
    coef(model_h4)["unsc3"]
  ),
  unsc_resource_coef = c(
    NA,
    coef(model_h2)["unsc3:resource_dep"],
    coef(model_h3)["unsc3:resource_dep"],
    coef(model_h4)["unsc3:resource_dep"]
  ),
  p_unsc = c(
    unsc_pval_h1,
    summary(model_h2)$p.value["unsc3"],
    summary(model_h3)$p.value["unsc3"],
    summary(model_h4)$p.value["unsc3"]
  ),
  p_interaction = c(
    NA,
    summary(model_h2)$p.value["unsc3:resource_dep"],
    summary(model_h3)$p.value["unsc3:resource_dep"],
    summary(model_h4)$p.value["unsc3:resource_dep"]
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
