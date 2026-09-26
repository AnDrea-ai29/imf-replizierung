# Kuratierte Ressourcen-/Stabilisierungsklassifikation der MONA-Bedingungen
#
# Problem (diagnostiziert 2026-09-26): Die bisherige Stichwort-Klassifikation
# in hypothesen_original_basis.R hat nachweisbare Fehltreffer, z. B. wird
# "restructuring & privatization of financial institutions" (137 Zeilen,
# Banken!) wegen des Stichworts "privatization" als rohstoff-bezogen
# klassifiziert. Stichworte wie export/subsidy/privatization sind zu breit.
#
# Loesung: Klassifikation auf Ebene der EINDEUTIGEN areadescription
# (= offizieller MONA-Kategorietext; 1.636 eindeutige Werte auf 22.810
# Bedingungszeilen, Top-200 decken 90 % aller Zeilen ab). Statt Inline-Regex:
# kuratiertes Woerterbuch je Beschreibung, manuell reviewbar.
#
# Vorgehen:
#   1. Dieses Skript erzeugt data/processed/bedingungsbeschreibungen_review.csv:
#      je eindeutiger Beschreibung: Zeilenanzahl, DSV-areaclass(en) der Autoren
#      (Handkodierung als Validierungsinstanz), alte Keyword-Flags (Vergleich),
#      konservative VORSCHLAGS-Kodierung (nur extraktiv-spezifische Begriffe
#      mit Wortgrenzen), zu pruefende Spalten rohstoff_final/stabil_final
#      (initial = Vorschlag) und Pruefhinweise fuer ambivalente Treffer.
#   2. AUTOR REVIEWED die Datei: mindestens die Top-200-Beschreibungen (90 %
#      Zeilendeckung) durchgehen, rohstoff_final/stabil_final korrigieren,
#      Pruefhinweise abarbeiten. Jede Aenderung ist damit dokumentiert und
#      verteidigbar (Dozentinnen-Anforderung).
#   3. hypothesen_original_basis.R liest die Review-Datei und klassifiziert
#      per Join auf die eindeutige Beschreibung — kein Inline-Regex mehr.
#
# Definitionsvorschlag (schriftlich fixieren, s. PROTOKOLL Session 7):
#   rohstoff = Bedingung, deren Gegenstand der extraktive Sektor ist:
#     Kraftstoffe/Energie-Rohstoffe (fuel, oil, petroleum, crude, hydrocarbon,
#     gas) oder Bergbau/Mineralien (mining, minerals, extractive) inkl.
#     rohstoffspezifischer Fiskaloperationen (oelfonds, mineral royalties).
#   energie  = Sensitivitaetskategorie: Energie/Brennstoffe breiter
#     (energy, electricity, power sector, coal) — NICHT identisch mit
#     Extraktivsektor; nur fuer Robustheitsvarianten.
#   stabil   = makro-stabilisierende Bedingungen (Fiskal, Geldmenge,
#     Zinsen, Wechselkurs, Reserven, Budget, Schulden).

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(haven)
  library(dplyr)
})

mona <- as.data.frame(read_dta(
  "data/raw/original/construction/Data MONA.dta"))

mona <- mona %>%
  mutate(
    desc = tolower(trimws(as.character(areadescription))),
    dsv  = trimws(as.character(areaclass))
  )

# ---------------------------------------------------------------------------
# Alte (breite) Keyword-Regel — nur noch zum Vergleich, nicht mehr massgeblich
# ---------------------------------------------------------------------------
alt_rohstoff <- "fuel|mineral|oil|gas|extractive|petroleum|crude|hydrocarbon|mining|privatization|subsidy|energy|resource|commodity|export|tax.*resource"
alt_stabil   <- "fiscal|inflation|budget|debt|deficit|surplus|reserve|monetary|interest|exchange|balance"

# ---------------------------------------------------------------------------
# Konservative Vorschlagsregeln (Wortgrenzen, nur extraktiv-spezifisch)
# ---------------------------------------------------------------------------
vorschlag_rohstoff <- paste(
  "\\b(oils?|gas(es)?|petroleum|crude(\\s+oil)?|hydrocarbons?|fuels?|",
  "minerals?|mining|mine\\b|extractive|ore(s)?|",
  "petrol(\\s+(price|fund|eum))?)\\b", sep = "")
vorschlag_stabil <- paste(
  "\\b(fiscal|inflation(ary)?|budget(ary|\\s+deficit)?|deficit[s]?|surplus(es)?|",
  "reserves?|monetary|money|interest\\s+(rates?|payments?)|",
  "exchange\\s+(rate|system|regime)|balance\\s+of\\s+payments?|",
  "debt(s)?|borrowing|external\\s+payments?)\\b", sep = "")
energie_regex <- "\\b(energy|electricity|power\\s+(sector|company|tariff)|coal|fuel\\s+(price|adjustment|tariff))\\b"

# Ambivalente Treffer kennzeichnen (manuell zu klaeren)
ambiguen_regex <- "edible oils|cooking oil"  # Agrar-Produkte, KEIN Extraktiv-Rohstoff

rev <- mona %>%
  mutate(
    rohstoff_kw_alt = as.integer(grepl(alt_rohstoff, desc)),
    stabil_kw_alt   = as.integer(grepl(alt_stabil, desc)),
    rohstoff_vorschlag = as.integer(grepl(vorschlag_rohstoff, desc)),
    stabil_vorschlag   = as.integer(grepl(vorschlag_stabil, desc)),
    energie_vorschlag  = as.integer(grepl(energie_regex, desc)),
    pruefhinweis = ifelse(grepl(ambiguen_regex, desc),
                          "ambivalent: edible oils = Agrar, klaren!", "")
  ) %>%
  group_by(desc) %>%
  summarise(
    n_rows = n(),
    rohstoff_kw_alt = max(rohstoff_kw_alt),
    stabil_kw_alt = max(stabil_kw_alt),
    rohstoff_vorschlag = max(rohstoff_vorschlag),
    stabil_vorschlag = max(stabil_vorschlag),
    energie_vorschlag = max(energie_vorschlag),
    pruefhinweis = first(pruefhinweis[pruefhinweis != ""]),
    dsv_klassen = paste(sort(unique(dsv[dsv != ""])), collapse = "; "),
    .groups = "drop"
  ) %>%
  mutate(
    # Manuell zu pruefende finale Kodierung; Startwert = Vorschlag
    rohstoff_final = rohstoff_vorschlag,
    stabil_final   = stabil_vorschlag
  ) %>%
  arrange(desc(n_rows))

write.csv(rev, "data/processed/bedingungsbeschreibungen_review.csv",
          row.names = FALSE)

# ---------------------------------------------------------------------------
# Diagnose: alt vs. Vorschlag, und Kohaerenz gegen DSV-Handkodierung
# ---------------------------------------------------------------------------
n_alt <- sum(mona$desc %in% rev$desc[rev$rohstoff_kw_alt == 1])
n_neu <- sum(mona$desc %in% rev$desc[rev$rohstoff_vorschlag == 1])
n_fin <- sum(mona$desc %in% rev$desc[rev$rohstoff_final == 1])
cat("=== Klassifikationsvergleich (auf 22.810 Bedingungszeilen) ===\n")
cat("Alt (breite Keywords):", n_alt, "Zeilen rohstoff\n")
cat("Vorschlag (extraktiv-spezifisch):", n_neu, "Zeilen rohstoff\n")
cat("Final (initial = Vorschlag):", n_fin, "Zeilen rohstoff\n\n")

neu_descs <- rev$desc[rev$rohstoff_vorschlag == 1]
tab <- mona %>%
  filter(desc %in% neu_descs) %>%
  count(dsv_kat = ifelse(dsv == "", "(leer)", dsv), sort = TRUE)
cat("=== DSV-areaclass der vorschlagsweise rohstoff-klassifizierten Zeilen ===\n")
print(as.data.frame(tab), row.names = FALSE)

cat("\n=== Top-15 haeufigste vorschlagsweise rohstoff-klassifizierte",
    "Beschreibungen ===\n")
print(as.data.frame(rev %>%
  filter(rohstoff_vorschlag == 1) %>%
  select(desc, n_rows, dsv_klassen) %>%
  head(15)), row.names = FALSE)

cat("\n=== Top-10 Beschreibungen, die ALT rohstoff waren, im Vorschlag",
    "aber nicht mehr ===\n")
print(as.data.frame(rev %>%
  filter(rohstoff_kw_alt == 1, rohstoff_vorschlag == 0) %>%
  select(desc, n_rows, dsv_klassen) %>%
  head(10)), row.names = FALSE)

cat("\nReview-Datei:", nrow(rev), "Beschreibungen ->",
    "data/processed/bedingungsbeschreibungen_review.csv\n")
cat("Top-200 decken", sprintf("%.0f%%", 100 * sum(head(rev$n_rows, 200)) / nrow(mona)),
    "aller Zeilen ab — mindestens diese manuell pruefen.\n")
