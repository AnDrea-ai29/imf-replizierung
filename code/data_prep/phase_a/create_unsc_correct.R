# Skript: Korrekte UNSC-Daten aus DPPA-SCMembership.csv erstellen
#
# Fix gegenueber der alten Version:
# - DPPA-Laendernamen wie "Bolivia (Plurinational State of)", "United Republic
#   of Tanzania", "Tuerkiye" usw. matchen nicht exakt auf WDI-Namen und fielen
#   bisher aus der ISO-Datei heraus (37 Panel-Laender fehlten komplett,
#   darunter tatsaechliche UNSC-Mitglieder im Zeitraum).
# - Jetzt: exakter WDI-Match + Override-Tabelle; Rest wird gemeldet.
# - Panel universell ueber alle WDI-Laender: Laender ohne Mitgliedschaft
#   bekommen unsc = 0 (korrekt), nicht NA.

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
