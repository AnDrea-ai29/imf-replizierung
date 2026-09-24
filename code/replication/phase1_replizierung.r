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
# ZWEI Kontrollsaetze:
# - Basis:    XDebtGNI + DebtServGNI + ResXDebt (wie bisher)
# - Erweitert: + nrcntprogram (kumulative Anzahl Arrangements, analog zur
#   Original-Kontrolle "count"; die uebrigen Original-Kovariaten — Wahljahr,
#   Aussenbilanz, Investitionsquote, US-Hilfe, IWF-Kreditvolumen — erfordern
#   zusaetzliche Datenquellen, siehe Beschaffungsliste)
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

ctrl_basis <- c("XDebtGNI", "DebtServGNI", "ResXDebt")
ctrl_ext   <- c(ctrl_basis, "nrcntprogram")

# ---------------------------------------------------------------------------
# Hilfsfunktionen
# ---------------------------------------------------------------------------
fit_h1 <- function(dat, depvar, controls) {
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

extract_validation <- function(m, dat, depvar, controls_label, window_label) {
  s <- summary(m)
  data.frame(
    depvar = depvar,
    kontrollen = controls_label,
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

dat_0208 <- filter(data_repl, Year >= 2002, Year <= 2008)

# ---------------------------------------------------------------------------
# (a) Replikationsspezifikation: avgcondtype_count
# ---------------------------------------------------------------------------
res_cc_b_full <- fit_h1(data_repl, "avgcondtype_count", ctrl_basis)
res_cc_b_0208 <- fit_h1(dat_0208,     "avgcondtype_count", ctrl_basis)
res_cc_e_full <- fit_h1(data_repl, "avgcondtype_count", ctrl_ext)
res_cc_e_0208 <- fit_h1(dat_0208,     "avgcondtype_count", ctrl_ext)

model_repl <- res_cc_b_full$model
saveRDS(model_repl, "results/model_repl.rds")
saveRDS(res_cc_b_0208$model, "results/model_repl_2002_2008.rds")
saveRDS(res_cc_e_full$model, "results/model_repl_ext_controls.rds")

# ---------------------------------------------------------------------------
# (b) Anteilsspezifikation: avgcondtype_share
# ---------------------------------------------------------------------------
res_sh_b_full <- fit_h1(data_repl, "avgcondtype_share", ctrl_basis)
res_sh_b_0208 <- fit_h1(dat_0208,     "avgcondtype_share", ctrl_basis)
res_sh_e_full <- fit_h1(data_repl, "avgcondtype_share", ctrl_ext)
res_sh_e_0208 <- fit_h1(dat_0208,     "avgcondtype_share", ctrl_ext)

saveRDS(res_sh_b_full$model, "results/model_repl_share.rds")
saveRDS(res_sh_b_0208$model, "results/model_repl_share_2002_2008.rds")
saveRDS(res_sh_e_full$model, "results/model_repl_share_ext_controls.rds")

# ---------------------------------------------------------------------------
# Ausgaben und Validierung
# ---------------------------------------------------------------------------
cat("\n=== H1 (a) avgcondtype_count, Basiskontrollen, alle Jahre ===\n")
print(summary(res_cc_b_full$model))
cat("\n=== H1 (a) avgcondtype_count, erweiterte Kontrollen, alle Jahre ===\n")
print(summary(res_cc_e_full$model))
cat("\n=== H1 (b) avgcondtype_share, Basiskontrollen, alle Jahre ===\n")
print(summary(res_sh_b_full$model))

validation <- rbind(
  extract_validation(res_cc_b_full$model, res_cc_b_full$dat, "avgcondtype_count",
                    "Basis (3 Kontrollen)", "2002-2025 (alle Jahre, global)"),
  extract_validation(res_cc_b_0208$model, res_cc_b_0208$dat, "avgcondtype_count",
                    "Basis (3 Kontrollen)", "2002-2008 (Originalzeitraum, global)"),
  extract_validation(res_cc_e_full$model, res_cc_e_full$dat, "avgcondtype_count",
                    "Erweitert (+ nrcntprogram)", "2002-2025 (alle Jahre, global)"),
  extract_validation(res_cc_e_0208$model, res_cc_e_0208$dat, "avgcondtype_count",
                    "Erweitert (+ nrcntprogram)", "2002-2008 (Originalzeitraum, global)"),
  extract_validation(res_sh_b_full$model, res_sh_b_full$dat, "avgcondtype_share",
                    "Basis (3 Kontrollen)", "2002-2025 (alle Jahre, global)"),
  extract_validation(res_sh_b_0208$model, res_sh_b_0208$dat, "avgcondtype_share",
                    "Basis (3 Kontrollen)", "2002-2008 (Originalzeitraum, global)"),
  extract_validation(res_sh_e_full$model, res_sh_e_full$dat, "avgcondtype_share",
                    "Erweitert (+ nrcntprogram)", "2002-2025 (alle Jahre, global)"),
  extract_validation(res_sh_e_0208$model, res_sh_e_0208$dat, "avgcondtype_share",
                    "Erweitert (+ nrcntprogram)", "2002-2008 (Originalzeitraum, global)")
)

write.csv(validation, "results/validation_repl.csv", row.names = FALSE)
cat("\n=== Validierung ===\n")
print(validation)

cat("\nBenchmark Original (Tabelle 2): unsc3 = -2.096 (GLS, p<0.01) bzw. -3.329 (OLS, p<0.10),\n")
cat("Depvar avgcondtype_all = Bedingungen pro Quartal, N=217, 1992-2008, volle Kovariaten.\n")
cat("Vergleichskandidat hier: avgcondtype_count, erweiterte Kontrollen.\n")
