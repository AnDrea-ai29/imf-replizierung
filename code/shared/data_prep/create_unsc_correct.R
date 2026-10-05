# Notizblatt für ein Replikationsskript
#
# ## 1) Skriptname
# - Datei: code/shared/data_prep/create_unsc_correct.R
# - Zweck: Korrigiert die UNSC-Mitgliedschaftsdaten aus DPPA-SCMembership.csv,
#   mappt DPPA-Namen auf ISO3-Codes und baut ein vollständiges Panel für alle
#   WDI-Länder auf.
# - Wichtig für: Replikations-Pipeline, globale Panelanalyse, Rechte/UNSC-Variablen
#   in MONA/Conditionality-Analysen.
#
# ## 2) Ziel des Skripts
# - Dieses Skript korrigiert falsche oder fehlende Zuordnungen zwischen
#   DPPA-UNSC-Namen und ISO3-Codes.
# - Es ist nötig, weil Mitgliedschaftsdatensätze zwar vollständig erscheinen,
#   aber bei historischen oder abweichenden Ländernamen im Namens-Match nicht
#   sauber auf WDI-Länder fallen.
# - Das Problem gelöst: 37 Länder fehlten im Panel; echte UNSC-Mitglieder wurden
#   als "kein Mitglied" (0) oder als NA kodiert, obwohl eine Mitgliedschaft
#   im betrachteten Zeitraum zutraf.
#
# ## 3) Input-Dateien
# - Eingabe 1: data/raw/unsc/DPPA-SCMembership.csv
# - Eingabe 2: data/raw/wdi/wdi_2002_2025_dep.csv
#
# Wichtige Fragen:
# - Welche Datei wird zuerst gelesen? Zuerst die DPPA-UNSC-Datei, dann die WDI-
#   Länder-Namensliste als Referenz.
# - Gibt es Joins / Merges? Ja, ein Namens-Match und ein lateraler Join auf ISO3
#   und Jahr.
# - Sind die Variablen schon in der richtigen Form? Der DPPA-Datensatz braucht
#   eine robuste ISO3-Zuordnung, die WDI-Datei liefert die Standardnamen/ISO3.
#
# ## 4) Output-Dateien
# - Output 1: data/raw/unsc/unsc_membership_correct.csv
# - Output 2: data/raw/unsc/unsc_membership_ISO3_correct.csv
#
# Wichtige Fragen:
# - Welche Datei entsteht hier? Zwei korrigierte UNSC-Panel-Dateien.
# - Wofür wird sie später verwendet? Als Grundlage für UNSC-Mitgliedschafts-
#   Variablen im globalen Replikationspanel.
# - Ist das ein Zwischenprodukt oder ein Endergebnis? Es ist ein wichtiges
#   Zwischenprodukt, das in späteren Analyseschritten weiterverarbeitet wird.
#
# ## 5) Zentrale Logik
# 1. DPPA- und WDI-Dateien werden eingelesen.
# 2. Ein exakter Namens-Match zwischen DPPA-Namen und WDI-Ländername wird gebaut.
# 3. Eine Override-Tabelle behandelt historische bzw. abweichende Namensformen
#    wie "Bolivia (Plurinational State of)" oder "Türkiye".
# 4. Aus den Mitgliedschaftszeilen entsteht ein eindeutiges ISO3 x Jahr-Panel.
# 5. Für alle WDI-Länder wird ein vollständiges Jahr-Panel 1946:2025 erzeugt,
#    wobei Nicht-Mitgliedschaft als 0 kodiert wird.
# 6. Ein Lag- und unsc3-Flag wird gebildet, damit ein Land in den Jahren nach
#    einem UNSC-Jahr weiterhin als behandelt gilt.
# 7. Die korrigierten Datensätze werden gespeichert und eine kurze Diagnostik
#    zeigt die Mitgliedsjahre im Analysezeitraum.
#
# ## 6) Kritische Begriffe
# - Gate: Theoretischer oder empirischer "Betrags-/Behandlungs-Schnitt" im
#   Replikationsdesign; hier die UNSC-Mitgliedschaft als Schockvariable.
# - Granularität: Datensätze werden auf ISO3 x Jahr-Ebene modelliert.
# - unsc3: Konstruiert als 1, wenn Land im aktuellen Jahr oder im Vorjahr UNSC-
#   Mitglied war; wird für die empirische Behandlung genutzt.
# - Review-Join: Spätere Verknüpfung mit WDI- oder MONA-Daten, die Datenqualitäts-
#   und Namensprüfungen umfasst.
# - resource_dep: Rohstoffabhängigkeit; in späteren Skripten mit UNSC-Interaktion
#   verwendet.
# - Rohstoff-Klassifikation: Ein Mapping, das bestimmte Bedingungen oder
#   Programmkategorien nach Rohstoff-/Stabilisierungstypen einordnet.
#
# ## 7) Wichtige Formeln / Variablen
# - Hauptmodell: Behandlung durch unsc3 und Nicht-Mitgliedschaft, später in
#   Ländermodellen mit FE und Kontrollvariablen.
# - Interaktion: unsc3 × resource_dep (später in H2/H4 genutzt).
# - abhängige Variable: avgcondtype_count oder avgcondtype_share im späteren
#   Panel.
# - Kontrollvariablen: WDI- und andere Makrovariablen, die in den folgenden
#   Replikationsschritten joins werden.
#
# ## 8) Was ich hier verstanden habe
# - Das Skript behebt ein klassisches Matching-Problem: Namen aus der DPPA-
#   Quelldatei stimmen nicht exakt mit WDI-Namen überein.
# - Durch die Override-Tabelle und das vollständige Panel werden echte
#   Mitgliedsjahre sauber erfasst und Nicht-Mitgliedschaften korrekt als 0
#   kodiert.
# - Die spätere Modellierung profitiert davon, weil der Analyse-Join mit einer
#   konsistenten ISO3 x Jahr-Struktur stattfindet.
# - Ohne diese Korrektur würden falsche NAs oder fehlende Länder das Ergebnis
#   in Richtung verlässlicher aber unplausibler Koeffizienten verzerren.
#
# ## 9) Das ist noch unklar
# 1. Wie viele historische DPPA-Mitgliedschaften werden bewusst verworfen?
# 2. Welche Länder fallen nur wegen des Overrides in die korrigierte Zuordnung?
# 3. Wie robust ist das Namensmapping gegenüber zukünftigen DPPA-Updates?
#
# ## 10) Kurzfazit
# - Dieses Skript ist wichtig, weil es die Grundlage für ein konsistentes,
#   globales UNSC-Panel bildet und damit spätere Replikationsmodelle erst
#   zuverlässig machen kann.
#
# ---------------------------------------------------------------------------
# 0) Setup
# ---------------------------------------------------------------------------
setwd("C:/Users/HP/io/imf-replizierung")
library(tidyverse)

print("Lade DPPA-SCMembership.csv...")
unsc_raw <- read.csv("data/raw/unsc/DPPA-SCMembership.csv", stringsAsFactors = FALSE)
wdi_data <- read.csv("data/raw/wdi/wdi_2002_2025_dep.csv", stringsAsFactors = FALSE)

print(paste("DPPA-Zeilen:", nrow(unsc_raw),
            "| Jahre:", min(unsc_raw$year), "-", max(unsc_raw$year),
            "| Laender:", n_distinct(unsc_raw$security_council_member)))

# ---------------------------------------------------------------------------
# 1) Namens-Mapping DPPA -> ISO3
# ---------------------------------------------------------------------------
# 1a: exakter Match ueber WDI-Laendernamen
name_to_iso <- wdi_data %>%
  select(country, iso3c) %>%
  distinct()

# 1b: Override-Tabelle fuer DPPA-spezifische Schreibweisen
# (historische Gebilde ohne Nachfolger im Analysezeitraum bleiben NA)
name_overrides <- c(
  "Bolivia (Plurinational State of)" = "BOL",
  "Congo" = "COG",
  "Democratic Republic of the Congo" = "COD",
  "Egypt" = "EGY",
  "Gambia" = "GMB",
  "German FR (German Federal Republic)" = "DEU",
  "Iran (Islamic Republic of)" = "IRN",
  "Kyrgyzstan" = "KGZ",
  "Republic of Korea" = "KOR",
  "Saint Vincent and the Grenadines" = "VCT",
  "Slovakia" = "SVK",
  "Somalia" = "SOM",
  "T\u00fcrkiye" = "TUR",
  "Ukrainian SSR (Ukrainian Soviet Socialist Republic)" = "UKR",
  "United Arab Republic" = "EGY",
  "United Kingdom of Great Britain and Northern Ireland" = "GBR",
  "United Republic of Tanzania" = "TZA",
  "United States of America" = "USA",
  "Venezuela (Bolivarian Republic of)" = "VEN",
  "Yemen" = "YEM"
)

dppa_names <- sort(unique(unsc_raw$security_council_member))
unmatched <- setdiff(dppa_names, c(name_to_iso$country, names(name_overrides)))
if (length(unmatched) > 0) {
  cat("WARNUNG: DPPA-Namen ohne ISO3-Zuordnung (werde verworfen):\n",
      paste(unmatched, collapse = ", "), "\n")
}

unsc_raw <- unsc_raw %>%
  mutate(
    ISO3 = ifelse(security_council_member %in% name_to_iso$country,
                  name_to_iso$iso3c[match(security_council_member, name_to_iso$country)],
                  name_overrides[security_council_member]),
    ISO3 = ifelse(is.na(ISO3), NA_character_, ISO3)
  )

dropped_hist <- unsc_raw %>% filter(is.na(ISO3))
cat("Verworfene historische Mitgliedschaften (z.B. USSR, Jugoslawien):",
    nrow(dropped_hist), "Zeilen\n")

members <- unsc_raw %>%
  filter(!is.na(ISO3)) %>%
  distinct(ISO3, year) %>%
  mutate(is_member = 1)

# ---------------------------------------------------------------------------
# 2) Vollstaendiges Panel: alle WDI-Laender x 1946-2025
# ---------------------------------------------------------------------------
all_iso <- sort(unique(wdi_data$iso3c))
max_year <- max(unsc_raw$year, na.rm = TRUE)
panel <- expand.grid(ISO3 = all_iso, year = 1946:max_year, stringsAsFactors = FALSE)

panel <- panel %>%
  left_join(members, by = c("ISO3", "year")) %>%
  mutate(unsc = ifelse(is.na(is_member), 0, 1)) %>%
  select(-is_member) %>%
  arrange(ISO3, year) %>%
  group_by(ISO3) %>%
  mutate(
    unsc_t1 = lag(unsc, 1, default = 0),
    unsc3 = ifelse(unsc == 1 | unsc_t1 == 1, 1, 0)
  ) %>%
  ungroup()

# ---------------------------------------------------------------------------
# 3) Speichern
# ---------------------------------------------------------------------------
out <- panel %>%
  left_join(name_to_iso, by = c("ISO3" = "iso3c")) %>%
  rename(country = country)

write.csv(out %>% select(country, ISO3, year, unsc, unsc_t1, unsc3),
          "data/raw/unsc/unsc_membership_correct.csv", row.names = FALSE)
write.csv(panel, "data/raw/unsc/unsc_membership_ISO3_correct.csv", row.names = FALSE)

cat("\n✓ unsc_membership_ISO3_correct.csv gespeichert (", nrow(panel), "Zeilen )\n")
cat("✓ unsc_membership_correct.csv gespeichert\n")

# ---------------------------------------------------------------------------
# 4) Diagnostik
# ---------------------------------------------------------------------------
cat("\n=== PRÜFUNG: UNSC-Mitgliedsjahre im Analysezeitraum ===\n")
check <- panel %>%
  filter(year >= 2002, year <= 2025) %>%
  group_by(ISO3) %>%
  summarise(
    n_member_years = sum(unsc),
    member_years = paste(year[unsc == 1], collapse = ","),
    .groups = "drop"
  ) %>%
  filter(n_member_years > 0) %>%
  arrange(ISO3)

cat("Laender mit UNSC-Mitgliedschaft 2002-2025:", nrow(check), "\n")
print(as.data.frame(check), row.names = FALSE)
