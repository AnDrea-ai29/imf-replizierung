# ---------------------------------------------------------------------------
# Erstellen des globalen MONA-Panel-Datensatzes aus Combined_ISO.xlsx
# ---------------------------------------------------------------------------
# Ziel:
# - raw MONA-Daten aus dem globalen Datensatz laden (ALLE Laender, ALLE Jahre)
# - ISO3 und Year standardisieren (inkl. Korrektur KANN -> KNA)
# - unoffizielle Codes XA/XK/XS aussortieren
# - Bedingungen nach dem bestehenden hierarchischen Muster klassifizieren
# - auf Land-Jahr-Ebene aggregieren
# - mit WDI und UNSC joinen
# - final_data_panel_ALL.csv erzeugen
#
# WICHTIG (1): Fehlende WDI-Werte bleiben NA (keine Null-Ersetzung mehr).
# Modelle schaetzen auf Complete Cases; N wird transparent dokumentiert.
#
# WICHTIG (2): KEINE vordefinierten Regionen. Regionen werden bewusst NICHT
# vorab festgelegt. Die Analyse verlaeuft erst ueber globale
# Durchschnittsergebnisse, einzelne Laenderergebnisse und Ausreisser.
# Regionszuordnungen sind spaeter allein ein deskriptives Hilfsmittel.
# ---------------------------------------------------------------------------

setwd("C:/Users/HP/io/imf-replizierung")

library(readxl)
library(dplyr)
library(stringr)
library(tidyr)

# ---------------------------------------------------------------------------
# 1) MONA-Datensatz laden und Spalten vereinheitlichen
# ---------------------------------------------------------------------------
raw_file <- "data/raw/mona/Combined_ISO.xlsx"
if (!file.exists(raw_file)) stop("Datei fehlt: ", raw_file)

mona_raw <- read_excel(raw_file)

iso_candidates <- c("iso_3ltr", "ISO3", "country_code", "iso3")
iso_col <- intersect(iso_candidates, names(mona_raw))
if (length(iso_col) == 0) stop("Keine ISO3-Spalte in Combined_ISO.xlsx gefunden.")

year_candidates <- c("Approval Year", "Approval.Year", "approval_year", "Year")
year_col <- intersect(year_candidates, names(mona_raw))
if (length(year_col) == 0) stop("Keine passende Jahr-Spalte in Combined_ISO.xlsx gefunden.")

mona_all <- mona_raw %>%
  rename(
    ISO3 = !!sym(iso_col[1]),
    Year = !!sym(year_col[1])
  ) %>%
  mutate(
    ISO3 = as.character(ISO3),
    Year = as.numeric(Year)
  ) %>%
  filter(!is.na(ISO3), !is.na(Year)) %>%
  mutate(
    ISO3 = case_when(
      ISO3 == "KANN" ~ "KNA",  # St. Kitts and Nevis: Tippfehler in Combined_ISO.xlsx
      ISO3 %in% c("XA", "XK", "XS") ~ NA_character_,
      TRUE ~ ISO3
    )
  ) %>%
  filter(!is.na(ISO3))

cat("Mona-Rohdaten nach ISO3/Year-Standardisierung:", nrow(mona_all), "Zeilen\n")

# ---------------------------------------------------------------------------
# 2) Bedingungen klassifizieren (hierarchisch, kompatibel zu bisheriger Logik)
# ---------------------------------------------------------------------------
ed <- trimws(tolower(mona_all[["Economic Descriptor"]]))
if (is.null(ed) || length(ed) == 0) {
  stop("In Combined_ISO.xlsx fehlt die Spalte 'Economic Descriptor'.")
}

desc_lower <- tolower(mona_all[["Description"]])
if (is.null(desc_lower) || length(desc_lower) == 0) {
  stop("In Combined_ISO.xlsx fehlt die Spalte 'Description'.")
}

rohstoff_keywords <- c(
  "fuel", "mineral", "oil", "gas", "extractive", "petroleum",
  "crude", "hydrocarbon", "mining", "privatization", "subsidy",
  "energy", "resource", "commodity", "export", "tax.*resource"
)

stabil_keywords <- c(
  "fiscal", "inflation", "budget", "debt", "deficit", "surplus",
  "reserve", "monetary", "interest", "exchange", "balance"
)

mona_classified <- mona_all %>%
  mutate(
    rohstoff_desc = as.numeric(
      startsWith(ed, "11.2") |
        startsWith(ed, "5.1.")
    ),
    stabil_desc = as.numeric(
      startsWith(ed, "1.") |
        startsWith(ed, "2.")
    ),
    rohstoff_text = as.numeric(
      str_detect(desc_lower, paste(rohstoff_keywords, collapse = "|"))
    ),
    stabil_text = as.numeric(
      str_detect(desc_lower, paste(stabil_keywords, collapse = "|"))
    )
  ) %>%
  mutate(
    rohstoff_cond = pmax(rohstoff_desc, rohstoff_text, na.rm = TRUE),
    stabil_cond = pmax(stabil_desc, stabil_text, na.rm = TRUE),
    sonstige_cond = ifelse(rohstoff_cond == 1 | stabil_cond == 1, 0, 1)
  )

# ---------------------------------------------------------------------------
# 3) Aggregation auf Land-Jahr-Ebene
# ---------------------------------------------------------------------------
mona_agg <- mona_classified %>%
  group_by(ISO3, Year) %>%
  summarise(
    total_cond = n(),
    rohstoff_cond = sum(rohstoff_cond, na.rm = TRUE),
    stabil_cond = sum(stabil_cond, na.rm = TRUE),
    sonstige_cond = sum(sonstige_cond, na.rm = TRUE),
    avgcondtype_all = if_else(total_cond > 0,
                              (sum(rohstoff_cond, na.rm = TRUE) + sum(stabil_cond, na.rm = TRUE)) / total_cond,
                              0),
    .groups = "drop"
  ) %>%
  mutate(
    rohstoff_cond_share = if_else(total_cond > 0, rohstoff_cond / total_cond, 0),
    stabil_cond_share = if_else(total_cond > 0, stabil_cond / total_cond, 0)
  )

write.csv(mona_agg, "data/processed/mona_ALL.csv", row.names = FALSE)
cat("Aggregierte MONA-ALL-Datei gespeichert: data/processed/mona_ALL.csv\n")

# ---------------------------------------------------------------------------
# 4) WDI und UNSC joinen
# ---------------------------------------------------------------------------
wdi_data <- read.csv("data/raw/wdi/wdi_2002_2025_dep.csv", stringsAsFactors = FALSE) %>%
  rename(
    ISO3 = iso3c,
    Year = year,
    FuelExportPct = TX.VAL.FUEL.ZS.UN,
    MineralExportPct = TX.VAL.MMTL.ZS.UN,
    XDebtGNI = NE.TRD.GNFS.ZS,
    DebtServGNI = DT.DOD.DSTC.ZS,
    ResXDebt = FI.RES.TOTL.DT.ZS
  )

unsc_data <- read.csv("data/raw/unsc/unsc_membership_ISO3_correct.csv", stringsAsFactors = FALSE) %>%
  rename(Year = year)

panel_all <- mona_agg %>%
  left_join(
    wdi_data %>% select(ISO3, Year, FuelExportPct, MineralExportPct, XDebtGNI, DebtServGNI, ResXDebt),
    by = c("ISO3", "Year")
  ) %>%
  left_join(unsc_data, by = c("ISO3", "Year")) %>%
  mutate(
    resource_dep = FuelExportPct + MineralExportPct,
    Rohstoffabhängigkeit = resource_dep
  ) %>%
  filter(!is.na(avgcondtype_all))

# Keine Null-Ersetzung fehlender Werte: NA bleibt NA,
# Modelle laufen auf Complete Cases (transparent, kein Bias durch Scheinnullen).

# ---------------------------------------------------------------------------
# 5) Diagnostik und finalen Datensatz speichern
# ---------------------------------------------------------------------------
cat("\n=== Diagnostik ===\n")
cat("Beobachtungen:", nrow(panel_all), "| Laender:", n_distinct(panel_all$ISO3),
    "| Jahre:", min(panel_all$Year), "-", max(panel_all$Year), "\n")
cat("UNSC-Mitgliedsjahre (unsc3==1):", sum(panel_all$unsc3 == 1, na.rm = TRUE), "\n")
cat("Complete Cases H1 (avgcondtype_all, unsc3, 3 Kontrollen):",
    sum(complete.cases(panel_all[, c("avgcondtype_all", "unsc3", "XDebtGNI", "DebtServGNI", "ResXDebt")])), "\n")
cat("Complete Cases H2/H4 (zusaetzlich resource_dep):",
    sum(complete.cases(panel_all[, c("avgcondtype_all", "unsc3", "resource_dep", "XDebtGNI", "DebtServGNI", "ResXDebt")])), "\n")

write.csv(panel_all, "data/processed/final_data_panel_ALL.csv", row.names = FALSE)

cat("\n=== Abschluss ===\n")
cat("Erstellt: data/processed/mona_ALL.csv\n")
cat("Erstellt: data/processed/final_data_panel_ALL.csv (alle Laender, alle Jahre, keine vordefinierten Regionen)\n")
