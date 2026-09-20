# ============================================================================
# SKRIPT: FINALEN DATENSATZ ERSTELLEN (Tag 2)
# ============================================================================
# Ziel: Kombiniert mona_ssa_mea.csv + wdi_ssa_mea.csv + unsc_ssa_mea.csv
# Ergebnis: final_data_ssa_mea.csv

# ============================================================================
# 1. DATEIEN LADEN
# ============================================================================

cat("\n=== Tag 2: Finalen Datensatz erstellen ===\n\n")

# Pfade zu den gefilterten Dateien
mona_file <- "C:/Users/HP/io/imf-replizierung/data/processed/mona_ssa_mea.csv"
wdi_file <- "C:/Users/HP/io/imf-replizierung/data/processed/wdi_ssa_mea.csv"
unsc_file <- "C:/Users/HP/io/imf-replizierung/data/processed/unsc_ssa_mea.csv"
output_file <- "C:/Users/HP/io/imf-replizierung/data/processed/final_data_ssa_mea.csv"

# 1.1 MONA-Daten laden
cat("[1/4] Lade MONA-Daten...\n")
if (file.exists(mona_file)) {
  mona_data <- read.csv(mona_file, stringsAsFactors = FALSE)
  cat("✓ MONA geladen. Zeilen:", nrow(mona_data), "\n")
  cat("  Spalten:", paste(names(mona_data), collapse = ", "), "\n")
} else {
  stop("❌ FEHLER: MONA-Datei nicht gefunden: ", mona_file)
}

# 1.2 WDI-Daten laden
cat("\n[2/4] Lade WDI-Daten...\n")
if (file.exists(wdi_file)) {
  wdi_data <- read.csv(wdi_file, stringsAsFactors = FALSE)
  cat("✓ WDI geladen. Zeilen:", nrow(wdi_data), "\n")
  cat("  Spalten:", paste(names(wdi_data), collapse = ", "), "\n")
} else {
  stop("❌ FEHLER: WDI-Datei nicht gefunden: ", wdi_file)
}

# 1.3 UNSC-Daten laden
cat("\n[3/4] Lade UNSC-Daten...\n")
if (file.exists(unsc_file)) {
  unsc_data <- read.csv(unsc_file, stringsAsFactors = FALSE)
  cat("✓ UNSC geladen. Zeilen:", nrow(unsc_data), "\n")
  cat("  Spalten:", paste(names(unsc_data), collapse = ", "), "\n")
} else {
  stop("❌ FEHLER: UNSC-Datei nicht gefunden: ", unsc_file)
}

# ============================================================================
# 2. SPALTENNAMEN PRÜFEN UND VEREINHEITLICHEN
# ============================================================================

cat("\n[4/4] Prüfe Spaltennamen...\n")

# MONA: Ländercode-Spalte (sollte ISO3 sein)
mona_country_col <- ifelse("ISO3" %in% names(mona_data), "ISO3", 
                          ifelse("country_code" %in% names(mona_data), "country_code", 
                                 ifelse("wdicode" %in% names(mona_data), "wdicode", NULL)))

# WDI: Ländercode-Spalte
wdi_country_col <- ifelse("country_code" %in% names(wdi_data), "country_code", 
                         ifelse("ISO3" %in% names(wdi_data), "ISO3", 
                                ifelse("wdicode" %in% names(wdi_data), "wdicode", NULL)))

# UNSC: Ländercode-Spalte
unsc_country_col <- ifelse("wdicode" %in% names(unsc_data), "wdicode", 
                          ifelse("ISO3" %in% names(unsc_data), "ISO3", 
                                 ifelse("country_code" %in% names(unsc_data), "country_code", NULL)))

# MONA: Jahres-Spalte (sollte Approval Year sein)
mona_year_col <- ifelse("Approval Year" %in% names(mona_data), "Approval Year", 
                       ifelse("year" %in% names(mona_data), "year", 
                              ifelse("Approval.Year" %in% names(mona_data), "Approval.Year", NULL)))

# WDI: Jahres-Spalte (sollte year sein)
wdi_year_col <- ifelse("year" %in% names(wdi_data), "year", 
                      ifelse("Year" %in% names(wdi_data), "Year", 
                             ifelse("Approval Year" %in% names(wdi_data), "Approval Year", NULL)))

# UNSC: Jahres-Spalte
unsc_year_col <- ifelse("year" %in% names(unsc_data), "year", 
                       ifelse("Year" %in% names(unsc_data), "Year", 
                              ifelse("Approval Year" %in% names(unsc_data), "Approval Year", NULL)))

cat("Spaltenzuordnung:\n")
cat("  MONA: Land =", mona_country_col, ", Jahr =", mona_year_col, "\n")
cat("  WDI:  Land =", wdi_country_col, ", Jahr =", wdi_year_col, "\n")
cat("  UNSC: Land =", unsc_country_col, ", Jahr =", unsc_year_col, "\n\n")

# ============================================================================
# 3. DATEN ZUSAMMENFÜHREN
# ============================================================================

cat("=== Führe Joins durch ===\n\n")

# 3.1 MONA + WDI verknüpfen
cat("[1/2] Verknüpfe MONA + WDI...\n")
# Renamen für Konsistenz
names_mona <- names(mona_data)
names_wdi <- names(wdi_data)

# Erstelle temporäre Spaltennamen für den Merge
mona_data_temp <- mona_data
wdi_data_temp <- wdi_data
unsc_data_temp <- unsc_data

# Standardisiere die Ländercode-Spalten auf ISO3
if (!is.null(mona_country_col) && mona_country_col != "ISO3") {
  names(mona_data_temp)[names(mona_data_temp) == mona_country_col] <- "ISO3"
}
if (!is.null(wdi_country_col) && wdi_country_col != "ISO3") {
  names(wdi_data_temp)[names(wdi_data_temp) == wdi_country_col] <- "ISO3"
}
if (!is.null(unsc_country_col) && unsc_country_col != "ISO3") {
  names(unsc_data_temp)[names(unsc_data_temp) == unsc_country_col] <- "ISO3"
}

# Standardisiere die Jahres-Spalten auf Year
if (!is.null(mona_year_col) && mona_year_col != "Year") {
  mona_data_temp$Year <- mona_data_temp[[mona_year_col]]
  mona_data_temp <- mona_data_temp[, !(names(mona_data_temp) == mona_year_col)]
}
if (!is.null(wdi_year_col) && wdi_year_col != "Year") {
  wdi_data_temp$Year <- wdi_data_temp[[wdi_year_col]]
  wdi_data_temp <- wdi_data_temp[, !(names(wdi_data_temp) == wdi_year_col)]
}
if (!is.null(unsc_year_col) && unsc_year_col != "Year") {
  unsc_data_temp$Year <- unsc_data_temp[[unsc_year_col]]
  unsc_data_temp <- unsc_data_temp[, !(names(unsc_data_temp) == unsc_year_col)]
}

# Merge MONA + WDI
merged_data <- merge(mona_data_temp, wdi_data_temp, 
                     by = c("ISO3", "Year"), all.x = TRUE)
cat("✓ MONA + WDI verknüpft. Zeilen:", nrow(merged_data), "\n")

# 3.2 UNSC-Daten hinzufügen
cat("\n[2/2] Füge UNSC-Daten hinzu...\n")
# Merge mit UNSC
final_data <- merge(merged_data, unsc_data_temp, 
                   by = c("ISO3", "Year"), all.x = TRUE)
cat("✓ Finale Daten erstellt. Zeilen:", nrow(final_data), "\n")

# ============================================================================
# 4. DATEN AUFBEREITEN
# ============================================================================

cat("\n=== Bereinige Daten ===\n\n")

# 4.1 Leere Zeilen entfernen
final_data <- na.omit(final_data)
cat("✓ Leere Zeilen entfernt. Zeilen:", nrow(final_data), "\n")

# 4.2 Wichtige Spalten prüfen
required_cols <- c("ISO3", "Year", "unsc3", "Rohstoffabhängigkeit", 
                  "avgcondtype_all", "XDebtGNI", "DebtServGNI", "ResXDebt")
missing_cols <- required_cols[!required_cols %in% names(final_data)]

if (length(missing_cols) > 0) {
  cat("⚠️ FEHLENDE SPALTEN:", paste(missing_cols, collapse = ", "), "\n")
  cat("Verfügbare Spalten:", paste(names(final_data), collapse = ", "), "\n")
} else {
  cat("✓ Alle benötigten Spalten vorhanden\n")
}

# ============================================================================
# 5. DATEI SPEICHERN
# ============================================================================

cat("\n=== Speichere final_data_ssa_mea.csv ===\n")
write.csv(final_data, output_file, row.names = FALSE)
cat("✓ Datei gespeichert in:\n")
cat("  ", output_file, "\n")

# ============================================================================
# 6. ZUSAMMENFASSUNG
# ============================================================================

cat("\n========================================\n")
cat("FERTIG! Finaler Datensatz erstellt.\n\n")

if (file.exists(output_file)) {
  cat("✅ ERFOLG!\n")
  cat("  Datei:", output_file, "\n")
  cat("  Größe:", file.info(output_file)$size, "Bytes\n")
  cat("  Zeilen:", nrow(final_data), "\n")
  cat("  Spalten:", ncol(final_data), "\n")
  cat("  Länder:", length(unique(final_data$ISO3)), "\n")
  cat("  Jahre:", min(final_data$Year), "-", max(final_data$Year), "\n")
} else {
  cat("❌ FEHLER: Datei wurde nicht erstellt!\n")
}

cat("\n========================================\n\n")

final_data_ssa_mea <- read.csv("../data/processed/final_data_ssa_mea.csv")




