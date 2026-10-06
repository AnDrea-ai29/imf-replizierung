# Diagnostik fuer die Phase-B-Hauptmodelle (H1, H2):
# R^2 (within), F-Test (FE vs. Pooling), Wooldridge (serielle Korrelation),
# Breusch-Pagan (Heteroskedastizitaet) — analog zur Phase-A-Diagnostik.
#
# Die Modelle werden mit plm geschaetzt (wie in Phase A), um die
# Testfunktionen pwartest(), pFtest() und bptest() direkt nutzen zu koennen.
# Die Koeffizienten stimmen mit den fixest-basierten Phase-B-Modellen ueberein
# (glebe Spezifikation, gleicher Schätzer within/FE).
#
# Output: results/phase_b/exploration/h1_h2_diagnostik.csv

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(dplyr)
  library(plm)
  library(lmtest)
})

panel_path <- "data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
panel <- read.csv(panel_path, stringsAsFactors = FALSE)
panel <- panel %>% filter(Year >= 1992, Year <= 2023)

controls_dsv <- c("nrquarterssmpl", "legelec_l", "XDebtGNI", "DebtServGNI",
                   "ResXDebt", "ExtBalGDP", "GFCFGDP", "USaidGDP",
                   "imf_conc_gdp", "imf_noconc_gdp")
basis_ctrl  <- "nrquarterssmpl"

diagnose <- function(dat, formel, label) {
  p <- pdata.frame(dat, index = c("ISO3", "Year"))
  m <- tryCatch(plm(formel, data = p, model = "within"), error = function(e) NULL)
  if (is.null(m)) return(data.frame(Spezifikation = label, R2_within = NA, F_FE = NA, Wooldridge = NA, BP = NA))

  # R^2 (within)
  r2 <- tryCatch(summary(m)$r.squared["rsq"], error = function(e) NA_real_)

  # F-Test: FE vs. Pooling (p-Wert)
  fep <- NA_real_
  ftest <- tryCatch({
    mp <- plm(formel, data = p, model = "pooling")
    pFtest(m, mp)$p.value
  }, error = function(e) NA_real_)

  # Wooldridge: serielle Korrelation (p-Wert)
  wald <- tryCatch(pwartest(m)$p.value, error = function(e) NA_real_)

  # Breusch-Pagan: Heteroskedastizitaet (p-Wert, nicht studentisiert)
  bp <- tryCatch({
    formel_lm <- gsub("\\|.*", "", deparse(formel))
    formel_lm <- trimws(formel_lm)
    dat_lm <- dat
    dat_lm$idcnt <- dat$ISO3
    formel_bp <- as.formula(paste(formel_lm, "+ factor(idcnt)"))
    bptest(lm(formel_bp, data = dat_lm), studentize = FALSE)$p.value
  }, error = function(e) NA_real_)

  data.frame(Spezifikation = label, R2_within = r2, F_FE = ftest, Wooldridge = wald, BP = bp)
}

# --- H1-Modelle ---
outcome <- "avgcondtype_count"

# Basis-FE (nur Laufzeit)
d1 <- panel %>% filter(complete.cases(across(all_of(c(outcome, "unsc3", basis_ctrl, "ISO3")))))
r1 <- diagnose(d1, as.formula(paste(outcome, "~ unsc3 +", basis_ctrl)), "H1 Basis-FE")

# Vollmodell-FE (DSV-Kontrollen, ohne Jahres-FE)
d2 <- panel %>% filter(complete.cases(across(all_of(c(outcome, "unsc3", controls_dsv, "ISO3")))))
r2 <- diagnose(d2, as.formula(paste(outcome, "~ unsc3 +", paste(controls_dsv, collapse = "+"))), "H1 Vollmodell-FE (ohne Jahr-FE)")

# Vollmodell-FE (mit Jahres-FE)
# Jahres-FE in plm: factor(Year) als Regressor
d3 <- d2
r3 <- diagnose(d3,
  as.formula(paste(outcome, "~ unsc3 +", paste(controls_dsv, collapse = "+"), "+ factor(Year)")),
  "H1 Vollmodell-FE (mit Jahr-FE)")

# --- H2-Modelle (Interaktion) ---
outcome_h2 <- "avgcondtype_count"
iv <- "unsc3 * resource_dep"

# Basis-FE
d4 <- panel %>% filter(complete.cases(across(all_of(c(outcome_h2, "unsc3", "resource_dep", basis_ctrl, "ISO3")))))
r4 <- diagnose(d4, as.formula(paste(outcome_h2, "~", iv, "+", basis_ctrl)), "H2 Basis-FE")

# Vollmodell-FE (ohne Jahres-FE)
d5 <- panel %>% filter(complete.cases(across(all_of(c(outcome_h2, "unsc3", "resource_dep", controls_dsv, "ISO3")))))
r5 <- diagnose(d5, as.formula(paste(outcome_h2, "~", iv, "+", paste(controls_dsv, collapse = "+"))), "H2 Vollmodell-FE (ohne Jahr-FE)")

# Vollmodell-FE (mit Jahres-FE)
d6 <- d5
r6 <- diagnose(d6,
  as.formula(paste(outcome_h2, "~", iv, "+", paste(controls_dsv, collapse = "+"), "+ factor(Year)")),
  "H2 Vollmodell-FE (mit Jahr-FE)")

# --- Zusammenfuehren und ausgeben ---
diagnostik <- bind_rows(r1, r2, r3, r4, r5, r6)
print(diagnostik, digits = 4, row.names = FALSE)

write.csv(diagnostik,
          "results/phase_b/exploration/h1_h2_diagnostik.csv",
          row.names = FALSE, na = "")

cat("\nOutput: results/phase_b/exploration/h1_h2_diagnostik.csv\n")
