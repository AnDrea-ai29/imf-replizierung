# H1-Replikation im globalen Laenderpool (ALLE Laender, ALLE Jahre)
# Datenbasis: final_data_panel_ALL.csv (aus Combined_ISO.xlsx)
# Kein SSA-Filter, keine Jahr-Beschraenkung im Hauptmodell.
#
# ZWEI Operationalisierungen der abhaengigen Variable:
# (a) avgcondtype_count: durchschnittliche Anzahl Bedingungen pro Quartal
#     (anzahlbasiert wie Dreher/Sturm/Vreeland 2015; deren Benchmark:
#     unsc3 = -2.096 GLS bzw. -3.329 OLS, N=217, 1992-2008)
# (b) avgcondtype_share: Anteil der als rohstoff-/stabilisierend
#     klassifizierten Bedingungen (eigene Erweiterung)
#
# Jeweils mit Vergleichsfenster 2002-2008 (Replikationsbasis, Neu.md Phase 2).

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(plm)

data_repl <- read.csv("data/processed/final_data_panel_ALL.csv",
                      stringsAsFactors = FALSE)

cat("Panel:", nrow(data_repl), "Beobachtungen,",
    n_distinct(data_repl$ISO3), "Laender, Jahre",
    min(data_repl$Year), "-", max(data_repl$Year), "\n")

controls <- c("XDebtGNI", "DebtServGNI", "ResXDebt")

# ---------------------------------------------------------------------------
# Hilfsfunktion: H1-Modell (Within-Schaetzer, Laender-FE) je Depvar/Fenster
# ---------------------------------------------------------------------------
fit_h1 <- function(dat, depvar) {
  dat <- dat %>%
    filter(complete.cases(across(c(depvar, "unsc3", all_of(controls)))))
  m <- plm(
    as.formula(paste(depvar, "~ unsc3 +", paste(controls, collapse = " + "))),
    data = dat,
    index = c("ISO3"),
    model = "within"
  )
  list(model = m, dat = dat)
}

extract_validation <- function(m, dat, depvar, window_label) {
  s <- summary(m)
  data.frame(
    depvar = depvar,
    window = window_label,
    unsc_coef = coef(m)[["unsc3"]],
    unsc_se = s$coefficients["unsc3", "Std. Error"],
    unsc_p = s$coefficients["unsc3", "Pr(>|t|)"],
    n_obs = nobs(m),
    n_countries = n_distinct(dat$ISO3),
    r2_within = s$r.squared[["rsq"]],
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# (a) Replikationsspezifikation: avgcondtype_count (Bedingungen pro Quartal)
# ---------------------------------------------------------------------------
res_count_full  <- fit_h1(data_repl, "avgcondtype_count")
res_count_0208  <- fit_h1(filter(data_repl, Year >= 2002, Year <= 2008), "avgcondtype_count")

model_repl <- res_count_full$model
saveRDS(model_repl, "results/model_repl.rds")
saveRDS(res_count_0208$model, "results/model_repl_2002_2008.rds")

# ---------------------------------------------------------------------------
# (b) Anteilsspezifikation: avgcondtype_share
# ---------------------------------------------------------------------------
res_share_full  <- fit_h1(data_repl, "avgcondtype_share")
res_share_0208  <- fit_h1(filter(data_repl, Year >= 2002, Year <= 2008), "avgcondtype_share")

saveRDS(res_share_full$model, "results/model_repl_share.rds")
saveRDS(res_share_0208$model, "results/model_repl_share_2002_2008.rds")

# ---------------------------------------------------------------------------
# Ausgaben und Validierung
# ---------------------------------------------------------------------------
cat("\n=== H1 (a) avgcondtype_count (Replikationsspezifikation) ===\n")
print(summary(res_count_full$model))
cat("\n=== H1 (a) avgcondtype_count, Fenster 2002-2008 ===\n")
print(summary(res_count_0208$model))
cat("\n=== H1 (b) avgcondtype_share ===\n")
print(summary(res_share_full$model))

validation <- rbind(
  extract_validation(res_count_full$model, res_count_full$dat,
                     "avgcondtype_count", "2002-2025 (alle Jahre, global)"),
  extract_validation(res_count_0208$model, res_count_0208$dat,
                     "avgcondtype_count", "2002-2008 (Originalzeitraum, global)"),
  extract_validation(res_share_full$model, res_share_full$dat,
                     "avgcondtype_share", "2002-2025 (alle Jahre, global)"),
  extract_validation(res_share_0208$model, res_share_0208$dat,
                     "avgcondtype_share", "2002-2008 (Originalzeitraum, global)")
)

write.csv(validation, "results/validation_repl.csv", row.names = FALSE)
cat("\n=== Validierung ===\n")
print(validation)

cat("\nBenchmark Original (Tabelle 2): unsc3 = -2.096 (GLS, p<0.01) bzw. -3.329 (OLS, p<0.10),\n")
cat("Depvar avgcondtype_all = Bedingungen pro Quartal, N=217, 1992-2008, andere Kovariaten.\n")
