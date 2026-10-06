# Spur A: Reproduktion von Dreher/Sturm/Vreeland (JCR 2015), "Politics and IMF
# Conditionality", Tabelle 2, auf dem Original-Datensatz.
#
# Spezifikation exakt nach data/raw/original/construction/JCR_DSV_Table2.doh:
#   Fuenf Modellschätzungen, je zwei Schätzer:
#   - Basis:            avgcondtype_0 ~ unsc3 + nrquarterssmpl            (N=314)
#   - Basis restring.:  dito, if fullsample==1                           (N=217)
#   - Vollmodell:       + legelec_l XDebtGNI DebtServGNI ResXDebt
#                       + ExtBalGDP GFCFGDP USaidGDP imf_conc_gdp
#                       + imf_noconc_gdp                                 (CC: N=217)
#   - Trunkiert:        unsc3 + nrquarterssmpl + legelec_l
#                       + imf_noconc_gdp                                 (CC: N=288)
#   - Trunkiert restr.: dito, if fullsample==1                            (N=217)
#   Schätzer: xtreg ..., fe  (plm within, Panel idcnt, 101 Gruppen)
#             xtgls ..., panels(hetero) force nmk  (manueller FGLS-Nachbau:
#               LSDV, sigma2_i = RSS_i/n_i, Singleton-Panels entfallen da
#               sigma=0 [Stata: force], gewichtete OLS, VCE (X'Om^-1X)^-1)
#
# Verifizierte Sollwerte (R-Replikation 2026-09-25):
#   Basis  FE  : unsc3 = -2.410 (t=-1.906), N=314  [identisch JCR_DSV_Table2.txt]
#   Voll   FE  : unsc3 = -3.329 (t=-1.950), N=217
#   Voll   GLS : unsc3 = -2.096, t ca. -4.0 (publiziert -4.023)
#
# Korrektur gegenueber der frueheren Fassung dieses Skripts: Das Vollmodell lief
# mit nrcntprogram statt nrquarterssmpl; Tabelle 2 enthaelt keine Jahr-FE und
# der "GLS"-Schätzer ist kein Random Effects, sondern xtgls panels(hetero).
#
# Zeitfenster-Zerlegung (1992-2001 / 2002-2008) bleibt als eigene Analyse
# erhalten, jetzt mit korrektem Regressorsatz.
#
# Output: results/phase_a/tables/original_replication.csv
#         results/phase_a/models/model_original_*.rds

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(haven)
  library(plm)
  library(lmtest)
})

d <- as.data.frame(read_dta("data/final/Dreher_Sturm_Vreeland_JCR.dta"))
d$idcnt <- as.integer(d$idcnt)
d$fs <- !is.na(d$fullsample) & d$fullsample == 1

cat("Original-Datensatz:", nrow(d), "Beobachtungen,",
    length(unique(d$idcnt)), "idcnt-Gruppen, Jahre",
    min(d$year), "-", max(d$year), "\n")
cat("DV avgcondtype_0 == avgcondtype_all (numerisch):",
    isTRUE(all.equal(as.numeric(d$avgcondtype_0), as.numeric(d$avgcondtype_all))), "\n\n")

fullvar <- c("legelec_l", "XDebtGNI", "DebtServGNI", "ResXDebt",
             "ExtBalGDP", "GFCFGDP", "USaidGDP", "imf_conc_gdp", "imf_noconc_gdp")

fix_basis <- c("unsc3", "nrquarterssmpl")
fix_voll  <- c(fix_basis, fullvar)
fix_trunc <- c("unsc3", "nrquarterssmpl", "legelec_l", "imf_noconc_gdp")

# ---------------------------------------------------------------------------
# Schaetzer
# ---------------------------------------------------------------------------
fit_fe <- function(dat, fixvars) {
  p <- pdata.frame(dat, index = c("idcnt", "year"))
  plm(as.formula(paste("avgcondtype_0 ~", paste(fixvars, collapse = " + "))),
      data = p, model = "within")
}

fit_fe_year <- function(dat, fixvars) {
  p <- pdata.frame(dat, index = c("idcnt", "year"))
  plm(
    as.formula(paste(
      "avgcondtype_0 ~", paste(fixvars, collapse = " + "), "+ factor(year)"
    )),
    data = p,
    model = "within"
  )
}

# xtgls ..., panels(hetero) force nmk (manueller FGLS-Nachbau)
# VCE: (X'Om^-1X)^-1 ohne Skalierung; zusaetzlich nmk-Variante * n/(n-k).
# Rangdefizite Designs (konstante Kovariaten in Teilsamples) via QR-Pivotierung
# reduziert; ist unsc3 selbst aliased, wird NA gemeldet.
fit_gls <- function(dat, fixvars) {
  dat <- dat[complete.cases(dat[, c("avgcondtype_0", fixvars, "idcnt")]), ]
  tab <- table(dat$idcnt)
  dat <- dat[dat$idcnt %in% names(tab)[tab > 1], ]
  lv <- sort(unique(dat$idcnt))
  D <- sapply(lv, function(l) as.numeric(dat$idcnt == l))
  X <- cbind(D, as.matrix(dat[, fixvars]))
  storage.mode(X) <- "double"
  colnames(X) <- c(paste0("cnt_", lv), fixvars)
  y <- as.numeric(dat$avgcondtype_0)
  e <- residuals(lm.fit(X, y))
  sig2 <- tapply(e, dat$idcnt, function(z) sum(z^2) / length(z))
  w <- as.numeric(1 / sqrt(sig2[as.character(dat$idcnt)]))
  Xw <- X * w
  yw <- y * w
  qrd <- qr(Xw)
  r <- qrd$rank
  keep <- sort(qrd$pivot[seq_len(r)])
  Xk <- Xw[, keep, drop = FALSE]
  b <- as.numeric(solve(crossprod(Xk), crossprod(Xk, yw)))
  names(b) <- colnames(Xk)
  V <- solve(crossprod(Xk))
  n <- nrow(Xw); k <- r
  get_unsc3 <- function(sevec) if ("unsc3" %in% names(sevec)) unname(sevec["unsc3"]) else NA_real_
  se <- setNames(sqrt(diag(V)), colnames(Xk))
  se_nmk <- se * sqrt(n / (n - k))
  list(coef = get_unsc3(b), se = get_unsc3(se), se_nmk = get_unsc3(se_nmk),
       n = n, k = k, n_singletons = sum(tab[tab == 1]),
       unsc3_in_design = "unsc3" %in% names(b))
}

# Diagnostik (analog xtserial / testparm dumcnt* / estat hettest)
diag_fe <- function(dat, fixvars) {
  m <- fit_fe(dat, fixvars)
  out <- c(wooldridge = NA_real_, ftest_fe = NA_real_, bp = NA_real_)
  out["wooldridge"] <- tryCatch(pwartest(m)$p.value, error = function(e) NA_real_)
  mp <- plm(as.formula(paste("avgcondtype_0 ~", paste(fixvars, collapse = " + "))),
            data = pdata.frame(dat, index = c("idcnt", "year")), model = "pooling")
  out["ftest_fe"] <- tryCatch(pFtest(m, mp)$p.value, error = function(e) NA_real_)
  out["bp"] <- tryCatch(
    bptest(lm(as.formula(paste("avgcondtype_0 ~",
                               paste(c(fixvars, "factor(idcnt)"), collapse = " + "))),
              data = dat), studentize = FALSE)$p.value,
    error = function(e) NA_real_)
  out
}

stars <- function(p) ifelse(is.na(p), "", ifelse(p < 0.01, "***",
                          ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", ""))))

# ---------------------------------------------------------------------------
# Tabelle 2: fuenf Spalten, je FE und GLS
# ---------------------------------------------------------------------------
run_column <- function(dat, fixvars, label, sample_label) {
  m_fe <- tryCatch(fit_fe(dat, fixvars), error = function(e) NULL)
  s_fe <- if (!is.null(m_fe)) coef(summary(m_fe)) else NULL
  # unsc3 kann in Teilsamples mit den Laender-Dummies kollinear sein
  # (z. B. Zeitfenster 2002-2008: jedes UNSC-Land hat dort nur ein Programm)
  fe_ok <- !is.null(s_fe) && "unsc3" %in% rownames(s_fe)
  g <- fit_gls(dat, fixvars)
  dg <- tryCatch(diag_fe(dat, fixvars), error = function(e) c(wooldridge = NA, ftest_fe = NA, bp = NA))

  data.frame(
    spalte = label,
    sample = sample_label,
    regressoren = paste(fixvars, collapse = " + "),
    fe_coef = if (fe_ok) s_fe["unsc3", "Estimate"] else NA_real_,
    fe_se = if (fe_ok) s_fe["unsc3", "Std. Error"] else NA_real_,
    fe_t = if (fe_ok) s_fe["unsc3", "Estimate"] / s_fe["unsc3", "Std. Error"] else NA_real_,
    fe_n = if (!is.null(m_fe)) nobs(m_fe) else NA_real_,
    gls_coef = g$coef,
    gls_se = g$se,
    gls_t = if (!is.na(g$coef) && !is.na(g$se)) g$coef / g$se else NA_real_,
    gls_se_nmk = g$se_nmk,
    gls_t_nmk = if (!is.na(g$coef) && !is.na(g$se_nmk)) g$coef / g$se_nmk else NA_real_,
    gls_n = g$n,
    gls_singletons = g$n_singletons,
    wooldridge_p = unname(if (!is.na(dg["wooldridge"])) dg["wooldridge"] else NA_real_),
    ftest_fe_p = unname(if (!is.na(dg["ftest_fe"])) dg["ftest_fe"] else NA_real_),
    bp_p = unname(if (!is.na(dg["bp"])) dg["bp"] else NA_real_),
    stringsAsFactors = FALSE
  )
}

alle <- d
fs <- d[d$fs, ]

tab2 <- rbind(
  run_column(alle, fix_basis, "Basis", "alle (314)"),
  run_column(fs,   fix_basis, "Basis", "fullsample==1 (217)"),
  run_column(alle, fix_voll,  "Vollmodell", "alle, Complete Cases"),
  run_column(alle, fix_trunc, "Trunkiert", "alle, Complete Cases"),
  run_column(fs,   fix_trunc, "Trunkiert", "fullsample==1")
)

dir.create("results/phase_a/tables", showWarnings = FALSE, recursive = TRUE)
dir.create("results/phase_a/models", showWarnings = FALSE, recursive = TRUE)
saveRDS(fit_fe(alle, fix_basis), "results/phase_a/models/model_original_fe_basis.rds")
saveRDS(fit_fe(alle, fix_voll), "results/phase_a/models/model_original_fe_voll.rds")
saveRDS(fit_gls(alle, fix_voll), "results/phase_a/models/model_original_gls_voll.rds")

cat("=== Tabelle 2: Reproduktion (xtreg fe / xtgls panels(hetero)) ===\n")
print(tab2, digits = 4)

cat("\n=== Sollwerte / Publiziertes ===\n")
cat("Basis FE: -2.410 (t=-1.906), N=314   [JCR_DSV_Table2.txt]\n")
cat("Voll  FE: -3.329 (t=-1.950), N=217   [Artikel, Tab. 2 Vollmodell]\n")
cat("Voll GLS: -2.096 (t=-4.023)           [Artikel, Tab. 2 Vollmodell]\n")

# ---------------------------------------------------------------------------
# Zusatzanalyse: Jahres-Fixed-Effects auf der Originalbasis
# ---------------------------------------------------------------------------
run_year_fe <- function(dat, fixvars, label, sample_label) {
  model <- tryCatch(fit_fe_year(dat, fixvars), error = function(e) NULL)
  coefficients <- if (!is.null(model)) coef(summary(model)) else NULL
  estimated <- !is.null(coefficients) && "unsc3" %in% rownames(coefficients)

  data.frame(
    Spezifikation = label,
    Sample = sample_label,
    Kontrollsatz = paste(fixvars[-1], collapse = " + "),
    Koeffizient = if (estimated) coefficients["unsc3", "Estimate"] else NA_real_,
    Standardfehler = if (estimated) coefficients["unsc3", "Std. Error"] else NA_real_,
    t_Wert = if (estimated) coefficients["unsc3", "t-value"] else NA_real_,
    p_Wert = if (estimated) coefficients["unsc3", "Pr(>|t|)"] else NA_real_,
    n_obs = if (!is.null(model)) nobs(model) else NA_integer_,
    Jahr_von = min(dat$year, na.rm = TRUE),
    Jahr_bis = max(dat$year, na.rm = TRUE),
    Status = if (estimated) "geschaetzt" else "unsc3 nicht schaetzbar",
    stringsAsFactors = FALSE
  )
}

tab_year_fe <- do.call(rbind, list(
  run_year_fe(alle, fix_basis, "Basis", "alle"),
  run_year_fe(fs, fix_basis, "Basis", "fullsample==1"),
  run_year_fe(alle, fix_voll, "Vollmodell", "alle, Complete Cases"),
  run_year_fe(alle, fix_trunc, "Trunkiert", "alle, Complete Cases"),
  run_year_fe(fs, fix_trunc, "Trunkiert", "fullsample==1")
))

write.csv(
  tab_year_fe,
  "results/phase_a/tables/original_replication_jahres_fe.csv",
  row.names = FALSE
)
saveRDS(
  fit_fe_year(alle, fix_basis),
  "results/phase_a/models/model_original_fe_basis_jahres_fe.rds"
)
saveRDS(
  fit_fe_year(alle, fix_voll),
  "results/phase_a/models/model_original_fe_voll_jahres_fe.rds"
)

cat("\n=== Zusatzanalyse: DSV-FE-Spezifikationen mit Jahres-FE ===\n")
print(tab_year_fe, row.names = FALSE, digits = 4)
cat("Zusatzoutput: results/phase_a/tables/original_replication_jahres_fe.csv\n")

# ---------------------------------------------------------------------------
# Zeitfenster-Zerlegung (eigene Analyse, korrigierter Regressorsatz)
# ---------------------------------------------------------------------------
d_90s <- d[d$year >= 1992 & d$year <= 2001, ]
d_00s <- d[d$year >= 2002 & d$year <= 2008, ]

zerlegung <- rbind(
  run_column(d_90s, fix_basis, "Basis", "1992-2001"),
  run_column(d_90s, fix_voll,  "Vollmodell", "1992-2001"),
  run_column(d_00s, fix_basis, "Basis", "2002-2008"),
  run_column(d_00s, fix_voll,  "Vollmodell", "2002-2008")
)
zerlegung$spalte <- paste(zerlegung$spalte, "-", zerlegung$sample)

cat("\n=== Zeitfenster-Zerlegung (eigene Analyse) ===\n")
print(zerlegung[, c("spalte", "fe_coef", "fe_t", "fe_n",
                    "gls_coef", "gls_t", "gls_n")], digits = 4)

write.csv(tab2, "results/phase_a/tables/original_replication.csv", row.names = FALSE)
write.csv(zerlegung, "results/phase_a/tables/original_replication_zeitfenster.csv",
          row.names = FALSE)

# ---------------------------------------------------------------------------
# Interaktion unsc3 x Nach-2001-Periode: direkter Test der Differenz
# zwischen den Zeitfenstern (ergaenzt original_replication_zeitfenster.csv).
# Der Koeffizient auf unsc3:ab2002 misst, um wie viel der UNSC-Effekt ab 2002
# vom Effekt 1992-2001 abweicht; sein p-Wert testet die Differenz direkt.
# ---------------------------------------------------------------------------
d_ab <- d
d_ab$ab2002 <- as.integer(d_ab$year >= 2002)
p_ab <- pdata.frame(d_ab, index = c("idcnt", "year"))

m_ab_basis <- plm(avgcondtype_0 ~ unsc3 * ab2002 + nrquarterssmpl,
                  data = p_ab, model = "within")
m_ab_voll <- plm(
  as.formula(paste(
    "avgcondtype_0 ~ unsc3 * ab2002 +",
    paste(setdiff(fix_voll, "unsc3"), collapse = " + ")
  )),
  data = p_ab, model = "within"
)

ab_zeile <- function(m, modell) {
  s <- summary(m)$coefficients
  i <- grep("unsc3:ab2002", rownames(s))
  data.frame(modell = modell, term = "unsc3:ab2002",
             coef = s[i, "Estimate"], se = s[i, "Std. Error"],
             t = s[i, "t-value"], p = s[i, "Pr(>|t|)"],
             n = nobs(m))
}

interaktion <- rbind(ab_zeile(m_ab_basis, "Basis"),
                     ab_zeile(m_ab_voll, "Vollmodell"))

cat("\n=== Interaktion unsc3 x ab2002 (Differenztest) ===\n")
print(interaktion, digits = 4)
write.csv(interaktion,
          "results/phase_a/tables/original_replication_zeitfenster_interaktion.csv",
          row.names = FALSE)

cat("\nOutput: results/phase_a/tables/original_replication.csv",
    "und original_replication_zeitfenster.csv\n")
