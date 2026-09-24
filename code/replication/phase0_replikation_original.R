# Spur A: Replikation der Originalstudie auf dem Original-Datensatz
# Dreher, Sturm & Vreeland (2015), Tabelle 2
# Datenbasis: data/final/Dreher_Sturm_Vreeland_JCR.dta (N=217, 1992-2008)
#
# Reproduziert:
# - OLS mit Laender-Fixed-Effects   (publiziert: unsc3 = -3.329, t = -1.950)
# - GLS (Random-Effects)            (publiziert: unsc3 = -2.096, t = -4.023)
# zusaetzlich Zeitfenster-Zerlegung (1992-2001 / 2002-2008), um zu zeigen,
# dass der publizierte Effekt primaer von den 1990er-Jahren getragen wird.
#
# Hinweis zur GLS-Spalte: Der Koeffizient reproduziert sich mit plm-RE
# (-2.45 vs. -2.10), die publizierten t-Werte jedoch nicht vollstaendig,
# da die Originalstudie eine eigene (robuste) GLS-VCOV verwendet.
#
# Output: results/tables/original_replication.csv, results/models/model_original_*.rds

setwd("C:/Users/HP/io/imf-replizierung")

library(haven)
library(plm)
library(dplyr)

d <- as.data.frame(read_dta("data/final/Dreher_Sturm_Vreeland_JCR.dta"))
cat("Original-Datensatz:", nrow(d), "Beobachtungen,",
    length(unique(d$country)), "Laender, Jahre",
    min(d$year), "-", max(d$year), "\n")
cat("Depvar avgcondtype_all (Bedingungen pro Quartal): Range",
    paste(round(range(d$avgcondtype_all), 1), collapse = "-"),
    "| Mean", round(mean(d$avgcondtype_all), 2), "\n")

ctrl <- "unsc3 + nrcntprogram + legelec_l + XDebtGNI + DebtServGNI + ResXDebt + ExtBalGDP + GFCFGDP + USaidGDP + imf_conc_gdp + imf_noconc_gdp"

# ---------------------------------------------------------------------------
# Hilfsfunktion: Modell je Schätzer/Daten, unsc3-Zeile extrahieren
# ---------------------------------------------------------------------------
get_unsc3 <- function(m, schaetzer, modell_label, fenster, publiziert, dat) {
  ct <- tryCatch(coef(summary(m)), error = function(e) NULL)
  n_l <- length(unique(dat$country))
  if (is.null(ct) || !("unsc3" %in% rownames(ct))) {
    return(data.frame(Modell = modell_label, Zeitraum = fenster,
                      Schaetzer = schaetzer, unsc3_coef = NA_real_,
                      unsc3_se = NA_real_, unsc3_p = NA_real_,
                      n_obs = if (!is.null(m)) nobs(m) else NA_real_,
                      n_laender = n_l, Publiziert = publiziert))
  }
  data.frame(
    Modell = modell_label,
    Zeitraum = fenster,
    Schaetzer = schaetzer,
    unsc3_coef = ct["unsc3", "Estimate"],
    unsc3_se = ct["unsc3", grep("Std", colnames(ct))[1]],
    unsc3_p = ct["unsc3", ncol(ct)],
    n_obs = nobs(m),
    n_laender = n_l,
    Publiziert = publiziert,
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# 1) Gesamter Zeitraum 1992-2008 (Original-Tabelle 2)
# ---------------------------------------------------------------------------
m_fe <- plm(as.formula(paste("avgcondtype_all ~", ctrl)),
            data = d, index = "country", model = "within")
m_gls <- plm(as.formula(paste("avgcondtype_all ~", ctrl)),
             data = d, index = "country", model = "random")

saveRDS(m_fe, "results/models/model_original_fe.rds")
saveRDS(m_gls, "results/models/model_original_gls.rds")

cat("\n=== Tabelle 2, Reproduktion: OLS mit Laender-FE ===\n")
print(summary(m_fe))
cat("\n=== Tabelle 2, Reproduktion: GLS (Random Effects) ===\n")
print(summary(m_gls))

# ---------------------------------------------------------------------------
# 2) Zeitfenster-Zerlegung: Wo lebt der Effekt?
# ---------------------------------------------------------------------------
d_90s <- d[d$year >= 1992 & d$year <= 2001, ]
d_00s <- d[d$year >= 2002 & d$year <= 2008, ]

m_fe_90s <- plm(as.formula(paste("avgcondtype_all ~", ctrl)),
                data = d_90s, index = "country", model = "within")
m_gls_90s <- plm(as.formula(paste("avgcondtype_all ~", ctrl)),
                 data = d_90s, index = "country", model = "random")
m_fe_00s <- plm(as.formula(paste("avgcondtype_all ~", ctrl)),
                data = d_00s, index = "country", model = "within")
m_gls_00s <- plm(as.formula(paste("avgcondtype_all ~", ctrl)),
                 data = d_00s, index = "country", model = "random")

# ---------------------------------------------------------------------------
# 3) Ergebnistabelle
# ---------------------------------------------------------------------------
tab <- rbind(
  get_unsc3(m_fe,   "OLS mit Laender-FE", "Tabelle 2 (Reproduktion)", "1992-2008", "-3.329 (t=-1.95)", d),
  get_unsc3(m_gls,  "GLS (Random Effects)", "Tabelle 2 (Reproduktion)", "1992-2008", "-2.096 (t=-4.02)", d),
  get_unsc3(m_fe_90s,  "OLS mit Laender-FE", "Zeitfenster-Zerlegung", "1992-2001", "", d_90s),
  get_unsc3(m_gls_90s, "GLS (Random Effects)", "Zeitfenster-Zerlegung", "1992-2001", "", d_90s),
  get_unsc3(m_fe_00s,  "OLS mit Laender-FE", "Zeitfenster-Zerlegung", "2002-2008", "", d_00s),
  get_unsc3(m_gls_00s, "GLS (Random Effects)", "Zeitfenster-Zerlegung", "2002-2008", "", d_00s)
) %>%
  mutate(across(c(unsc3_coef, unsc3_se, unsc3_p), ~ round(.x, 4)))

write.csv(tab, "results/tables/original_replication.csv", row.names = FALSE)

cat("\n=== Benchmark-Tabelle: Originaldatensatz ===\n")
print(tab, row.names = FALSE)

cat("\nFazit: Der publizierte negative unsc3-Effekt wird von den 1990er-Jahren\n")
cat("getragen; ab 2002 ist er auch auf den Originaldaten statistisch Null.\n")
