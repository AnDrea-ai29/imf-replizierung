# Notizblatt für ein Replikationsskript

## 1) Skriptname

- Datei: `code/data_prep/rebuild_conditionality_1992_2008.R`
- Zweck: Nachbau des Original-Konditionalitätsblocks 1992–2008
- Wichtig für: Validierung des originalen Basisdatensatzes, bevor die eigene Erweiterung überhaupt ernsthaft genutzt werden kann

## 2) Ziel des Skripts

In 2–3 Sätzen:

- Dieses Skript erzeugt den Original-Nachbau, also den Datensatz, der die Hauptvariablen des Originals reproduziert.
- Es ist der erste große Prüfstein der Replikation und zeigt, ob die Kernlogik der Originaldaten sauber rekonstruiert werden kann.
- Wenn dieser Schritt nicht sauber ist, sind alle späteren Schritte nicht belastbar.

## 3) Input-Dateien

- `data/raw/original/construction/Data MONA.dta`
- ggf. weitere Original-Dateien aus `data/raw/original/construction/`

Wichtige Fragen:

- Welche Originaldatei ist hier die Grundlage?
- Wie werden Programme, Länder und Zeitpunkte identifiziert?
- Gibt es Besonderheiten bei Join- oder Merge-Variablen?

## 4) Output-Dateien

- `data/processed/conditionality_dsv_1992_2008.csv`

Wichtige Fragen:

- Welche Variablen entstehen hier konkret?
- Wofür wird dieser Datensatz später verwendet?
- Ist das ein Zwischenprodukt oder ein Endergebnis?

## 5) Zentrale Logik

Notiere hier die wichtigsten Schritte in eigenen Worten:

1. Programm definieren als `countryname × approvaldate`
2. Zeilenzählung ohne Dedup
3. Land-Jahr-Aggregation
4. Verschiebungen für Senegal und Uganda berücksichtigen
5. `nrquarterssmpl` nach der Original-Regel berechnen
6. `avgcondtype_all` aus Zählung und Quartalsregel ableiten

Wichtige Fragen:

- Was passiert mit den Daten?
- Wo wird eine Variable verändert?
- Was ist der kritische Join / Merge?
- Welche Regeln werden im Nachbau exakt übernommen?

## 6) Kritische Begriffe

- Aggregation:
- Gate:
- Granularität:
- unsc3:
- Review-Join:
- resource_dep:
- Rohstoff-Klassifikation:
- `nrcondtype_all`:
- `nrquarterssmpl`:

## 7) Wichtige Formeln / Variablen

- Hauptmodell: Original-Konditionalitätsblock mit Programmdaten und Land-Jahr-Aggregation
- Interaktion: keine eigene Interaktion in diesem Schritt, Fokus auf Reproduktion
- abhängige Variable: nicht im engeren Sinne, sondern Kernvariablen des Originaldatensatzes
- Kontrollvariablen: je nach Originalbasis; hier zentral `unsc3`, `countryname`, `approvaldate`, `finalenddate`
- Wichtige Varianten:
  - `nrcondtype_all`
  - `nrcondtype_pc`
  - `nrcondtype_pa`
  - `nrcondtype_sb`
  - `nrquarterssmpl`
  - `nrcntprogram`
  - `avgcondtype_all`

Formel:

- `nrquarterssmpl = round((min(finalenddate, 28.09.2008) - max(approvaldate, 31.03.1992))/90)`

## 8) Was ich hier verstanden habe

Schreibe 3–5 Sätze in einfacher Sprache:

- Der Nachbau dient dazu, den Original-Konditionalitätsblock exakt zu reproduzieren.
- Erst wenn dieser Schritt stimmt, ist die Originalbasis belastbar.
- Die zentrale Logik liegt in der richtigen Definition von Programmen, der Aggregation auf Land-Jahr-Ebene und der exakten Berechnung der Quartalsvariable.
- Die Validierung ist erfolgreich, wenn die Kernvariablen mit dem Original identisch sind.

## 9) Das ist noch unklar

Notiere 3 konkrete Fragen:

1. Wo genau wird `nrquarterssmpl` im Skript berechnet?
2. Wie werden Senegal und Uganda im Nachbau behandelt?
3. Was ist der genaue Vergleich mit dem Originaldatensatz?

## 10) Kurzfazit

Ein Satz:

- Dieser Nachbau ist der wichtigste Validierungspunkt der gesamten Replikation, weil der Original-Konditionalitätsblock exakt reproduziert werden muss, bevor die eigene Erweiterung als belastbar gelten kann.
