#### **Modelle:**

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(plm)
library(stargazer)

# Daten für Replizierung (2002–2008) - ALLE LAENDER
data_repl <- read.csv("data/processed/data_with_cond_types.csv")

# Jahr-Filter (2002-2008)
data_repl <- data_repl[data_repl$Year >= 2002 & data_repl$Year <= 2008, ]

# NAs in avgcondtype_all entfernen
data_repl <- data_repl %>%
  filter(!is.na(avgcondtype_all))

# Pruefe Spaltennamen
print("Verfuegbare Spalten:")
print(colnames(data_repl))

# Duplikate pro (ISO3, Year) aggregieren (Mittelwert)
# Verwende Rohstoffabhaengigkeit falls vorhanden, sonst FuelExportPct + MineralExportPct
if("Rohstoffabhaengigkeit" %in% colnames(data_repl)) {
  data_repl <- data_repl %>%
    group_by(ISO3, Year, unsc3, Rohstoffabhaengigkeit, XDebtGNI, DebtServGNI, ResXDebt) %>%
    summarise(avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE), .groups = "drop")
} else if("Rohstoffabhängigkeit" %in% colnames(data_repl)) {
  data_repl <- data_repl %>%
    group_by(ISO3, Year, unsc3, Rohstoffabhängigkeit, XDebtGNI, DebtServGNI, ResXDebt) %>%
    summarise(avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE), .groups = "drop")
} else {
  data_repl <- data_repl %>%
    mutate(Rohstoffabhängigkeit = FuelExportPct + MineralExportPct) %>%
    group_by(ISO3, Year, unsc3, Rohstoffabhängigkeit, XDebtGNI, DebtServGNI, ResXDebt) %>%
    summarise(avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE), .groups = "drop")
}

print(paste("Anzahl Laender (2002-2008):", n_distinct(data_repl$ISO3)))
print(paste("Anzahl Beobachtungen:", nrow(data_repl)))

model_repl <- plm(
  avgcondtype_all ~ unsc3 + Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_repl,
  index = c("ISO3"),
  model = "within"
)

# Ergebnis speichern
saveRDS(model_repl, "results/model_repl.rds")

# Validierung
summary_repl <- summary(model_repl)

if ("unsc3" %in% names(coef(model_repl))) {
  p_col <- ifelse("Pr(>|t|)" %in% colnames(summary_repl$coefficients), "Pr(>|t|)", "Pr(>|z|)")
  r2_val <- summary_repl$r.squared["rsq"]
  
  validation <- data.frame(
    unsc_coef = unname(coef(model_repl)["unsc3"]),
    unsc_p = summary_repl$coefficients["unsc3", p_col],
    n_obs = nobs(model_repl),
    r2 = r2_val,
    n_countries = length(unique(data_repl$ISO3)),
    replication_success = ifelse(
      abs(coef(model_repl)["unsc3"]) >= 1.8 & abs(coef(model_repl)["unsc3"]) <= 2.5 & summary_repl$coefficients["unsc3", p_col] < 0.05,
      "SUCCESS",
      "FAILED"
    ),
    row.names = NULL
  )
} else {
  r2_val <- summary_repl$r.squared["rsq"]
  
  validation <- data.frame(
    unsc_coef = NA,
    unsc_p = NA,
    n_obs = nobs(model_repl),
    r2 = r2_val,
    n_countries = length(unique(data_repl$ISO3)),
    replication_success = "FAILED",
    row.names = NULL
  )
  warning("unsc3 was dropped from the model (likely time-invariant)")
}

write.csv(validation, "results/validation_repl.csv", row.names = FALSE)

# Anzeigen
summary(model_repl)
