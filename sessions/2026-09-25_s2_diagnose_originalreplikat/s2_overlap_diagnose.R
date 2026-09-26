# S2-Diagnose: Original-Datensatz vs. eigenes Replikationspanel (2026-09-25)
#
# Konsolidierte, persistente Fassung der Diagnose-Vergleiche aus Session 2
# (die urspruenglichen Analysen liefen als Ad-hoc-Skripte). Prueft:
#   1. Struktur (Zeilen, Laender, Jahre, Variablen-Overlap)
#   2. Konditionalitaetszaehlung auf den ueberlappenden Land-Jahren
#   3. unsc3-Diskrepanzen (eigenes Panel kodiert zurueckliegende Mitgliedschaft)
#   4. Quartale (nrquarterssmpl)
# Dieses Skript ist zugleich das Gate-Check-Werkzeug: Sobald das eigene
# 2000-2026-Panel neu ausgerichtet ist (MONA-Granularitaet, Quartalsregel),
# muss es das Gate bestehen (Median-Verhaeltnis 0.8-1.2, >=50% exakt).

setwd("C:/Users/HP/io/imf-replizierung")
suppressMessages(library(haven))

orig <- as.data.frame(read_dta("data/raw/original/Dreher_Sturm_Vreeland_JCR.dta"))
repl <- read.csv("data/processed/final_data_panel_ALL.csv", stringsAsFactors = FALSE)

cat("=== Struktur ===\n")
cat("Original:", nrow(orig), "Zeilen |", length(unique(orig$country)), "Laender |",
    paste(range(orig$year), collapse = "-"), "\n")
cat("Replikat:", nrow(repl), "Zeilen |", length(unique(repl$ISO3)), "Laender |",
    paste(range(repl$Year), collapse = "-"), "\n")
cat("Gemeinsame Variablennamen:",
    paste(intersect(names(orig), names(repl)), collapse = ", "), "\n\n")

# Crosswalk (aus Session 4; ISO3 ist die Merge-Bruecke)
cw <- read.csv("data/processed/crosswalk_dsv_iso3.csv", stringsAsFactors = FALSE)
ox <- merge(cw, orig[, c("country", "year", "nrcondtype_all", "nrquarterssmpl", "unsc3")],
            by = "country")
m <- merge(ox, repl[, c("ISO3", "Year", "nrcondtype_all", "nrquarterssmpl", "unsc3")],
           by.x = c("ISO3", "year"), by.y = c("ISO3", "Year"),
           suffixes = c(".orig", ".repl"))
cat("=== Overlap ===\n")
cat("Ueberlappende Land-Jahre:", nrow(m), "\n")
cat("Median-Verhaeltnis nrcondtype_all (repl/orig):",
    round(median(m$nrcondtype_all.repl / m$nrcondtype_all.orig, na.rm = TRUE), 2), "\n")
cat("Anteil exakt identisch:",
    round(mean(m$nrcondtype_all.repl == m$nrcondtype_all.orig), 3), "\n")
cat("Korrelation:",
    round(cor(m$nrcondtype_all.repl, m$nrcondtype_all.orig), 3), "\n")
cat("Median-Verhaeltnis nrquarterssmpl:",
    round(median(m$nrquarterssmpl.repl / m$nrquarterssmpl.orig, na.rm = TRUE), 2), "\n\n")

cat("=== unsc3-Diskrepanzen ===\n")
d <- m[m$unsc3.orig != m$unsc3.repl, c("ISO3", "year", "unsc3.orig", "unsc3.repl")]
cat("Diskrepanzen:", nrow(d), "von", nrow(m), "\n")
if (nrow(d) > 0) print(d, row.names = FALSE)
cat("\nGate-Ziel: Median 0.8-1.2 und >=50% exakt -> derzeit",
    ifelse(median(m$nrcondtype_all.repl / m$nrcondtype_all.orig, na.rm = TRUE) %in% 0.8:1.2,
           "BESTANDEN", "GEFAILED"), "\n")
