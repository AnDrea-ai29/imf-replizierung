# Datenbeschreibung für den processed-Ordner

## Abhängige Variablen (zwei Operationalisierungen)

`final_data_panel_ALL.csv` enthält zwei Maße für IMF-Konditionalität:

### avgcondtype_count — Original-Spezifikation (Dreher/Sturm/Vreeland 2015)
- Bedeutung: durchschnittliche **Anzahl Bedingungen pro Quartal**
- Berechnung: `nrcondtype_all / nrquarterssmpl`
  - `nrcondtype_all`: Anzahl aller Bedingungen (Zeilen in Combined_ISO.xlsx) je Land-Jahr
  - `nrquarterssmpl`: Summe der Programmlaufzeiten (in Quartalen) der in dem Jahr genehmigten Arrangements, berechnet aus Approval-/Revised- bzw. Initial-End-Datum, Minimum 1 Quartal
- Range im Panel: ca. 0.1–39.5, Mittel ~8.3 (Original: 0.8–45.1, Mittel 8.2)
- Im Original-Datensatz heisst diese Variable `avgcondtype_all` — hier bewusst anders benannt, um Verwechslungen zu vermeiden.

### avgcondtype_share — eigene Erweiterung (H2/H4)
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
- `unsc_t1`: Land war im Vorjahr UNSC-Mitglied
- `unsc3`: `unsc == 1` ODER `unsc_t1 == 1` (relevante Dummy-Variable für die FE-Analyse)

Berechnung: `unsc_t1 = lag(unsc, 1, default = 0)`; `unsc3 = 1, falls unsc == 1 oder unsc_t1 == 1, sonst 0`

Im aktuellen Panel treten 25 Land-Jahr-Beobachtungen mit `unsc3 == 1` auf.

## Relevante Datensätze

- `final_data_panel_ALL.csv`: globales Land-Jahr-Panel (99 Länder, alle Jahre aus Combined_ISO.xlsx), Grundlage aller aktiven Analysen
- `mona_ALL.csv`: Land-Jahr-Aggregation der MONA-Bedingungen vor dem WDI/UNSC-Join
- Die früheren SSA-Datensätze (`final_data_panel_SSA.csv`, `data_with_cond_types.csv` usw.) liegen in `archive/ssa_legacy/data/` und werden nicht mehr verwendet.
