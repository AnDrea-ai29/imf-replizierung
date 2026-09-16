## MONA-Daten einlesen und um Rohstoffabhängigkeit ergänzen

library(tidyverse)
library(readxl)
library(dplyr)
library(readr)

# 1. MONA-Daten laden
mona_raw <- read_excel("data/raw/mona/Combined_ISO.xlsx") %>%
  rename(ISO3 = iso_3ltr) # Spaltenname anpassen

# 2. Datums-Spalten SEPARAT konvertieren
mona_raw <- mona_raw %>%
  mutate(
    `Approval date` = parse_date_time(`Approval date`, orders = c("dby", "ymd", "dmy")),
    `Initial End Date` = parse_date_time(`Initial End Date`, orders = c("dby", "ymd", "dmy")),
    `Revised End Date` = parse_date_time(`Revised End Date`, orders = c("dby", "ymd", "dmy"))
  )

# 3. NA-Werte in Date-Objekte umwandeln
mona_raw <- mona_raw %>%
  mutate(across(c(`Approval date`, `Initial End Date`, `Revised End Date`), as.Date))

# 4. Bedingungstypen klassifizieren
program_data <- mona_raw %>%
  mutate(
    condtype = case_when(
      is.na(`Key Code`) ~ NA_character_,
      `Key Code` %in% c("SPC", "PC", "SAC") ~ "Performance Criteria",
      `Key Code` == "PA" ~ "Prior Action",
      `Key Code` == "SB" ~ "Structural Benchmark",
      TRUE ~ NA_character_
    ),
    arrtype_group = case_when(
      is.na(`Arrangement Type`) ~ NA_character_,
      `Arrangement Type` %in% c("SBA", "EFF") ~ "EFF_SBA",
      `Arrangement Type` %in% c("PRGF", "ECF", "SAF", "ESAF") ~ "PRGF",
      TRUE ~ "Other"
    )
  ) %>%
  filter(arrtype_group != "Other") %>%
  group_by(`Arrangement Number`, `Approval Year`, `Country Name`, `MONA Code`, `ISO3`) %>%
  mutate(
    programnr = cur_group_id(),
    nrdays = as.numeric(difftime(coalesce(`Revised End Date`, `Initial End Date`), `Approval date`, units = "days")),
    nrquarters = round(nrdays / 90, 0)
  ) %>%
  ungroup() %>%
  group_by(programnr, `Arrangement Number`, `Country Name`, `MONA Code`, `ISO3`, `Approval Year`, arrtype_group, nrquarters) %>%
  summarise(
    approvaldate = first(`Approval date`),
    nrcondtype_pc = sum(condtype == "Performance Criteria", na.rm = TRUE),
    nrcondtype_pa = sum(condtype == "Prior Action", na.rm = TRUE),
    nrcondtype_sb = sum(condtype == "Structural Benchmark", na.rm = TRUE),
    nrcondtype_all = nrcondtype_pc + nrcondtype_pa + nrcondtype_sb
  ) %>%
  mutate(
    avgcondtype_all = ifelse(nrquarters > 0, nrcondtype_all / nrquarters, NA_real_),
    avgcondtype_pc = ifelse(nrquarters > 0, nrcondtype_pc / nrquarters, NA_real_),
    avgcondtype_pa = ifelse(nrquarters > 0, nrcondtype_pa / nrquarters, NA_real_),
    avgcondtype_sb = ifelse(nrquarters > 0, nrcondtype_sb / nrquarters, NA_real_)
  ) %>%
  ungroup()


# 5. UNSC-Daten einlesen und vollständiges Panel erstellen
unsc_raw <- read_csv("C:/Users/HP/io/imf-replizierung/data/raw/unsc/unsc_membership_2002_2025.csv")

  # Spaltennamen anpassen (für Verknüpfung mit MONA)
  unsc_raw <- unsc_raw %>%
    rename(country_code = wdicode)  # wdicode → country_code (für ISO3-Verknüpfung)




# 6. WDI-Daten einlesen + ISO-Codes hinzufügen
iso_codes <- read.csv("C:/Users/HP/io/imf-replizierung/data/raw/country_codes_wdi-iso-itu.csv") %>%
  select(wdi_short_name, iso_3ltr) %>%
  rename(country = wdi_short_name, country_code = iso_3ltr)

wdi_data <- read.csv("data/raw/wdi/wdi_2002_2025_dep.csv") %>%
  left_join(iso_codes, by = "country") %>%  # Verknüpfung über Ländername
  drop_na(country_code) %>%  # Aggregationen entfernen
  select(
    country_code, year,
    XDebtGNI = `NE.TRD.GNFS.ZS`,
    DebtServGNI = `DT.DOD.DSTC.ZS`,
    ResXDebt = `FI.RES.TOTL.DT.ZS`,
    FuelExportPct = `TX.VAL.FUEL.ZS.UN`,
    MineralExportPct = `TX.VAL.MMTL.ZS.UN`
  ) %>%
  mutate(
    Rohstoffabhängigkeit = FuelExportPct + MineralExportPct
  ) %>%
  drop_na(Rohstoffabhängigkeit)

# 7. Finalen Datensatz erstellen
final_data <- program_data %>%
  left_join(
    unsc_raw %>% select(country_code, year, unsc, unsc3),  # Nur benötigte Spalten
    by = c("ISO3" = "country_code", "Approval Year" = "year")  # Verknüpfung über ISO3!
  ) %>%
  group_by(ISO3) %>%
  mutate(
    unsc_t1 = lag(unsc, 1, default = 0),
    unsc3 = ifelse(unsc == 1 | unsc_t1 == 1, 1, 0)
  ) %>%
  ungroup() %>%
  left_join(
    wdi_data,
    by = c("ISO3" = "country_code", "Approval Year" = "year")
  ) %>%
  drop_na(avgcondtype_all, unsc3, XDebtGNI, DebtServGNI, ResXDebt, Rohstoffabhängigkeit)

print(final_data)

# 8. Teildatensätze erstellen
africa_codes <- read_csv("data/afrika_iso_codes_wdi.csv") %>% pull(`ISO-alpha3 Code`)

data_part1 <- final_data %>% filter(`Approval Year` >= 2002, `Approval Year` <= 2008)
data_part2 <- final_data %>% filter(`Approval Year` >= 2008, `Approval Year` <= 2025, ISO3 %in% africa_codes)



##----------------------------------------------------##

##Check 1: Prüfe program_data
    # 1. Anzahl der Zeilen
    nrow(program_data)
    
    # 2. Spaltennamen
    colnames(program_data)
    
    # 3. Beispielzeile
    head(program_data)
    
    # 4. Eindeutige Länder-Codes
    unique(program_data$`Country Code`)



##Check 2: Prüfe unsc_raw
    # 1. Anzahl der Zeilen
    nrow(unsc_raw)
    
    # 2. Spaltennamen
    colnames(unsc_raw)
    
    # 3. Beispielzeile
    head(unsc_raw)
    
    # 4. Eindeutige Länder-Codes
    unique(unsc_raw$wdicode)


##Check 3: Prüfe wdi_data
    # 1. Anzahl der Zeilen
    nrow(wdi_data)
    
    # 2. Spaltennamen
    colnames(wdi_data)
    
    # 3. Beispielzeile
    head(wdi_data)
    
    # 4. Eindeutige Länder-Codes
    unique(wdi_data$country_code)


##Check 4: Prüfe Verknüpfungen schrittweise
    # Schritt 1: program_data + unsc_raw
    test1 <- program_data %>%
      left_join(unsc_raw, by = c("Country Code" = "wdicode", "Approval Year" = "year"))
    nrow(test1)  # Sollte ~ gleich program_data sein
    
    # Schritt 2: test1 + wdi_data
    test2 <- test1 %>%
      left_join(wdi_data, by = c("Country Code" = "country_code", "Approval Year" = "year"))
    nrow(test2)  # Sollte ~ gleich test1 sein


  # 1. Einfache Verknüpfung: nur program_data + unsc_raw
    test_minimal <- program_data %>%
      left_join(unsc_raw, by = c("Country Code" = "wdicode", "Approval Year" = "year"))
    nrow(test_minimal)


##-----------------------------------------------------------##  
    
    
##Schritt-für-Schritt-Debug für drop_na()
##Führe diesen Code aus (ersetze final_data in deiner Phase 2.txt):
      # 1. Erstelle final_data OHNE drop_na()
      final_data_no_drop <- program_data %>%
      left_join(
        unsc_raw,
        by = c("Country Name" = "country", "Approval Year" = "year")
      ) %>%
      group_by(`Country Code`) %>%
      mutate(
        unsc_t1 = lag(unsc, 1, default = 0),
        unsc3 = ifelse(unsc == 1 | unsc_t1 == 1, 1, 0)
      ) %>%
      ungroup() %>%
      left_join(
        wdi_data,
        by = c("Country Code" = "country_code", "Approval Year" = "year")
      )
    
    # 2. Prüfe die Anzahl der Zeilen
    nrow(final_data_no_drop)  # Sollte > 0 sein
    
    # 3. Prüfe, welche Spalten NA-Werte haben
    colSums(is.na(final_data_no_drop))
    
    # 4. Prüfe spezifisch die Spalten aus drop_na()
    na_counts <- final_data_no_drop %>%
      summarise(across(c(avgcondtype_all, unsc3, XDebtGNI, DebtServGNI, ResXDebt, Rohstoffabhängigkeit),
                       ~ sum(is.na(.))))
    print(na_counts)
    

    
    
    
    
    
#Schritt 1: Prüfe avgcondtype_all
    # 1. Wie viele NA-Werte in avgcondtype_all?
    sum(is.na(final_data_no_drop$avgcondtype_all))
    
    # 2. Prüfe die Berechnung:
    head(program_data %>% select(avgcondtype_all, nrquarters, nrcondtype_all))
    
    # 3. Ursache: Division durch Null?
    sum(program_data$nrquarters == 0)  # Falls > 0: nrquarters = 0 → avgcondtype_all = NA   
    
    
#Schritt 2: Prüfe unsc3
    # 1. Wie viele NA-Werte in unsc3?
    sum(is.na(final_data_no_drop$unsc3))
    
    # 2. Prüfe unsc und unsc_t1:
    head(final_data_no_drop %>% select(unsc, unsc_t1, unsc3))
    
    # 3. Prüfe, ob unsc Raw-daten hat:
    sum(unsc_raw$unsc, na.rm = TRUE)  # Sollte > 0 sein (Anzahl der UNSC-Mitgliedschaften)  

    
# Endgültige Lösung: Teste ohne drop_na()
    final_data <- program_data %>%
      left_join(
        unsc_raw,
        by = c("Country Code" = "wdicode", "Approval Year" = "year")
      ) %>%
      group_by(`Country Code`) %>%
      mutate(
        unsc_t1 = lag(unsc, 1, default = 0),
        unsc3 = ifelse(unsc == 1 | unsc_t1 == 1, 1, 0)
      ) %>%
      ungroup() %>%
      left_join(
        wdi_data,
        by = c("Country Code" = "country_code", "Approval Year" = "year")
      )
    # KEIN drop_na()!
    
    nrow(final_data)  # Sollte > 0 sein

    
##------------------------------------------------##

## 1. Prüfe die Verknüpfung program_data + unsc_raw
  # Test: Verknüpfe nur program_data + unsc_raw
  test_unsc <- program_data %>%
    left_join(
      unsc_raw,
      by = c("Country Name" = "country", "Approval Year" = "year")
    )
  
  # Prüfe die Spalten unsc und unsc3
  summary(test_unsc$unsc)     # Sollte 0 und 1 enthalten (keine NA!)
  summary(test_unsc$unsc3)   # Sollte 0 und 1 enthalten (keine NA!)
  nrow(test_unsc)             # Sollte ~ gleich program_data sein


 ##Schritt 1: Prüfe die Übereinstimmung der Länder-Codes
  # Welche Länder sind in program_data?
  unique(program_data$`Country Code`)
  
  # Welche Länder sind in unsc_raw?
  unique(unsc_raw$wdicode)
  
  # Unterschiede finden:
  setdiff(program_data$`Country Code`, unsc_raw$wdicode)  # Länder in program_data, aber nicht in unsc_raw
  setdiff(unsc_raw$wdicode, program_data$`Country Code`)  # Länder in unsc_raw, aber nicht in program_data
  #→ Wenn hier viele Länder gelten, stimmen die Codes nicht überein!

##---------------------------------------------------------##
## Lösung der Nicht-Übereinstimmung 
  
##Schritt 1: Finde die Differenz der Länder-Codes
  # Welche Länder sind in program_data, aber nicht in unsc_raw?
  missing_in_unsc <- setdiff(program_data$`Country Code`, unsc_raw$wdicode)
  print(missing_in_unsc)
  
  # Welche Länder sind in unsc_raw, aber nicht in program_data?
  missing_in_mona <- setdiff(unsc_raw$wdicode, program_data$`Country Code`)
  print(missing_in_mona)












