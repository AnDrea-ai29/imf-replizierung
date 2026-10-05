# Apply the shared Phase-A definition rules to modern MONA descriptions.

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages(library(readxl))
source("code/shared/data_prep/phase_a_definition_rules.R")

source_path <- "data/raw/mona/Combined_ISO.xlsx"
phase_a_reference_path <- "data/processed/Conddisc_final.csv"
output_path <- "data/processed/phase_b_classification_crosswalk.csv"
if (!file.exists(source_path)) stop("MONA-Export fehlt: ", source_path)
if (!file.exists(phase_a_reference_path)) {
  stop("Kuratierte Phase-A-Referenz fehlt: ", phase_a_reference_path)
}

mona <- read_excel(source_path, col_types = "text")
required <- c(
  "Economic Code", "Economic Descriptor", "Description", "Approval Year"
)
if (!all(required %in% names(mona))) {
  stop("MONA-Export benoetigt: ", paste(required, collapse = ", "))
}

approval_year <- suppressWarnings(as.integer(mona[["Approval Year"]]))
in_scope <- !is.na(approval_year) & approval_year >= 2009 & approval_year <= 2025
modern <- mona[in_scope, , drop = FALSE]
modern$economic_code <- trimws(as.character(modern[["Economic Code"]]))
modern$economic_descriptor <- trimws(
  as.character(modern[["Economic Descriptor"]])
)
modern$description <- trimws(as.character(modern[["Description"]]))
if (anyNA(modern[c("economic_code", "economic_descriptor", "description")]) ||
    any(!nzchar(modern$economic_descriptor)) ||
    any(!nzchar(modern$description))) {
  stop("Moderne MONA-Zeilen haben fehlende Klassifikationsschluessel.")
}

key_columns <- c(
  "economic_code", "economic_descriptor", "description"
)
crosswalk <- stats::aggregate(
  x = list(n_conditions = rep(1L, nrow(modern))),
  by = modern[key_columns],
  FUN = sum
)
crosswalk$n_conditions <- as.integer(crosswalk$n_conditions)
signals <- classify_phase_a_definition(crosswalk$description)
crosswalk$rohstoff_final <- signals$rohstoff_final
crosswalk$stabil_final <- signals$stabil_final
crosswalk$cooking_oil_ausgeschlossen <-
  signals$cooking_oil_ausgeschlossen
crosswalk$beschreibung_fehlend <- signals$beschreibung_fehlend
crosswalk$klassifikationsregel_version <-
  phase_a_definition_rule_version
crosswalk$phase_a_reference_md5 <-
  unname(tools::md5sum(phase_a_reference_path))
crosswalk$modern_source_md5 <- unname(tools::md5sum(source_path))
crosswalk <- crosswalk[order(
  crosswalk$economic_descriptor, crosswalk$economic_code,
  crosswalk$description
), ]

if (anyDuplicated(crosswalk[key_columns]) ||
    anyNA(crosswalk$rohstoff_final) || anyNA(crosswalk$stabil_final) ||
    any(!crosswalk$rohstoff_final %in% c(0L, 1L)) ||
    any(!crosswalk$stabil_final %in% c(0L, 1L)) ||
    sum(crosswalk$n_conditions) != nrow(modern)) {
  stop("Crosswalk-Validierung fehlgeschlagen.")
}

write.csv(crosswalk, output_path, row.names = FALSE, na = "")
cat(
  "Phase-A-definitionsbasierter Crosswalk:", nrow(crosswalk),
  "Schluessel |", sum(crosswalk$n_conditions),
  "MONA-Bedingungen | Rohstoff:", sum(
    crosswalk$n_conditions[crosswalk$rohstoff_final == 1L]
  ),
  "| Stabilisierung:", sum(
    crosswalk$n_conditions[crosswalk$stabil_final == 1L]
  ), "\n"
)
cat("Regelversion:", phase_a_definition_rule_version, "\n")
cat("Gespeichert:", output_path, "\n")
