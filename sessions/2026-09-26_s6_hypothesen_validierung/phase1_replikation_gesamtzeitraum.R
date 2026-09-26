# Schritt 6 Abschluss: Tabellen-2-Spalten auf Spur-B-Basis (eigene Rekonstruktion)
# und dreispaltige Validierungstabelle: publiziert | Spur A (Originaldaten) |
# Spur B (Nachbau + eigene Kontrollen).
#
# Spur B = data/processed/conditionality_dsv_1992_2008.csv (314/314 gegen das
# Original validiert) × data/processed/controls_wdi_1990_2025.csv (alle 9
# DSV-Kontrollen; IMF-Serien = NFL-Nettofluesse (konzepttreu, s. Diagnose in
# build_controls_wdi.R), legelec_l aus DPI-2023.
#
# Modellvarianten exakt nach JCR_DSV_Table2.doh:
#   Basis      : unsc3 + nrquarterssmpl                          (alle 314)
#   Basis restr.: dito, complete cases auf den 9 eigenen Kontrollen
#                (Analogon zur Original-fullsample-Regel)
#   Vollmodell : + legelec_l XDebtGNI DebtServGNI ResXDebt ExtBalGDP GFCFGDP
#                USaidGDP imf_conc_gdp imf_noconc_gdp            (Complete Cases)
#   Trunkiert  : unsc3 + nrquarterssmpl + legelec_l + imf_noconc_gdp
#   Trunkiert restr.: dito, complete cases
# Schätzer: xtreg fe (within, ISO3-FE) und xtgls panels(hetero) force nmk
# (manueller FGLS-Nachbau wie in phase0).
#
# Publizierte Referenzwerte (vorliegend): Basis-FE -2.410 (t=-1.906, N=314,
# JCR_DSV_Table2.txt); Vollmodell-FE -3.329 (t=-1.950); Vollmodell-GLS -2.096
# (t=-4.023). Fuer alle uebrigen Spalten liegt kein publizierter Output vor.
#
# Output: results/tables/replication_gesamtzeitraum.csv

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(plm)
  library(dplyr)
})

# ---------------------------------------------------------------------------
# 1) Spur-B-Daten zusammenbauen
# ---------------------------------------------------------------------------
base <- read.csv("data/processed/conditionality_dsv_1992_2008.csv",
                 stringsAsFactors = FALSE)
wdi  <- read.csv("data/processed/controls_wdi_1990_2025.csv",
                 stringsAsFactors = FALSE)

ctrl_vars <- c("XDebtGNI", "DebtServGNI", "ResXDebt", "ExtBalGDP", "GFCFGDP",
               "USaidGDP", "imf_conc_gdp", "imf_noconc_gdp", "legelec_l")

d <- base %>%
  left_join(wdi %>% select(ISO3, Year, all_of(ctrl_vars)),
            by = c("ISO3", "Year")) %>%
  mutate(fs_own = complete.cases(.[, ctrl_vars]))

cat("Spur-B-Panel:", nrow(d), "Zeilen | complete cases auf 9 eigenen Kontrollen:",
    sum(d$fs_own), "\n")

# ---------------------------------------------------------------------------
# 2) Schaetzer (xtreg fe und xtgls panels(hetero) force nmk)
# ---------------------------------------------------------------------------
fit_fe <- function(dat, fixvars) {
  p <- pdata.frame(dat, index = c("ISO3", "Year"))
  m <- plm(as.formula(paste("avgcondtype_all ~", paste(fixvars, collapse = " + "))),
           data = p, model = "within")
  s <- coef(summary(m))
  c(coef = s["unsc3", "Estimate"], t = s["unsc3", "Estimate"] / s["unsc3", "Std. Error"],
    n = nobs(m))
}

# xtgls ..., panels(hetero) force nmk (manueller FGLS-Nachbau, s. phase0)
fit_gls <- function(dat, fixvars) {
  dat <- dat[complete.cases(dat[, c("avgcondtype_all", fixvars, "ISO3")]), ]
  tab <- table(dat$ISO3)
  dat <- dat[dat$ISO3 %in% names(tab)[tab > 1], ]
  lv <- sort(unique(dat$ISO3))
  D <- sapply(lv, function(l) as.numeric(dat$ISO3 == l))
  X <- cbind(D, as.matrix(dat[, fixvars]))
  storage.mode(X) <- "double"
  colnames(X) <- c(paste0("cnt_", lv), fixvars)
  y <- as.numeric(dat$avgcondtype_all)
  e <- residuals(lm.fit(X, y))
  sig2 <- tapply(e, dat$ISO3, function(z) sum(z^2) / length(z))
  w <- as.numeric(1 / sqrt(sig2[as.character(dat$ISO3)]))
  Xw <- X * w; yw <- y * w
  qrd <- qr(Xw); r <- qrd$rank
  keep <- sort(qrd$pivot[seq_len(r)])
  Xk <- Xw[, keep, drop = FALSE]
  b <- as.numeric(solve(crossprod(Xk), crossprod(Xk, yw)))
  names(b) <- colnames(Xk)
  V <- solve(crossprod(Xk))
  n <- nrow(Xw); k <- r
  if ("unsc3" %in% names(b)) {
    se <- sqrt(V["unsc3", "unsc3"])
    c(coef = unname(b["unsc3"]),
      t_nmk = unname(b["unsc3"]) / (se * sqrt(n / (n - k))), n = n)
  } else c(coef = NA_real_, t_nmk = NA_real_, n = n)
}

fix_basis <- c("unsc3", "nrquarterssmpl")
fix_voll  <- c(fix_basis, ctrl_vars)
fix_trunc <- c("unsc3", "nrquarterssmpl", "legelec_l", "imf_noconc_gdp")

specs <- list(
  list(modell = "Basis", fix = fix_basis, dat = d),
  list(modell = "Basis", fix = fix_basis, dat = d[d$fs_own, ]),
  list(modell = "Vollmodell", fix = fix_voll, dat = d),
  list(modell = "Trunkiert", fix = fix_trunc, dat = d),
  list(modell = "Trunkiert", fix = fix_trunc, dat = d[d$fs_own, ])
)

spurB <- do.call(rbind, lapply(seq_along(specs), function(i) {
  s <- specs[[i]]
  fe <- fit_fe(s$dat, s$fix)
  gl <- fit_gls(s$dat, s$fix)
  data.frame(variant = i,
             modell = s$modell,
             sample = if (nrow(s$dat) < nrow(d)) "Complete Cases (9 eigene Kontrollen)" else "alle (314)",
             regressoren = paste(s$fix, collapse = " + "),
             spurB_fe_coef = unname(fe["coef"]), spurB_fe_t = unname(fe["t"]),
             spurB_fe_n = unname(fe["n"]),
             spurB_gls_coef = unname(gl["coef"]), spurB_gls_t = unname(gl["t_nmk"]),
             spurB_gls_n = unname(gl["n"]))
}))
cat("\n=== Spur B: Tabellen-2-Spalten auf eigener Basis ===\n")
print(spurB, digits = 3, row.names = FALSE)

# ---------------------------------------------------------------------------
# 3) Dreispaltige Validierungstabelle: publiziert | Spur A | Spur B
# ---------------------------------------------------------------------------
spurA <- read.csv("results/tables/original_replication.csv",
                  stringsAsFactors = FALSE)
# Reihenfolge in original_replication.csv entspricht den 5 Varianten:
# 1 Basis/alle(314), 2 Basis/fullsample(217), 3 Vollmodell/alle CC,
# 4 Trunkiert/alle CC, 5 Trunkiert/fullsample==1
spurA <- spurA %>%
  mutate(variant = row_number()) %>%
  transmute(variant,
            spurA_sample = sample,
            spurA_fe_coef = fe_coef, spurA_fe_t = fe_t, spurA_fe_n = fe_n,
            spurA_gls_coef = gls_coef, spurA_gls_t = gls_t_nmk,
            spurA_gls_n = gls_n)

# Publizierte Referenzwerte (vorliegende Zellen; Rest: kein Output vorhanden)
# variant 1 = Basis (alle), variant 3 = Vollmodell
pub <- data.frame(
  variant = c(1, 3, 3),
  schaetzer = c("fe", "fe", "gls"),
  publ_coef = c(-2.410, -3.329, -2.096),
  publ_t = c(-1.906, -1.950, -4.023))

tab <- spurB %>% left_join(spurA, by = "variant")

rows_fe <- tab %>%
  transmute(variant, modell, sample, schaetzer = "fe",
            publ_coef = NA_real_, publ_t = NA_real_,
            spurA_coef = spurA_fe_coef, spurA_t = spurA_fe_t, spurA_n = spurA_fe_n,
            spurB_coef = spurB_fe_coef, spurB_t = spurB_fe_t, spurB_n = spurB_fe_n)
rows_gls <- tab %>%
  transmute(variant, modell, sample, schaetzer = "gls",
            publ_coef = NA_real_, publ_t = NA_real_,
            spurA_coef = spurA_gls_coef, spurA_t = spurA_gls_t, spurA_n = spurA_gls_n,
            spurB_coef = spurB_gls_coef, spurB_t = spurB_gls_t, spurB_n = spurB_gls_n)
final <- rbind(rows_fe, rows_gls)

# Publizierte Werte einsetzen (variant + Schaetzer eindeutig)
for (i in seq_len(nrow(pub))) {
  idx <- which(final$variant == pub$variant[i] & final$schaetzer == pub$schaetzer[i])
  final$publ_coef[idx] <- pub$publ_coef[i]
  final$publ_t[idx] <- pub$publ_t[i]
}
final <- final %>%
  mutate(abweichung_B_vs_publ_pkt = ifelse(!is.na(publ_coef),
                                           round(spurB_coef - publ_coef, 3), NA)) %>%
  arrange(modell, schaetzer, sample)

write.csv(final, "results/tables/replication_gesamtzeitraum.csv",
          row.names = FALSE)
cat("\n=== Dreispaltige Validierungstabelle (publiziert | Spur A | Spur B) ===\n")
print(final, row.names = FALSE, digits = 3)
cat("\nOutput: results/tables/replication_gesamtzeitraum.csv\n")
cat("\nHinweise:\n")
cat("- Spur B Basis-FE entspricht exakt dem Original (Nachbau 314/314 validiert).\n")
cat("- Spur-B-Vollmodell nutzt eigene WDI-2026/DPI-Kontrollen; IMF-Serien sind\n")
cat("  NFL-Nettofluesse — konzepttreu, da auch das Original Nettofluesse misst\n")
cat("  (Summen-Korrelation 0.835); nur die Typen-Aufteilung weicht ab.\n")
cat("  USaidGDP: MarktbIP statt Faktorkosten — benannt.\n")
cat("- 'Basis restr.'/'Trunkiert restr.' verwenden die Complete-Case-Regel auf\n")
cat("  den eigenen Kontrollen (Analogon zur Original-fullsample-Regel).\n")
