#### **Modelle:**

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(plm)
library(stargazer)

# Daten für Replizierung (2002–2008)
# Korrigierte Version - Verwende data_with_cond_types.csv wie im Originalplan
data_repl <- read.csv("data/processed/data_with_cond_types.csv")

# Zuerst Jahr-Filter, DANN UNSC-Variation
data_repl <- data_repl[data_repl$Year >= 2002 & data_repl$Year <= 2008, ]

# Nur Länder mit Variation in unsc3 behalten
data_repl <- data_repl %>%
  group_by(ISO3) %>%
  filter(length(unique(unsc3)) > 1) %>%
  ungroup()

# NAs in avgcondtype_all entfernen BEVOR Aggregation
data_repl <- data_repl %>%
  filter(!is.na(avgcondtype_all))

# Duplikate pro (ISO3, Year) aggregieren (Mittelwert)
data_repl <- data_repl %>%
  group_by(ISO3, Year, unsc3, Rohstoffabhängigkeit, XDebtGNI, DebtServGNI, ResXDebt) %>%
  summarise(avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE), .groups = "drop")

print(paste("Länder mit UNSC-Variation (2002-2008):", n_distinct(data_repl$ISO3)))
print(paste("Anzahl Beobachtungen nach Aggregation:", nrow(data_repl)))
print(table(data_repl$unsc3))
print("UNSC-Variation pro Land nach Aggregation:")
print(data_repl %>%
  group_by(ISO3) %>%
  summarise(unsc3_values = paste(sort(unique(unsc3)), collapse = ", ")))
print(table(data_repl$ISO3, data_repl$Year))
print(summary(data_repl))
print(data_repl %>% select(ISO3, Year, unsc3, avgcondtype_all) %>% head(25))

model_repl <- plm(
  avgcondtype_all ~ unsc3 + Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_repl,
  index = c("ISO3"),  # Country Fixed Effects (Year-FE über Kontrollvariablen)
  model = "within"
)

# Ergebnis speichern
saveRDS(model_repl, "results/model_repl.rds")

# Validierung
summary_repl <- summary(model_repl)

# Check if unsc3 is in the model coefficients
if ("unsc3" %in% names(coef(model_repl))) {
  # Note: pooling model uses t-distribution, so p-value column is "Pr(>|t|)" not "Pr(>|z|)"
  p_col <- ifelse("Pr(>|t|)" %in% colnames(summary_repl$coefficients), "Pr(>|t|)", "Pr(>|z|)")
  # For plm pooling model, r.squared is a named vector with rsq and adjrsq
  r2_val <- summary_repl$r.squared["rsq"]
  
  validation <- data.frame(
    unsc_coef = unname(coef(model_repl)["unsc3"]),
    unsc_p = summary_repl$coefficients["unsc3", p_col],
    n_obs = nobs(model_repl),
    r2 = r2_val,
    replication_success = ifelse(
      abs(coef(model_repl)["unsc3"]) >= 1.8 & abs(coef(model_repl)["unsc3"]) <= 2.5 & summary_repl$coefficients["unsc3", p_col] < 0.05,
      "SUCCESS",
      "FAILED"
    ),
    row.names = NULL
  )
} else {
  # For pooling model, r.squared is a named vector with rsq and adjrsq
  r2_val <- summary_repl$r.squared["rsq"]
  
  validation <- data.frame(
    unsc_coef = NA,
    unsc_p = NA,
    n_obs = nobs(model_repl),
    r2 = r2_val,
    replication_success = "FAILED",
    row.names = NULL
  )
  warning("unsc3 was dropped from the model (likely time-invariant)")
}

write.csv(validation, "results/validation_repl.csv", row.names = FALSE)

# Modell laden
model_repl <- readRDS("results/model_repl.rds")

# Anzeigen
summary(model_repl)







