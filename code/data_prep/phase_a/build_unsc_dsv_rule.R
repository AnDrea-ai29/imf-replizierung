# UNSC-Mitgliedschaftsserie nach DSV-Regel (Dreher/Sturm/Vreeland, JCR 2015)
# fuer das vollstaendige Laender-Jahr-Panel.
#
# Regel (verifiziert gegen das Original, s. rebuild_conditionality_1992_2008.R):
#   unsc3_dsv(t) = 1 wenn temporäres UNSC-Mitglied in Jahr t ODER in Jahr t+1
#   ("election year included", s. JCR_DSV_Table1.doh).
# Handkorrekturen des Originals (AETH 1992, RUS 1995/1996/1999) betreffen nur
# dessen Programm-Subsample und werden NICHT auf das Vollpanel angewandt.
#
# Quelle: data/raw/unsc/unsc_membership_ISO3_correct.csv (DPPA, Vollpanel)
# Output: data/processed/unsc_dsv_rule_1946_2026.csv (ISO3, year, unsc, unsc3_dsv)

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages(library(dplyr))

raw <- read.csv("data/raw/unsc/unsc_membership_ISO3_correct.csv",
                stringsAsFactors = FALSE)

if (!all(c("ISO3", "year", "unsc") %in% names(raw))) {
  stop("Erwartete Spalten ISO3/year/unsc fehlen in unsc_membership_ISO3_correct.csv")
}

out <- raw %>%
  select(ISO3, year, unsc) %>%
  arrange(ISO3, year) %>%
  group_by(ISO3) %>%
  mutate(unsc_tplus1 = lead(unsc),
         unsc3_dsv = as.integer((unsc == 1) |
                                (!is.na(unsc_tplus1) & unsc_tplus1 == 1))) %>%
  ungroup() %>%
  select(-unsc_tplus1)

write.csv(out, "data/processed/unsc_dsv_rule_1946_2026.csv", row.names = FALSE)
cat("UNSC-Serie nach DSV-Regel:", nrow(out), "Zeilen,",
    length(unique(out$ISO3)), "Laender, Jahre",
    min(out$year), "-", max(out$year), "->",
    "data/processed/unsc_dsv_rule_1946_2026.csv\n")

# Konsistenz mit dem Original: Programm-Jahre mit unsc3==1 (Soll: 18 Faelle
# lt. JCR_DSV_Table1.log, ohne die Handkorrekturen ETH 1992 / RUS)
cat("Laender-Jahre mit unsc3_dsv==1 im Zeitraum 1992-2008:",
    sum(out$unsc3_dsv == 1 & out$year >= 1992 & out$year <= 2008), "\n")
