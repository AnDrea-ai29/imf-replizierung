getwd() # An entsprechende Working-Directory anpassen

library(plm)
library(stargazer)

# Daten für Replizierung (2002–2008)
data_repl <- data_with_cond_types %>%
  filter(`Approval Year` >= 2002, `Approval Year` <= 2008)

# Modell 1: Replizierung (H1)
model_repl <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_repl,
  index = c("ISO3", "Approval Year"),
  model = "within"
)

# Ergebnis speichern
saveRDS(model_repl, "results/model_repl.rds")

# Validierung
summary_repl <- summary(model_repl)
validation <- data.frame(
  unsc_coef = coef(model_repl)["unsc3"],
  unsc_p = summary_repl$coefficients["unsc3", "Pr(>|z|)"],
  n_obs = nobs(model_repl),
  r2 = summary_repl$r.squared,
  replication_success = ifelse(
    abs(coef(model_repl)["unsc3"]) >= 1.8 & abs(coef(model_repl)["unsc3"])) <= 2.5 &
    summary_repl$coefficients["unsc3", "Pr(>|z|)"] < 0.05,
  "✅ ERFOLGREICH",
  "❌ FEHLGESCHLAGEN"
)

write_csv(validation, "results/validation_repl.csv")