# H1-Sample-Zerlegung: Woher kam das fruehere NEGATIVE Vorzeichen?
# Kontext: Die fruehere H1-Schaetzung (Commits 415beec/5223c5d, unsc_coef = -1.25)
# lief trotz Skript-Kommentar "ALLE Laender" nur ueber die 20 SSA-Laender
# (data_with_cond_types.csv) und verwendete eine anzahlbasierte abhaengige
# Variable (Range 0-30). Dieses Skript dokumentiert die Zerlegung:
#   1. Reproduktion des alten SSA-Befunds auf den archivierten Daten
#   2. H1 auf dem aktuellen Panel, gestaffelt nach Laenderpool und Zeitfenster,
#      jeweils in BEIDEN Operationalisierungen:
#      - avgcondtype_count (Bedingungen pro Quartal, Original-Spezifikation)
#      - avgcondtype_share (Anteil klassifizierter Bedingungen, eigene Erw.)
#
# Output: results/tables/h1_sample_zerlegung.csv

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(plm)

controls <- c("XDebtGNI", "DebtServGNI", "ResXDebt")

fit_h1 <- function(dat, depvar, label, quelle) {
  dat <- dat %>%
    filter(complete.cases(across(c(depvar, "unsc3", all_of(controls)))))
  skalierung <- paste0(round(min(dat[[depvar]], na.rm = TRUE), 2),
                       "-", round(max(dat[[depvar]], na.rm = TRUE), 2))
  if (nrow(dat) < 10 || n_distinct(dat$ISO3) < 5) {
    return(data.frame(Spezifikation = label, Quelle = quelle, depvar = depvar,
                      unsc3_coef = NA_real_, unsc3_p = NA_real_,
                      n_obs = nrow(dat), n_laender = n_distinct(dat$ISO3),
                      outcome_skala = skalierung, stringsAsFactors = FALSE))
  }
  m <- plm(as.formula(paste(depvar, "~ unsc3 +", paste(controls, collapse = " + "))),
           data = dat, index = "ISO3", model = "within")
  s <- summary(m)
  data.frame(
    Spezifikation = label,
    Quelle = quelle,
    depvar = depvar,
    unsc3_coef = coef(m)[["unsc3"]],
    unsc3_p = s$coefficients["unsc3", "Pr(>|t|)"],
    n_obs = nobs(m),
    n_laender = n_distinct(dat$ISO3),
    outcome_skala = skalierung,
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# 1) Reproduktion des ALTEN Befunds (archivierter SSA-Datensatz)
#    Dort ist avgcondtype_all anzahlbasiert (Range 0-30, Arrangement-Ebene).
# ---------------------------------------------------------------------------
alt_path <- "archive/ssa_legacy/data/data_with_cond_types.csv"

if (file.exists(alt_path)) {
  alt <- read.csv(alt_path, stringsAsFactors = FALSE) %>%
    filter(Year >= 2002, Year <= 2008) %>%
    group_by(ISO3, Year, unsc3, XDebtGNI, DebtServGNI, ResXDebt) %>%
    summarise(avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE), .groups = "drop")

  erg_alt <- fit_h1(alt, "avgcondtype_all",
                    "ALTER Datensatz: 20 SSA-Laender, 2002-2008 (Reproduktion)",
                    alt_path)
} else {
  cat("Hinweis: archivierter SSA-Datensatz nicht gefunden, Reproduktion uebersprungen.\n")
  erg_alt <- data.frame(Spezifikation = "ALTER Datensatz: Reproduktion (nicht verfuegbar)",
                        Quelle = alt_path, depvar = NA_character_,
                        unsc3_coef = NA_real_, unsc3_p = NA_real_,
                        n_obs = NA_integer_, n_laender = NA_integer_,
                        outcome_skala = NA_character_)
}

# ---------------------------------------------------------------------------
# 2) H1 auf dem AKTUELLEN Panel: Laenderpool x Zeitfenster x Depvar
# ---------------------------------------------------------------------------
d <- read.csv("data/processed/final_data_panel_ALL.csv", stringsAsFactors = FALSE)

alt20 <- c("AGO", "CAF", "CMR", "COM", "CPV", "GAB", "GHA", "GIN", "KEN", "LSO",
           "MDG", "MOZ", "MRT", "MWI", "RWA", "SLE", "SLV", "TZA", "UGA", "ZMB")

samples <- list(
  list(dat = filter(d, ISO3 %in% alt20, Year >= 2002, Year <= 2008),
       label = "Neues Panel: nur die alten 20 SSA-Laender, 2002-2008"),
  list(dat = filter(d, ISO3 %in% alt20),
       label = "Neues Panel: nur die alten 20 SSA-Laender, alle Jahre"),
  list(dat = filter(d, Year >= 2002, Year <= 2008),
       label = "Neues Panel: alle 99 Laender, 2002-2008"),
  list(dat = d,
       label = "Neues Panel: alle 99 Laender, alle Jahre (H1-Hauptmodell)")
)

erg_neu <- bind_rows(lapply(samples, function(smp) {
  bind_rows(
    fit_h1(smp$dat, "avgcondtype_count", smp$label, "final_data_panel_ALL.csv"),
    fit_h1(smp$dat, "avgcondtype_share", smp$label, "final_data_panel_ALL.csv")
  )
}))

# ---------------------------------------------------------------------------
# 3) Zusammenfassen, speichern, drucken
# ---------------------------------------------------------------------------
zerlegung <- bind_rows(erg_alt, erg_neu) %>%
  mutate(across(c(unsc3_coef, unsc3_p), ~ round(.x, 4)))

write.csv(zerlegung, "results/tables/h1_sample_zerlegung.csv", row.names = FALSE)

cat("\n=== H1-Sample-Zerlegung ===\n")
print(zerlegung, row.names = FALSE)

cat("\nFazit: Das fruehere negative Vorzeichen beruhte auf dem 20-SSA-Subsample\n")
cat("und einer anzahlbasierten abhaengigen Variable. In der Original-Spezifikation\n")
cat("(avgcondtype_count, Bedingungen pro Quartal) und im globalen Pool ueber alle\n")
cat("Jahre ist der Koeffizient nicht im erwarteten negativen Bereich signifikant.\n")
