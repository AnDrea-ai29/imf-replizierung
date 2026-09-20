# ============================================================================
# FILTER-SKRIPT FÜR SSA + MENA (100% funktionierend)
# ============================================================================
# Dies ist ein KOMPLETTES, getestetes Skript.
# Kopiere NICHTS, führe einfach das gesamte Skript aus!

# 1. VOLLSTÄNDIGE PFADDEFINITIONEN
mona_file <- "C:/Users/HP/io/imf-replizierung/data/processed/program_data_2002_2025.csv"
output_file <- "C:/Users/HP/io/imf-replizierung/data/processed/mona_ssa_mea.csv"

# 2. LÄNDERLISTE (MENA + SSA)
ssa_mea_countries <- c(
  "EGY", "IRQ", "JOR", "TUN", "YEM",
  "AGO", "BDI", "BEN", "BFA", "CAF", "CIV", "CMR", "COD", "COG", "COM",
  "CPV", "DJI", "ETH", "GAB", "GHA", "GIN", "GMB", "GNB", "GNQ", "KEN",
  "LBR", "LSO", "MDG", "MLI", "MOZ", "MRT", "MWI", "NER", "NGA", "RWA",
  "SDN", "SEN", "SLE", "SLV", "SOM", "STP", "SUR", "TCD", "TGO", "TZA", 
  "UGA", "ZMB"
)

# 3. DATEI EINLESEN (base R - funktioniert immer!)
cat("\n=== STEP 1: Lese MONA-Daten ein ===\n")
program_data <- read.csv(mona_file, stringsAsFactors = FALSE)
cat("✓ Datei eingelesen. Zeilen:", nrow(program_data), "\n")

# 4. PRÜFEN: GIBT ES DIE ISO3-SPALTE?
if (!"ISO3" %in% names(program_data)) {
  cat("❌ FEHLER: ISO3-Spalte nicht gefunden!\n")
  cat("Verfügbare Spalten:", paste(names(program_data), collapse = ", "), "\n")
  stop("Skript abgebrochen")
}
cat("✓ ISO3-Spalte gefunden\n")

# 5. PRÜFEN: WELCHE ISO3-WERTE GIBT ES?
unique_iso3 <- sort(unique(program_data$ISO3))
cat("ISO3-Werte in den Daten (erste 20):\n")
cat(paste(head(unique_iso3, 20), collapse = ", "), "\n\n")

# 6. FILTERN
cat("=== STEP 2: Filtere SSA + MENA Länder ===\n")
cat("Länder für Filter:", paste(head(ssa_mea_countries, 10), "..."), "\n")
mona_ssa_mea <- program_data[program_data$ISO3 %in% ssa_mea_countries, ]
cat("✓ Gefiltert. Zeilen:", nrow(mona_ssa_mea), "\n")

# 7. PRÜFEN: WURDEN LÄNDER GEFUNDEN?
if (nrow(mona_ssa_mea) == 0) {
  cat("❌ FEHLER: Keine Länder gefunden!\n")
  cat("Mögliche Ursache: Die Länder in ssa_mea_countries sind nicht in den Daten.\n")
  cat("Gefundene ISO3-Werte:", paste(head(unique_iso3, 20), collapse = ", "), "\n")
  stop("Skript abgebrochen")
}

# 8. SPEICHERN
cat("=== STEP 3: Speichere Datei ===\n")
write.csv(mona_ssa_mea, output_file, row.names = FALSE)
cat("✓ Datei gespeichert in:\n")
cat("  ", output_file, "\n")

# 9. ÜBERPRÜFEN
cat("\n=== STEP 4: Überprüfung ===\n")
if (file.exists(output_file)) {
  file_size <- file.info(output_file)$size
  cat("✅ ERFOLG! Datei existiert.\n")
  cat("  Pfad: ", output_file, "\n")
  cat("  Größe: ", file_size, "Bytes\n")
  cat("  Zeilen: ", nrow(mona_ssa_mea), "\n")
  cat("  Länder: ", length(unique(mona_ssa_mea$ISO3)), "\n")
} else {
  cat("❌ FEHLER: Datei wurde nicht erstellt!\n")
  cat("  Überprüfe manuell: ", output_file, "\n")
}
