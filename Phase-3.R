
# 3 - BASISMODELL TESTEN (TEIL 1 + 2)

## Regressionen für 2002-2008 (alle Länder) und 2009-2026 (Afrika) durchführen
## Ergebnisse speichern (regression_results.csv)
## Durchführen des Interaktionsmodells (unsc3 x Rohstoffabhängigkeit), Test H2 + H4
## Erwartetes Ergebnis: model_part1, model_part2 + Ergebnisse

## Übersicht der Schritte mit entsprechenden Datensätzen

# 1. data_part1_2002_2008.csv
#  **Zweck:** Replizierung der Originalstudie (Teil 1: 2002-2008, alle Länder)
#  **Verwendet in:**
#     - Modell 1 (M1_fe): avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI
#     - Modell 2 (M2_fe): + Kontrollvariablen (ResXDebt, ExtBalGDP, GFCFGDP)
#  **Index für Panel-Regression: c("MONA Code", "Approval Year")

# 2. data_part2_2002_2025.csv
# **Zweck:** Dependenz-Analyse (Teil 2: 2008-2025, nur Afrika)
# **Verwendet in:** 
#     - Modell 3 (M3_dep): Basismodell + Rohstoffabhängigkeit
#     - Modell 4 (M4_interaction): Interaktionsterm unsc3 * Rohstoffabhängigkeit (Test von H4)
#     - Modell 5 (M5_africa): Vergleich mit globalem Effekt (Test von H2)
# **Index für Panel-Regression:** c("MONA Code", "Approval Year")

## Hinweise: 
# - MONA Code muss als String (nicht numerisch) vorliegen, da es als Panel-Identifier dient
# - Approval Year muss als Numerisch vorliegen (für Zeitdimension)
# - Fehlende Werte (NA) in unsc3 oder Rohstoffabhängigkeit werden in den Modellen automatisch ausgeschlossen


install.packages("plm", dependencies = TRUE)
install.packages("stargazer")


library(plm)
library(fixest)
library(stargazer)
library(tidyverse)

# Teildatensätze laden + Spalte umbennen
data_part1 <- read.csv("C:/Users/HP/io/imf-replizierung/data/processed/data_part1_2002_2008.csv") %>%
  mutate(`MONA Code` = as.character(`MONA Code`))  # dbl → chr

data_part2 <- read.csv("C:/Users/HP/io/imf-replizierung/data/processed/data_part2_2008_2025_africa.csv") %>%
  mutate(`MONA Code` = as.character(`MONA Code`))


## Aggregierte Teildatensätze laden + Spalte umbenennen (aggregiert, da für 1 Jahr mehrere Programme vorliegen)

data_part1 <- data_part1 %>%
  group_by(`MONA Code`, `Approval Year`) %>%
  summarise(across(everything(), mean, na.rm = TRUE)) %>%  # Mittelwert aller Variablen
  ungroup()

data_part2 <- data_part2 %>%
  group_by(`MONA Code`, `Approval Year`) %>%
  summarise(across(everything(), mean, na.rm = TRUE)) %>%
  ungroup()

# Prüfen, ob Duplikate weg sind
data_part1 %>%
  group_by(`MONA Code`, `Approval Year`) %>%
  summarise(n = n()) %>%
  filter(n > 1)  # Sollte 0 Zeilen zurückgeben!

# Optional: Finaler Datensatz (falls benötigt)
#final_data <- read_csv("C:/Users/HP/io/imf-replizierung/data/processed/final_data_2002_2025.csv")


## =========== TEIL 1: Replizierung 2002-2008 (alle Länder) ======

## Modell 1: Fixed Effects (Hauptmodell der Originalstudie)

  # Panel-IDs manuell erstellen (da vorher Variable `MONA Code` nicht finden konnte)
data_part1 <- data_part1 %>%
  mutate(
    id = as.character(`MONA Code`),
    time = `Approval Year`
  )

  # Modell mit manuellen IDs
model_1_fe <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI,
  data = data_part1,
  index = c("id", "time"),  # Jetzt mit manuellen Spalten
  model = "within"
)


# Modell 2: + Kontrollvariablen
model_1_full <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_part1, 
  index = c("id", "Approval Year"),
  model = "within"
)

## -------------------------------------------------

#Schritt 1: Kompletten Neustart + Debugging
# 1. ALLE Objekte löschen
rm(list = ls())

# 2. Pakete neu laden
detach("package:plm", unload = TRUE)
library(plm)
library(tidyverse)

# 3. Daten FRISCH laden
data_part1 <- read_csv("C:/Users/HP/io/imf-replizierung/data/processed/data_part1_2002_2008.csv")

# 4. EXAKTEN Spaltennamen prüfen (inkl. unsichtbarer Zeichen)
dput(names(data_part1))  # Gibt den Spaltennamen in R-Code-Syntax aus!


















## ---------------------------------------------

# plm-Paket neu installieren (für R 4.6.1 optimiert)
install.packages("plm", dependencies = TRUE)
library(plm)
library(tidyverse)

# Daten FRISCH laden
data_part1 <- read_csv("C:/Users/HP/io/imf-replizierung/data/processed/data_part1_2002_2008.csv")

#  EXAKTEN Spaltennamen prüfen (inkl. unsichtbarer Zeichen)
dput(names(data_part1))  # Gibt den Spaltennamen in R-Code-Syntax aus!

# Führen Sie diese 3 Tests aus:
# Test 1: Spalte existiert?
"MONA Code" %in% names(data_part1)  # Muss TRUE sein!

# Test 2: Spalte ist character?
class(data_part1$`MONA Code`)  # Muss "character" sein!

data_part1$`MONA Code` <- as.character(data_part1$`MONA Code`)

class(data_part1$`MONA Code`)  # Muss "character" sein!

# Spaltenpositionen finden
idx_col <- which(names(data_part1) == "MONA Code")
time_col <- which(names(data_part1) == "Approval Year")

# Modell mit Positionen
model_1_full <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_part1,
  index = c(idx_col, time_col),  # ✅ 100% sicher!
  model = "within"
)
## --> gibt Warnmeldung: In pdata.frame(data, index = index,...) : The time index (second element of 'index' argument) will be ignored

# Panel manuell erstellen
pdata <- pdata.frame(
  data_part1,
  index = c("MONA Code", "Approval Year")
)

# Modell mit dem Panel-Objekt
model_1_full <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt + GFCFGDP,
  data = pdata,
  model = "within"
)


# Test 3: pdata.frame manuell testen
pdata.frame(data_part1, index = c("MONA Code", "Approval Year"))  # Muss funktionieren!


# plm-Paket neu installieren (für R 4.6.1 optimiert)
install.packages("plm", dependencies = TRUE)
library(plm)
library(tidyverse)

idx_col <- which(names(data_part1) == "MONA Code")
time_col <- which(names(data_part1) == "Approval Year")

# 3. Modell 2 ausführen
model_1_full <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt + GFCFGDP,
  data = data_part1,
  index = c(idx_col, time_col),
  model = "within"
)














