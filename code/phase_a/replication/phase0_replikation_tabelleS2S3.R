# Spur A: Reproduktion der Supplement-Tabellen S2 und S3 aus
# Dreher/Sturm/Vreeland (JCR 2015) auf dem Original-Datensatz.
#
# Spezifikation exakt nach data/raw/original/construction/:
#   JCR_DSV_TableS2.doh: depvar scope_0, fuenf Spezifikationen,
#     je drei Schaetzer: xtreg ..., fe / xtgls ..., corr(ar1) force nmk /
#     xtpoisson ..., fe; Diagnostik xtserial, testparm dumcnt*, estat hettest.
#   JCR_DSV_TableS3.doh: depvar scope_1..scope_3, fuenf Spezifikationen,
#     nur xtgls ..., corr(ar1) force nmk.
#
# Regressorsaetze (unvar = unsc3):
#   Basis:      unsc3 nrquarterssmpl
#   Vollmodell: unsc3 nrquarterssmpl + fullvar
#   Trunkiert:  unsc3 nrquarterssmpl ResXDebt
#   Samples: alle / fullsample==1
#
# Wichtige Umsetzungshinweise:
# - xtgls ... corr(ar1) force nmk hat kein exaktes R-Pendant. Nachbau:
#     LSDV in Levels, gemeinsames rho pooled aus den Level-Residuen,
#     Prais-Winsten-Transformation (Erstbeobachtung * sqrt(1-rho^2)),
#     iterative FGLS bis Konvergenz, VCE sigma^2 (X*'X*)^-1 mit
#     nmk-Freiheitsgradkorrektur, panels(iid) wie Stata-Default.
# - Es liegen keine Stata-Sollwerte fuer S2/S3 im Repo vor (nur
#   JCR_DSV_Table1.log und JCR_DSV_Table2.txt). Die AR(1)-GLS-Koeffizienten
#   sind daher ein dokumentierter Nachbau ohne Zeilengleichheit gegen
#   Stata; die FE- und Poisson-Spaetzen nutzen dieselbe Maschinerie wie
#   die validierte Tabelle-2-Replikation (phase0_replikation_original.R).
# - xtserial (Wooldridge) wird wie dort nur via pwartest approximiert.
# - nrcntprogram dient als Panel-Zeitindex (xtset idcnt nrcntprogram) fuer
#   die AR(1)-Sequenz; das ist die einzige Stelle im R-Pfad, an der die
#   Variable wirklich benoetigt wird.
#
# Output: results/phase_a/tables/original_replication_tabelleS2.csv
#         results/phase_a/tables/original_replication_tabelleS3.csv

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(haven)
  library(plm)
  library(lmtest)
  library(fixest)
})

d <- as.data.frame(read_dta("data/final/Dreher_Sturm_Vreeland_JCR.dta"))
d$idcnt <- as.integer(d$idcnt)
d$fs <- !is.na(d$fullsample) & d$fullsample == 1
d <- d[order(d$idcnt, d$nrcntprogram), ]

stopifnot(all(c("scope_0", "scope_1", "scope_2", "scope_3") %in% names(d)))

fullvar <- c("legelec_l", "XDebtGNI", "DebtServGNI", "ResXDebt",
             "ExtBalGDP", "GFCFGDP", "USaidGDP", "imf_conc_gdp", "imf_noconc_gdp")
fix_basis  <- c("unsc3", "nrquarterssmpl")
fix_voll   <- c(fix_basis, fullvar)
fix_trunc  <- c("unsc3", "nrquarterssmpl", "ResXDebt")

# ---------------------------------------------------------------------------
# Schaetzer
# ---------------------------------------------------------------------------

fit_fe <- function(dat, depvar, fixvars) {
  p <- pdata.frame(dat, index = c("idcnt", "nrcntprogram"))
  plm(as.formula(paste(depvar, "~", paste(fixvars, collapse = " + "))),
      data = p, model = "within")
}

# xtgls ..., corr(ar1) force nmk (manueller iterierter FGLS-Nachbau)
fit_gls_ar1 <- function(dat, depvar, fixvars,
                        max_iter = 100, tol = 1e-9) {
  dat <- dat[complete.cases(dat[, c(depvar, fixvars,
                                    "idcnt", "nrcntprogram")]), ]
  dat <- dat[order(dat$idcnt, dat$nrcntprogram), ]
  lv <- sort(unique(dat$idcnt))
  D <- sapply(lv, function(l) as.numeric(dat$idcnt == l))
  X <- cbind(D, as.matrix(dat[, fixvars]))
  storage.mode(X) <- "double"
  y <- as.numeric(dat[[depvar]])
  n <- nrow(X)
  idx_by <- split(seq_len(n), dat$idcnt)

  rho <- 0
  b_prev <- rep(NA_real_, ncol(X))
  converged <- FALSE
  iter_used <- 0L
  for (it in seq_len(max_iter)) {
    iter_used <- it
    w_first <- if (abs(rho) < 1) sqrt(1 - rho^2) else 0
    Xt <- matrix(0, nrow(X), ncol(X))
    yt <- numeric(n)
    for (idx in idx_by) {
      if (length(idx) == 0) next
      Xt[idx[1], ] <- X[idx[1], ] * w_first
      yt[idx[1]] <- y[idx[1]] * w_first
      if (length(idx) > 1) {
        for (j in 2:length(idx)) {
          Xt[idx[j], ] <- X[idx[j], ] - rho * X[idx[j - 1], ]
          yt[idx[j]] <- y[idx[j]] - rho * y[idx[j - 1]]
        }
      }
    }
    fit <- lm.fit(Xt, yt)
    b <- fit$coefficients
    b[is.na(b)] <- 0
    # rho aus den Level-Residuen des aktuellen GLS-Schätzers
    u <- y - as.numeric(X %*% b)
    num <- 0; den <- 0
    for (idx in idx_by) {
      if (length(idx) < 2) next
      e <- u[idx]
      num <- num + sum(e[-1] * e[-length(e)])
      den <- den + sum(e[-length(e)]^2)
    }
    rho_new <- if (den > 0) num / den else 0
    delta <- if (all(is.finite(b_prev))) max(abs(b - b_prev)) else Inf
    b_prev <- b
    rho <- rho_new
    if (is.finite(delta) && delta < tol) { converged <- TRUE; break }
  }

  # VCE aus dem transformierten Modell, nmk-korrigiert
  fit <- lm.fit(Xt, yt)
  qrd <- qr(Xt)
  r <- qrd$rank
  keep <- sort(qrd$pivot[seq_len(r)])
  Xk <- Xt[, keep, drop = FALSE]
  colnames(Xk) <- colnames(X)[keep]
  b <- fit$coefficients[keep]
  names(b) <- colnames(Xk)
  resid <- yt - as.numeric(Xt[, keep, drop = FALSE] %*% b)
  sigma2 <- sum(resid^2) / (n - r)
  V <- solve(crossprod(Xk)) * sigma2
  se <- sqrt(diag(V))
  get_unsc3 <- function(v) if ("unsc3" %in% names(v)) unname(v["unsc3"]) else NA_real_
  list(coef = get_unsc3(b), se = get_unsc3(se), rho = rho,
       n = n, k = r, iterations = iter_used, converged = converged,
       unsc3_in_design = "unsc3" %in% names(b))
}

# xtpoisson ..., fe (konditionaler Poisson-FE-Schätzer)
fit_pois <- function(dat, depvar, fixvars) {
  tryCatch({
    m <- fepois(
      as.formula(paste(depvar, "~",
                       paste(fixvars, collapse = " + "), "| idcnt")),
      data = dat,
      notes = FALSE
    )
    tab <- coeftable(m)
    list(coef = if ("unsc3" %in% rownames(tab)) unname(tab["unsc3", "Estimate"]) else NA_real_,
         se = if ("unsc3" %in% rownames(tab)) unname(tab["unsc3", "Std. Error"]) else NA_real_,
         n = nobs(m))
  }, error = function(e) {
    list(coef = NA_real_, se = NA_real_, n = NA_integer_)
  })
}

# Diagnostik (analog xtserial / testparm dumcnt* / estat hettest)
diag_fe <- function(dat, depvar, fixvars) {
  out <- c(wooldridge = NA_real_, ftest_fe = NA_real_, bp = NA_real_)
  m <- tryCatch(fit_fe(dat, depvar, fixvars), error = function(e) NULL)
  out["wooldridge"] <- if (!is.null(m)) {
    tryCatch(pwartest(m)$p.value, error = function(e) NA_real_)
  } else NA_real_
  mp <- tryCatch(
    plm(as.formula(paste(depvar, "~", paste(fixvars, collapse = " + "))),
        data = pdata.frame(dat, index = c("idcnt", "nrcntprogram")),
        model = "pooling"),
    error = function(e) NULL
  )
  out["ftest_fe"] <- if (!is.null(m) && !is.null(mp)) {
    tryCatch(pFtest(m, mp)$p.value, error = function(e) NA_real_)
  } else NA_real_
  out["bp"] <- tryCatch(
    bptest(lm(as.formula(paste(depvar, "~",
                               paste(c(fixvars, "factor(idcnt)"),
                                     collapse = " + "))),
              data = dat), studentize = FALSE)$p.value,
    error = function(e) NA_real_
  )
  out
}

# ---------------------------------------------------------------------------
# S2: scope_0, fuenf Spezifikationen x (xtreg fe, xtgls ar1, xtpoisson fe)
# ---------------------------------------------------------------------------

run_s2 <- function(dat, fixvars, label, sample_label) {
  s_fe <- tryCatch(coef(summary(fit_fe(dat, "scope_0", fixvars))),
                   error = function(e) NULL)
  fe_ok <- !is.null(s_fe) && "unsc3" %in% rownames(s_fe)
  g <- fit_gls_ar1(dat, "scope_0", fixvars)
  p <- fit_pois(dat, "scope_0", fixvars)
  dg <- tryCatch(diag_fe(dat, "scope_0", fixvars),
                 error = function(e) c(wooldridge = NA, ftest_fe = NA, bp = NA))

  data.frame(
    Spezifikation = label,
    Sample = sample_label,
    Regressoren = paste(fixvars, collapse = " + "),
    fe_coef = if (fe_ok) s_fe["unsc3", "Estimate"] else NA_real_,
    fe_se = if (fe_ok) s_fe["unsc3", "Std. Error"] else NA_real_,
    fe_t = if (fe_ok) s_fe["unsc3", "Estimate"] / s_fe["unsc3", "Std. Error"] else NA_real_,
    fe_n = if (fe_ok) nobs(fit_fe(dat, "scope_0", fixvars)) else NA_integer_,
    wooldridge_p = unname(dg["wooldridge"]),
    ftest_fe_p = unname(dg["ftest_fe"]),
    bp_p = unname(dg["bp"]),
    gls_coef = g$coef,
    gls_se = g$se,
    gls_t = if (is.finite(g$coef) && is.finite(g$se)) g$coef / g$se else NA_real_,
    gls_rho = g$rho,
    gls_n = g$n,
    gls_iterations = g$iterations,
    gls_konvergiert = g$converged,
    pois_coef = p$coef,
    pois_se = p$se,
    pois_t = if (is.finite(p$coef) && is.finite(p$se)) p$coef / p$se else NA_real_,
    pois_n = p$n,
    stringsAsFactors = FALSE
  )
}

alle <- d
fs <- d[d$fs, ]

tab_s2 <- rbind(
  run_s2(alle, fix_basis, "Basis", "alle"),
  run_s2(fs,   fix_basis, "Basis", "fullsample==1"),
  run_s2(alle, fix_voll,  "Vollmodell", "alle, Complete Cases"),
  run_s2(alle, fix_trunc, "Trunkiert", "alle, Complete Cases"),
  run_s2(fs,   fix_trunc, "Trunkiert", "fullsample==1")
)

# ---------------------------------------------------------------------------
# S3: scope_1..3, fuenf Spezifikationen, nur xtgls ar1
# ---------------------------------------------------------------------------

run_s3 <- function(dat, depvar, fixvars, label, sample_label) {
  g <- fit_gls_ar1(dat, depvar, fixvars)
  data.frame(
    AV = depvar,
    Spezifikation = label,
    Sample = sample_label,
    Regressoren = paste(fixvars, collapse = " + "),
    gls_coef = g$coef,
    gls_se = g$se,
    gls_t = if (is.finite(g$coef) && is.finite(g$se)) g$coef / g$se else NA_real_,
    gls_rho = g$rho,
    gls_n = g$n,
    gls_iterations = g$iterations,
    gls_konvergiert = g$converged,
    stringsAsFactors = FALSE
  )
}

tab_s3 <- do.call(rbind, lapply(c("scope_1", "scope_2", "scope_3"), function(dv) {
  rbind(
    run_s3(alle, dv, fix_basis, "Basis", "alle"),
    run_s3(fs,   dv, fix_basis, "Basis", "fullsample==1"),
    run_s3(alle, dv, fix_voll, "Vollmodell", "alle, Complete Cases"),
    run_s3(alle, dv, fix_trunc, "Trunkiert", "alle, Complete Cases"),
    run_s3(fs,   dv, fix_trunc, "Trunkiert", "fullsample==1")
  )
}))

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

dir.create("results/phase_a/tables", showWarnings = FALSE, recursive = TRUE)
write.csv(tab_s2, "results/phase_a/tables/original_replication_tabelleS2.csv",
          row.names = FALSE)
write.csv(tab_s3, "results/phase_a/tables/original_replication_tabelleS3.csv",
          row.names = FALSE)

cat("=== Tabelle S2: scope_0 (xtreg fe / xtgls ar1 / xtpoisson fe) ===\n")
print(tab_s2, row.names = FALSE, digits = 4)
cat("\n=== Tabelle S3: scope_1..3 (xtgls ar1) ===\n")
print(tab_s3, row.names = FALSE, digits = 4)
cat("\nHinweis: AR(1)-GLS ist ein iterativer FGLS-Nachbau ohne Stata-Sollwerte\n")
cat("im Repo; FE/Poisson nutzen die validierte Tabelle-2-Maschinerie.\n")
cat("\nOutput: results/phase_a/tables/original_replication_tabelleS2.csv\n")
cat("        results/phase_a/tables/original_replication_tabelleS3.csv\n")
