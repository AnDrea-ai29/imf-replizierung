#### **Tag 5: Erweiterung (2008–2025) - SSA-Länder**
#### **Modelle H2–H4: Rohstoffabhängigkeit, UNSC-Effekt, Inhaltsanalyse**

setwd("C:/Users/HP/io/imf-replizierung")

# Pakete laden
library(tidyverse)
library(plm)
library(stargazer)

# 1. DATEN LADEN ---------------------------------------------------------------
print("Lade data_with_cond_types.csv...")
data <- read.csv("data/processed/data_with_cond_types.csv")

if (nrow(data) == 0) {
  stop("FEHLER: Keine Daten in data_with_cond_types.csv gefunden!")
}

# 2. DATEN FÜR ERWEITERUNG (2008–2025) FILTERN --------------------------------
print("Filtere Daten für 2008–2025 (SSA-Länder)...")
data_ext <- data %>%
  filter(Year >= 2008 & Year <= 2025) %>%
  filter(!is.na(avgcondtype_all))  # NAs entfernen

print(paste("Anzahl Beobachtungen (vor Filter):", nrow(data_ext)))

# SSA-Länderliste (20 Länder)
ssa_countries <- c("AGO", "CAF", "CMR", "COM", "CPV", "GAB", "GHA", "GIN", "KEN", "LSO", 
                   "MDG", "MOZ", "MRT", "MWI", "RWA", "SLE", "SLV", "TZA", "UGA", "ZMB")
data_ext <- data_ext %>% filter(ISO3 %in% ssa_countries)

print(paste("Anzahl SSA-Länder:", n_distinct(data_ext$ISO3)))

# 3. DUPLIKATE BEHANDELN ----------------------------------------------------------
# Pro (ISO3, Year) aggregieren (Mittelwert)
data_ext <- data_ext %>%
  group_by(ISO3, Year, unsc3, Rohstoffabhängigkeit, XDebtGNI, DebtServGNI, ResXDebt, rohstoff_cond_share) %>%
  summarise(avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE), .groups = "drop")

print(paste("Anzahl Beobachtungen nach Aggregation:", nrow(data_ext)))

# 4. MODELL H2: ROHSTOFFABHÄNGIGKEIT ↑ KONDITIONALITÄTEN -------------------------
print("\n=== H2: Rohstoffabhängigkeit ↑ IMF-Konditionalitäten ===")
model_h2 <- plm(
  avgcondtype_all ~ Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_ext,
  index = c("ISO3", "Year"),
  model = "within"
)

saveRDS(model_h2, "results/model_h2.rds")
summary_h2 <- summary(model_h2)
print(summary_h2)

# 5. MODELL H3: UNSC-EFFEKT STÄRKER IN ROHSTOFFABHÄNGIGEN LÄNDERN --------------
print("\n=== H3: UNSC-Effekt stärker in rohstoffabhängigen Ländern ===")
model_h3 <- plm(
  avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_ext,
  index = c("ISO3", "Year"),
  model = "within"
)

saveRDS(model_h3, "results/model_h3.rds")
summary_h3 <- summary(model_h3)
print(summary_h3)

# 6. MODELL H4: UNSC → WENIGER ROHSTOFF-SPEZIFISCHE BEDINGUNGEN ---------------
print("\n=== H4: UNSC → weniger rohstoff-spezifische Bedingungen ===")
model_h4 <- plm(
  rohstoff_cond_share ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_ext,
  index = c("ISO3", "Year"),
  model = "within"
)

saveRDS(model_h4, "results/model_h4.rds")
summary_h4 <- summary(model_h4)
print(summary_h4)

# 7. ERGEBNISSE ZUSAMMENFASSEN ---------------------------------------------------
print("\n=== Zusammenfassung H2–H4 ===")

# Hilfsfunktion zum Extrahieren von Koeffizienten und p-Werten
get_result <- function(summary_obj, var_name) {
  if (var_name %in% rownames(summary_obj$coefficients)) {
    coef <- summary_obj$coefficients[var_name, "Estimate"]
    pval <- summary_obj$coefficients[var_name, "Pr(>|t|)"]
    return(c(coef = coef, pval = pval))
  } else {
    return(c(coef = NA, pval = NA))
  }
}

# H2 Ergebnisse
res_h2 <- get_result(summary_h2, "Rohstoffabhängigkeit")
# H3 Ergebnisse (Interaktionsterm)
res_h3 <- get_result(summary_h3, "unsc3:Rohstoffabhängigkeit")
# H4 Ergebnisse (Interaktionsterm)
res_h4 <- get_result(summary_h4, "unsc3:Rohstoffabhängigkeit")

# Zusammenfassung Dataframe
results_summary <- data.frame(
  Model = c("H2", "H3", "H4"),
  Variable = c("Rohstoffabhängigkeit", "unsc3:Rohstoffabhängigkeit", "unsc3:Rohstoffabhängigkeit"),
  Coefficient = c(res_h2["coef"], res_h3["coef"], res_h4["coef"]),
  P_Value = c(res_h2["pval"], res_h3["pval"], res_h4["pval"]),
  N_Obs = c(nobs(model_h2), nobs(model_h3), nobs(model_h4)),
  R2 = c(summary_h2$r.squared, summary_h3$r.squared, summary_h4$r.squared)
)

write.csv(results_summary, "results/results_summary.csv", row.names = FALSE)

# 8. HYPOTHESENPRÜFUNG --------------------------------------------------------
print("\n=== Hypothesentests ===")

# H2: Rohstoffabhängigkeit > 0
if (!is.na(res_h2["coef"])) {
  h2_text <- ifelse(res_h2["coef"] > 0 & res_h2["pval"] < 0.05, 
                    "✅ BESTÄTIGT", 
                    ifelse(res_h2["coef"] > 0, "⚠️  POSITIV aber nicht signifikant", "❌ ABGELEHNT"))
} else {
  h2_text <- "❌ Variablenfehler"
}

# H3: Interaktion < 0 (UNSC schützt rohstoffreiche Länder)
if (!is.na(res_h3["coef"])) {
  h3_text <- ifelse(res_h3["coef"] < 0 & res_h3["pval"] < 0.05, 
                    "✅ BESTÄTIGT", 
                    ifelse(res_h3["coef"] < 0, "⚠️  NEGATIV aber nicht signifikant", "❌ ABGELEHNT"))
} else {
  h3_text <- "❌ Variablenfehler"
}

# H4: Interaktion < 0 (UNSC → weniger rohstoff-spezifische Bedingungen)
if (!is.na(res_h4["coef"])) {
  h4_text <- ifelse(res_h4["coef"] < 0 & res_h4["pval"] < 0.05, 
                    "✅ BESTÄTIGT", 
                    ifelse(res_h4["coef"] < 0, "⚠️  NEGATIV aber nicht signifikant", "❌ ABGELEHNT"))
} else {
  h4_text <- "❌ Variablenfehler"
}

print(paste("H2 (Rohstoffabhängigkeit ↑ Konditionalitäten):", h2_text))
print(paste("  Koeffizient:", round(res_h2["coef"], 4), "p =", round(res_h2["pval"], 4)))
print(paste("H3 (UNSC-Effekt stärker in rohstoffabhängigen Ländern):", h3_text))
print(paste("  Koeffizient:", round(res_h3["coef"], 4), "p =", round(res_h3["pval"], 4)))
print(paste("H4 (UNSC → weniger rohstoff-spezifische Bedingungen):", h4_text))
print(paste("  Koeffizient:", round(res_h4["coef"], 4), "p =", round(res_h4["pval"], 4)))

# 9. ZUSAMMENFASSUNG ---------------------------------------------------------------
print("\n===========================================================================")
print("ZUSAMMENFASSUNG TAG 5 (Erweiterung H2–H4, 2008–2025, SSA)")
print("===========================================================================")
print(paste("Daten: SSA-Länder (2008–2025)"))
print(paste("Beobachtungen:", nrow(data_ext)))
print(paste("Länder:", n_distinct(data_ext$ISO3)))
print("Modelle gespeichert in:")
print("  - results/model_h2.rds")
print("  - results/model_h3.rds")
print("  - results/model_h4.rds")
print("Ergebnisse: results/results_summary.csv")
print("===========================================================================")
