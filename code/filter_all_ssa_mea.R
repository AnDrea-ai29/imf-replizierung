# ============================================================================
# FILTER-ALL SKRIPT FÜR SSA + MENA (100% funktionierend)
# ============================================================================
# Erstellt alle 3 gefilterten Dateien:
# - mona_ssa_mea.csv (IMF-Programme)
# - wdi_ssa_mea.csv (Rohstoffdaten)
# - unsc_ssa_mea.csv (UNSC-Mitgliedschaft)

# ============================================================================
# 1. LÄNDERLISTEN DEFINIEREN
# ============================================================================

# MENA-Länder (aus Combined_ISO.xlsx enthalten)
mena_countries <- c("EGY", "IRQ", "JOR", "TUN", "YEM")

# SSA-Länder (aus Combined_ISO.xlsx enthalten)
ssa_countries <- c(
  "AGO", "BDI", "BEN", "BFA", "CAF", "CIV", "CMR", "COD", "COG", "COM",
  "CPV", "DJI", "ETH", "GAB", "GHA", "GIN", "GMB", "GNB", "GNQ", "KEN",
  "LBR", "LSO", "MDG", "MLI", "MOZ", "MRT", "MWI", "NER", "NGA", "RWA",
  "SDN", "SEN", "SLE", "SLV", "SOM", "STP", "SUR", "TCD", "TGO", "TZA", 
  "UGA", "ZMB"
)

# Kombinierte Liste
ssa_mea_countries <- c(ssa_countries, mena_countries)

cat("\n========================================\n")
cat("Filter-All Skript für SSA + MENA\n")
cat("MENA-Länder:", paste(mena_countries, collapse = ", "), "\n")
cat("SSA-Länder:", paste(head(ssa_countries, 10), "..."), "\n")
cat("Gesamt:", length(ssa_mea_countries), "Länder\n")
cat("========================================\n\n")

# ============================================================================
# 2. MONA-DATEN FILTERN
# ============================================================================

cat("[1/3] Filtere MONA-Daten...\n")
mona_file <- "C:/Users/HP/io/imf-replizierung/data/processed/program_data_2002_2025.csv"
output_mona <- "C:/Users/HP/io/imf-replizierung/data/processed/mona_ssa_mea.csv"

if (file.exists(mona_file)) {
  program_data <- read.csv(mona_file, stringsAsFactors = FALSE)
  
  if ("ISO3" %in% names(program_data)) {
    mona_ssa_mea <- program_data[program_data$ISO3 %in% ssa_mea_countries, ]
    write.csv(mona_ssa_mea, output_mona, row.names = FALSE)
    cat("✓ GESPEICHERT:", output_mona, "\n")
    cat("  - Gefilterte Zeilen:", nrow(mona_ssa_mea), "\n")
    cat("  - Unique Länder:", length(unique(mona_ssa_mea$ISO3)), "\n")
  } else {
    cat("✗ FEHLER: ISO3-Spalte nicht gefunden in MONA-Daten\n")
    cat("  Verfügbar:", paste(names(program_data), collapse = ", "), "\n")
  }
} else {
  cat("✗ FEHLER: MONA-Datei nicht gefunden:", mona_file, "\n")
}

# ============================================================================
# 3. WDI-DATEN FILTERN
# ============================================================================

cat("\n[2/3] Filtere WDI-Daten...\n")
wdi_file <- "C:/Users/HP/io/imf-replizierung/data/processed/wdi_2002_2025_dep.csv"
output_wdi <- "C:/Users/HP/io/imf-replizierung/data/processed/wdi_ssa_mea.csv"

if (file.exists(wdi_file)) {
  wdi_data <- read.csv(wdi_file, stringsAsFactors = FALSE)
  
  # Prüfen, welche Spalte den Ländercode enthält
  country_col <- ifelse("country_code" %in% names(wdi_data), "country_code", 
                       ifelse("ISO3" %in% names(wdi_data), "ISO3", 
                              ifelse("wdicode" %in% names(wdi_data), "wdicode", NULL)))
  
  if (!is.null(country_col)) {
    wdi_ssa_mea <- wdi_data[wdi_data[[country_col]] %in% ssa_mea_countries, ]
    write.csv(wdi_ssa_mea, output_wdi, row.names = FALSE)
    cat("✓ GESPEICHERT:", output_wdi, "\n")
    cat("  - Gefilterte Zeilen:", nrow(wdi_ssa_mea), "\n")
    cat("  - Unique Länder:", length(unique(wdi_ssa_mea[[country_col]])), "\n")
  } else {
    cat("✗ FEHLER: Keine Ländercode-Spalte gefunden in WDI-Daten\n")
    cat("  Verfügbar:", paste(names(wdi_data), collapse = ", "), "\n")
  }
} else {
  cat("✗ FEHLER: WDI-Datei nicht gefunden:", wdi_file, "\n")
}

# ============================================================================
# 4. UNSC-DATEN FILTERN
# ============================================================================

cat("\n[3/3] Filtere UNSC-Daten...\n")
unsc_file <- "C:/Users/HP/io/imf-replizierung/data/raw/unsc/unsc_membership_2002_2025.csv"
output_unsc <- "C:/Users/HP/io/imf-replizierung/data/processed/unsc_ssa_mea.csv"

if (file.exists(unsc_file)) {
  unsc_data <- read.csv(unsc_file, stringsAsFactors = FALSE)
  
  # Prüfen, welche Spalte den Ländercode enthält
  country_col <- ifelse("wdicode" %in% names(unsc_data), "wdicode", 
                       ifelse("ISO3" %in% names(unsc_data), "ISO3", 
                              ifelse("country_code" %in% names(unsc_data), "country_code", NULL)))
  
  if (!is.null(country_col)) {
    # Leere Zeilen filtern
    unsc_data_clean <- unsc_data[!is.na(unsc_data[[country_col]]) & 
                                 unsc_data[[country_col]] != "", ]
    unsc_ssa_mea <- unsc_data_clean[unsc_data_clean[[country_col]] %in% ssa_mea_countries, ]
    write.csv(unsc_ssa_mea, output_unsc, row.names = FALSE)
    cat("✓ GESPEICHERT:", output_unsc, "\n")
    cat("  - Gefilterte Zeilen:", nrow(unsc_ssa_mea), "\n")
    cat("  - Unique Länder:", length(unique(unsc_ssa_mea[[country_col]])), "\n")
  } else {
    cat("✗ FEHLER: Keine Ländercode-Spalte gefunden in UNSC-Daten\n")
    cat("  Verfügbar:", paste(names(unsc_data), collapse = ", "), "\n")
  }
} else {
  cat("✗ FEHLER: UNSC-Datei nicht gefunden:", unsc_file, "\n")
}

# ============================================================================
# 5. ZUSAMMENFASSUNG
# ============================================================================

cat("\n========================================\n")
cat("FERTIG!\n\n")

output_files <- c(output_mona, output_wdi, output_unsc)
file_names <- c("mona_ssa_mea.csv", "wdi_ssa_mea.csv", "unsc_ssa_mea.csv")

for (i in 1:length(output_files)) {
  if (file.exists(output_files[i])) {
    cat("✓ ERSTELLT:", file_names[i], "\n")
  } else {
    cat("✗ NICHT ERSTELLT:", file_names[i], "\n")
  }
}

cat("\nGefilterte Länder (SSA + MENA):\n")
cat(paste(sort(ssa_mea_countries), collapse = ", "), "\n")
cat("\n========================================\n\n")
