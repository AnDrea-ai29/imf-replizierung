library(tidyverse)

# 1. Datei einlesen (mit Schrägstrichen)
sc_membership <- read_csv("C:/Users/HP/io/imf-replizierung/data/raw/unsc/DPPA-SCMembership.csv") %>%
  rename(country = security_council_member)

# 2. Nur 2002–2025 filtern
sc_2002_2025 <- sc_membership %>%
  filter(year >= 2002, year <= 2025)

# 3. Afrikanische Länder identifizieren (per Ländername)
african_countries <- c(
  "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi",
  "Cabo Verde", "Cameroon", "Central African Republic", "Chad", "Comoros",
  "Congo", "Democratic Republic of the Congo", "Cote d'Ivoire", "Djibouti",
  "Egypt", "Equatorial Guinea", "Eritrea", "Eswatini", "Ethiopia", "Gabon",
  "Gambia", "Ghana", "Guinea", "Guinea-Bissau", "Kenya", "Lesotho", "Liberia",
  "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco",
  "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda", "Sao Tome and Principe",
  "Senegal", "Seychelles", "Sierra Leone", "Somalia", "South Africa", "South Sudan",
  "Sudan", "Tanzania", "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe"
)

# 4. Nur afrikanische Länder + Jahr extrahieren
sc_africa <- sc_2002_2025 %>%
  filter(country %in% african_countries) %>%
  select(year, country) %>%
  distinct()  # Jedes Land nur einmal pro Jahr

# 5. ISO-3-Codes hinzufügen (Mapping)
country_mapping <- tibble(
  country = c(
    "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi",
    "Cabo Verde", "Cameroon", "Central African Republic", "Chad", "Comoros",
    "Congo", "Democratic Republic of the Congo", "Cote d'Ivoire", "Djibouti",
    "Egypt", "Equatorial Guinea", "Eritrea", "Eswatini", "Ethiopia", "Gabon",
    "Gambia", "Ghana", "Guinea", "Guinea-Bissau", "Kenya", "Lesotho", "Liberia",
    "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco",
    "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda", "Sao Tome and Principe",
    "Senegal", "Seychelles", "Sierra Leone", "Somalia", "South Africa", "South Sudan",
    "Sudan", "Tanzania", "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe"
  ),
  wdicode = c(
    "DZA", "AGO", "BEN", "BWA", "BFA", "BDI", "CPV", "CMR", "CAF", "TCD", "COM",
    "COG", "COD", "CIV", "DJI", "EGY", "GNQ", "ERI", "SWZ", "ETH", "GAB", "GMB",
    "GHA", "GIN", "GNB", "KEN", "LSO", "LBR", "LBY", "MDG", "MWI", "MLI", "MRT",
    "MUS", "MAR", "MOZ", "NAM", "NER", "NGA", "RWA", "STP", "SEN", "SYC", "SLE",
    "SOM", "ZAF", "SSD", "SDN", "TZA", "TGO", "TUN", "UGA", "ZMB", "ZWE"
  )
)

# 6. wdicode hinzufügen
sc_africa <- sc_africa %>%
  left_join(country_mapping, by = "country")

# 7. unsc (temporäre Mitgliedschaft) = 1 für jedes afrikanische Land im UNSC
sc_africa <- sc_africa %>%
  mutate(unsc = 1)

# 8. Vollständiges Panel erstellen (alle afrikanischen Länder × alle Jahre)
all_years <- seq(2002, 2025, by = 1)
all_countries <- country_mapping$wdicode

full_panel <- tibble(
  wdicode = rep(all_countries, each = length(all_years)),
  year = rep(all_years, times = length(all_countries))
) %>%
  left_join(sc_africa, by = c("wdicode", "year")) %>%
  mutate(unsc = ifelse(is.na(unsc), 0, unsc)) %>%
  arrange(wdicode, year)

# 9. unsc_t1 (Mitgliedschaft in t-1) und unsc3 berechnen
full_panel <- full_panel %>%
  group_by(wdicode) %>%
  arrange(year) %>%
  mutate(
    unsc_t1 = lag(unsc, default = 0),
    unsc3 = ifelse(unsc == 1 | unsc_t1 == 1, 1, 0)
  ) %>%
  ungroup()

# 10. Kontrolle: UNSC-Mitglieder pro Jahr anzeigen
full_panel %>%
  filter(unsc == 1) %>%
  count(year, sort = TRUE) %>%
  print(n = 24)

# 11. Speichern
write_csv(full_panel, "C:/Users/HP/io/imf-replizierung/data/raw/unsc/unsc_membership_africa_2002_2025.csv")

# 12. Kontrolle: Welche afrikanischen Länder waren 2002–2025 im UNSC?
full_panel %>%
  filter(unsc == 1) %>%
  distinct(wdicode, country) %>%
  arrange(country) %>%
  print(n = 54)


library(tidyverse)

# 1. UNSC-Daten einlesen (aus Canvas oder lokal)
unsc <- read_csv("raw/unsc/unsc_membership_africa_2002_2025.csv")

# 2. Afrikanische Länder-Codes einlesen
africa_codes <- read_delim("raw/africa/africa_country_codes.csv", delim = ";", col_names = FALSE) %>%
  setNames(c("Global Code", "Global Name", "Region Code", "Region Name",
             "Sub-region Code", "Sub-region Name", "Intermediate Region Code",
             "Intermediate Region Name", "Country or Area", "M49 Code",
             "ISO-alpha2 Code", "ISO-alpha3 Code", "LDC", "LLDC", "SIDS")) %>%
  rename(country = `Country or Area`, wdicode = `ISO-alpha3 Code`) %>%
  select(country, wdicode) %>%
  mutate(country = trimws(country)) # Leerzeichen entfernen

# 3. Abgleich: Fehlende wdicode in UNSC-Tabelle ergänzen
unsc_updated <- unsc %>%
  left_join(africa_codes, by = "country") %>%
  mutate(wdicode = ifelse(is.na(wdicode.x), wdicode.y, wdicode.x)) %>%  # Priorität: UNSC-Tabelle
  select(-wdicode.x, -wdicode.y) %>%  # Doppelte Spalte entfernen
  rename(wdicode = wdicode)  # Umbenennen

# 4. Kontrolle: Welche Länder haben keinen wdicode?
missing_codes <- unsc_updated %>%
  filter(is.na(wdicode)) %>%
  distinct(country)

print(missing_codes)  # Sollte leer sein

# 5. Speichern
write_csv(unsc_updated, "raw/unsc/unsc_membership_africa_2002_2025_updated.csv")

