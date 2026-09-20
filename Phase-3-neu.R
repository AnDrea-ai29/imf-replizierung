# ===== R-Version Hinweis =====
# Falls Warnmeldungen "Paket wurde unter R Version 4.6.1 erstellt" erscheinen:
# -> Pakete unter aktueller R-Version (4.6.0) neu installieren:
install.packages(c("plm", "fixest", "stargazer", "ggeffects", "marginaleffects"))
# -> Oder R auf 4.6.1 aktualisieren (empfohlen für langfristige Kompatibilität)

library(plm)
library(dplyr)
library(fixest)
library(stargazer)
library(ggeffects)  # Fallback für marginale Effekte in R 4.6.1

# Teildatensätze laden + Spalte umbennen
data_part1 <- read.csv("C:/Users/HP/io/imf-replizierung/data/processed/data_part1_2002_2008.csv")

data_part2 <- read.csv("C:/Users/HP/io/imf-replizierung/data/processed/data_part2_2008_2025_africa.csv") 

data_part1 <- data_part1 %>% mutate(`MONA Code` = as.character(`MONA Code`))








# ===== TEIL 1: Replizierung 2002–2008 (alle Länder) =====

# Modell 1: Fixed Effects (Hauptmodell der Originalstudie)
model_1_fe <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI,
  data = data_part1,
  index = c("MONA Code", "Approval Year"),
  model = "within"
)

# Modell 1_full: + Kontrollvariable ResXDebt
model_1_full <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_part1,
  index = c("MONA Code", "Approval Year"),
  model = "within"
)
