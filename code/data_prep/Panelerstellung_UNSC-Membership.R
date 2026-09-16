## Panel-Datensatz UNSC-Mitgliedschaft für alle Länder (2002-2025)

library(tidyverse)

# 1. UNSC-Rohdaten einlesen (DPPA-SCMembership.csv)
sc_membership <- read_csv("data/raw/unsc/DPPA-SCMembership.csv") %>%
  rename(country = security_council_member)

# 2. Zeitraum filtern
sc_2002_2025 <- sc_membership %>% filter(year >= 2002, year <= 2025)

# 3. ISO-3-Codes für ALLE Länder einlesen
country_mapping <- read.csv("data/raw/country_codes_wdi-iso-itu.csv") %>%
  select(wdi_short_name, iso_3ltr) %>%
  rename(country = wdi_short_name, wdicode = iso_3ltr)

# 4. UNSC-Daten mit ISO-Codes verknüpfen + Permanente Mitglieder manuell ergänzen
sc_all <- sc_2002_2025 %>%
  left_join(country_mapping, by = "country") %>%
  mutate(
    wdicode = coalesce(wdicode, case_when(
      country == "United States of America" ~ "USA",
      country == "United Kingdom of Great Britain and Northern Ireland" ~ "GBR",
      country == "Russia" ~ "RUS",
      country == "Chinese People's Republic" ~ "CHN",
      country == "France" ~ "FRA",
      TRUE ~ wdicode
    ))
  ) %>%
  mutate(unsc = 1) %>%  # Jeder Eintrag = Mitgliedschaft
  select(wdicode, country, year, unsc) %>%
  distinct()  # Jedes Land nur einmal pro Jahr

# 5. VOLLSTÄNDIGES PANEL erstellen (alle Länder × alle Jahre)
all_years <- seq(2002, 2025, by = 1)
all_countries <- country_mapping$wdicode

full_panel <- tibble(
  wdicode = rep(all_countries, each = length(all_years)),
  year = rep(all_years, times = length(all_countries))
) %>%
  left_join(sc_all, by = c("wdicode", "year")) %>%
  mutate(unsc = ifelse(is.na(unsc), 0, unsc)) %>%  # Nicht-Mitglieder = 0
  arrange(wdicode, year)

# 6. unsc3 berechnen (Mitglied in t ODER t-1)
full_panel <- full_panel %>%
  group_by(wdicode) %>%
  arrange(year) %>%
  mutate(
    unsc_t1 = lag(unsc, default = 0),
    unsc3 = ifelse(unsc == 1 | unsc_t1 == 1, 1, 0)
  ) %>%
  ungroup()

# 7. Speichern
write_csv(full_panel,
          "data/raw/unsc/unsc_membership_2002_2025.csv",
          na = "")
