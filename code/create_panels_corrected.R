# Skript: Erstellen von final_data_panel_ALL.csv und final_data_panel_SSA.csv
# Ziel: Zwei separate Datensätze mit korrekten nrcondtype* und avgcondtype* Werten
# KORRIGIERT: Nur Land-Jahr-Kombinationen MIT MONA-Daten behalten

setwd("C:/Users/HP/io/imf-replizierung")
library(tidyverse)
library(readr)

# ============================================================================
# KONFIGURATION
# ============================================================================

# SSA-Länder (20 Länder)
ssa_countries <- c(
  "AGO", "CAF", "CMR", "COM", "CPV",
  "GAB", "GHA", "GIN", "KEN", "LSO",
  "MDG", "MOZ", "MRT", "MWI", "RWA",
  "SLE", "SLV", "TZA", "UGA", "ZMB"
)

# ============================================================================
# DATEN LADEN
# ============================================================================

print("Lade UNSC-Daten (KORRIGIERT)...")
unsc_data_full <- read.csv("data/raw/unsc/unsc_membership_ISO3_correct.csv", stringsAsFactors = FALSE) %>%
  rename(Year = year)

# Für SSA: Filtere die korrigierten UNSC-Daten
unsc_data <- unsc_data_full %>% filter(ISO3 %in% ssa_countries)

print("Lade WDI-Daten...")
wdi_data_full <- read.csv("data/raw/wdi/wdi_2002_2025_dep.csv", stringsAsFactors = FALSE) %>%
  rename(ISO3 = iso3c, Year = year, 
         FuelExportPct = TX.VAL.FUEL.ZS.UN, 
         MineralExportPct = TX.VAL.MMTL.ZS.UN,
         XDebtGNI = NE.TRD.GNFS.ZS,
         DebtServGNI = DT.DOD.DSTC.ZS,
         ResXDebt = FI.RES.TOTL.DT.ZS)

wdi_data <- read.csv("data/processed/wdi_ssa_mea.csv", stringsAsFactors = FALSE) %>%
  rename(ISO3 = country_code, Year = year)

# ============================================================================
# HILFSFUNKTION: Panel erstellen
# ============================================================================

create_panel <- function(country_filter = NULL, panel_name = "", mona_file, wdi_data_to_use, unsc_data_to_use) {
  print(paste("\n=== Erstelle", panel_name, "Panel ==="))
  
  # 1. MONA-Daten laden
  mona_data <- read.csv(mona_file, stringsAsFactors = FALSE)
  
  # Spaltennamen vereinheitlichen: Approval.Year -> Year
  if ("Approval.Year" %in% names(mona_data) && !"Year" %in% names(mona_data)) {
    mona_data <- mona_data %>% rename(Year = Approval.Year)
  }
  
  if (!is.null(country_filter)) {
    mona_data <- mona_data %>% filter(ISO3 %in% country_filter)
  }

  # 2. MONA-Daten auf Land-Jahr-Ebene aggregieren
  mona_agg <- mona_data %>%
    group_by(ISO3, Year) %>%
    summarise(
      avgcondtype_all = mean(avgcondtype_all, na.rm = TRUE),
      nrcondtype_all = mean(nrcondtype_all, na.rm = TRUE),
      nrcondtype_pc = mean(nrcondtype_pc, na.rm = TRUE),
      nrcondtype_pa = mean(nrcondtype_pa, na.rm = TRUE),
      nrcondtype_sb = mean(nrcondtype_sb, na.rm = TRUE),
      avgcondtype_pc = mean(avgcondtype_pc, na.rm = TRUE),
      avgcondtype_pa = mean(avgcondtype_pa, na.rm = TRUE),
      avgcondtype_sb = mean(avgcondtype_sb, na.rm = TRUE),
      .groups = "drop"
    )

  # 3. WDI mergen
  wdi_cols <- c("FuelExportPct", "MineralExportPct", "XDebtGNI", "DebtServGNI", "ResXDebt")
  available_wdi_cols <- wdi_cols[wdi_cols %in% names(wdi_data_to_use)]
  
  panel <- merge(
    mona_agg,
    wdi_data_to_use %>% select(all_of(c("ISO3", "Year", available_wdi_cols))),
    by = c("ISO3", "Year"),
    all.x = FALSE  # NUR Land-Jahr mit MONA UND WDI-Daten
  )

  # 4. UNSC mergen
  panel <- merge(
    panel,
    unsc_data_to_use,
    by = c("ISO3", "Year"),
    all.x = FALSE  # NUR Land-Jahr mit MONA UND UNSC-Daten
  )

  # Rohstoffabhängigkeit berechnen
  panel$Rohstoffabhängigkeit <- panel$FuelExportPct + panel$MineralExportPct

  # 5. NAs in numerischen Spalten durch 0 ersetzen (nur für Kontrollvariablen, NICHT für avgcondtype_all!)
  numeric_cols <- c("FuelExportPct", "MineralExportPct", "XDebtGNI", "DebtServGNI", "ResXDebt",
                   "Rohstoffabhängigkeit", "unsc", "unsc_t1", "unsc3")
  numeric_cols <- numeric_cols[numeric_cols %in% names(panel)]
  
  panel <- panel %>%
    mutate(across(all_of(numeric_cols), ~ replace_na(., 0)))

  # avgcondtype_all NAs entfernen (keine 0-Ersetzung!)
  panel <- panel %>% filter(!is.na(avgcondtype_all))

  # Überprüfung
  print(paste("Panel: ", nrow(panel), " Beobachtungen, ", 
              n_distinct(panel$ISO3), " Länder"))

  return(panel)
}

# ============================================================================
# DATENSÄTZE ERSTELLEN
# ============================================================================

# 1. Panel für ALLE Länder (H1)
print("\n### Erstelle ALL Panel ###")
final_data_panel_ALL <- create_panel(
  country_filter = NULL,
  panel_name = "ALL",
  mona_file = "data/processed/mona_ALL.csv",
  wdi_data_to_use = wdi_data_full,
  unsc_data_to_use = unsc_data_full
)

# 2. Panel für SSA-Länder (H2-H4)
print("\n### Erstelle SSA Panel ###")
final_data_panel_SSA <- create_panel(
  country_filter = ssa_countries,
  panel_name = "SSA",
  mona_file = "data/processed/mona_ssa_mea.csv",
  wdi_data_to_use = wdi_data,
  unsc_data_to_use = unsc_data
)

# ============================================================================
# SPEICHERN
# ============================================================================

write.csv(final_data_panel_ALL, "data/processed/final_data_panel_ALL.csv", row.names = FALSE)
write.csv(final_data_panel_SSA, "data/processed/final_data_panel_SSA.csv", row.names = FALSE)

print("\n✓ final_data_panel_ALL.csv gespeichert")
print("✓ final_data_panel_SSA.csv gespeichert")

# ============================================================================
# ZUSAMMENFASSUNG
# ============================================================================

print("\n=== Zusammenfassung ===")
print("Erstellt:")
print("- final_data_panel_ALL.csv: Alle Länder für H1 (UNSC-Analyse)")
print("- final_data_panel_SSA.csv: Nur 20 SSA-Länder für H2-H4 (Rohstoffbedingungen)")
