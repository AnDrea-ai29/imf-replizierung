# Datenbeschreibung für den processed-Ordner

## H4-Klassifikation und Crosswalk

`Conddisc_final.csv` enthält die kuratierten Phase-A-Einzelwerte und bleibt
die fachliche Referenz. Da Phase B andere Beschreibungen verwendet, ist kein
direkter Schlüsselabgleich möglich. Für H4 werden deshalb die
Phase-A-Definitionsvorschläge in eine gemeinsame deterministische Regel
überführt und aus `code/shared/data_prep/phase_a_definition_rules.R` auf
die Beschreibungen beider Zeiträume angewandt. Historische
`areadescription`-Texte und moderne Phase-B-`Description`-Texte werden für
H4 somit mit derselben deterministischen Regel klassifiziert; historische
H4-Werte können daher von den kuratierten Werten in `Conddisc_final.csv`
abweichen. Die Regel operationalisiert die Phase-A-Definitionsvorschläge,
sie behauptet nicht, jede kuratierte Einzelentscheidung zu reproduzieren.

`phase_b_classification_crosswalk.csv` enthält eine Zeile je moderner
Kombination aus `Economic Code`, `Economic Descriptor` und `Description`,
ihre Häufigkeit, die Rohstoff-/Stabilitätsflags sowie Regelversion und
Prüfsummen der Eingaben. `cooking oil` und `edible oil` werden nicht als
Rohstoff gewertet; weitere gültige Rohstoffsignale im selben Text bleiben
wirksam. Das Skript `code/shared/data_prep/build_phase_a_definition_crosswalk.R`
erstellt den Crosswalk reproduzierbar.

`phase_b_h4_panel_1992_2025.csv` ist das daraus erzeugte Land-Jahr-Panel.
`code/phase_b/data_prep/build_phase_b_h4_panel.R` klassifiziert historische
und moderne Bedingungstexte mit derselben Regelversion und validiert die
Land-Jahr-Abdeckung sowie die Bedingungszähler gegen das aktive Phase-B-Panel.
Die 417 historischen Zeilen ohne `areadescription` erhalten nach der Regel
„kein Textsignal = 0“ ebenfalls den Wert 0; ihre Verteilung nach Land und
Jahr steht transparent in `phase_b_h4_missing_description_audit.csv`.

## Ältere globale Zusatzmaße (nicht Teil des aktiven Phase-B-Pfads)

`avgcondtype_count` bleibt die aktive H1/H2-Zähl-AV. Die folgenden
klassifikationsbasierten Variablen beschreiben dagegen den bisherigen
globalen MONA-Regelpfad und sind nicht H4-Eingabe. Aktuelle H4-Werte stehen
im dedizierten `phase_b_h4_panel_1992_2025.csv`.

### avgcondtype_count — aktive count-basierte Messung
- Bedeutung: durchschnittliche **Anzahl Bedingungen pro Quartal**
- Berechnung: `nrcondtype_all / nrquarterssmpl`
  - `nrcondtype_all`: Anzahl aller Bedingungen (Zeilen in Combined_ISO.xlsx) je Land-Jahr
  - `nrquarterssmpl`: Summe der Programmlaufzeiten (in Quartalen) der in dem Jahr genehmigten Arrangements, berechnet aus Approval-/Revised- bzw. Initial-End-Datum, Minimum 1 Quartal
- Range im Panel: ca. 0.1–39.5, Mittel ~8.3 (Original: 0.8–45.1, Mittel 8.2)
- Im Original-Datensatz heisst diese Variable `avgcondtype_all` — hier bewusst anders benannt, um Verwechslungen zu vermeiden.

### avgcondtype_share — ältere Erweiterung (nicht aktueller H4-Output)
- Bedeutung: **Anteil** der als rohstoff- oder stabilisierungsspezifisch klassifizierten Bedingungen an allen Bedingungen
- Berechnung: `(rohstoff_cond + stabil_cond) / nrcondtype_all`
- Range im Panel: 0–1.33, Mittel ~0.76
- Für H4 additionally: `rohstoff_cond_share` (nur Rohstoff-Anteil)

## Rohstoffabhängigkeit

Zwei Namen für dieselbe Variable, beide im finalen Panel identisch:

- `resource_dep` (bevorzugt in neuen Analysen)
- `Rohstoffabhängigkeit` (Lesbarkeit, Kompatibilität)

Formel: `resource_dep = FuelExportPct + MineralExportPct`

Fehlende WDI-Werte bleiben NA (keine Null-Ersetzung); Modelle schaetzen auf Complete Cases.

## UNSC-Mitgliedschaft

- `unsc`: Land ist im aktuellen Jahr UNSC-Mitglied
- `unsc3`: DSV-Regel, Mitgliedschaft im Jahr `t` oder im Folgejahr `t+1`

Das aktive Phase-B-Panel wird von
`code/phase_b/data_prep/build_phase_b_identical_measurement.R` direkt mit
`unsc_dsv_rule_1946_2026.csv` verknüpft. `erstellen_mona_all.r` erstellt
optional das ältere globale Panel und ist kein Schritt im aktuellen
Phase-B-Ausführungsablauf.

Im aktuell neu gebauten Panel treten 23 Land-Jahr-Beobachtungen mit
`unsc3 == 1` auf.

## Programmhistorie

- `nrcntprogram`: kumulative Anzahl der Arrangements eines Landes bis einschließlich Jahr t (analog zur Original-Kontrolle "count"/`nrcntprogram` in Dreher et al. 2015, dort Range 1-7). Range im Panel: 1-9, Mittel ~2.7.
- Caveat: Zählung beginnt mit dem MONA-Export (Jahr 2000); vor-2000-Programme sind erst nach Bereitstellung des erweiterten MONA-Exports enthalten.

## Aktive und historische Datensätze

- `phase_b_panel_identical_measurement_1992_2025.csv`: aktive Phase-B-Basis
  für die count-basierten H1/H2-Tests; enthält keine klassifizierten Outcomes
- `phase_b_classification_crosswalk.csv`: reproduzierbare moderne Zuordnung
  nach den gemeinsamen Phase-A-Definitionsregeln
- `phase_b_h4_panel_1992_2025.csv`: aktives klassifiziertes H4-Panel mit
  Rohstoff- und Stabilitätsanteilen sowie den H1/H2-Kontrollen
- `phase_b_h4_missing_description_audit.csv`: Audit historischer Bedingungen
  ohne `areadescription`, die mangels Textsignal als 0 klassifiziert sind
- `final_data_panel_ALL.csv`: älteres globales Land-Jahr-Panel; nicht die
  Eingabe der aktuellen Phase-B-Hypothesenanalyse
- `mona_ALL.csv`: globale Land-Jahr-Aggregation; Hilfs-/Altoutput, kein
  aktueller Analyseinput
- Die früheren SSA-Datensätze (`final_data_panel_SSA.csv`, `data_with_cond_types.csv` usw.) liegen in `archive/ssa_legacy/data/` und werden nicht mehr verwendet.
