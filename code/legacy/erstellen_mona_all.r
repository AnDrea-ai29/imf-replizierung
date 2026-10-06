# ---------------------------------------------------------------------------
# Erstellen des globalen MONA-Panel-Datensatzes aus Combined_ISO.xlsx
# ---------------------------------------------------------------------------
# Ziel:
# - raw MONA-Daten aus dem globalen Datensatz laden (ALLE Laender, ALLE Jahre)
# - ISO3 und Year standardisieren (inkl. Korrektur KANN -> KNA)
# - unoffizielle Codes XA/XK/XS aussortieren
# - MONA-Zeilen je Land-Jahr zählen (keine Klassifikation)
# - auf Land-Jahr-Ebene aggregieren
# - mit WDI und UNSC joinen
# - final_data_panel_ALL.csv erzeugen
#
# Abhaengige Variable:
# - avgcondtype_count : durchschnittliche Anzahl Bedingungen pro Quartal
#   (anzahlbasiert wie im Original, Dreher/Sturm/Vreeland 2015: dort heisst
#   die Variable avgcondtype_all, Range ~0.8-45; berechenbar aus
#   nrcondtype_all / nrquarterssmpl)
#
# WICHTIG (1): Fehlende WDI-Werte bleiben NA (keine Null-Ersetzung).
# WICHTIG (2): KEINE vordefinierten Regionen (nur spaeter deskriptiv).
# Klassifikationsbasierte Outcomes bleiben ausgesetzt, bis der gemeinsame
# Phase-A/Phase-B-Crosswalk manuell geprueft und freigegeben ist.
# ---------------------------------------------------------------------------

setwd("C:/Users/HP/io/imf-replizierung")

library(readxl)
library(dplyr)
library(tidyr)

parse_datum <- function(x) {
  if (inherits(x, "Date") || inherits(x, "POSIXct")) return(as.Date(x))
  as.Date(suppressWarnings(readr::parse_date(as.character(x), format = "%d-%b-%y")))
}

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

# kumulative Anzahl der Arrangements je Land bis einschliesslich Jahr t
# (analog nrcntprogram im Original-Datensatz, dort Range 1-7; Caveat: Zaehlung
# beginnt mit unseren MONA-Daten im Jahr 2000, vor-2000-Programme fehlen bis
# zur Bereitstellung des erweiterten MONA-Exports)
nrcnt_arr <- arr_quarters %>%
  distinct(ISO3, Year, ARR) %>%
  count(ISO3, Year, name = "n_arr_jahr") %>%
  arrange(ISO3, Year) %>%
  group_by(ISO3) %>%
  mutate(nrcntprogram = cumsum(n_arr_jahr)) %>%
  ungroup() %>%
  select(ISO3, Year, nrcntprogram)

cat("Arrangements:", nrow(arr_quarters),
    "| Quartale: Range", paste(round(range(arr_quarters$quarters, na.rm = TRUE)), collapse = "-"),
    "| Median", median(arr_quarters$quarters, na.rm = TRUE),
    "| ohne Datum:", sum(is.na(arr_quarters$quarters)), "\n")

# ---------------------------------------------------------------------------
# 3) Aggregation auf Land-Jahr-Ebene
# ---------------------------------------------------------------------------
# count-basiert (Original-Spezifikation): Bedingungen / Programm-Quartale
q_agg <- arr_quarters %>%
  group_by(ISO3, Year) %>%
  summarise(nrquarterssmpl = sum(quarters, na.rm = TRUE), .groups = "drop")

mona_agg <- mona_all %>%
  group_by(ISO3, Year) %>%
  summarise(
    nrcondtype_all = n(),
    .groups = "drop"
  ) %>%
  left_join(q_agg, by = c("ISO3", "Year")) %>%
  left_join(nrcnt_arr, by = c("ISO3", "Year")) %>%
  mutate(
    # Count-basiert, wie im Original (dort: avgcondtype_all)
    avgcondtype_count = if_else(!is.na(nrquarterssmpl) & nrquarterssmpl > 0,
                                nrcondtype_all / nrquarterssmpl, NA_real_)
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

unsc_path <- "data/processed/unsc_dsv_rule_1946_2026.csv"
if (!file.exists(unsc_path)) {
  stop("DSV-UNSC-Regel fehlt: ", unsc_path,
       ". Bitte zuerst build_unsc_dsv_rule.R ausfuehren.")
}
unsc_data <- read.csv(unsc_path, stringsAsFactors = FALSE) %>%
  rename(Year = year, unsc3 = unsc3_dsv) %>%
  select(ISO3, Year, unsc, unsc3)
if (anyDuplicated(unsc_data[c("ISO3", "Year")])) {
  stop("DSV-UNSC-Regel enthaelt doppelte ISO3-Jahr-Schluessel.")
}

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
cat("UNSC-Mitgliedsjahre (unsc3==1):", sum(panel_all$unsc3 == 1, na.rm = TRUE), "\n")
cat("nrcntprogram: Range", paste(range(panel_all$nrcntprogram, na.rm = TRUE), collapse = "-"),
    "| Mean", round(mean(panel_all$nrcntprogram, na.rm = TRUE), 2), "\n")
cat("Complete Cases H1 count:", sum(complete.cases(panel_all[, c("avgcondtype_count", "unsc3", "XDebtGNI", "DebtServGNI", "ResXDebt")])), "\n")
write.csv(panel_all, "data/processed/final_data_panel_ALL.csv", row.names = FALSE)

cat("\n=== Abschluss ===\n")
cat("Erstellt: data/processed/mona_ALL.csv\n")
cat("Erstellt: data/processed/final_data_panel_ALL.csv\n")
cat("Depvar: avgcondtype_count (Original-Spezifikation); klassifikationsbasierte Outcomes ausgesetzt\n")
