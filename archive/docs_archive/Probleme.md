## Status: Was existiert bereits

Abgleich des Designs aus `Neu.md` mit den Dateien im Repo (Stand heute, letzte Runs vom 24.09.):

| **Design-Schritt** 				| **Status** 			| **Beleg** |
|-----------------------------------|-----------------------|-----------------------------------------------------|
| 1. Globaler Datensatz 			| erledigt 				| `final_data_panel_ALL.csv`: 99 Länder, 333 Country-Year-Obs., inkl. `resource_dep`, `unsc3`, `avgcondtype_all`, Kontrollen |
| 2. `resource_dep` 				| weitgehend erledigt 	| vorhanden bzw. aus Fuel+Mineral rekonstruierbar |
| Basismodell im globalen Pool 		| erledigt 				| `model_global_region.rds` + `results_h1_h4.csv` |
| Robustheit (global, ohne Region)  | erledigt 				| `robustness_checks.csv/.tex`: BP-/White-Test, Pooled OLS, Year FE, Two-way FE, hetero SE |

## Was noch fehlt (in dieser Reihenfolge)

1. **`region`-Variable (Schritt 3) — der zentrale Blocker.** 
In keinem Datensatz und keinem ausgeführten Skript existiert `region`. `global_effect_analysis.R` wurde bewusst ohne Regionendummy gerechnet; 
`model_global_region.rds` enthält daher *keine* Regionsinteraktion (Name ist irreführend).

2. **Regionale Deskriptivanalyse (Phase 4).** Es gibt nur `country_summary.csv` ohne Regionenspalte; 
ein `region_summary` (Mittelwerte nach Region) existiert nicht.

3. **Interaktionsmodelle mit Region (Phase 5 / Schritt 6).** 
Weder `unsc3 * resource_dep * region` noch die lesbare Variante 
(`unsc3*resource_dep + unsc3*region + resource_dep*region`) wurde geschätzt. 
`R/regional_effect_summary.R` ist als Funktion fertig, aber **nie ausgeführt** — der Beispiel-Code ist auskommentiert, es gibt keine Output-Dateien.

4. **Subgroup-Modelle (Phase 6).** 
Keine `ssa_model`/`other_model`-Ergebnisse, 
keine Entscheidungsgrundlage dafür, welche Region im Finalmodell relevant ist (Aufgabe 6 aus `Neu.md` Abschnitt 8).

5. **H1-Replikation im erweiterten Pool (Phase 2 des Designs).** 
Die bisherige Replikation (`validation_repl.csv`) läuft nur über 20 SSA-Länder und ist **FAILED** (unsc-Koeffizient −1.25, p = 0.69). 
Der im Design geforderte Vergleich „Original-Zeitraum vs. erweiterter Zeitraum" im globalen Pool fehlt komplett.

6. **Regionale Robustheitschecks (Phase 7).** 
`robustness_checks.csv` deckt nur das globale Modell ohne Region ab. 
Fehlend: Subgroup-Robustheit, alternative `resource_dep`-Spezifikationen, Zeitfenster-Varianten, Ausreißerbehandlung 
(Ausreißer sind in `top_resource_countries.csv` identifiziert, aber nicht behandelt).

7. **Dokumentation (Schritt 9).** 
`README.md` beschreibt noch den veralteten 10-Tage-SSA-Plan; 
die Checkliste `R/global_effect_validation_checklist.md` ist durchgehend ungehakt; 
Latex-Ergebniskapitel hängen an den fehlenden Regionalergebnissen.

## Datenproblem, das vorher geklärt werden sollte

Von 333 Zeilen im globalen Panel haben **71 den Wert `resource_dep == 0`** (z. B. AFG: Fuel=0, Mineral=0). 
Das sieht nach fehlenden WDI-Werten aus, die als 0 kodiert sind, nicht nach echter Rohstoffunabhängigkeit — das würde die Regionen- und Interaktionsmodelle verzerren. 
Vor Schritt 3 sollte geprüft werden, ob diese 0er zu `NA` werden müssen.

Kurz: die globale Basisanalyse steht, aber der eigentliche Kern des neuen Designs — Regionsvariable, Regionalmodelle, Subgroups, regionale Robustheit und die finale Dokumentation — 
ist noch nicht gerechnet. Wenn du möchtest, beginne ich mit der Bereinigung der `resource_dep`-Nullwerte und der Erzeugung der `region`-Variable.