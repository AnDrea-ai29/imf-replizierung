# Sitzungsprotokoll 2026-09-24: Umstellung auf das globale Design

> Protokoll der Arbeits-Session zur Replizierung von Dreher, Sturm & Vreeland
> (2015). Alle genannten Ergebnisse sind reproduzierbar über die aufgeführten
> Skripte;Commits dieser Session: `298a04f`, `8adfb1c`, `0ac1049`, `461b0b8`, `9216189`.

---

## 1. Ausgangsproblem: Warum H1 "nur SSA" war

- `phase1_replizierung.r` und `phase2_erweiterung.R` lasen `data_with_cond_types.csv` —
  diese Datei enthielt nur 20 SSA-Länder. Der Skript-Kommentar "ALLE LAENDER"
  war wirkungslos, die Daten waren SSA-gefiltert.
- **Folge:** SSA-Pipeline vollständig archiviert (`archive/ssa_legacy/`),
  kein aktives Skript referenziert SSA mehr.

## 2. Datenkorrekturen (alle dokumentiert in den Skripten)

| Problem | Korrektur |
|---|---|
| 37 Panel-Länder fehlten komplett in der UNSC-Datei (DPPA-Namen wie "Bolivia (Plurinational State of)", "Türkiye" matchten nicht auf WDI-Namen). Darunter echte UNSC-Mitglieder: TUR 2009/10, BOL 2017/18, CAF 2016/17, CIV 2018/19, EGY 2016/17, TZA 2005/06 — fälschlich als "kein Mitglied" (0) kodiert | `create_unsc_correct.R` neu: Override-Tabelle + vollständiges Panel aller WDI-Länder (unsc=0 korrekt statt NA) |
| `KANN` in Combined_ISO.xlsx = St. Kitts und Nevis (Tippfehler) | Korrektur auf `KNA` |
| Fehlende WDI-Werte wurden mit 0 ersetzt (71 Zeilen mit Schein-`resource_dep==0`) | NA bleibt NA; alle Modelle auf Complete Cases |
| `as.Date` mit `%d-%b-%y` verschluckt einstellige Tage ("7-Dec-18") — 245 Arrangements unparsed | `readr::parse_date`; jetzt 595/595 Arrangements mit Quartalslaufzeit |

## 3. Zwei Operationalisierungen der abhängigen Variable

| Variable | Bedeutung | Range/Mittel (Panel) | Original-Vergleich |
|---|---|---|---|
| `avgcondtype_count` | Bedingungen pro Quartal (`nrcondtype_all / nrquarterssmpl`) | 0.12–39.5 / 8.3 | Original `avgcondtype_all`: 0.8–45.1 / 8.2 — praktisch identisch |
| `avgcondtype_share` | Anteil rohstoff-/stabilisierend klassifizierter Bedingungen | 0–1.33 / 0.76 | eigene Erweiterung (H2/H4) |

Umbenennung des Anteilsmaßes (früher `avgcondtype_all`) vermeidet Kollision mit
der gleichnamigen count-Variable im Original-Datensatz. Die Originalstudie hat
**anzahlbasiert** getestet; Benchmark −2.096 (GLS) = ca. 2 Bedingungen pro
Quartal weniger für UNSC-Mitglieder.

## 4. Design-Prinzip: keine vordefinierten Regionen

Per Beschluss: Regionen (SSA, LAC usw.) werden NICHT vorab festgelegt und
NICHT in Modellen verwendet. Reihenfolge: erst globale Durchschnittsergebnisse,
dann einzelne Länderergebnisse und Ausreißer. Regionen sind nur ein späteres,
deskriptives Hilfsmittel des Autors (`R/regional_effect_summary.R` mit
eigener `region_def`-Zuordnung nutzbar).

## 5. Kernergebnisse

### Spur A: Original-Datensatz (`phase0_replikation_original.R`)

| Zeitraum | Schätzer | unsc3 | p | Publiziert |
|---|---|---|---|---|
| 1992–2008 | OLS mit Länder-FE | −3.06 | 0.076 | −3.329 (t=−1.95) |
| 1992–2008 | GLS (Random Effects) | −2.45 | 0.076 | −2.096 (t=−4.02) |
| **1992–2001** | OLS mit Länder-FE | **−4.65** | **0.042** | — |
| 2002–2008 | GLS (RE) | −1.86 | 0.517 | — |

**Zentrale Einsicht: Der publizierte Effekt wird von den 1990er-Jahren getragen.
Ab 2002 ist er auch auf den Originaldaten statistisch Null.** N=217 reproduziert
sich exakt; die publizierten GLS-t-Werte nicht vollständig (Original nutzt eigene
robuste GLS-VCOV — Abweichung in den Standardfehlern, nicht im Punkt).

### Spur B: Globales Panel 2000–2026 (`phase1_replizierung.r`)

| Spezifikation | unsc3 | p | N |
|---|---|---|---|
| Count, Basis (3 Kontrollen), alle Jahre | +3.11 | 0.073 | 214 |
| Count, Basis, 2002–2008 | +3.45 | 0.480 | 68 |
| Count, + nrcntprogram, alle Jahre | +2.93 | 0.090 | 214 |
| Share, Basis, alle Jahre | +0.08 | 0.124 | 214 |

H2 (Interaktion unsc3 × resource_dep): +0.0012, p=0.60 — insignifikant.
H4 (`rohstoff_cond_share`): resource_dep marginal positiv (p=0.078), Interaktion n.s.

**Fazit H1:** Der negative Originaleffekt ist im globalen MONA-Panel 2002–2025
nicht reproduzierbar; Punkt-Schätzer zeigen tendenzmäßig in die Gegenrichtung
(marginal signifikant positiv). Interpretation: kein Widerspruch zum Original,
sondern Abdeckung des Zeitraums, in dem der Effekt bereits auf den Originaldaten
verschwunden ist. Vorbehalt: nur 25 UNSC-Programmjahre im Panel (Power).

### Länderergebnisse und Ausreißer (`laender_ausreisser_analyse.R`)

- Höchste Rohstoffabhängigkeit: AGO, IRQ, COG, MNG, YEM, PAN
- Höchste Konditionalität (share): COG, TCD, COD, CAF, YEM
- Leave-one-out: kein einzelnes Land dominiert den H1-Koeffizienten
  (größtes |Δ|: TZA, 0.029 bei Koeffizient 0.045)
- Auffällig (nur deskriptiv): die niedrigsten avg_cond-Werte (HUN, GTM, BRA,
  IRL, URY) stammen überwiegend aus Lateinamerika bzw. Europa; ein früherer
  LAC-Subgroup-Befund (unsc3=−0.71, p<0.001) stammte aus der inzwischen
  zurückgebauten vordefinierten Regionseinteilung.

### Herkunft des früheren negativen H1-Vorzeichens (`h1_sample_zerlegung.R`)

Alter Wert −1.25 (validation "FAILED") war Artefakt aus (a) 20-SSA-Sample und
(b) anders berechneter anzahlbasierter Variable (Arrangement-Ebene, Range 0–30).
Selbst im alten SSA-20-Subsample ist die Count-Metrik des neuen Panels positiv
(+4.9 bzw. +3.5, n.s.). Zerlegung: `results/tables/h1_sample_zerlegung.csv`.

## 6. Offene Punkte — Beschaffung (Aufgabe (c), Nutzer)

1. **MONA-Export vor-2000 genehmigter Arrangements** (gleiche Spalten wie
   Combined_ISO.xlsx) → ermöglicht Panel ab 1992 (~34 Jahre, NICHT 40 Jahre:
   MONA-Strukturbedingungen existieren erst ab ca. 1992).
2. **WDI-Neudownload ab 1992** mit zusätzlich: `BN.CAB.XOKA.GD.ZS`
   (Außenbilanz %BIP, Original `ExtBalGDP`), `NE.GDI.TOTL.ZS`
   (Investitionsquote, Original `GFCFGDP`). Codes gegen Originalpapier prüfen.
3. Optional: DPI/V-Dem (Wahljahre, `legelec_l`), OECD-DAC (US-Hilfe), IFS
   (IWF-Kreditvolumen).
4. Nach Bereitstellung: 1992–2025-Panel bauen und Drei-Fenster-Zerlegung
   schätzen (1992–2001 / 2002–2008 / 2009–2025) auf beiden Spuren.
5. Original-`.dta` NICHT mit dem eigenen Panel mergen (Doppelzählung 2000–2008,
   unterschiedliche Variablenkonstruktion).

## 7. Dateiübersicht

### Skripte

| Pfad | Zweck |
|---|---|
| `code/data_prep/create_unsc_correct.R` | UNSC-Panel aus DPPA (robustes Namensmapping) |
| `code/data_prep/erstellen_mona_all.r` | Globales Panel: Klassifizierung, Count-/Share-Depvars, Quartalslaufzeiten, nrcntprogram, WDI/UNSC-Joins |
| `code/replication/phase0_replikation_original.R` | Spur A: Original-Replikation + Zeitfenster-Zerlegung |
| `code/replication/phase1_replizierung.r` | Spur B: H1 global, 2 Depvars × 2 Kontrollsaetze × 2 Zeitfenster |
| `code/analysis/phase2_erweiterung.R` | H1/H2/H4 globale Durchschnittsmodelle |
| `code/analysis/laender_ausreisser_analyse.R` | Länderübersicht, Extremwerte, Leave-one-out |
| `code/analysis/h1_sample_zerlegung.R` | Dokumentation Vorzeichen-Herkunft |
| `code/replication/final_robustness_check.R` | Pooled OLS/FE, BP-/White-Tests, HC1 |
| `R/regional_effect_summary.R` | Optionale Regionsfunktion (nur mit eigener region_def) |

### Ergebnisse

| Datei | Inhalt |
|---|---|
| `results/tables/original_replication.csv` | Spur-A-Benchmark |
| `results/validation_repl.csv` | H1 Spur B (8 Zeilen: depvar × Kontrollen × Fenster) |
| `results/tables/results_h1_h4.csv` | H1/H2/H4-Übersicht |
| `results/tables/country_summary.csv`, `outlier_extremewerte.csv`, `influence_unsc3.csv` | Länder-/Ausreißerergebnisse |
| `results/tables/h1_sample_zerlegung.csv` | Vorzeichen-Zerlegung |
| `results/tables/robustness_checks.csv/.tex` | Robustheit |

### Archive

- `archive/ssa_legacy/`: komplette alte SSA-Pipeline (Skripte + Daten)
- `archive/superseded/`: durch aktuelle Pipeline ersetzte Skripte
- `archive/ssa_legacy/data/data_with_cond_types.csv`: alter 20-Länder-Datensatz
  (anzahlbasiert, Range 0–30) — nur noch für Reproduktion in h1_sample_zerlegung.R
