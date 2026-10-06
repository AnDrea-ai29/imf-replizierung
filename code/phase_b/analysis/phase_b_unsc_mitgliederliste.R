# Länderliste der temporären UNSC-Mitglieder fuer Phase B, analog zu Tabelle 1
# der Originalstudie ("Levels of IMF Conditionality for UNSC Members"):
# two-year terms (Amtszeit) plus vorangegangenes Wahljahr. Das
# Behandlungsfenster unsc3 (Mitgliedschaft in t oder t+1, "election year
# included") entspricht genau Wahljahr + Amtszeit.
#
# Inhalt je Zeile (Land x Amtszeit):
#   Wahljahr (Jahr vor Amtsbeginn), Amtszeit (zweijährig),
#   Behandlungsfenster (unsc3==1),
#   Programm-Jahre im Phase-B-Panel mit Bedingungen pro Quartal
#   (Bedingungen gesamt je Land-Jahr),
#   Quelle der MONA-Zeilen.
#
# Ständige Mitglieder (USA, UK, Frankreich, Russland, China) werden nicht als
# temporäre Mitglieder gelistet. Hinweis zur Abweichung: Das Original setzt
# unsc3 per Handkorrektur auf 0 fuer RUS 1995/1996/1999 und ETH 1992
# (txt2dta7.do, "PLEASE CHECK"); der Phase-B-Nachbau wendet diese Korrekturen
# bewusst nicht auf das Vollpanel an, sodass die drei RUS-Programmjahre im
# Panel als unsc3==1 kodiert sind. Die Liste weist darauf aus.
#
# Output: results/phase_b/tables/phase_b_unsc_mitglieder.csv

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages(library(dplyr))

unsc_path <- "data/processed/unsc_dsv_rule_1946_2026.csv"
panel_path <- "data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
codes_path <- "data/raw/country_codes_wdi-iso-itu.csv"
for (p in c(unsc_path, panel_path, codes_path)) {
  if (!file.exists(p)) stop("Erforderliche Datei fehlt: ", p)
}

unsc <- read.csv(unsc_path, stringsAsFactors = FALSE)
panel <- read.csv(panel_path, stringsAsFactors = FALSE)
codes <- read.csv(codes_path, check.names = FALSE, stringsAsFactors = FALSE)

analysis_start <- 1992L
analysis_end <- 2023L
staendige <- c("USA", "GBR", "FRA", "RUS", "CHN")

name_of <- local({
  idx <- match(codes$code_wdi_iso, codes$code_wdi_iso)
  setNames(codes$wdi_short_name, codes$code_wdi_iso)
})

# ---------------------------------------------------------------------------
# 1) Zweijaehrige Amtszeiten aus der Mitgliedschaftsreihe ableiten
# ---------------------------------------------------------------------------
members <- unsc %>%
  filter(unsc == 1, year >= analysis_start - 1, year <= analysis_end + 1) %>%
  filter(!ISO3 %in% staendige) %>%
  arrange(ISO3, year)

terms <- members %>%
  group_by(ISO3) %>%
  mutate(luecke = cumsum(c(1L, diff(year) != 1L))) %>%
  group_by(ISO3, luecke) %>%
  summarise(amt_von = min(year), amt_bis = max(year), .groups = "drop") %>%
  arrange(amt_von, ISO3)

# Behandlungsfenster unsc3 = Wahljahr bis Amtszeit-Ende
terms$wahljahr <- terms$amt_von - 1L
terms$fenster_von <- pmax(terms$wahljahr, analysis_start)
terms$fenster_bis <- pmax(terms$amt_bis, analysis_start)

# ---------------------------------------------------------------------------
# 2) Programm-Jahre im Panel je Behandlungsfenster zuordnen
# ---------------------------------------------------------------------------
panel_b <- panel %>%
  filter(Year >= analysis_start, Year <= analysis_end) %>%
  select(ISO3, Year, avgcondtype_count, nrcondtype_all, source)

rows <- lapply(seq_len(nrow(terms)), function(i) {
  tr <- terms[i, ]
  prog <- panel_b %>%
    filter(ISO3 == tr$ISO3, Year >= tr$fenster_von, Year <= tr$fenster_bis) %>%
    arrange(Year)
  data.frame(
    ISO3 = tr$ISO3,
    Land = ifelse(!is.na(name_of[[tr$ISO3]]), name_of[[tr$ISO3]], tr$ISO3),
    Wahljahr = tr$wahljahr,
    Amtszeit = paste0(tr$amt_von, "-", tr$amt_bis),
    Behandlungsfenster = paste0(tr$fenster_von, "-", tr$fenster_bis),
    im_Panel = nrow(prog) > 0,
    Programmjahre = if (nrow(prog)) paste(prog$Year, collapse = ", ") else NA_character_,
    Bedingungen_pro_Quartal = if (nrow(prog)) {
      paste(sprintf("%.1f", prog$avgcondtype_count), collapse = ", ")
    } else NA_character_,
    Bedingungen_gesamt = if (nrow(prog)) {
      paste(prog$nrcondtype_all, collapse = ", ")
    } else NA_character_,
    Quelle = if (nrow(prog)) paste(unique(prog$source), collapse = ", ") else NA_character_,
    stringsAsFactors = FALSE
  )
})
tabelle <- bind_rows(rows)

dir.create("results/phase_b/tables", recursive = TRUE, showWarnings = FALSE)
write.csv(tabelle, "results/phase_b/tables/phase_b_unsc_mitglieder.csv",
          row.names = FALSE)

# ---------------------------------------------------------------------------
# 3) Ausgabe und Plausibilitaetspruefungen
# ---------------------------------------------------------------------------
cat("=== Temporaere UNSC-Mitglieder (Wahljahr + Amtszeit), Fenster 1992-2023 ===\n")
cat("Amtszeiten insgesamt:", nrow(tabelle),
    "| davon mit IMF-Programm im Panel:", sum(tabelle$im_Panel), "\n\n")
print(tabelle, row.names = FALSE)

# Abgleich: unsc3==1 im Panel gegen die Liste (nur nicht-staendige Mitglieder)
panel_unsc <- panel %>%
  filter(Year >= analysis_start, Year <= analysis_end, unsc3 == 1)
listed_countries <- unique(tabelle$ISO3)
ohne_liste <- setdiff(unique(panel_unsc$ISO3), listed_countries)
cat("\nPanel-Jahre mit unsc3==1:", nrow(panel_unsc),
    "aus", length(unique(panel_unsc$ISO3)), "Laendern\n")
cat("davon NOTWENDIG temporal (Panel ohne Luecken) zuzuordnen; nicht in der Temporaeren-Liste:",
    if (length(ohne_liste)) paste(ohne_liste, collapse = ", ") else "keine\n")
cat("\nHinweis: Ständige Mitglieder (USA, GBR, FRA, RUS, CHN) sind keine temporären\n")
cat("Mitglieder. RUS-Programmjahre 1995/1996/1999 sind im Panel als unsc3==1 kodiert,\n")
cat("das Original setzt sie per Handkorrektur auf 0 (Abweichung dokumentiert).\n")
cat("\nOutput: results/phase_b/tables/phase_b_unsc_mitglieder.csv\n")
