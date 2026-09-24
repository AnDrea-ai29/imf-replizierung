# H1-Replikation im globalen Laenderpool (ALLE Laender, ALLE Jahre)
# Datenbasis: final_data_panel_ALL.csv (aus Combined_ISO.xlsx)
# Kein SSA-Filter, keine Jahr-Beschraenkung im Hauptmodell.
# Vergleichsfenster 2002-2008 (Originalzeitraum) zusaetzlich fuer die
# Replikationsbasis gemaess Neu.md Phase 2.

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(plm)

data_repl <- read.csv("data/processed/final_data_panel_ALL.csv",
                      stringsAsFactors = FALSE)

cat("Panel:", nrow(data_repl), "Beobachtungen,",
    n_distinct(data_repl$ISO3), "Laender, Jahre",
    min(data_repl$Year), "-", max(data_repl$Year), "\n")

# Complete Cases fuer H1 (Schluss auf vollstaendige Information, keine Null-Ersetzung)
vars_h1 <- c("avgcondtype_all", "unsc3", "XDebtGNI", "DebtServGNI", "ResXDebt")
data_h1 <- data_repl %>%
  filter(complete.cases(across(all_of(vars_h1))))

cat("H1-Sample (Complete Cases):", nrow(data_h1), "Beobachtungen,",
    n_distinct(data_h1$ISO3), "Laender\n")

# ---------------------------------------------------------------------------
# Modell 1: H1 ueber alle verfuegbaren Jahre (Hauptmodell)
# ---------------------------------------------------------------------------
model_repl <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_h1,
  index = c("ISO3"),
  model = "within"
)

saveRDS(model_repl, "results/model_repl.rds")
print(summary(model_repl))

# ---------------------------------------------------------------------------
# Modell 2: H1 im Originalzeitraum 2002-2008 (Vergleichsfenster)
# ---------------------------------------------------------------------------
data_h1_0208 <- data_h1 %>% filter(Year >= 2002, Year <= 2008)

model_repl_0208 <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_h1_0208,
  index = c("ISO3"),
  model = "within"
)

saveRDS(model_repl_0208, "results/model_repl_2002_2008.rds")
print(summary(model_repl_0208))

# ---------------------------------------------------------------------------
# Validierung: beide Zeitfenster dokumentieren
# ---------------------------------------------------------------------------
extract_validation <- function(m, dat, window_label) {
  s <- summary(m)
  data.frame(
    window = window_label,
    unsc_coef = coef(m)[["unsc3"]],
    unsc_se = s$coefficients["unsc3", "Std. Error"],
    unsc_p = s$coefficients["unsc3", "Pr(>|t|)"],
    n_obs = nobs(m),
    n_countries = n_distinct(dat$ISO3),
    r2_within = s$r.squared[["rsq"]],
    unsc_signifikant_negativ = (coef(m)[["unsc3"]] < 0 && s$coefficients["unsc3", "Pr(>|t|)"] < 0.05),
    stringsAsFactors = FALSE
  )
}

validation <- rbind(
  extract_validation(model_repl, data_h1, "2002-2025 (alle Jahre, global)"),
  extract_validation(model_repl_0208, data_h1_0208, "2002-2008 (Originalzeitraum, global)")
)

write.csv(validation, "results/validation_repl.csv", row.names = FALSE)
cat("\n=== Validierung ===\n")
print(validation)
