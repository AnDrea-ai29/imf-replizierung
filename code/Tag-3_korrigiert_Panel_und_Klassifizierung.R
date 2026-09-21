setwd("C:/Users/HP/io/imf-replizierung")
# Tag 3: Korrigierte Panel-Erstellung + Inhaltsanalyse der Bedingungen
# Ziel: Vollständiges Panel für 20 SSA-Länder (2002-2025) mit UNSC, MONA und WDI Daten

# Arbeitsverzeichnis setzen
setwd("C:/Users/HP/io/imf-replizierung")

# Pakete laden
library(tidyverse)
library(readr)
library(readxl)
library(stringr)

# ============================================================================
# TEIL 1: Vollständiges Panel erstellen
# ============================================================================

# 1.1 Ländercodes für SSA (20 Länder)
ssa_countries <- c(
  "AGO", "CAF", "CMR", "COM", "CPV",
  "GAB", "GHA", "GIN", "KEN", "LSO",
  "MDG", "MOZ", "MRT", "MWI", "RWA",
  "SLE", "SLV", "TZA", "UGA", "ZMB"
)

# 1.2 Alle Land-Jahr-Kombinationen erstellen (2002-2025)
print("1. Erstelle vollständiges Panel...")
all_years <- expand.grid(
  ISO3 = ssa_countries,
  Year = 2002:2025,
  stringsAsFactors = FALSE
)
print(paste("Panel-Größe:", nrow(all_years), "Beobachtungen"))

# 1.3 UNSC-Daten laden und zuordnen
unsc_ssa_correct <- read.csv("data/processed/unsc_ssa_correct.csv", stringsAsFactors = FALSE)
print("\nUNSC-Daten geladen:")
print(unsc_ssa_correct)

# UNSC-Daten zum Panel mergen (alle Land-Jahr-Kombis behalten)
panel_with_unsc <- merge(
  all_years,
  unsc_ssa_correct,
  by = c("ISO3", "Year"),
  all.x = TRUE
)

# Fehlende UNSC-Werte durch 0 ersetzen (keine Mitgliedschaft)
panel_with_unsc$unsc[is.na(panel_with_unsc$unsc)] <- 0
panel_with_unsc$unsc_t1[is.na(panel_with_unsc$unsc_t1)] <- 0
panel_with_unsc$unsc3[is.na(panel_with_unsc$unsc3)] <- 0

print("\nUNSC-Länder im Panel:")
print(unique(panel_with_unsc$ISO3[panel_with_unsc$unsc3 == 1]))

# 1.4 MONA-Daten aggregieren (durchschnittlich pro Land-Jahr)
print("\n2. MONA-Daten aggregieren...")
mona_ssa_mea <- read.csv("data/processed/mona_ssa_mea.csv", stringsAsFactors = FALSE)

# Nur relevante Spalten auswählen und nach Land-Jahr aggregieren
mona_agg <- mona_ssa_mea %>%
  # Filter: Nur EFF_SBA Arrangements (wie Originalstudie)
  filter(`Arrangement.Type` %in% c("SBA", "EFF", "PRGF-EFF", "ECF-EFF", "SBA-SCF") |
         `Program.Type` %in% c("SBA", "EFF")) %>%
  
  # Bedingungstypen klassifizieren
  mutate(
    condtype_pc = ifelse(`Key.Code` %in% c("SPC", "PC", "SAC"), 1, 0),
    condtype_pa = ifelse(`Key.Code` == "PA", 1, 0),
    condtype_sb = ifelse(`Key.Code` == "SB", 1, 0)
  ) %>%
  # Datums-Spalten konvertieren und Quartale vor dem Gruppieren berechnen
  mutate(
    `Approval.date` = as.Date(`Approval.date`, format = "%d-%b-%y"),
    `Initial.End.Date` = as.Date(`Initial.End.Date`, format = "%d-%b-%y"),
    `Revised.End.Date` = as.Date(`Revised.End.Date`, format = "%d-%b-%y"),
    nrdays = as.numeric(difftime(
      coalesce(`Revised.End.Date`, `Initial.End.Date`), 
      `Approval.date`, 
      units = "days"
    )),
    nrquarters = round(nrdays / 90, 0)
  ) %>%
  
  # Nach Arrangement Number und Quartal gruppieren
  group_by(`ISO3`, `Year`, `Arrangement.Number`) %>%
  summarise(
    nrcondtype_pc = sum(condtype_pc, na.rm = TRUE),
    nrcondtype_pa = sum(condtype_pa, na.rm = TRUE),
    nrcondtype_sb = sum(condtype_sb, na.rm = TRUE),
    nrcondtype_all = nrcondtype_pc + nrcondtype_pa + nrcondtype_sb,
    nrdays = first(nrdays),
    nrquarters = first(nrquarters),
    .groups = "drop"
  ) %>%
  # Durch Quartale teilen
  mutate(
    avgcondtype_all = nrcondtype_all / nrquarters,
    avgcondtype_pc = nrcondtype_pc / nrquarters,
    avgcondtype_pa = nrcondtype_pa / nrquarters,
    avgcondtype_sb = nrcondtype_sb / nrquarters
  ) %>%
  
  # Nach Land-Jahr aggregieren (Durchschnitt aller Arrangements pro Jahr)
  group_by(ISO3, Year) %>%
  summarise(
    avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE),
    avgcondtype_pc = mean(avgcondtype_pc, na.rm = TRUE),
    avgcondtype_pa = mean(avgcondtype_pa, na.rm = TRUE),
    avgcondtype_sb = mean(avgcondtype_sb, na.rm = TRUE),
    nrcondtype_all = sum(nrcondtype_all, na.rm = TRUE),
    nrcondtype_pc = sum(nrcondtype_pc, na.rm = TRUE),
    nrcondtype_pa = sum(nrcondtype_pa, na.rm = TRUE),
    nrcondtype_sb = sum(nrcondtype_sb, na.rm = TRUE)
  )

print("Aggregierte MONA-Daten:")
print(head(mona_agg))
print(paste("Anzahl einzigartiger Land-Jahr-Kombinationen:", nrow(mona_agg)))

# 1.5 MONA-Daten zum Panel mergen
panel_with_mona <- merge(
  panel_with_unsc,
  mona_agg,
  by = c("ISO3", "Year"),
  all.x = TRUE
)

# Fehlende avgcondtype_all durch 0 ersetzen (keine Programme = 0 Bedingungen)
panel_with_mona$avgcondtype_all[is.na(panel_with_mona$avgcondtype_all)] <- 0
panel_with_mona$avgcondtype_pc[is.na(panel_with_mona$avgcondtype_pc)] <- 0
panel_with_mona$avgcondtype_pa[is.na(panel_with_mona$avgcondtype_pa)] <- 0
panel_with_mona$avgcondtype_sb[is.na(panel_with_mona$avgcondtype_sb)] <- 0

# 1.6 WDI-Daten laden und zuordnen
print("\n3. WDI-Daten laden...")
wdi_ssa_mea <- read.csv("data/processed/wdi_ssa_mea.csv", stringsAsFactors = FALSE)

# WDI-Daten zum Panel mergen
panel_final <- merge(
  panel_with_mona,
  wdi_ssa_mea %>% rename(ISO3 = country_code, Year = year) %>% select(ISO3, Year, FuelExportPct, MineralExportPct, XDebtGNI, DebtServGNI, ResXDebt),
  by = c("ISO3", "Year"),
  all.x = TRUE
)

# Rohstoffabhängigkeit berechnen
panel_final$Rohstoffabhängigkeit <- 
  panel_final$FuelExportPct + panel_final$MineralExportPct

# Fehlende WDI-Werte durch NA belassen (werden später behandelt)

print("\n4. Finales Panel gespeichert...")
print(paste("Anzahl Beobachtungen:", nrow(panel_final)))
print(paste("Anzahl Länder:", length(unique(panel_final$ISO3))))
print(paste("Anzahl Jahre:", length(unique(panel_final$Year))))
print("\nUNSC-Länder im finalen Panel:")
print(unique(panel_final$ISO3[panel_final$unsc3 == 1]))

# Speichern
write.csv(panel_final, "data/processed/final_data_panel_ssa.csv", row.names = FALSE)
print("\n✓ final_data_panel_ssa.csv gespeichert")

# ============================================================================
# TEIL 2: Inhaltsanalyse der Bedingungen
# ============================================================================

print("\n\n=== TEIL 2: INHALTSANALYSE DER BEDINGUNGEN ===")

# 2.1 MONA-Rohdaten laden für Klassifizierung
mona_raw <- read_excel("data/raw/mona/Combined_ISO.xlsx")

# Nur SSA-Länder filtern
mona_ssa <- mona_raw %>%
  filter(iso_3ltr %in% ssa_countries) %>%
  rename(ISO3 = iso_3ltr, Year = `Approval Year`)

print(paste("Anzahl Bedingungen in MONA für SSA:", nrow(mona_ssa)))

# 2.2 Bedingungs-Klassifizierung
# Rohstoff-spezifische Keywords (erweitert)
rohstoff_keywords <- c(
  "fuel", "mineral", "oil", "gas", "extractive", "petroleum", 
  "crude", "hydrocarbon", "mining", "privatization", "subsidy",
  "energy", "resource", "commodity", "export", "tax.*resource"
)

# Stabilisierungs-Keywords
stabil_keywords <- c(
  "fiscal", "inflation", "budget", "debt", "deficit", "surplus",
  "reserve", "monetary", "interest", "exchange", "balance"
)

# Klassifizierung durchführen
conditions_classified <- mona_ssa %>%
  mutate(
    # Description in Lowercase für Suche
    desc_lower = tolower(`Description`),
    
    # Rohstoff-spezifisch?
    rohstoff_cond = ifelse(
      str_detect(desc_lower, paste(rohstoff_keywords, collapse = "|")),
      1, 0
    ),
    
    # Stabilisierend?
    stabil_cond = ifelse(
      str_detect(desc_lower, paste(stabil_keywords, collapse = "|")),
      1, 0
    ),
    
    # Sonstige (weder rohstoff noch stabil)
    sonstige_cond = ifelse(rohstoff_cond == 1 | stabil_cond == 1, 0, 1)
  )

# 2.3 Anteile pro Land-Jahr berechnen
cond_summary <- conditions_classified %>%
  group_by(ISO3, Year) %>%
  summarise(
    total_cond = n(),
    rohstoff_cond = sum(rohstoff_cond, na.rm = TRUE),
    stabil_cond = sum(stabil_cond, na.rm = TRUE),
    sonstige_cond = sum(sonstige_cond, na.rm = TRUE),
    rohstoff_cond_share = mean(rohstoff_cond, na.rm = TRUE),
    stabil_cond_share = mean(stabil_cond, na.rm = TRUE)
  )

print("\nKlassifizierungsergebnisse:")
print(summary(conditions_classified$rohstoff_cond))
print(summary(conditions_classified$stabil_cond))
print("\nAnteile pro Land-Jahr:")
print(head(cond_summary))

# 2.4 Mit finalem Panel mergen
final_with_cond_types <- merge(
  panel_final,
  cond_summary,
  by = c("ISO3", "Year"),
  all.x = TRUE
)

# Fehlende Werte durch 0 ersetzen
final_with_cond_types$rohstoff_cond[is.na(final_with_cond_types$rohstoff_cond)] <- 0
final_with_cond_types$stabil_cond[is.na(final_with_cond_types$stabil_cond)] <- 0
final_with_cond_types$sonstige_cond[is.na(final_with_cond_types$sonstige_cond)] <- 0
final_with_cond_types$rohstoff_cond_share[is.na(final_with_cond_types$rohstoff_cond_share)] <- 0
final_with_cond_types$stabil_cond_share[is.na(final_with_cond_types$stabil_cond_share)] <- 0

print("\n5. Finaler Datensatz mit Bedingungs-Typen gespeichert...")
print(paste("Anzahl Beobachtungen:", nrow(final_with_cond_types)))

# Speichern
write.csv(final_with_cond_types, "data/processed/data_with_cond_types.csv", row.names = FALSE)
print("✓ data_with_cond_types.csv gespeichert")

# 2.5 Beispieldaten ausgeben
print("\nBeispiel: Länder mit UNSC-Mitgliedschaft und Bedingungen:")
print(final_with_cond_types %>%
  filter(unsc3 == 1) %>%
  select(ISO3, Year, avgcondtype_all, unsc3, Rohstoffabhängigkeit, rohstoff_cond, stabil_cond) %>%
  head(20))

# 2.6 Statistik pro UNSC-Status
print("\nStatistik nach UNSC-Status:")
print(final_with_cond_types %>%
  group_by(unsc3) %>%
  summarise(
    avg_avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE),
    avg_rohstoff_share = mean(rohstoff_cond_share, na.rm = TRUE),
    count = n()
  ))

# 2.7 Beispiele für rohstoff-spezifische Bedingungen
print("\nBeispiele für rohstoff-spezifische Bedingungen:")
rohstoff_examples <- conditions_classified %>%
  filter(rohstoff_cond == 1) %>%
  distinct(ISO3, Year, `Key Code`, `Economic Descriptor`, `Description`) %>%
  head(10)
print(rohstoff_examples)

print("\nBeispiele für stabilisierende Bedingungen:")
stabil_examples <- conditions_classified %>%
  filter(stabil_cond == 1) %>%
  distinct(ISO3, Year, `Key Code`, `Economic Descriptor`, `Description`) %>%
  head(10)
print(stabil_examples)

print("\n✓ Tag 3 abgeschlossen!")
print("Ergebnisse:")
print("- final_data_panel_ssa.csv: Vollständiges Panel mit UNSC und MONA")
print("- data_with_cond_types.csv: Panel mit klassifizierten Bedingungen")
