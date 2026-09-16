wdi_data <- wdi_data %>%
  rename(
    country_code = `country`, 
    year = `year`
  ) %>%
  select(
    country_code, year, 
    XDebtGNI = `NE.TRD.GNFS.ZS`,
    DebtServGNI = `DT.DOD.DSTC.ZS`,
    ResXDebt = `FI.RES.TOTL.DT.ZS`,
    FuelExportPct = `TX.VAL.FUEL.ZS.UN`,  # Brennstoffe
    MineralExportPct = `TX.VAL.MMTL.ZS.UN`  # Metalle/Erze
  ) %>%
  mutate(
    Rohstoffabhängigkeit = FuelExportPct + MineralExportPct
  ) %>%
  drop_na(Rohstoffabhängigkeit) # Nur Länder mit Rohstoffdaten

# Prüfen der Indikatoren
#unique(wdi_data$TX.VAL.FUEL.ZS.UN)
#unique(wdi_data$TX.VAL.MMTL.ZS.UN)

# Prüfen des Zeitraums
#range(wdi_data$year, na.rm = TRUE) # Sollte 2002-2025 sein

# Prüfen der Anzahl der Länder
#length(unique(wdi_data$country)) # Es sind 265 Länder (ursprünglich)