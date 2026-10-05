# Ergebnismatrix

Diese Matrix ist ein Inventar, keine Anweisung zum Löschen. „Aktuell“ meint,
dass die Datei vom derzeitigen Skript-/Analysepfad erzeugt wurde. Es sagt
nicht, dass jeder Befund statistisch signifikant ist oder dass die
Ergebnismessung eine unveränderte Kopie der DSV-Originalmessung darstellt.
Dateipfade in der Tabelle sind relativ zu `results/`. Dateien mit Status
„prüfen/archivieren“ vor einem Löschen erst auf Abhängigkeiten und
Reproduzierbarkeit prüfen.

## Aktuelle Phase-B-Ausgaben

| Datei | Phase | Erzeugendes Skript | Aktualitätsstatus | Verwendung |
|---|---|---|---|---|
| `phase_b/tables/phase_b_hypothesen_robustheit.csv` | B | `code/phase_b/analysis/phase_b_hypothesen_robustheit.R` | H1/H2 neu gerechnet; keine klassifikationsbasierte H4-Schätzung | Count-basierte H1/H2 |
| `phase_b/tables/phase_b_modellvergleich.csv` | B | `code/phase_b/analysis/phase_b_hypothesen_robustheit.R` | Enthält H1/H2 | Basismodell, Länder-FE und Zwei-Wege-FE; DSV-nahes GLS für H1/H2 |
| `phase_b/publication/phase_b_h1_ergebnisse.*`, `phase_b_h1_modellvergleich.*` | B, Export | `code/phase_b/analysis/export_phase_b_tables.R` | H1-Ergebnistabelle und Table-2-artiger Modellspezifikationsvergleich | LaTeX (`.tex`) und Word (`.docx`) |
| `phase_b/publication/phase_b_h2_ergebnisse.*`, `phase_b_h2_modellvergleich.*` | B, Export | `code/phase_b/analysis/export_phase_b_tables.R` | H2-Ergebnistabelle und Table-2-artiger Modellspezifikationsvergleich | LaTeX (`.tex`) und Word (`.docx`) |
| `phase_b/publication/phase_b_h3_laenderprofile.*` | B, Export, explorativ | `code/phase_b/analysis/export_phase_b_tables.R` | Deskriptive H3-Länderprofile; kein inferenzieller Modellvergleich | LaTeX (`.tex`) und Word (`.docx`) |
| `phase_b/publication/phase_b_hypothesen_robustheit.*`, `phase_b_modellvergleich.*` | B, Export | `code/phase_b/analysis/export_phase_b_tables.R` | Aktualisierte zusammenfassende Tabellen als ergänzende Anhangsübersicht | LaTeX (`.tex`) und Word (`.docx`); werden mit den Einzeltabellen neu erzeugt |
| `phase_b/tables/phase_b_h2_leave_one_country_out.csv` | B | `code/phase_b/analysis/phase_b_hypothesen_robustheit.R` | Neu gerechnet nach Panel-Neuaufbau | Einflussdiagnostik des H2-Vollmodells |
| `phase_b/exploration/h3_country_profiles.csv` | B, explorativ | `code/phase_b/analysis/phase_b_h3_exploration.R` | 116 Länder, 526 Land-Jahre im Analysezeitraum 1992–2023; keine automatische Ausreißer- oder Regionsklassifikation und kein inferenzieller H3-Test | Deskriptive Länderprofile für manuellen Fallvergleich und explorative Muster |
| `phase_b/exploration/h4_conditionality_resource_change_3y.csv`, `_summary.csv`, `.png` | B, explorativ | `code/phase_b/analysis/phase_b_h4_exploration.R` | 333 Programm-Land-Jahre aus 99 Ländern; Bewilligungsjahr t bis t+3, Spearman rho = 0,039; deskriptiv, nicht kausal | Beobachtungen, Zusammenfassung und Streudiagramm zur späteren Veränderung der Rohstoffexportabhängigkeit |
| `phase_b/models/phase_b_h2_main.rds` | B | `code/phase_b/analysis/phase_b_hypothesen_robustheit.R` | Neu gerechnet nach Panel-Neuaufbau | Gespeichertes H2-Vollmodell |

## Archivierte Phase-A-definitionsbasierte Klassifikationspipeline

Diese Pipeline dokumentiert die frühere, nicht mehr confirmatorisch verwendete
H4-Messung. Die erzeugten Daten und Modelle bleiben für Audit und
Reproduzierbarkeit erhalten, sind aber keine aktuellen Phase-B-Ergebnisse.

| Datei | Phase | Erzeugendes Skript | Aktualitätsstatus | Verwendung |
|---|---|---|---|---|
| `../data/processed/phase_b_classification_crosswalk.csv` | Gemeinsame Definition, Phase-B-Crosswalk | `code/shared/data_prep/build_phase_a_definition_crosswalk.R` | Moderne Phase-B-Beschreibungen werden mit der operationalisierten Phase-A-Definitionsregel klassifiziert; Quelle und Referenz sind per MD5 dokumentiert | Reproduzierbarer Crosswalk, Eingabe für das H4-Panel |
| `../data/processed/phase_b_h4_panel_1992_2025.csv` | A/B, einheitliche Messregel | `code/phase_b/data_prep/build_phase_b_h4_panel.R` | Historische und moderne MONA-Texte mit derselben Regelversion klassifiziert; Land-Jahr-Abdeckung und Zähler validiert | H4-AV `rohstoff_cond_share` und alle Kovariaten, 1992–2025 |
| `../data/processed/phase_b_h4_missing_description_audit.csv` | A, H4-Audit | `code/phase_b/data_prep/build_phase_b_h4_panel.R` | 417 historische Bedingungen ohne `areadescription`; kein Textsignal wird als 0 kodiert | Transparenz/Audit der fehlenden historischen Beschreibungstexte |

## Phase-A-Replikation und Jahres-FE-Erweiterung

| Datei | Phase | Erzeugendes Skript | Aktualitätsstatus | Verwendung |
|---|---|---|---|---|
| `phase_a/tables/original_replication.csv` | A | `code/phase_a/replication/phase0_replikation_original.R` | Aktuell für die DSV-Originalspezifikation; separat von Phase B | Reproduktion ohne Jahres-FE |
| `phase_a/tables/original_replication_jahres_fe.csv` | A, Zusatzanalyse | `code/phase_a/replication/phase0_replikation_original.R` | Aktuell; ergänzende Jahres-FE-Sensitivität | DSV-Modelle mit zusätzlichem Jahres-FE |
| `phase_a/tables/original_replication_zeitfenster.csv` | A, Zusatzanalyse | `code/phase_a/replication/phase0_replikation_original.R` | Aktuell im selben Replikationslauf | Zeitfensterdiagnostik |
| `phase_a/models/model_original_fe_basis.rds` | A | `code/phase_a/replication/phase0_replikation_original.R` | Aktuell | DSV-Basis-FE-Modell |
| `phase_a/models/model_original_fe_voll.rds` | A | `code/phase_a/replication/phase0_replikation_original.R` | Aktuell | DSV-Vollmodell-FE |
| `phase_a/models/model_original_gls_voll.rds` | A | `code/phase_a/replication/phase0_replikation_original.R` | Aktuell | DSV-Vollmodell-GLS |
| `phase_a/models/model_original_fe_basis_jahres_fe.rds` | A, Zusatzanalyse | `code/phase_a/replication/phase0_replikation_original.R` | Aktuell | Basis-FE mit Jahres-FE |
| `phase_a/models/model_original_fe_voll_jahres_fe.rds` | A, Zusatzanalyse | `code/phase_a/replication/phase0_replikation_original.R` | Aktuell | Vollmodell-FE mit Jahres-FE |

## Weitere Phase-A-Ausgaben und Kontrolldiagnostik

| Datei | Phase | Erzeugendes Skript | Aktualitätsstatus | Verwendung |
|---|---|---|---|---|
| `phase_a/tables/hypothesen_original_basis.csv` | A, optionale Projekt-Hypothesen | `code/phase_a/analysis/hypothesen_original_basis.R` | Separate Originalbasis-Analyse; nicht Phase-B-Hauptergebnis | H1–H4 auf historischem DSV-Panel |
| `phase_a/models/model_origbasis_m1base.rds` | A, optional | `code/phase_a/analysis/hypothesen_original_basis.R` | Separate Originalbasis-Analyse | Basis-/Sanity-Modell |
| `phase_a/models/model_origbasis_h1.rds` | A, optional | `code/phase_a/analysis/hypothesen_original_basis.R` | Separate Originalbasis-Analyse | H1 |
| `phase_a/models/model_origbasis_h1_wdi.rds` | A, optional | `code/phase_a/analysis/hypothesen_original_basis.R` | Separate Originalbasis-Analyse | H1 mit WDI-Kontrollen |
| `phase_a/models/model_origbasis_h1_voll8.rds` | A, optional | `code/phase_a/analysis/hypothesen_original_basis.R` | Separate Originalbasis-Analyse | H1-Vollmodell, reduzierte Kontrollen |
| `phase_a/models/model_origbasis_h1_voll9.rds` | A, optional | `code/phase_a/analysis/hypothesen_original_basis.R` | Separate Originalbasis-Analyse | H1-Vollmodell |
| `phase_a/models/model_origbasis_h2.rds` | A, optional | `code/phase_a/analysis/hypothesen_original_basis.R` | Separate Originalbasis-Analyse | H2 |
| `phase_a/models/model_origbasis_h4.rds` | A, optional | `code/phase_a/analysis/hypothesen_original_basis.R` | Separate Originalbasis-Analyse | H4 |
| `phase_a/models/model_origbasis_h4_energie.rds` | A, optional | `code/phase_a/analysis/hypothesen_original_basis.R` | Separate Originalbasis-Analyse | H4-Energievariante |
| `shared/tables/wdi_kontrollen_vintage_check.csv` | Gemeinsam/Datenprüfung | `code/shared/data_prep/build_controls_wdi.R` | Diagnostik; nicht Hypothesenergebnis | Vintage-/Kontrollvergleich |

## Vorhandene Ausgaben mit älterem oder gesondertem Analysepfad

| Datei | Vermutete Phase | Erzeugendes Skript | Aktualitätsstatus | Empfehlung |
|---|---|---|---|---|
| `legacy/tables/country_summary.csv` | Früherer globaler Analysepfad | `code/legacy/analysis/laender_ausreisser_analyse.R` | Nicht gegen das aktuelle Phase-B-Panel validiert | Bis zur Neuberechnung als alt/prüfen markieren |
| `legacy/tables/outlier_extremewerte.csv` | Früherer globaler Analysepfad | `code/legacy/analysis/laender_ausreisser_analyse.R` | Nicht gegen das aktuelle Phase-B-Panel validiert | Bis zur Neuberechnung als alt/prüfen markieren |
| `legacy/tables/influence_unsc3.csv` | Früherer globaler Analysepfad | `code/legacy/analysis/laender_ausreisser_analyse.R` | Nicht gegen das aktuelle Phase-B-Panel validiert | Bis zur Neuberechnung als alt/prüfen markieren |
| `legacy/tables/h1_sample_zerlegung.csv` | Frühere H1-Diagnostik | `code/legacy/analysis/h1_sample_zerlegung.R` | Nicht gegen das aktuelle Phase-B-Panel validiert | Bis zur Neuberechnung als alt/prüfen markieren |
| `legacy/tables/krisen_robustheit.csv` | Frühere Phase-B-/globalen-Pool-Diagnostik | `code/legacy/analysis/zeitraeume_krisen_robustheit.R` | Nicht gegen das aktuelle Phase-B-Panel validiert | Bis zur Anpassung/Neuberechnung als alt/prüfen markieren |
| `legacy/tables/results_h1_h4.csv` | Frühere globale Hypothesenanalyse | `code/legacy/analysis/phase2_erweiterung.R` | Beruht auf früherem Panel-/Modellpfad | Als überholt archivieren, nicht als aktuelles Ergebnis zitieren |
| `phase_a/tables/replication_1992_2008.csv` | Erweiterte Replikationsdiagnostik | `code/phase_a/replication/phase1_replikation_1992_2008.R` | Separater historischer Vergleich für 1992–2008; kein aktueller Phase-B-Hypothesentest | Als historische Replikationsdiagnostik behalten |
| `legacy/tables/robustness_checks.csv` | Allgemeine ältere Robustheitsanalyse | `code/legacy/replication/final_robustness_check.R` | Datenbasis/Spezifikation gegen aktuellen Stand prüfen | Bis zur Prüfung als alt/prüfen markieren |
| `legacy/tables/robustness_checks.tex` | Allgemeine ältere Robustheitsanalyse | `code/legacy/replication/final_robustness_check.R` | Entspricht obiger CSV | Gemeinsam mit CSV behandeln |
| `legacy/tables/` sonstige `.gitkeep` | Keine Analyse | — | Platzhalter | Behalten |
| `legacy/models/` sonstige `.gitkeep` | Keine Analyse | — | Platzhalter | Behalten |
| `figures/.gitkeep` | Keine Analyse | — | Platzhalter | Behalten |

## Pflege bei künftigen Läufen

Nach einem neuen Lauf die zugehörigen Zeilen aktualisieren:

1. Erzeugendes Skript und Phase anhand des tatsächlichen Codepfads eintragen.
2. Status nur dann auf „aktuell“ setzen, wenn das Skript erfolgreich mit den
   aktuellen Eingaben und der aktuellen Spezifikation gelaufen ist.
3. Veraltete Dateien zunächst nach `legacy/` bzw. `archive/` verschieben,
   sobald feststeht, dass nichts mehr davon abhängt.
4. Aktuelle Tabellen nicht manuell bearbeiten: Skript erneut ausführen und
   die generierten Dateien ersetzen lassen.
5. Keine Dateien allein aufgrund ihres Namens oder eines nicht-signifikanten
   Ergebnisses löschen.
