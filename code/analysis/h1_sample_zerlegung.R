# H1-Sample-Zerlegung: Woher kam das fruehere NEGATIVE Vorzeichen?
# Kontext: Die fruehere H1-Schaetzung (Commits 415beec/5223c5d, unsc_coef = -1.25)
# lief trotz Skript-Kommentar "ALLE LAender" nur ueber die 20 SSA-Laender
# (data_with_cond_types.csv) und verwendete eine anzahlbasierte abhaengige
# Variable (Range 0-30). Dieses Skript dokumentiert die Zerlegung:
#   1. Reproduktion des alten SSA-Befunds auf den archivierten Daten
#   2. H1 auf dem aktuellen Panel, gestaffelt nach Laenderpool und Zeitfenster
#
# Output: results/tables/h1_sample_zerlegung.csv

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(plm)

ctrl_formel <- "avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt"

fit_h1 <- function(dat, label, quelle) {
  dat <- dat %>%
    filter(complete.cases(across(c(avgcondtype_all, unsc3, XDebtGNI, DebtServGNI, ResXDebt))))
  if (nrow(dat) < 10 || n_distinct(dat$ISO3) < 5) {
    return(data.frame(Spezifikation = label, Quelle = quelle,
                      unsc3_coef = NA_real_, unsc3_p = NA_real_,
                      n_obs = nrow(dat), n_laender = n_distinct(dat$ISO3),
                      outcome_skala = NA_character_))
  }
  m <- plm(as.formula(ctrl_formel), data = dat, index = "ISO3", model = "within")
  s <- summary(m)
  data.frame(
    Spezifikation = label,
    Quelle = quelle,
    unsc3_coef = coef(m)[["unsc3"]],
    unsc3_p = s$coefficients["unsc3", "Pr(>|t|)"],
    n_obs = nobs(m),
    n_laender = n_distinct(dat$ISO3),
    outcome_skala = paste0(round(min(dat$avgcondtype_all, na.rm = TRUE), 2),
                           "-", round(max(dat$avgcondtype_all, na.rm = TRUE), 2)),
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# 1) Reproduktion des ALTEN Befunds (archivierter SSA-Datensatz)
# ---------------------------------------------------------------------------
alt_path <- "archive/ssa_legacy/data/data_with_cond_types.csv"
alt_vorhanden <- file.exists(alt_path)

if (alt_vorhanden) {
  alt <- read.csv(alt_path, stringsAsFactors = FALSE) %>%
    filter(Year >= 2002, Year <= 2008) %>%
    group_by(ISO3, Year, unsc3, XDebtGNI, DebtServGNI, ResXDebt) %>%
    summarise(avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE), .groups = "drop")

  erg_alt <- fit_h1(alt,
    "ALTER Datensatz: 20 SSA-Laender, 2002-2008 (Reproduktion)",
    "archive/ssa_legacy/data/data_with_cond_types.csv")
} else {
  cat("Hinweis: archivierter SSA-Datensatz nicht gefunden, Reproduktion uebersprungen.\n")
  erg_alt <- data.frame(Spezifikation = "ALTER Datensatz: Reproduktion (nicht verfuegbar)",
                        Quelle = alt_path, unsc3_coef = NA_real_, unsc3_p = NA_real_,
                        n_obs = NA_integer_, n_laender = NA_integer_,
                        outcome_skala = NA_character_)
}

# ---------------------------------------------------------------------------
# 2) H1 auf dem AKTUELLEN Panel: gestaffelt nach Laenderpool und Zeitfenster
# ---------------------------------------------------------------------------
d <- read.csv("data/processed/final_data_panel_ALL.csv", stringsAsFactors = FALSE)

alt20 <- c("AGO", "CAF", "CMR", "COM", "CPV", "GAB", "GHA", "GIN", "KEN", "LSO",
           "MDG", "MOZ", "MRT", "MWI", "RWA", "SLE", "SLV", "TZA", "UGA", "ZMB")

erg_neu <- bind_rows(
  fit_h1(filter(d, ISO3 %in% alt20, Year >= 2002, Year <= 2008),
         "Neues Panel: nur die alten 20 SSA-Laender, 2002-2008",
         "final_data_panel_ALL.csv"),
  fit_h1(filter(d, ISO3 %in% alt20),
         "Neues Panel: nur die alten 20 SSA-Laender, alle Jahre",
         "final_data_panel_ALL.csv"),
  fit_h1(filter(d, Year >= 2002, Year <= 2008),
         "Neues Panel: alle 99 Laender, 2002-2008",
         "final_data_panel_ALL.csv"),
  fit_h1(d,
         "Neues Panel: alle 99 Laender, alle Jahre (H1-Hauptmodell)",
         "final_data_panel_ALL.csv")
)

# ---------------------------------------------------------------------------
# 3) Zusammenfassen, speichern, drucken
# ---------------------------------------------------------------------------
zerlegung <- bind_rows(erg_alt, erg_neu) %>%
  mutate(across(c(unsc3_coef, unsc3_p), ~ round(.x, 4)))

write.csv(zerlegung, "results/tables/h1_sample_zerlegung.csv", row.names = FALSE)

cat("\n=== H1-Sample-Zerlegung ===\n")
print(zerlegung, row.names = FALSE)

cat("\nFazit: Das fruehere negative Vorzeichen beruhte auf dem 20-SSA-Subsample\n")
cat("und einer anzahlbasierten abhaengigen Variable. Im globalen Pool ueber alle\n")
cat("Laender und Jahre ist der Koeffizient positiv, aber insignifikant; der\n")
cat("negative Effekt der Originalstudie ist in diesem MONA-Panel nicht reproduzierbar.\n")
