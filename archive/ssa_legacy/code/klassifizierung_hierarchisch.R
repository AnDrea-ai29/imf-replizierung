# ============================================================================
# Hierarchische Klassifizierung der MONA-Bedingungen (angepasste Version)
# Tag 3-Korrektur: Ersetzt die reine Keyword-Klassifizierung durch eine
# hierarchische Regelbasierte Klassifizierung (3 Stufen + Kombination).
#
# Stufe 1: Economic Descriptor (numerierte IMF-Kategorien, Primaer)
#   Rohstoff-spezifisch:
#     - "11.2. natural resource and agricultural policies" (Mining, Forst,
#       Rohstoffpolitik)
#     - "5.1. public enterprise pricing and subsidies" (Petroleum-Preise,
#       Brennstoffsubventionen)
#   Stabilisierend:
#     - "1.x" (Fiskal: Haushalt, Steuern, Schulden, Ausgaben)
#     - "2.x" (Zentralbank/monetaer)
#   Der Key Code (PA, SAC, SB, SPC) ist ein Instrumententyp KEINE
#   Inhaltskategorie und wird daher nicht als Klassifizierungsstufe
#   verwendet (85% der SPC/SAC-Bedingungen haben keinen Rohstoffbehalt).
#
# Stufe 2: Description (Text-Matching, 16 Rohstoff- / 11 Stabilisierungs-
#   Keywords, wie in klassifizierung_dokumentation.md Stufe 3)
#
# Stufe 3: Kombination via pmax() - 1, wenn mindestens eine Stufe positiv
#
# Ausgaben:
#   - data/processed/data_with_cond_types.csv (erneuert)
#   - data/processed/conditions_classified_hierarchisch.csv (Bedingungs-
#     Ebene, fuer Transparenz/Beispieltabellen)
# ============================================================================

setwd("C:/Users/HP/io/imf-replizierung")
library(readxl)
library(stringr)
library(dplyr)

ssa_countries <- c("AGO", "CAF", "CMR", "COM", "CPV", "GAB", "GHA", "GIN", "KEN", "LSO",
                   "MDG", "MOZ", "MRT", "MWI", "RWA", "SLE", "SLV", "TZA", "UGA", "ZMB")

# ---------------------------------------------------------------------------
# 1. MONA-Rohdaten laden und auf SSA filtern
# ---------------------------------------------------------------------------
mona_raw <- read_excel("data/raw/mona/Combined_ISO.xlsx")
mona_ssa <- mona_raw %>%
  filter(iso_3ltr %in% ssa_countries) %>%
  rename(ISO3 = iso_3ltr, Year = `Approval Year`)

cat("Bedingungen (SSA, 2002-2025):", nrow(mona_ssa), "\n")

# ---------------------------------------------------------------------------
# 2. Stufe 1: Economic Descriptor (numerierte IMF-Kategorien)
# ---------------------------------------------------------------------------
ed <- trimws(tolower(mona_ssa[["Economic Descriptor"]]))

mona_ssa <- mona_ssa %>%
  mutate(
    rohstoff_desc = as.numeric(
      startsWith(ed, "11.2") |          # natural resource and agricultural policies
      startsWith(ed, "5.1.")            # public enterprise pricing and subsidies
    ),
    stabil_desc = as.numeric(
      startsWith(ed, "1.") |            # Fiskal (Haushalt, Steuern, Schulden)
      startsWith(ed, "2.")              # Zentralbank / monetaer
    )
  )

cat("Stufe 1 (Descriptor): rohstoff =", sum(mona_ssa$rohstoff_desc),
    "| stabil =", sum(mona_ssa$stabil_desc), "\n")

# ---------------------------------------------------------------------------
# 3. Stufe 2: Description (Text-Matching)
# ---------------------------------------------------------------------------
rohstoff_keywords <- c(
  "fuel", "mineral", "oil", "gas", "extractive", "petroleum",
  "crude", "hydrocarbon", "mining", "privatization", "subsidy",
  "energy", "resource", "commodity", "export", "tax.*resource"
)

stabil_keywords <- c(
  "fiscal", "inflation", "budget", "debt", "deficit", "surplus",
  "reserve", "monetary", "interest", "exchange", "balance"
)

desc_lower <- tolower(mona_ssa[["Description"]])

mona_ssa <- mona_ssa %>%
  mutate(
    rohstoff_text = as.numeric(
      str_detect(desc_lower, paste(rohstoff_keywords, collapse = "|"))
    ),
    stabil_text = as.numeric(
      str_detect(desc_lower, paste(stabil_keywords, collapse = "|"))
    )
  )

cat("Stufe 2 (Description): rohstoff =", sum(mona_ssa$rohstoff_text),
    "| stabil =", sum(mona_ssa$stabil_text), "\n")

# ---------------------------------------------------------------------------
# 4. Stufe 3: Kombination (pmax) und Sonstige
# ---------------------------------------------------------------------------
conditions_classified <- mona_ssa %>%
  mutate(
    rohstoff_cond = pmax(rohstoff_desc, rohstoff_text),
    stabil_cond   = pmax(stabil_desc, stabil_text),
    sonstige_cond = ifelse(rohstoff_cond == 1 | stabil_cond == 1, 0, 1)
  )

cat("Final: rohstoff =", sum(conditions_classified$rohstoff_cond),
    "| stabil =", sum(conditions_classified$stabil_cond),
    "| sonstige =", sum(conditions_classified$sonstige_cond), "\n")
cat("Nur durch Stufe 1 zusätzlich erkannt (rohstoff):",
    sum(conditions_classified$rohstoff_cond == 1 &
          conditions_classified$rohstoff_text == 0), "\n")

# Bedingungs-Ebene speichern (Transparenz / Beispieltabellen Hausarbeit)
conditions_classified %>%
  select(ISO3, Year, `Arrangement Number`, `Key Code`,
         `Economic Descriptor`, Description,
         rohstoff_desc, rohstoff_text, rohstoff_cond,
         stabil_desc, stabil_text, stabil_cond, sonstige_cond) %>%
  write.csv("data/processed/conditions_classified_hierarchisch.csv",
            row.names = FALSE, fileEncoding = "UTF-8")

# ---------------------------------------------------------------------------
# 5. Aggregation auf Land-Jahr-Ebene
# ---------------------------------------------------------------------------
cond_summary <- conditions_classified %>%
  group_by(ISO3, Year) %>%
  summarise(
    total_cond          = n(),
    rohstoff_cond       = sum(rohstoff_cond, na.rm = TRUE),
    stabil_cond         = sum(stabil_cond, na.rm = TRUE),
    sonstige_cond       = sum(sonstige_cond, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    # Anteile NACH der Aggregation berechnen: in summarise() wuerde
    # mean(rohstoff_cond) aufgrund der dplyr-Sequenzsemantik auf die
    # gerade erzeugte Summe zugreifen (Fehler der alten Version:
    # "share" enthielt Anzahlwerte statt Anteile)
    rohstoff_cond_share = rohstoff_cond / total_cond,
    stabil_cond_share   = stabil_cond / total_cond
  )

# ---------------------------------------------------------------------------
# 6. Bestehenden Panel-Datensatz aktualisieren
#    (nur die Klassifizierungsvariablen werden ersetzt, Panel + WDI bleiben
#    unveraendert; avgcondtype_all und unsc3 sind von der Klassifizierung
#    nicht betroffen => model_repl / H1 unveraendert)
# ---------------------------------------------------------------------------
data_with_cond_types <- read.csv("data/processed/data_with_cond_types.csv",
                                 check.names = FALSE, fileEncoding = "UTF-8")

cond_cols <- c("total_cond", "rohstoff_cond", "stabil_cond", "sonstige_cond",
               "rohstoff_cond_share", "stabil_cond_share")

data_new <- data_with_cond_types %>%
  select(-all_of(cond_cols)) %>%
  left_join(cond_summary, by = c("ISO3", "Year"))

# Land-Jahre ohne Bedingungen: 0 (wie bisher)
data_new[cond_cols][is.na(data_new[cond_cols])] <- 0

# Spaltenreihenfolge wie im Original
col_order <- c("ISO3", "Year", "unsc", "unsc_t1", "unsc3",
               "nrcondtype_pc", "nrcondtype_pa", "nrcondtype_sb",
               "nrcondtype_all", "avgcondtype_all", "avgcondtype_pc",
               "avgcondtype_pa", "avgcondtype_sb",
               "FuelExportPct", "MineralExportPct",
               "XDebtGNI", "DebtServGNI", "ResXDebt",
               "Rohstoffabhängigkeit", cond_cols)
data_new <- data_new[, col_order]

write.csv(data_new, "data/processed/data_with_cond_types.csv",
          row.names = FALSE, fileEncoding = "UTF-8")

# ---------------------------------------------------------------------------
# 7. Vergleich: neue hierarchische Klassifizierung vs. alte reine
#    Keyword-Klassifizierung (hier neu und korrekt als Anteil berechnet;
#    die alte Datei enthielt durch den summarise()-Bug Anzahlwerte)
# ---------------------------------------------------------------------------
alt_kw <- conditions_classified %>%
  group_by(ISO3, Year) %>%
  summarise(
    rohstoff_share_kw = mean(rohstoff_text, na.rm = TRUE),
    stabil_share_kw   = mean(stabil_text, na.rm = TRUE),
    .groups = "drop"
  )

cmp <- data_new %>%
  select(ISO3, Year, rohstoff_cond_share_new = rohstoff_cond_share,
         stabil_cond_share_new = stabil_cond_share) %>%
  left_join(alt_kw, by = c("ISO3", "Year"))

cat("\n=== VERGLEICH alt (nur Keywords, korrekt) vs. neu (hierarchisch) ===\n")
cat("Zeilen:", nrow(data_new), "(erwartet: 480)\n")
cat("rohstoff_cond_share range:", range(data_new$rohstoff_cond_share),
    "| stabil_cond_share range:", range(data_new$stabil_cond_share),
    "(erwartet: je 0 bis 1)\n")
cat("Land-Jahre ohne MONA-Bedingungen (Anteil NA im Alt-Vergleich):",
    sum(is.na(cmp$rohstoff_share_kw)), "\n")
cmp_ok <- cmp[!is.na(cmp$rohstoff_share_kw), ]
cat("Rohstoff-Anteil (Mittelwert, nur Land-Jahre mit Bedingungen):",
    "alt =", round(mean(cmp_ok$rohstoff_share_kw), 3),
    "| neu =", round(mean(cmp_ok$rohstoff_cond_share_new), 3), "\n")
cat("Stabilisierungs-Anteil (Mittelwert, nur Land-Jahre mit Bedingungen):",
    "alt =", round(mean(cmp_ok$stabil_share_kw), 3),
    "| neu =", round(mean(cmp_ok$stabil_cond_share_new), 3), "\n")
cat("Rohstoff-Anteil (Mittelwert, alle 480 Land-Jahre):",
    "neu =", round(mean(data_new$rohstoff_cond_share), 3), "\n")
cat("Stabilisierungs-Anteil (Mittelwert, alle 480 Land-Jahre):",
    "neu =", round(mean(data_new$stabil_cond_share), 3), "\n")
cat("Korrelation rohstoff_cond_share alt/neu:",
    round(cor(cmp$rohstoff_share_kw, cmp$rohstoff_cond_share_new,
              use = "complete.obs"), 3), "\n")
cat("Rohstoff-Bedingungen gesamt: neu =", sum(data_new$rohstoff_cond), "\n")
cat("Land-Jahre mit >0 rohstoff-spezifischen Bedingungen: neu =",
    sum(data_new$rohstoff_cond > 0), "\n")
cat("data_with_cond_types.csv aktualisiert.\n")
