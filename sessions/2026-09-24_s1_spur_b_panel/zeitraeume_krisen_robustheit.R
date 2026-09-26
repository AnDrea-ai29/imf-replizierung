# Zeiträume und Krisen: Robustheit der H1-Schaetzung gegen
# Finanzkrise (2008-2010) und Corona-Pandemie (2020-2022)
#
# Frage: Verzerrten die Krisen die unsc3-Koeffizienten?
# Drei Prüfungen:
#   1. Ausschluss-Fenster: Krisenjahre aus der Stichprobe entfernen
#   2. Jahres-FE: gemeinsame Schocks direkt absorbieren (twoways)
#   3. Heterogenitaet: Interaktion unsc3 x Krisenjahre
#
# Spezifikation: H1-Replikationsspezifikation (avgcondtype_count, Basis-Kontrollen,
# Within-Schaetzer mit Laender-FE, analog phase1_replizierung.r).
#
# Output: results/tables/krisen_robustheit.csv

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(plm)

d <- read.csv("data/processed/final_data_panel_ALL.csv",
              stringsAsFactors = FALSE)

controls <- c("XDebtGNI", "DebtServGNI", "ResXDebt")
formel <- as.formula(paste("avgcondtype_count ~ unsc3 +",
                           paste(controls, collapse = " + ")))

krisen_fc  <- 2008:2010  # internationale Finanzkrise
krisen_cov <- 2020:2022  # Corona-Pandemie

fit_variante <- function(dat, fe, label) {
  dat <- dat %>%
    filter(complete.cases(across(c("avgcondtype_count", "unsc3", all_of(controls)))))
  eff <- if (fe == "laender") "individual" else "twoways"
  m <- plm(formel, data = dat, index = "ISO3", model = "within", effect = eff)
  s <- summary(m)
  data.frame(
    Variante = label,
    FE = if (fe == "laender") "Laender" else "Laender + Jahre",
    n_obs = nobs(m),
    n_laender = n_distinct(dat$ISO3),
    unsc3 = round(coef(m)[["unsc3"]], 3),
    unsc3_p = round(s$coefficients["unsc3", "Pr(>|t|)"], 4),
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# 1) Ausschluss-Fenster
# ---------------------------------------------------------------------------
tab <- bind_rows(
  fit_variante(d, "laender", "Alle Jahre 2002-2025 (Referenz)"),
  fit_variante(filter(d, !Year %in% krisen_fc),  "laender",
               paste0("Ohne Finanzkrise ", min(krisen_fc), "-", max(krisen_fc))),
  fit_variante(filter(d, !Year %in% krisen_cov), "laender",
               paste0("Ohne Corona ", min(krisen_cov), "-", max(krisen_cov))),
  fit_variante(filter(d, !Year %in% c(krisen_fc, krisen_cov)), "laender",
               "Ohne beide Krisenzeitraeume")
)

# ---------------------------------------------------------------------------
# 2) Jahres-FE absorbieren gemeinsame Schocks
# ---------------------------------------------------------------------------
tab <- bind_rows(
  tab,
  fit_variante(d, "jahre", "Alle Jahre, mit Jahres-FE"),
  fit_variante(filter(d, !Year %in% c(krisen_fc, krisen_cov)), "jahre",
               "Ohne beide Krisenzeitraeume, mit Jahres-FE")
)

# ---------------------------------------------------------------------------
# 3) Heterogenitaet: unsc3 x Krise
# ---------------------------------------------------------------------------
d_krise <- d %>%
  mutate(krise = ifelse(Year %in% c(krisen_fc, krisen_cov), 1, 0)) %>%
  filter(complete.cases(across(c("avgcondtype_count", "unsc3", "krise", all_of(controls)))))

m_int <- plm(avgcondtype_count ~ unsc3 * krise + XDebtGNI + DebtServGNI + ResXDebt,
             data = d_krise, index = "ISO3", model = "within")
s_int <- summary(m_int)

cat("=== Interaktion unsc3 x Krisenjahre ===\n")
print(coef(summary(m_int)))

cat("\nBehandelte Land-Jahre (unsc3==1) in Krisenjahren:",
    sum(d_krise$unsc3 == 1 & d_krise$krise == 1),
    "| ausserhalb:", sum(d_krise$unsc3 == 1 & d_krise$krise == 0), "\n")

# ---------------------------------------------------------------------------
# Ausgabe
# ---------------------------------------------------------------------------
write.csv(tab, "results/tables/krisen_robustheit.csv", row.names = FALSE)
cat("\n=== Krisen-Robustheit (H1, avgcondtype_count) ===\n")
print(tab, row.names = FALSE)
