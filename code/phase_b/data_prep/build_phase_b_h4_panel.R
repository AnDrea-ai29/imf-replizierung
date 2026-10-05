# Apply one shared Phase-A-definition rule set to historical and modern MONA
# descriptions before aggregating H4 outcomes by country-year.

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(dplyr)
  library(haven)
  library(readxl)
})
source("code/shared/data_prep/phase_a_definition_rules.R")

stata_origin <- as.Date("1960-01-01")
historical_path <- "data/raw/original/construction/Data MONA.dta"
historical_review_path <- "data/processed/Conddisc_final.csv"
modern_path <- "data/raw/mona/Combined_ISO.xlsx"
classification_path <- "data/processed/phase_b_classification_crosswalk.csv"
panel_path <- "data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
missing_description_audit_path <-
  "data/processed/phase_b_h4_missing_description_audit.csv"
output_path <- "data/processed/phase_b_h4_panel_1992_2025.csv"

required_files <- c(
  historical_path, historical_review_path, modern_path,
  classification_path, panel_path
)
missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files)) {
  stop("Erforderliche Eingabedatei(en) fehlen: ",
       paste(missing_files, collapse = ", "))
}

make_key <- function(data, columns) {
  do.call(paste, c(data[columns], sep = "\r"))
}
classification_key <- c(
  "economic_code", "economic_descriptor", "description"
)

# Conddisc_final.csv is retained as the curated Phase-A reference; H4 uses
# the shared deterministic definition rules on both historical and modern text.
phase_a_reference <- read.csv(
  historical_review_path, stringsAsFactors = FALSE, na.strings = ""
)
if (!all(c("desc", "rohstoff_final", "stabil_final") %in%
         names(phase_a_reference)) ||
    anyDuplicated(phase_a_reference$desc)) {
  stop("Conddisc_final.csv hat kein eindeutiges Phase-A-Referenzschema.")
}
phase_a_reference_md5 <- unname(tools::md5sum(historical_review_path))
historical <- as.data.frame(read_dta(historical_path))
historical_required <- c(
  "condtype_0", "areadescription", "wdicode", "countryname",
  "approvalyear", "approvaldatestata"
)
if (!all(historical_required %in% names(historical))) {
  stop("Data MONA.dta fehlen erforderliche H4-Spalten.")
}
historical <- historical[historical$condtype_0 == 1, , drop = FALSE]
historical_signals <- classify_phase_a_definition(
  historical$areadescription
)
historical$rohstoff_final <- historical_signals$rohstoff_final
historical$stabil_final <- historical_signals$stabil_final
historical$cooking_oil_ausgeschlossen <-
  historical_signals$cooking_oil_ausgeschlossen
historical$beschreibung_fehlend <- historical_signals$beschreibung_fehlend
if (anyNA(historical$rohstoff_final) || anyNA(historical$stabil_final) ||
    any(!historical$rohstoff_final %in% c(0, 1)) ||
    any(!historical$stabil_final %in% c(0, 1))) {
  stop("Historische Phase-A-Klassifikation enthaelt ungueltige Flags.")
}

historical$ISO3 <- as.character(historical$wdicode)
historical$ISO3[historical$ISO3 == "ROM"] <- "ROU"
historical$ISO3[historical$ISO3 == "ZAR"] <- "COD"
historical$ISO3[historical$ISO3 == "YUG"] <- "SRB"
historical$Year <- as.integer(historical$approvalyear)
historical_country <- tolower(trimws(as.character(historical$countryname)))
historical_approval <- as.Date(
  historical$approvaldatestata,
  origin = stata_origin
)
historical$Year[
  historical_country == "senegal" &
    historical_approval == as.Date("1994-08-29")
] <- 1995L
historical$Year[
  historical_country == "uganda" &
    historical_approval == as.Date("2006-12-15")
] <- 2007L
historical <- historical[
  !is.na(historical$ISO3) &
    nzchar(historical$ISO3) &
    historical$Year >= 1992 & historical$Year <= 2008,
  ,
  drop = FALSE
]
missing_description_audit <- historical[
  historical$beschreibung_fehlend,
  c("ISO3", "Year"),
  drop = FALSE
]
missing_description_audit <- missing_description_audit %>%
  count(ISO3, Year, name = "n_missing_description_conditions") %>%
  arrange(ISO3, Year)
write.csv(
  missing_description_audit, missing_description_audit_path, ## audit ist eine Prüf- bzw. Nachvollziehbarkeitstabelle und macht fehlende Beschreibungen von historischen Bedingungen transparent
  row.names = FALSE
)


historical_classified <- historical %>%
  group_by(ISO3, Year) %>%
  summarise(
    nrcondtype_all_h4 = n(),
    rohstoff_cond = sum(rohstoff_final),
    stabil_cond = sum(stabil_final),
    rohstoff_cond_share = rohstoff_cond / nrcondtype_all_h4,
    stabil_cond_share = stabil_cond / nrcondtype_all_h4,
    classification_version = phase_a_definition_rule_version,
    .groups = "drop"
  )

# Modern observations join the generated condition-description-level crosswalk.
classification <- read.csv(
  classification_path,
  stringsAsFactors = FALSE,
  na.strings = "",
  colClasses = c(economic_code = "character")
)
classification_columns <- c(
  classification_key, "n_conditions", "rohstoff_final", "stabil_final",
  "cooking_oil_ausgeschlossen", "beschreibung_fehlend",
  "klassifikationsregel_version", "phase_a_reference_md5",
  "modern_source_md5"
)
if (!all(classification_columns %in% names(classification))) {
  stop("Die finale moderne Klassifikation hat nicht das erwartete Schema.")
}
if (anyDuplicated(classification[classification_key]) ||
    anyNA(classification$rohstoff_final) ||
    anyNA(classification$stabil_final) ||
    any(!classification$rohstoff_final %in% c(0, 1)) ||
    any(!classification$stabil_final %in% c(0, 1))) {
  stop("Finale moderne Klassifikation hat doppelte oder ungueltige Flags.")
}
rule_versions <- unique(classification$klassifikationsregel_version)
if (length(rule_versions) != 1L || is.na(rule_versions)) {
  stop("Moderne Klassifikation enthaelt keine eindeutige Regelversion.")
}
if (rule_versions[[1]] != phase_a_definition_rule_version) {
  stop("Der moderne Crosswalk nutzt nicht die aktive Phase-A-Regelversion.")
}

modern_raw <- read_excel(modern_path, col_types = "text")
modern_required <- c(
  "Economic Code", "Economic Descriptor", "Description",
  "iso_3ltr", "Approval Year"
)
if (!all(modern_required %in% names(modern_raw))) {
  stop("Combined_ISO.xlsx fehlen notwendige H4-Spalten: ",
       paste(setdiff(modern_required, names(modern_raw)), collapse = ", "))
}
approval_year <- suppressWarnings(as.integer(modern_raw[["Approval Year"]]))
modern <- modern_raw[
  !is.na(approval_year) & approval_year >= 2009 & approval_year <= 2025,
  ,
  drop = FALSE
]
modern$economic_code <- trimws(as.character(modern[["Economic Code"]]))
modern$economic_descriptor <- trimws(
  as.character(modern[["Economic Descriptor"]])
)
modern$description <- as.character(modern[["Description"]])
modern$ISO3 <- trimws(as.character(modern[["iso_3ltr"]]))
modern$ISO3[modern$ISO3 == "KANN"] <- "KNA"
modern$Year <- suppressWarnings(as.integer(modern[["Approval Year"]]))
if (anyNA(modern[c(classification_key, "ISO3", "Year")])) {
  stop("Moderne MONA-Zeilen haben fehlende H4-Schluessel oder Land-Jahr-Werte.")
}

classification_keys <- make_key(classification, classification_key)
modern_all_keys <- make_key(modern, classification_key)
actual_counts <- as.data.frame(table(modern_all_keys), stringsAsFactors = FALSE)
names(actual_counts) <- c("classification_key", "actual_n_conditions")
expected_counts <- data.frame(
  classification_key = classification_keys,
  expected_n_conditions = classification$n_conditions,
  stringsAsFactors = FALSE
)
count_index <- match(
  expected_counts$classification_key,
  actual_counts$classification_key
)
if (anyNA(count_index) ||
    any(expected_counts$expected_n_conditions !=
          actual_counts$actual_n_conditions[count_index])) {
  stop("Finale Klassifikationshaeufigkeiten stimmen nicht mit Combined_ISO ueberein.")
}

modern <- modern[
  !is.na(modern$ISO3) &
    nzchar(modern$ISO3) &
    !modern$ISO3 %in% c("XA", "XK", "XS"),
  ,
  drop = FALSE
]
modern_index <- match(
  make_key(modern, classification_key),
  classification_keys
)
if (anyNA(modern_index)) {
  stop(
    "Finale Klassifikation deckt nicht alle modernen Analysezeilen ab: ",
    sum(is.na(modern_index))
  )
}
modern$rohstoff_final <- classification$rohstoff_final[modern_index]
modern$stabil_final <- classification$stabil_final[modern_index]
modern$cooking_oil_ausgeschlossen <-
  classification$cooking_oil_ausgeschlossen[modern_index]
modern$beschreibung_fehlend <-
  classification$beschreibung_fehlend[modern_index]
modern_classified <- modern %>%
  group_by(ISO3, Year) %>%
  summarise(
    nrcondtype_all_h4 = n(),
    rohstoff_cond = sum(rohstoff_final),
    stabil_cond = sum(stabil_final),
    rohstoff_cond_share = rohstoff_cond / nrcondtype_all_h4,
    stabil_cond_share = stabil_cond / nrcondtype_all_h4,
    classification_version = rule_versions[[1]],
    .groups = "drop"
  )

classified <- bind_rows(historical_classified, modern_classified)
if (anyDuplicated(classified[c("ISO3", "Year")])) {
  stop("Klassifiziertes H4-Panel hat doppelte Land-Jahr-Schluessel.")
}

panel <- read.csv(panel_path, stringsAsFactors = FALSE)
if (!all(c("ISO3", "Year", "nrcondtype_all") %in% names(panel)) ||
    anyDuplicated(panel[c("ISO3", "Year")])) {
  stop("Einheitliches Phase-B-Panel hat kein eindeutiges erwartetes Schema.")
}
panel_keys <- make_key(panel, c("ISO3", "Year"))
classified_keys <- make_key(classified, c("ISO3", "Year"))
if (!setequal(panel_keys, classified_keys)) {
  stop("Klassifizierte H4-Land-Jahre decken das aktive Phase-B-Panel nicht exakt ab.")
}

h4_panel <- panel %>%
  left_join(classified, by = c("ISO3", "Year"))
if (nrow(h4_panel) != nrow(panel) ||
    anyNA(h4_panel$rohstoff_cond_share) ||
    any(h4_panel$nrcondtype_all != h4_panel$nrcondtype_all_h4)) {
  stop("H4-Join oder Bedingungszaehler weicht vom aktiven Phase-B-Panel ab.")
}
if (any(h4_panel$rohstoff_cond_share < 0 |
        h4_panel$rohstoff_cond_share > 1, na.rm = TRUE)) {
  stop("Rohstoffanteil liegt ausserhalb [0, 1].")
}

dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
write.csv(h4_panel, output_path, row.names = FALSE, na = "")

cat(
  "H4-Panel:", nrow(h4_panel), "Land-Jahre |",
  n_distinct(h4_panel$ISO3), "Laender |",
  min(h4_panel$Year), "-", max(h4_panel$Year), "\n"
)
cat(
  "Historisch klassifizierte Zeilen:", sum(historical_classified$nrcondtype_all_h4),
  "| moderne klassifizierte Zeilen:", sum(modern_classified$nrcondtype_all_h4),
  "| Rohstoffbedingungen gesamt:", sum(h4_panel$rohstoff_cond), "\n"
)
cat(
  "Historische MONA-Zeilen ohne areadescription (als kein Signal = 0):",
  sum(missing_description_audit$n_missing_description_conditions),
  "| Audit:", missing_description_audit_path, "\n"
)
cat(
  "Einheitliche Klassifikationsregelversion:", rule_versions[[1]],
  "| Phase-A-Referenz:", phase_a_reference_md5, "\n"
)
cat("Gespeichert:", output_path, "\n")
