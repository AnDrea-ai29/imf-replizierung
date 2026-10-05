# Code-Übersicht

Der Code ist nach Projektphase und Arbeitsschritt geordnet. Die Skripte
werden aus dem Projektstamm `C:\Users\HP\io\imf-replizierung` ausgeführt.
Die festen `setwd()`-Einträge in den R-Skripten bleiben daher unverändert.

## Verzeichnisstruktur

```text
code/
  README.md
  shared/
    data_prep/                    # Datenaufbereitung, die beide Phasen benötigen
  phase_a/
    data_prep/                    # zusätzliche historische/DSV-Aufbereitung
    replication/                  # unveränderte DSV-Replikation + Jahres-FE-Test
    analysis/                     # optionale Hypothesenanalyse auf DSV-Basis
  phase_b/
    data_prep/                    # MONA-Panel und einheitliche Zähl-AV
    analysis/                     # aktuelle Phase-B-Hypothesen/Robustheit
    replication_comparison/       # ältere globale Replikationsanalyse
  legacy/
    analysis/                     # ältere, nicht aktualisierte Analysen
    replication/                  # ältere allgemeine Robustheit
```

`shared/data_prep/` enthält Skripte, deren Daten Phase B benötigt, obwohl
Teile davon ursprünglich für die historische Replikation entwickelt wurden.
Die aktuelle Phase-B-Hypothesenanalyse wird nicht auf dem Original-
Ergebnisdatensatz geschätzt.

## Phase B: eigene Hypothesen

Vom Projektstamm aus in dieser Reihenfolge ausführen:

1. `Rscript "code\shared\data_prep\create_unsc_correct.R"`
2. `Rscript "code\shared\data_prep\build_unsc_dsv_rule.R"`
3. `Rscript "code\shared\data_prep\rebuild_conditionality_1992_2008.R"`
4. `Rscript "code\shared\data_prep\build_controls_wdi.R"`
5. `Rscript "code\phase_b\data_prep\build_phase_b_identical_measurement.R"`
6. `Rscript "code\shared\data_prep\build_phase_a_definition_crosswalk.R"`
7. `Rscript "code\phase_b\data_prep\build_phase_b_h4_panel.R"`
8. `Rscript "code\phase_b\analysis\phase_b_hypothesen_robustheit.R"`
9. `Rscript "code\phase_b\analysis\phase_b_h3_exploration.R"`
10. `Rscript "code\phase_b\analysis\export_phase_b_tables.R"`

Die Analyse verwendet die gemeinsame MONA-Zählregel und beschränkt alle
Phase-B-Modelle sowie H3-Länderprofile auf den Analysezeitraum 1992–2023.
Die zugrunde liegenden Panels können weiterhin bis 2025 reichen; 2024 und
2025 gehen nicht in die berichteten Analysen ein. Die Analyse verwendet den
vollständigen DSV-Kontrollsatz und erstellt H1/H2, deren Robustheiten und
Modellvergleichsvarianten. Schritt 6 erzeugt den modernen
`phase_b_classification_crosswalk.csv`: Die gemeinsame Operationalisierung
der Phase-A-Definitionsvorschläge wird auf die konkreten
Phase-B-Beschreibungen angewandt; `cooking oil` wird nicht
als Rohstoff gewertet. Dieselbe Funktion klassifiziert anschließend die
historischen Beschreibungen in Schritt 7. Die kuratierte
`Conddisc_final.csv` bleibt Referenz, wird für die H4-Zeitreihe aber nicht
als abweichender Klassifikationspfad verwendet. H4 wird mit Hauptmodell,
alternativen Rohstoffmaßen, Quellenzeitfenstern, Winsorisierung und
Leave-one-country-out geprüft. Der separate Schritt 9 erstellt deskriptive
Länderprofile als explorative Grundlage für H3. Er weist keine Ausreißer
automatisch aus, ordnet keine Regionen zu und führt keinen inferenziellen
H3-Test durch. Länderunterschiede werden anhand der Profile manuell geprüft;
mögliche Gruppen oder Besonderheiten sind anschließend transparent und als
explorativ zu beschreiben. Ergebnispfade und Aktualitätsstatus stehen in
`results/ERgebnismatrix.md`.

Schritt 10 exportiert getrennte Ergebnis- und Modellvergleichstabellen für
H1, H2 und H4 als LaTeX-Fragmente (`.tex`) und Word-Dokumente (`.docx`) nach
`results/phase_b/publication/`. H3 erhält eine deskriptive Länderprofil-
Tabelle, aber keinen Modellvergleich, da H3 explorativ ist. Die
zusammenfassenden Tabellen sind als Anhangsübersicht enthalten. Die
LaTeX-Dateien sind Tabellenfragmente; benötigte Pakete stehen in den
Dateiköpfen. Word- und LaTeX-Tabellen werden standardmäßig im Querformat
gesetzt. Die CSV-Ausgaben behalten die ungerundete Präzision.

## Phase A: DSV-Originalreplikation

Die gemeinsame Datenaufbereitung aus Schritten 1–4 oben erzeugt auch
historische Prüf-/Vergleichsdaten. Für die DSV-Replikation:

`Rscript "code\phase_a\replication\phase0_replikation_original.R"`

Das Skript erstellt die unveränderte Original-Spezifikation und zusätzlich
die Jahres-FE-Sensitivität. Die Zusatzanalyse ist klar von der publizierten
Spezifikation getrennt. Die optionale Hypothesenanalyse auf der DSV-Basis
liegt unter `phase_a/analysis/`.

## Pfadregeln

- Ausgabe- und Datenpfade innerhalb der Skripte beziehen sich weiterhin auf
  den Projektstamm, nicht auf den jeweiligen Skriptordner.
- Rufe Skripte daher aus dem Projektstamm auf (die Skripte setzen ihn auch
  über `setwd()` explizit).
- `phase_b/replication_comparison/` enthält nicht die aktuelle
  Phase-B-Hauptanalyse; diese liegt in `phase_b/analysis/`.
- `legacy/`-Skripte sind zur Nachvollziehbarkeit behalten, aber nicht Teil
  der aktuellen Ausführungsreihenfolge.
