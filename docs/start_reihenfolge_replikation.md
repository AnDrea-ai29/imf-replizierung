# Startreihenfolge für die Replikation

## Kurz gesagt

Wenn du die vollständige Ausführung selbst durchlaufen willst, dann starte mit den Data-Prep-Skripten und nicht mit den Analyse-Skripten.

## Saubere Reihenfolge

1. `Rscript "code/data_prep/rebuild_conditionality_1992_2008.R"`
2. `Rscript "code/data_prep/build_unsc_dsv_rule.R"`
3. `Rscript "code/data_prep/build_controls_wdi.R"`
4. `Rscript "code/data_prep/klassifikation_bedingungen.R"`
5. `Rscript "code/analysis/hypothesen_original_basis.R"`

## Warum diese Reihenfolge?

- Das erste Skript baut die Konditionalitätsdaten und die validierte Originalbasis auf.
- Das zweite baut die UNSC-Regel.
- Das dritte baut die WDI-Kontrollen.
- Das vierte erzeugt die Review-Klassifikation für die Bedingungstexte.
- Das fünfte verwendet genau diese erzeugten Dateien und schätzt die projektinternen H1–H4-Modelle auf der Originalbasis.

> Wichtiger Punkt: Die H1–H4 sind hier keine Originalstudien-Formeln aus dem Stata-Code, sondern projekt- bzw. theoriebasierte Hypothesen, die auf der validierten Originalbasis getestet werden.

## Wichtig

Wenn du nur die letzten Ergebnisse anschauen willst, reicht der letzte Befehl. Aber wenn du die Pipeline wirklich reproduzieren willst, dann musst du die Reihenfolge einhalten.

## Typische Output-Dateien

Nach der Ausführung sollten diese Dateien neu vorliegen:

- `data/processed/conditionality_dsv_1992_2008.csv`
- `data/processed/unsc_dsv_rule_1946_2026.csv`
- `data/processed/controls_wdi_1990_2025.csv`
- `data/processed/bedingungsbeschreibungen_review.csv`
- `results/tables/hypothesen_original_basis.csv`

## Wenn du nur die Hauptergebnisse reproduzieren willst

Dann ist der entscheidende Lauf:

- `Rscript "code/analysis/hypothesen_original_basis.R"`

Das ist aber nur die letzte Stufe der vollständigen Pipeline.


I’m outlining the exact execution order from raw data to final models so you know the minimal set of scripts to run and where to start without guessing.



### Startreihenfolge für die vollständige Ausführung

Wenn du die Pipeline selbst sauber durchlaufen willst, starte nicht mit dem Analyse-Skript, sondern mit den Datenvorbereitungen. Der sichere Einstieg ist:

1. `README.md`
2. `Replikationsanleitung_Gesamtzeitraum.md`

Diese beiden Dateien sagen dir, was die kanonische Reihenfolge ist und was die aktuellen “Gate”-Schritte sind.

---

## Die Reihenfolge, die du in der Praxis durchlaufen solltest

### 1) Datenvorbereitung: Original- und Kontroll-Inputs
Diese Skripte bauen die Inputdaten, die später für die Modelle gebraucht werden:

- `rebuild_conditionality_1992_2008.R`
- `build_unsc_dsv_rule.R`
- `build_controls_wdi.R`
- `create_unsc_correct.R`

Diese erzeugen die Dateien unter `processed` wie:

- `conditionality_dsv_1992_2008.csv`
- `unsc_dsv_rule_1946_2026.csv`
- `controls_wdi_1990_2025.csv`

> Das ist der eigentliche Startpunkt, wenn du “von vorne” anfangen willst.

---

### 2) Ressourcen-Klassifikation
Danach die eigentliche Klassifikationslogik:

- `klassifikation_bedingungen.R`

Dieses Skript erzeugt:

- `bedingungsbeschreibungen_review.csv`

Das ist der entscheidende Review-Join-Schritt für H2/H4. Ohne diese Datei ist die Ressourcen-Klassifikation nicht sauber.

---

### 3) Replikations-/Benchmark-Skripte
Wenn du die komplette Replication mit verschiedenen Varianten durchlaufen willst, dann kommen als Nächstes die Hauptskripte:

- `phase0_replikation_original.R`
- `phase1_replikation_gesamtzeitraum.R`
- `final_robustness_check.R`

Diese prüfen die Original- und Gesamtzeitraum-Ergebnisse.

---

### 4) Projekt-Hypothesen auf der validierten Originalbasis
Dann kommen die Tests der projektinternen Hypothesen:

- `hypothesen_original_basis.R`

Dieses Skript schätzt die H1–H4-Modelle auf der validierten Originalbasis, nicht die Originalstudienformeln selbst. Der Sinn ist: Erst die Originalbasis sauber reproduzieren und validieren, dann dieselbe Hypothesenspezifikation in dieser Basis prüfen, bevor man das erweiterte globale Panel interpretiert.

---

## Was du konkret selbst starten solltest

Wenn du nur “vollständig” und ohne Überforderung starten willst, dann nimm diese Reihenfolge:

1. `build_controls_wdi.R`
2. `build_unsc_dsv_rule.R`
3. `rebuild_conditionality_1992_2008.R`
4. `klassifikation_bedingungen.R`
5. `hypothesen_original_basis.R`

Wenn du zusätzlich die komplette Replikationspipeline mit Benchmark- und Robustness-Schritten willst:

6. `phase0_replikation_original.R`
7. `phase1_replikation_gesamtzeitraum.R`
8. `final_robustness_check.R`

---

## Wichtigste Kurzregel

- Wenn du die validierte Originalbasis und die projektinternen H1–H4 auf dieser Basis verstehen willst: start bei `hypothesen_original_basis.R`
- Wenn du die gesamte Pipeline sauber reproduzieren willst: start bei den Data-Prep-Skripten, nicht bei den Analyse-Skripten
- Wenn du die moderne, erweiterte Panel-Logik bauen willst: dann ist `erstellen_mona_all.r` der relevante Erweiterungspfad, nicht der Original-Replikationspfad

> In diesem Workspace habe ich die relevanten Skripte bereits frisch ausgeführt und das bestätigt: `klassifikation_bedingungen.R` und `hypothesen_original_basis.R` liefen erfolgreich mit Exit Code 0.

Wenn du möchtest, kann ich dir als Nächstes eine noch einfachere “nur 3 Klicks”-Checkliste machen, also genau: “Was muss ich jetzt in welchem Terminal ausführen?”