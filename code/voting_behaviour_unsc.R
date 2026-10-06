## Voting-Verhalten der UNSC-Mitglieder (lauffaehig, korrigiert 2026-10-05)
##
## =====================================================================
## UNSC-Voting-Daten: Einlesen (Schritt 1) und Aufbereitung (Schritt 2)
## Quelle: UN Digital Library / Dag Hammarskjold Library
## Dataset: "United Nations Security Council Voting Data", Version 6
##   (2026-02-06): Resolution 1 (1946) bis Resolution 2815 (30.01.2026),
##   41.349 Eintraege; hier gefiltert auf 1990-01-01 bis 2025-12-31.
##
## Wichtige Einschraenkungen des Datensatzes (Metadata-Datei):
##   - NUR angenommene Resolutionen; Abstimmungen ueber Paragraphen und
##     gescheiterte Entwuerfe fehlen (Selection-on-Outcome-Bias fuer
##     Voting-Analysen).
##   - Bei Annahme ohne nennenswerte Abstimmung ("by acclamation") werden
##     alle Stimmen als "Y" gefuehrt.
##   - ms_vote: Y = Ja, N = Nein, A = Enthaltung, X = non-voting (als NA).
##
## Spalten des CSV (verifiziert):
##   undl_id, ms_code, ms_name, permanent_member, ms_vote, date, resolution,
##   draft, meeting, description, agenda, subjects, vote_note, total_*,
##   modality, undl_link
## ms_code ist bereits ein Dreibuchstabencode; nur SUN (USSR) und
## YMD (Sued-Jemen) sind keine ISO3-Codes und werden auf Nachfolgestaaten
## abgebildet (SUN -> RUS, YMD -> YEM), analog zur Konvention des
## Projekt-Crosswalks (YSR -> SRB, ROM -> ROU, ZAR -> COD).
##
## =====================================================================

# ---- 0. Pakete ------------------------------------------------------
# install.packages(c("tidyverse", "countrycode"))
library(tidyverse)
library(countrycode)   # Validierung der Codes gegen ISO3c

# =====================================================================
# SCHRITT 1: Einlesen (Datei liegt bereits lokal; Download-Link im Kopf)
# =====================================================================

setwd("C:/Users/HP/io/imf-replizierung")

sc_csv_path <- "data/raw/unsc/voting/2026_02_06_sc_voting.csv"
if (!file.exists(sc_csv_path)) {
  stop("UNSC-Voting-CSV fehlt: ", sc_csv_path,
       " (Download: https://digitallibrary.un.org/record/4055387)")
}

raw <- read_csv(sc_csv_path, show_col_types = FALSE)

# =====================================================================
# SCHRITT 2: Filtern & Aufbereitung
# =====================================================================

# ---- 2.1 Jahresfilter ------------------------------------------------
# Analysefenster hier: 1990-2025. Hinweis: Stubbs et al. (2020) nutzen
# 1990-2014; fuer deren Replikation das Fenster entsprechend verengen.
zeitraum_von <- as.Date("1990-01-01")
zeitraum_bis <- as.Date("2025-12-31")

sc <- raw %>%
  mutate(date = as.Date(date)) %>%
  filter(date >= zeitraum_von, date <= zeitraum_bis)

# ---- 2.2 Codes harmonisieren ----------------------------------------
# ms_code ist bereits ISO3 (verifiziert), Ausnahmen per Override:
code_overrides <- c("SUN" = "RUS",   # UdSSR -> Russische Foederation
                    "YMD" = "YEM")   # Sued-Jemen -> Jemen (Vereinigung 1990)

sc <- sc %>%
  mutate(iso3 = if_else(ms_code %in% names(code_overrides),
                        unname(code_overrides[ms_code]),
                        ms_code))

# Validierung 1: nicht-ISO3-Codes duerfen nur die beiden Overrides sein
ungueltig <- sc %>%
  filter(is.na(countrycode(iso3, origin = "iso3c", destination = "iso3c"))) %>%
  distinct(ms_code, ms_name)
if (nrow(ungueltig) > 0) {
  cat("WARNUNG: nicht zuordenbare Codes:\n")
  print(as.data.frame(ungueltig), row.names = FALSE)
}

# Validierung 2: alle iso3 muessen im Projekt-UNSC-Vollpanel bekannt sein
unsc_panel_laender <- read.csv(
  "data/raw/unsc/unsc_membership_ISO3_correct.csv",
  stringsAsFactors = FALSE
)$ISO3 |> unique()
unbekannt <- setdiff(unique(sc$iso3), unsc_panel_laender)
if (length(unbekannt) > 0) {
  cat("WARNUNG: Codes nicht im Projekt-UNSC-Panel bekannt:",
      paste(unbekannt, collapse = ", "), "\n")
}

# ---- 2.3 Votes kodieren -----------------------------------------------
# Y = 1 (Ja), N = -1 (Nein), A = 0 (Enthaltung),
# X = non-voting -> NA (NICHT Enthaltung); leer -> NA
sc <- sc %>%
  mutate(vote = case_when(
    toupper(ms_vote) == "Y" ~  1,
    toupper(ms_vote) == "N" ~ -1,
    toupper(ms_vote) == "A" ~  0,
    toupper(ms_vote) == "X" ~ NA_real_,
    is.na(ms_vote)          ~ NA_real_,
    TRUE                    ~ NA_real_))

cat("Votes nach Kategorie (X als NA):\n")
print(sc %>% count(vote_kat = toupper(ms_vote), na_ueberall = is.na(vote)))

# ---- 2.4 Wide-Format: Roll-Call-Matrix ---------------------------------
# Zeilen = Resolution, Spalten = Mitglied (ISO3), Zelle = Stimme.
# Duplikate je Resolution x Land entschaerfen (Mehrheit = Ja-Stimme):
vote_matrix <- sc %>%
  filter(!is.na(iso3)) %>%
  select(resolution, date, iso3, vote) %>%
  pivot_wider(names_from = iso3,
              values_from = vote,
              values_fn   = ~ if (all(is.na(.x))) NA_real_ else max(.x, na.rm = TRUE))

# ---- 2.5 Kennzahlen pro Land -------------------------------------------
state_summary <- sc %>%
  filter(!is.na(iso3)) %>%
  group_by(iso3) %>%
  summarise(n_res      = n_distinct(resolution),
            n_yes      = sum(vote ==  1, na.rm = TRUE),
            n_no       = sum(vote == -1, na.rm = TRUE),
            n_abstain  = sum(vote ==  0,  na.rm = TRUE),
            n_non_voting = sum(toupper(ms_vote) == "X"),
            share_yes  = sum(vote == 1, na.rm = TRUE) /
                         sum(!is.na(vote)),
            .groups = "drop") %>%
  arrange(desc(n_res))

# ---- 2.6 Output ---------------------------------------------------------
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
write.csv(vote_matrix,
          "data/processed/unsc_voting_rollcall_1990_2025.csv",
          row.names = FALSE)
write.csv(state_summary,
          "data/processed/unsc_voting_state_summary.csv",
          row.names = FALSE)

cat("\nRoll-Call-Matrix:", nrow(vote_matrix), "Resolutionen x",
    ncol(vote_matrix) - 2, "Laender\n")
cat("Land-Summary (Anfang):\n")
print(head(as.data.frame(state_summary), 10), row.names = FALSE)
cat("\nOutput:\n")
cat("- data/processed/unsc_voting_rollcall_1990_2025.csv\n")
cat("- data/processed/unsc_voting_state_summary.csv\n")

