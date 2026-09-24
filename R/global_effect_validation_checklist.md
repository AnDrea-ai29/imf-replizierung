# Validierungscheckliste für global_effect_analysis.R

Diese Checkliste hilft dir schnell zu prüfen, ob das globale Design sauber läuft, bevor du mit der Hausarbeit weiterarbeitest.

## 1. Datensatz vorhanden?
- [ ] `data/processed/final_data_panel_ALL.csv` existiert
- [ ] der Datensatz enthält die Spalten `ISO3`, `Year`, `avgcondtype_all`, `unsc3`
- [ ] die Kontrollvariablen sind vorhanden: `XDebtGNI`, `DebtServGNI`, `ResXDebt`

## 2. Rohstoffvariable korrekt?
- [ ] `resource_dep` existiert oder wird korrekt rekonstruiert
- [ ] Alternative: `FuelExportPct` + `MineralExportPct` existieren
- [ ] `resource_dep` enthält keine unerwarteten NAs oder extremen Ausreißer, die die Analyse zerstören

## 3. Regionale Variable korrekt?
- [ ] `region` existiert im Panel (SSA, ECA, LAC, MENA, SA, EAP)
- [ ] alle Laender haben eine Regionszuordnung; unmapped Codes werden beim Panelbau gemeldet
- [ ] Regionen werden empirisch geprueft (Neu.md: keine Region a priori privilegieren)

## 4. Deskriptive Prüfung
- [ ] `region_summary` zeigt plausible Mittelwerte
- [ ] `country_summary` zeigt hohe und niedrige Rohstoffwerte sinnvoll an
- [ ] auffällige Länder sind sichtbar

## 5. Basismodell läuft?
- [ ] `model_global` wird ohne Fehler geschätzt
- [ ] Koeffizienten sind numerisch plausibel
- [ ] mindestens ein signifikantes oder relevantes Muster ist erkennbar

## 6. Interaktionsmodell läuft?
- [ ] `model_global_2` wird ohne Fehler geschätzt
- [ ] `unsc3:resource_dep` und / oder `region`-Interaktion sind interpretierbar
- [ ] kein identischer Fehler wie bei fehlender Variablen oder falscher Formel

## 7. Regionenspezifische Modelle laufen?
- [ ] `ssa_model` läuft
- [ ] `other_model` läuft
- [ ] Unterschiede zwischen Regionen können interpretiert werden

## 8. Robustheitsprüfung
- [ ] fehlende Werte kontrolliert
- [ ] Ausreißer identifiziert
- [ ] ggf. alternative Spezifikation getestet
- [ ] Ergebnisse nicht nur auf Einzelländer zurückführbar

## 9. Interpretationsfrage
- [ ] Gibt es regionale Heterogenität?
- [ ] Sind auffällige Regionen tatsächlich relevant oder nur wenige Ausreißer?
- [ ] Ist das Ergebnis stärker in einem Subsample als im Gesamtsample?

## 10. Abschlussentscheidung
- [ ] Das Design ist für die Hausarbeit konsistent und nachvollziehbar
- [ ] die Interpretation basiert auf dem finalen globalen Design, nicht auf dem alten SSA-Fokus
- [ ] die regionale Differenzierung ist transparent beschrieben
