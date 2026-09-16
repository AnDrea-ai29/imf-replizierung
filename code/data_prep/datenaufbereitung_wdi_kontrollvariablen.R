# WDI-Daten einlesen und filtern

library(WDI)
library(tidyverse)

# 1. Alle Länder-Codes aus deiner ISO-Datei laden
iso_codes <- read.csv("C:/Users/HP/io/imf-replizierung/data/raw/country_codes_wdi-iso-itu.csv")
country_codes <- iso_codes$iso_3ltr  # Extrahiere alle ISO-3-Codes

# 2. WDI-Daten nur für einzelne Länder herunterladen
wdi_data <- WDI(
  country = country_codes,  # Nur Länder aus der ISO-Liste
  indicator = c(
    "NE.TRD.GNFS.ZS",     # XDebtGNI
    "DT.DOD.DSTC.ZS",     # DebtServGNI
    "FI.RES.TOTL.DT.ZS",   # ResXDebt
    "TX.VAL.FUEL.ZS.UN",  # FuelExportPct (EXPORTE in US-$) 👈 Dein Code
    "TX.VAL.MMTL.ZS.UN"   # MineralExportPct (EXPORTE in US-$) 👈 Dein Code
  ),
  start = 2002,
  end = 2025
)

# 3. Datei speichern
write_csv(
  wdi_data,
  "C:/Users/HP/io/imf-replizierung/data/raw/wdi/wdi_2002_2025_dep.csv",
  na = ""
)

# Überprüfen der Anzahl der Länder (ohne Areas bei 215)
length(unique(wdi_data$country))
  
  
  
  
  
  
  
  
  