setwd("C:/Users/HP/io/imf-replizierung")
library(tidyverse)
library(readr)
library(readxl)

# Ländercodes
ssa_countries <- c("AGO", "CAF", "CMR", "COM", "CPV", "GAB", "GHA", "GIN", "KEN", "LSO",
                   "MDG", "MOZ", "MRT", "MWI", "RWA", "SLE", "SLV", "TZA", "UGA", "ZMB")

# Basis-Panel
all_years <- expand.grid(ISO3 = ssa_countries, Year = 2002:2025, stringsAsFactors = FALSE)

# UNSC-Daten
unsc_ssa_correct <- read.csv("data/processed/unsc_ssa_correct.csv", stringsAsFactors = FALSE)
panel_with_unsc <- merge(all_years, unsc_ssa_correct, by = c("ISO3", "Year"), all.x = TRUE)
panel_with_unsc[c("unsc", "unsc_t1", "unsc3")] <- lapply(panel_with_unsc[c("unsc", "unsc_t1", "unsc3")], function(x) ifelse(is.na(x), 0, x))

# MONA auf Arrangement-Ebene
mona_ssa_mea <- read.csv("data/processed/mona_ssa_mea.csv", stringsAsFactors = FALSE)
mona_arrangements <- mona_ssa_mea %>%
  rename(Year = Approval.Year, ArrangementID = `Arrangement.Number`) %>%
  mutate(
    avgcondtype_all = ifelse(is.na(nrcondtype_all), 0, nrcondtype_all / nrquarters),
    nrcondtype_all = ifelse(is.na(nrcondtype_all), 0, nrcondtype_all)
  ) %>%
  select(ISO3, Year, ArrangementID, avgcondtype_all, nrcondtype_all)

for (col in c("avgcondtype_all", "nrcondtype_all")) {
  if (col %in% names(mona_arrangements)) mona_arrangements[[col]][is.na(mona_arrangements[[col]])] <- 0
}
print(paste("MONA Arrangements:", nrow(mona_arrangements)))

# WDI-Daten
wdi_ssa_mea <- read.csv("data/processed/wdi_ssa_mea.csv", stringsAsFactors = FALSE)

# Klassifizierung
mona_raw <- read_excel("data/raw/mona/Combined_ISO.xlsx")
mona_ssa <- mona_raw %>%
  filter(iso_3ltr %in% ssa_countries) %>%
  rename(ISO3 = iso_3ltr)

rohstoff_keywords <- c("fuel", "mineral", "oil", "gas", "extractive", "petroleum")
stabil_keywords <- c("fiscal", "inflation", "budget", "debt", "deficit")

conditions_classified <- mona_ssa %>%
  mutate(
    desc_lower = tolower(`Description`),
    rohstoff_cond = ifelse(str_detect(desc_lower, paste(rohstoff_keywords, collapse = "|")), 1, 0),
    stabil_cond = ifelse(str_detect(desc_lower, paste(stabil_keywords, collapse = "|")), 1, 0)
  )

cond_summary <- conditions_classified %>%
  group_by(ISO3, `Arrangement Number`) %>%
  summarise(
    rohstoff_cond = sum(rohstoff_cond, na.rm = TRUE),
    stabil_cond = sum(stabil_cond, na.rm = TRUE),
    rohstoff_cond_share = mean(rohstoff_cond, na.rm = TRUE),
    stabil_cond_share = mean(stabil_cond, na.rm = TRUE)
  )

# Finales Panel
final_panel <- panel_with_unsc %>%
  left_join(mona_arrangements, by = c("ISO3", "Year")) %>%
  left_join(cond_summary, by = c("ISO3", "ArrangementID" = "Arrangement Number")) %>%
  left_join(wdi_ssa_mea %>% rename(ISO3 = country_code, Year = year), by = c("ISO3", "Year")) %>%
  mutate(
    Rohstoffabhaengigkeit = FuelExportPct + MineralExportPct,
    unsc3 = ifelse(is.na(unsc3), 0, unsc3)
  )

final_panel$rohstoff_cond[is.na(final_panel$rohstoff_cond)] <- 0
final_panel$stabil_cond[is.na(final_panel$stabil_cond)] <- 0
final_panel$rohstoff_cond_share[is.na(final_panel$rohstoff_cond_share)] <- 0
final_panel$stabil_cond_share[is.na(final_panel$stabil_cond_share)] <- 0

write.csv(final_panel, "data/processed/final_data_arrangement_level.csv", row.names = FALSE)

print("\n=== ERGEBNIS ===")
print(paste("Beobachtungen:", nrow(final_panel)))
print(paste("Arrangements:", length(unique(final_panel$ArrangementID))))
print(final_panel %>% group_by(ISO3) %>% summarise(n_obs = n()))
