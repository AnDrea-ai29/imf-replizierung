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
# ZWEI Operationalisierungen der abhaengigen Variable:
# - avgcondtype_count : durchschnittliche Anzahl Bedingungen pro Quartal
#   (anzahlbasiert wie im Original, Dreher/Sturm/Vreeland 2015: dort heisst
#   die Variable avgcondtype_all, Range ~0.8-45; berechenbar aus
#   nrcondtype_all / nrquarterssmpl)
# - avgcondtype_share : Anteil der als rohstoff-/stabilisierend klassifizierten
#   Bedingungen an allen Bedingungen (0-1.x; eigene Erweiterung fuer H2/H4)
#
# WICHTIG (1): Fehlende WDI-Werte bleiben NA (keine Null-Ersetzung).
# WICHTIG (2): KEINE vordefinierten Regionen (nur spaeter deskriptiv).
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
# 1b) Programmlaufzeit je Arrangement in Quartalen (fuer avgcondtype_count)
# ---------------------------------------------------------------------------
parse_datum <- function(x) {
  if (inherits(x, "Date") || inherits(x, "POSIXct")) return(as.Date(x))
  # readr parst auch einstellige Tagesangaben ("7-Dec-18"), as.Date nicht
  as.Date(suppressWarnings(readr::parse_date(as.character(x), format = "%d-%b-%y")))
}

arr_quarters <- mona_all %>%
  distinct(
    ARR = `Arrangement Number`, ISO3, Year,
    d_appr = `Approval date`,
    d_iend = `Initial End Date`,
    d_rend = `Revised End Date`
  ) %>%
  mutate(
    d_appr = parse_datum(d_appr),
    d_iend = parse_datum(d_iend),
    d_rend = parse_datum(d_rend),
    d_end = coalesce(d_rend, d_iend),
    quarters = ifelse(!is.na(d_appr) & !is.na(d_end),
                      pmax(1, ceiling(as.numeric(difftime(d_end, d_appr, units = "days")) / 91.3)),
                      NA_real_)
  ) %>%
  select(ISO3, Year, ARR, quarters)

cat("Arrangements:", nrow(arr_quarters),
    "| Quartale: Range", paste(round(range(arr_quarters$quarters, na.rm = TRUE)), collapse = "-"),
    "| Median", median(arr_quarters$quarters, na.rm = TRUE),
    "| ohne Datum:", sum(is.na(arr_quarters$quarters)), "\n")

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
# count-basiert (Original-Spezifikation): Bedingungen / Programm-Quartale
q_agg <- arr_quarters %>%
  group_by(ISO3, Year) %>%
  summarise(nrquarterssmpl = sum(quarters, na.rm = TRUE), .groups = "drop")

mona_agg <- mona_classified %>%
  group_by(ISO3, Year) %>%
  summarise(
    nrcondtype_all = n(),
    rohstoff_cond = sum(rohstoff_cond, na.rm = TRUE),
    stabil_cond = sum(stabil_cond, na.rm = TRUE),
    sonstige_cond = sum(sonstige_cond, na.rm = TRUE),
    rohstoff_cond_share = if_else(nrcondtype_all > 0, rohstoff_cond / nrcondtype_all, 0),
    stabil_cond_share = if_else(nrcondtype_all > 0, stabil_cond / nrcondtype_all, 0),
    .groups = "drop"
  ) %>%
  left_join(q_agg, by = c("ISO3", "Year")) %>%
  mutate(
    # anzahlbasiert, wie im Original (dort: avgcondtype_all)
    avgcondtype_count = if_else(!is.na(nrquarterssmpl) & nrquarterssmpl > 0,
                                nrcondtype_all / nrquarterssmpl, NA_real_),
    # anteilsbasiert, eigene Erweiterung
    avgcondtype_share = if_else(nrcondtype_all > 0,
                                (rohstoff_cond + stabil_cond) / nrcondtype_all, 0)
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
  filter(nrcondtype_all > 0)

# Keine Null-Ersetzung fehlender Werte: NA bleibt NA,
# Modelle laufen auf Complete Cases (transparent, kein Bias durch Scheinnullen).

# ---------------------------------------------------------------------------
# 5) Diagnostik und finalen Datensatz speichern
# ---------------------------------------------------------------------------
cat("\n=== Diagnostik ===\n")
cat("Beobachtungen:", nrow(panel_all), "| Laender:", n_distinct(panel_all$ISO3),
    "| Jahre:", min(panel_all$Year), "-", max(panel_all$Year), "\n")
cat("avgcondtype_count (Bedingungen/Quartal): Range",
    paste(round(range(panel_all$avgcondtype_count, na.rm = TRUE), 2), collapse = " - "),
    "| Mean", round(mean(panel_all$avgcondtype_count, na.rm = TRUE), 2), "\n")
cat("avgcondtype_share (Anteil klassifiziert): Range",
    paste(round(range(panel_all$avgcondtype_share, na.rm = TRUE), 2), collapse = " - "),
    "| Mean", round(mean(panel_all$avgcondtype_share, na.rm = TRUE), 2), "\n")
cat("UNSC-Mitgliedsjahre (unsc3==1):", sum(panel_all$unsc3 == 1, na.rm = TRUE), "\n")
cat("Complete Cases H1 count:", sum(complete.cases(panel_all[, c("avgcondtype_count", "unsc3", "XDebtGNI", "DebtServGNI", "ResXDebt")])), "\n")
cat("Complete Cases H1 share:", sum(complete.cases(panel_all[, c("avgcondtype_share", "unsc3", "XDebtGNI", "DebtServGNI", "ResXDebt")])), "\n")
cat("Complete Cases H2/H4 (zusaetzlich resource_dep):",
    sum(complete.cases(panel_all[, c("avgcondtype_share", "unsc3", "resource_dep", "XDebtGNI", "DebtServGNI", "ResXDebt")])), "\n")

write.csv(panel_all, "data/processed/final_data_panel_ALL.csv", row.names = FALSE)

cat("\n=== Abschluss ===\n")
cat("Erstellt: data/processed/mona_ALL.csv\n")
cat("Erstellt: data/processed/final_data_panel_ALL.csv\n")
cat("Depvars: avgcondtype_count (Original-Spezifikation) und avgcondtype_share (eigene Erweiterung)\n")
