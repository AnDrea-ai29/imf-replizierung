# Shared operationalization of the Phase-A proposal patterns for H4.
phase_a_definition_rule_version <- "phase-a-definition-aligned-v1"

phase_a_resource_pattern <- paste(
  "\\b(oils?|gas(es)?|petroleum|crude(\\s+oil)?|hydrocarbons?|fuels?|",
  "minerals?|mining|mine\\b|extractive|ore(s)?|",
  "petrol(\\s+(price|fund|eum))?)\\b",
  sep = ""
)
phase_a_stability_pattern <- paste(
  "\\b(fiscal|inflation(ary)?|budget(ary|\\s+deficit)?|deficit[s]?|",
  "surplus(es)?|reserves?|monetary|money|interest\\s+(rates?|payments?)|",
  "exchange\\s+(rate|system|regime)|balance\\s+of\\s+payments?|",
  "debt(s)?|borrowing|external\\s+payments?)\\b",
  sep = ""
)
phase_a_food_oil_pattern <- "\\b(cooking|edible)\\s+oils?\\b"

normalize_phase_a_description <- function(description) {
  normalized <- tolower(trimws(as.character(description)))
  normalized[is.na(normalized)] <- ""
  normalized[
    normalized == "gross issuance of promissory notes by govt"
  ] <- "gross issuance of promissory notes by government"
  normalized
}

classify_phase_a_definition <- function(description) {
  normalized <- normalize_phase_a_description(description)
  resource_text <- gsub(
    phase_a_food_oil_pattern, " ", normalized,
    ignore.case = TRUE, perl = TRUE
  )
  data.frame(
    description_normalized = normalized,
    beschreibung_fehlend = !nzchar(normalized),
    rohstoff_final = as.integer(grepl(
      phase_a_resource_pattern, resource_text,
      ignore.case = TRUE, perl = TRUE
    )),
    stabil_final = as.integer(grepl(
      phase_a_stability_pattern, normalized,
      ignore.case = TRUE, perl = TRUE
    )),
    cooking_oil_ausgeschlossen = grepl(
      phase_a_food_oil_pattern, normalized,
      ignore.case = TRUE, perl = TRUE
    ),
    stringsAsFactors = FALSE
  )
}
