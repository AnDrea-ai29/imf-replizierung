# Skript: Korrekte UNSC-Daten aus DPPA-SCMembership.csv erstellen

setwd("C:/Users/HP/io/imf-replizierung")
library(tidyverse)

print("Lade DPPA-SCMembership.csv...")
unsc_raw <- read.csv("data/raw/unsc/DPPA-SCMembership.csv", stringsAsFactors = FALSE)

print(paste("Anzahl Zeilen:", nrow(unsc_raw)))
print(paste("Jahre:", min(unsc_raw$year, na.rm = TRUE), "-", max(unsc_raw$year, na.rm = TRUE)))
print(paste("UNSC-Mitglieder:", n_distinct(unsc_raw$security_council_member)))

# Erzeuge vollständiges Panel für alle Länder in allen Jahren
print("\nErzeuge vollständiges Land-Jahr-Panel...")
all_countries <- sort(unique(unsc_raw$security_council_member))
all_years <- 1946:2025

# Erstelle Basis-Panel: Alle Länder × alle Jahre
panel <- expand.grid(
  country = all_countries,
  year = all_years,
  stringsAsFactors = FALSE
)

print(paste("Basis-Panel: ", nrow(panel), " Land-Jahr-Kombinationen"))

# Markiere UNSC-Mitglieder pro Jahr
print("\nMarkiere UNSC-Mitglieder...")
unsc_members <- unsc_raw %>%
  select(country = security_council_member, year, is_member = 1)

panel <- left_join(panel, unsc_members, by = c("country", "year"))
panel$unsc <- ifelse(is.na(panel$is_member), 0, 1)
panel <- panel %>% select(-is_member)

# Berechne unsc_t1 (Mitglied im Vorjahr)
print("Berechne unsc_t1 und unsc3...")
panel <- panel %>%
  group_by(country) %>%
  arrange(year) %>%
  mutate(
    unsc_t1 = lag(unsc, 1, default = 0),
    unsc3 = ifelse(unsc == 1 | unsc_t1 == 1, 1, 0)
  ) %>%
  ungroup()

# ISO3-Codes hinzufügen (falls verfügbar)
# Versuche, ISO3 aus WDI-Daten zu mappen
if (file.exists("data/raw/wdi/wdi_2002_2025_dep.csv")) {
  wdi_data <- read.csv("data/raw/wdi/wdi_2002_2025_dep.csv")
  # Mappe security_council_member zu country in WDI
  # Erstelle Mapping: Ländername -> ISO3
  iso_mapping <- wdi_data %>% select(country, iso3c) %>% distinct()
  
  panel <- left_join(panel, iso_mapping, by = c("country" = "country"))
  names(panel)[names(panel) == "iso3c"] <- "ISO3"
} else {
  print("WDI-Daten nicht gefunden, ISO3-Codes werden nicht gemappt")
}

# Speichern
print("\nSpeichere korrigierte UNSC-Daten...")

# Version 1: Mit Ländernamen
write.csv(panel %>% select(country, year, unsc, unsc_t1, unsc3, ISO3), 
          "data/raw/unsc/unsc_membership_correct.csv", row.names = FALSE)

# Version 2: Nur mit ISO3 (falls verfügbar)
if ("ISO3" %in% names(panel)) {
  iso_panel <- panel %>% filter(!is.na(ISO3)) %>% select(ISO3, year, unsc, unsc_t1, unsc3)
  write.csv(iso_panel, "data/raw/unsc/unsc_membership_ISO3_correct.csv", row.names = FALSE)
  print(paste("✓ unsc_membership_ISO3_correct.csv gespeichert (", nrow(iso_panel), " Zeilen)"))
}

print(paste("✓ unsc_membership_correct.csv gespeichert (", nrow(panel), " Zeilen)"))

# Prüfe UNSC-Variation
print("\n=== PRÜFUNG: UNSC-Variation pro Land (2002-2008) ===")
unsc_check <- panel %>%
  filter(year >= 2002 & year <= 2008) %>%
  group_by(country) %>%
  summarise(
    unsc_values = paste(sort(unique(unsc)), collapse = ", "),
    unsc_varies = length(unique(unsc)) > 1
  ) %>%
  filter(unsc_varies)

print(paste("Länder mit UNSC-Variation (2002-2008):", nrow(unsc_check)))
if (nrow(unsc_check) > 0) {
  print(head(unsc_check$country, 20))
} else {
  print("FEHLER: Keine Länder mit UNSC-Variation gefunden!")
}
