# Build the Phase-B outcome for 1992-2025 with one MONA row-count and
# program-duration rule across the historical and current source files.

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(dplyr)
  library(haven)
  library(readxl)
})

analysis_start <- as.Date("1992-03-31")
analysis_end <- as.Date("2025-12-31")
stata_origin <- as.Date("1960-01-01")

parse_mona_date <- function(x) {
  if (inherits(x, "Date")) return(x)
  if (inherits(x, "POSIXt")) return(as.Date(x))
  if (is.numeric(x)) return(as.Date(x, origin = "1899-12-30"))

  value <- trimws(as.character(x))
  result <- as.Date(rep(NA_character_, length(value)))
  valid <- !is.na(value) & nzchar(value)

  iso <- valid & grepl("^\\d{4}-\\d{2}-\\d{2}$", value)
  result[iso] <- as.Date(value[iso], format = "%Y-%m-%d")

  slash <- valid & grepl("^\\d{1,2}/\\d{1,2}/\\d{2,4}$", value)
  if (any(slash)) {
    fields <- strsplit(value[slash], "/", fixed = TRUE)
    numbers <- do.call(rbind, lapply(fields, as.integer))
    year <- numbers[, 3]
    year[year < 100] <- ifelse(year[year < 100] <= 68,
                               year[year < 100] + 2000,
                               year[year < 100] + 1900)
    result[slash] <- as.Date(sprintf("%04d-%02d-%02d",
                                     year, numbers[, 1], numbers[, 2]))
  }

  named <- valid & grepl("^\\d{1,2}-[A-Za-z]{3}-\\d{2,4}$", value)
  if (any(named)) {
    fields <- regmatches(value[named], regexec(
      "^(\\d{1,2})-([A-Za-z]{3})-(\\d{2,4})$", value[named]
    ))
    parts <- do.call(rbind, lapply(fields, `[`, 2:4))
    month <- match(toupper(parts[, 2]), toupper(month.abb))
    year <- as.integer(parts[, 3])
    year[year < 100] <- ifelse(year[year < 100] <= 68,
                               year[year < 100] + 2000,
                               year[year < 100] + 1900)
    result[named] <- as.Date(sprintf("%04d-%02d-%02d",
                                     year, month, as.integer(parts[, 1])))
  }
  result
}

quarter_duration <- function(start, end) {
  start <- pmax(start, analysis_start)
  end <- pmin(end, analysis_end)
  days <- as.numeric(end - start)
  quarters <- floor(days / 90 + 0.5)
  ifelse(!is.na(days) & days > 0 & quarters > 0, quarters, NA_real_)
}

historical_path <- "data/raw/original/construction/Data MONA.dta"
modern_path <- "data/raw/mona/Combined_ISO.xlsx"
dsv_check_path <- "data/processed/conditionality_dsv_1992_2008.csv"
controls_path <- "data/processed/controls_wdi_1990_2025.csv"
unsc_path <- "data/processed/unsc_dsv_rule_1946_2026.csv"

required_files <- c(
  historical_path, modern_path, dsv_check_path,
  controls_path, unsc_path
)
missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files)) {
  stop("Erforderliche Eingabedatei(en) fehlen: ",
       paste(missing_files, collapse = ", "))
}

# Historical rows use the already validated DSV MONA extract.
historical_raw <- as.data.frame(read_dta(historical_path))
if (!all(c("programnr", "countryname", "wdicode", "approvalyear",
           "approvaldatestata", "enddatestata", "condtype_0") %in%
         names(historical_raw))) {
  stop("Unerwartetes Schema in Data MONA.dta.")
}
if (any(historical_raw$condtype_0 != 1, na.rm = TRUE)) {
  stop("Die historische DSV-Zähleinheit ist nicht mehr eine MONA-Zeile.")
}

historical_programs <- historical_raw %>%
  group_by(programnr) %>%
  summarise(
    ISO3 = case_when(
      first(wdicode) == "ROM" ~ "ROU",
      first(wdicode) == "ZAR" ~ "COD",
      first(wdicode) == "YUG" ~ "SRB",
      TRUE ~ first(wdicode)
    ),
    country = first(countryname),
    Year = as.integer(first(approvalyear)),
    approval = as.Date(first(approvaldatestata), origin = stata_origin),
    end = as.Date(max(enddatestata, na.rm = TRUE), origin = stata_origin),
    nrcondtype_all = sum(condtype_0, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    Year = case_when(
      country == "senegal" & approval == as.Date("1994-08-29") ~ 1995L,
      country == "uganda" & approval == as.Date("2006-12-15") ~ 2007L,
      TRUE ~ Year
    ),
    quarters = quarter_duration(approval, end),
    source = "historical_DSV_MONA"
  ) %>%
  filter(Year >= 1992, Year <= 2008)

# Current MONA begins the Phase-B series after the historical source period,
# avoiding duplicate country-years from overlapping source vintages.
modern_raw <- read_excel(modern_path, col_types = "text")
modern_required <- c(
  "Arrangement Number", "Country Name", "iso_3ltr", "Approval date",
  "Approval Year", "Initial End Date", "Revised End Date"
)
if (!all(modern_required %in% names(modern_raw))) {
  stop("Erforderliche Spalten fehlen in Combined_ISO.xlsx: ",
       paste(setdiff(modern_required, names(modern_raw)), collapse = ", "))
}

approval_dates <- parse_mona_date(modern_raw[["Approval date"]])
initial_end_dates <- parse_mona_date(modern_raw[["Initial End Date"]])
revised_end_dates <- parse_mona_date(modern_raw[["Revised End Date"]])
if (any(!is.na(modern_raw[["Approval date"]]) &
        is.na(approval_dates)) ||
    any(!is.na(modern_raw[["Initial End Date"]]) &
        is.na(initial_end_dates)) ||
    any(!is.na(modern_raw[["Revised End Date"]]) &
        is.na(revised_end_dates))) {
  stop("Mindestens ein MONA-Datum konnte nicht interpretiert werden.")
}

modern_rows <- modern_raw %>%
  transmute(
    arrangement = as.character(`Arrangement Number`),
    country = as.character(`Country Name`),
    ISO3 = as.character(iso_3ltr),
    Year = as.integer(`Approval Year`),
    approval = approval_dates,
    initial_end = initial_end_dates,
    revised_end = revised_end_dates
  ) %>%
  filter(
    !is.na(arrangement), !is.na(ISO3), !is.na(Year),
    !ISO3 %in% c("XA", "XK", "XS"), Year >= 2009, Year <= 2025
  ) %>%
  mutate(
    ISO3 = if_else(ISO3 == "KANN", "KNA", ISO3),
    end = coalesce(revised_end, initial_end)
  )

modern_programs <- modern_rows %>%
  group_by(arrangement, ISO3, Year) %>%
  summarise(
    country = first(country),
    approval = if (all(is.na(approval))) as.Date(NA) else min(approval, na.rm = TRUE),
    end = if (all(is.na(end))) as.Date(NA) else max(end, na.rm = TRUE),
    nrcondtype_all = n(),
    .groups = "drop"
  ) %>%
  mutate(
    quarters = quarter_duration(approval, end),
    source = "current_Combined_ISO"
  )

programs <- bind_rows(
  historical_programs %>%
    select(ISO3, country, Year, nrcondtype_all, quarters, source),
  modern_programs %>%
    select(ISO3, country, Year, nrcondtype_all, quarters, source)
)

if (any(programs$Year[programs$source == "historical_DSV_MONA"] > 2008) ||
    any(programs$Year[programs$source == "current_Combined_ISO"] < 2009)) {
  stop("Die Quellperioden überschneiden sich oder enthalten eine Lücke.")
}

# Confirm that historical condition-row counts preserve the validated DSV count.
dsv_check <- read.csv(dsv_check_path, stringsAsFactors = FALSE) %>%
  group_by(ISO3, Year) %>%
  summarise(dsv_nrcondtype_all = sum(nrcondtype_all), .groups = "drop")
historical_counts <- programs %>%
  filter(source == "historical_DSV_MONA") %>%
  group_by(ISO3, Year) %>%
  summarise(nrcondtype_all = sum(nrcondtype_all), .groups = "drop") %>%
  full_join(dsv_check, by = c("ISO3", "Year"))
if (anyNA(historical_counts$nrcondtype_all) ||
    anyNA(historical_counts$dsv_nrcondtype_all) ||
    any(historical_counts$nrcondtype_all != historical_counts$dsv_nrcondtype_all)) {
  stop("Historische Zeilenzählung stimmt nicht mit dem validierten DSV-Output überein.")
}

panel <- programs %>%
  group_by(ISO3, Year) %>%
  summarise(
    country = first(country),
    nrcondtype_all = sum(nrcondtype_all),
    nrquarterssmpl = if (all(is.na(quarters))) NA_real_ else max(quarters, na.rm = TRUE),
    source = first(source),
    .groups = "drop"
  ) %>%
  mutate(
    avgcondtype_count = if_else(
      !is.na(nrquarterssmpl) & nrquarterssmpl > 0,
      nrcondtype_all / nrquarterssmpl,
      NA_real_
    )
  ) %>%
  arrange(ISO3, Year) %>%
  group_by(ISO3) %>%
  mutate(nrcntprogram = row_number()) %>%
  ungroup()

controls <- read.csv(controls_path, stringsAsFactors = FALSE)
unsc <- read.csv(unsc_path, stringsAsFactors = FALSE) %>%
  transmute(ISO3, Year = year, unsc, unsc3 = unsc3_dsv)
if (anyDuplicated(controls[c("ISO3", "Year")]) ||
    anyDuplicated(unsc[c("ISO3", "Year")])) {
  stop("Kontroll- oder UNSC-Panel enthält doppelte ISO3-Jahr-Schlüssel.")
}

panel <- panel %>%
  left_join(controls, by = c("ISO3", "Year")) %>%
  left_join(unsc, by = c("ISO3", "Year"))

if (anyNA(panel$unsc3)) stop("UNSC-Daten fehlen für mindestens eine Panelzeile.")
if (anyDuplicated(panel[c("ISO3", "Year")])) {
  stop("Das fertige Phase-B-Panel enthält doppelte ISO3-Jahr-Schlüssel.")
}
if (min(panel$Year) != 1992 || max(panel$Year) != 2025) {
  stop("Das fertige Panel deckt nicht den vollständigen Zeitraum 1992-2025 ab.")
}

output_path <- "data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
write.csv(panel, output_path, row.names = FALSE)

cat("Einheitliches Phase-B-Panel:", nrow(panel), "Land-Jahre |",
    n_distinct(panel$ISO3), "Laender |",
    min(panel$Year), "-", max(panel$Year), "\n")
cat("Quellenjahre: historisches DSV-MONA 1992-2008; Combined_ISO 2009-2025\n")
cat("Gleiche Regel: MONA-Zeilen je Programm zählen; Bedingungen des Land-Jahres",
    "durch die maximale Programmlaufzeit in 90-Tage-Quartalen teilen.\n")
cat("Klassifizierte AVs sind absichtlich nicht enthalten. Fuer H4 zuerst",
    "build_phase_a_definition_crosswalk.R und danach",
    "build_phase_b_h4_panel.R ausfuehren.\n")
cat("H1/H2 mit vollständigen Kontrollen:",
    sum(complete.cases(panel[, c(
      "avgcondtype_count", "unsc3", "XDebtGNI", "DebtServGNI", "ResXDebt"
    )])), "\n")
missing_outcome <- panel %>%
  filter(is.na(avgcondtype_count)) %>%
  select(ISO3, Year, source)
if (nrow(missing_outcome)) {
  cat("Land-Jahre ohne berechenbare Zähl-AV (fehlende Programmlaufzeit):\n")
  print(missing_outcome, n = Inf)
}
cat("Gespeichert:", output_path, "\n")
