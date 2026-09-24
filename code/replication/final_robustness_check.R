# Robustness checks with explicit heteroskedasticity tests
# Output: compact table for text + csv/latex exports

library(tidyverse)
library(lmtest)
library(sandwich)
library(fixest)

# ------------------------------------------------------------------
# 1) Load data
# ------------------------------------------------------------------
raw_path <- file.path("data", "processed", "final_data_panel_ALL.csv")
if (!file.exists(raw_path)) {
  stop("Data file not found: ", raw_path)
}

d <- read.csv(raw_path, stringsAsFactors = FALSE)

# Ensure resource_dep exists
if (!"resource_dep" %in% names(d)) {
  if (all(c("FuelExportPct", "MineralExportPct") %in% names(d))) {
    d <- d %>%
      mutate(resource_dep = FuelExportPct + MineralExportPct)
  } else {
    stop("resource_dep could not be reconstructed.")
  }
}

# Standardize variable types
# In the all-country panel, the core variables are already in the right format,
# but this safeguards against accidental type mismatches.
d <- d %>%
  mutate(
    Year = as.integer(Year),
    ISO3 = as.character(ISO3),
    avgcondtype_share = as.numeric(avgcondtype_share),
    unsc3 = as.numeric(unsc3),
    resource_dep = as.numeric(resource_dep),
    XDebtGNI = as.numeric(XDebtGNI),
    DebtServGNI = as.numeric(DebtServGNI),
    ResXDebt = as.numeric(ResXDebt)
  )

# Complete Cases fuer alle Robustheitsmodelle:
# konsistente Stichprobe ueber alle Spezifikationen, keine Schein-Nullen.
d <- d %>%
  filter(complete.cases(across(c(
    "avgcondtype_share", "unsc3", "resource_dep",
    "XDebtGNI", "DebtServGNI", "ResXDebt"
  ))))
cat("Robustheits-Sample (Complete Cases):", nrow(d), "Beobachtungen
")

# ------------------------------------------------------------------
# 2) Helper: extract coefficients and p-values
# ------------------------------------------------------------------
extract_term <- function(mod, term_pattern) {
  if (inherits(mod, "fixest")) {
    tab <- summary(mod)$coeftable
  } else {
    tab <- coef(summary(mod))
  }

  idx <- grep(term_pattern, rownames(tab), value = FALSE)
  if (length(idx) == 0) {
    return(NULL)
  }

  tab[idx, , drop = FALSE]
}

# ------------------------------------------------------------------
# 3) Main models
# ------------------------------------------------------------------
# Model A: pooled OLS
m_ols <- lm(
  avgcondtype_share ~ unsc3 * resource_dep +
    XDebtGNI + DebtServGNI + ResXDebt,
  data = d
)

# Model B: OLS with year dummies
m_ols_year <- lm(
  avgcondtype_share ~ unsc3 * resource_dep +
    XDebtGNI + DebtServGNI + ResXDebt +
    factor(Year),
  data = d
)

# Model C: OLS with country + year fixed effects (as additional robustness)
m_ols_country_year <- lm(
  avgcondtype_share ~ unsc3 * resource_dep +
    XDebtGNI + DebtServGNI + ResXDebt +
    factor(ISO3) + factor(Year),
  data = d
)

# FE main model as comparison model
m_fe <- feols(
  avgcondtype_share ~ unsc3 * resource_dep +
    XDebtGNI + DebtServGNI + ResXDebt |
    ISO3 + Year,
  data = d,
  vcov = "hetero"
)

# ------------------------------------------------------------------
# 4) Heteroskedasticity tests
# ------------------------------------------------------------------
bp_ols <- bptest(m_ols)
white_ols <- bptest(m_ols, ~ fitted(m_ols) + I(fitted(m_ols)^2))

bp_ols_year <- bptest(m_ols_year)
white_ols_year <- bptest(m_ols_year, ~ fitted(m_ols_year) + I(fitted(m_ols_year)^2))

bp_ols_country_year <- bptest(m_ols_country_year)
white_ols_country_year <- bptest(
  m_ols_country_year,
  ~ fitted(m_ols_country_year) + I(fitted(m_ols_country_year)^2)
)

# Robust SEs
ols_hc1 <- coeftest(m_ols, vcov = vcovHC(m_ols, type = "HC1"))
ols_year_hc1 <- coeftest(m_ols_year, vcov = vcovHC(m_ols_year, type = "HC1"))
ols_country_year_hc1 <- coeftest(m_ols_country_year, vcov = vcovHC(m_ols_country_year, type = "HC1"))

# ------------------------------------------------------------------
# 5) Extract key coefficients
# ------------------------------------------------------------------
extract_coeff <- function(model_obj, term_name, robust_tab = NULL) {
  if (!is.null(robust_tab)) {
    tab <- robust_tab
  } else if (inherits(model_obj, "fixest")) {
    tab <- summary(model_obj)$coeftable
  } else {
    tab <- coef(summary(model_obj))
  }

  idx <- grep(term_name, rownames(tab), fixed = FALSE)
  if (length(idx) == 0) {
    return(c(Estimate = NA_real_, `p-value` = NA_real_))
  }

  row <- tab[idx[1], , drop = FALSE]
  c(
    Estimate = as.numeric(row[1, "Estimate"]),
    `p-value` = as.numeric(row[1, "Pr(>|t|)"])
  )
}

# use the robust coefficient tables for OLS models
coef_ols <- extract_coeff(m_ols, "unsc3")
coef_ols_res <- extract_coeff(m_ols, "resource_dep")
coef_ols_int <- extract_coeff(m_ols, "unsc3:resource_dep")

coef_ols_year <- extract_coeff(m_ols_year, "unsc3")
coef_ols_year_res <- extract_coeff(m_ols_year, "resource_dep")
coef_ols_year_int <- extract_coeff(m_ols_year, "unsc3:resource_dep")

coef_ols_cy <- extract_coeff(m_ols_country_year, "unsc3")
coef_ols_cy_res <- extract_coeff(m_ols_country_year, "resource_dep")
coef_ols_cy_int <- extract_coeff(m_ols_country_year, "unsc3:resource_dep")

# FE model coefficients
fe_tab <- summary(m_fe)$coeftable
fe_unsc <- fe_tab[grep("unsc3", rownames(fe_tab)), , drop = FALSE]
fe_res <- fe_tab[grep("resource_dep", rownames(fe_tab)), , drop = FALSE]
fe_int <- fe_tab[grep("unsc3:resource_dep", rownames(fe_tab)), , drop = FALSE]

fe_unsc_coef <- if (nrow(fe_unsc) > 0) as.numeric(fe_unsc[1, "Estimate"]) else NA_real_
fe_unsc_p <- if (nrow(fe_unsc) > 0) as.numeric(fe_unsc[1, "Pr(>|t|)"]) else NA_real_
fe_res_coef <- if (nrow(fe_res) > 0) as.numeric(fe_res[1, "Estimate"]) else NA_real_
fe_res_p <- if (nrow(fe_res) > 0) as.numeric(fe_res[1, "Pr(>|t|)"]) else NA_real_
fe_int_coef <- if (nrow(fe_int) > 0) as.numeric(fe_int[1, "Estimate"]) else NA_real_
fe_int_p <- if (nrow(fe_int) > 0) as.numeric(fe_int[1, "Pr(>|t|)"]) else NA_real_

# ------------------------------------------------------------------
# 6) Compact results table for text/reporting
# ------------------------------------------------------------------
robustness_table <- tibble::tribble(
  ~Model,
  ~`UNSC3 coef`,
  ~`UNSC3 p`,
  ~`UNSC3 x Resource coef`,
  ~`UNSC3 x Resource p`,
  ~`Resource coef`,
  ~`Resource p`,
  ~`BP p`,
  ~`White p`,
  "Pooled OLS",
  unname(coef_ols["Estimate"]),
  unname(coef_ols["p-value"]),
  unname(coef_ols_int["Estimate"]),
  unname(coef_ols_int["p-value"]),
  unname(coef_ols_res["Estimate"]),
  unname(coef_ols_res["p-value"]),
  bp_ols$p.value,
  white_ols$p.value,
  "OLS + Year FE",
  unname(coef_ols_year["Estimate"]),
  unname(coef_ols_year["p-value"]),
  unname(coef_ols_year_int["Estimate"]),
  unname(coef_ols_year_int["p-value"]),
  unname(coef_ols_year_res["Estimate"]),
  unname(coef_ols_year_res["p-value"]),
  bp_ols_year$p.value,
  white_ols_year$p.value,
  "OLS + Country + Year FE",
  unname(coef_ols_cy["Estimate"]),
  unname(coef_ols_cy["p-value"]),
  unname(coef_ols_cy_int["Estimate"]),
  unname(coef_ols_cy_int["p-value"]),
  unname(coef_ols_cy_res["Estimate"]),
  unname(coef_ols_cy_res["p-value"]),
  bp_ols_country_year$p.value,
  white_ols_country_year$p.value,
  "FE Main Model (hetero SE)",
  fe_unsc_coef,
  fe_unsc_p,
  fe_int_coef,
  fe_int_p,
  fe_res_coef,
  fe_res_p,
  NA_real_,
  NA_real_
)

# ------------------------------------------------------------------
# 7) Print compact results to console
# ------------------------------------------------------------------
cat("\n==== Robustness Checks ===\n")
print(robustness_table)

# ------------------------------------------------------------------
# 8) Save outputs
# ------------------------------------------------------------------
out_dir <- file.path("results", "tables")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

write.csv(robustness_table, file.path(out_dir, "robustness_checks.csv"), row.names = FALSE)

# Simple LaTeX table
latex_lines <- c(
  "\\begin{tabular}{lcccccccc}",
  "\\hline",
  "Model & UNSC3 coef & UNSC3 p & UNSC3 x Resource coef & UNSC3 x Resource p & Resource coef & Resource p & BP p & White p \\\\",
  "\\hline"
)

for (i in seq_len(nrow(robustness_table))) {
  row <- robustness_table[i, ]
  line <- sprintf(
    "%s & %.6f & %.4f & %.6f & %.4f & %.6f & %.4f & %.4f & %.4f \\\\",
    row$Model,
    if (is.na(row$`UNSC3 coef`)) NA_real_ else row$`UNSC3 coef`,
    if (is.na(row$`UNSC3 p`)) 1 else row$`UNSC3 p`,
    if (is.na(row$`UNSC3 x Resource coef`)) NA_real_ else row$`UNSC3 x Resource coef`,
    if (is.na(row$`UNSC3 x Resource p`)) 1 else row$`UNSC3 x Resource p`,
    if (is.na(row$`Resource coef`)) NA_real_ else row$`Resource coef`,
    if (is.na(row$`Resource p`)) 1 else row$`Resource p`,
    if (is.na(row$`BP p`)) NA_real_ else row$`BP p`,
    if (is.na(row$`White p`)) NA_real_ else row$`White p`
  )
  latex_lines <- c(latex_lines, line)
}

latex_lines <- c(latex_lines, "\\hline", "\\end{tabular}")
writeLines(latex_lines, file.path(out_dir, "robustness_checks.tex"))

cat("\nSaved CSV: ", file.path(out_dir, "robustness_checks.csv"), "\n")
cat("Saved LaTeX: ", file.path(out_dir, "robustness_checks.tex"), "\n")

# ------------------------------------------------------------------
# 9) Optional print of key statistical tests
# ------------------------------------------------------------------
cat("\n==== Heteroskedasticity tests (OLS models) ===\n")
print(bp_ols)
print(white_ols)
print(bp_ols_year)
print(white_ols_year)
print(bp_ols_country_year)
print(white_ols_country_year)

cat("\n==== FE summary ===\n")
summary(m_fe)
