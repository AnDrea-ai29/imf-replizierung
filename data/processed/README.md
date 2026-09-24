# Datenbeschreibung für den processed-Ordner

## Wichtige Variable: Rohstoffabhängigkeit

Im aktuellen Projekt gibt es zwei Namen für dieselbe Variable:

- `resource_dep`
- `Rohstoffabhängigkeit`

Beide bezeichnen dieselbe Messung und sind im finalen Panel identisch. Sie entsprechen der Summe aus:

- `FuelExportPct`
- `MineralExportPct`

Formel:

resource_dep = FuelExportPct + MineralExportPct

## Bedeutung
Diese Variable misst die Rohstoffabhängigkeit eines Landes im jeweiligen Land-Jahr-Paar. Sie wird in den FE-Regressionsmodellen als zentrale Interaktionsvariable verwendet.

## Hinweis zur Verwendung
Für neue Analysen und Modelle sollte bevorzugt `resource_dep` verwendet werden, da dieser Name konsistent und kurz ist. Die deutsche Bezeichnung `Rohstoffabhängigkeit` dient vor allem der Lesbarkeit und Kompatibilität mit älteren Skripten.

## Relevante Datensätze

- `final_data_panel_ALL.csv`: globales Land-Jahr-Panel fuer H1
- `final_data_panel_SSA.csv`: SSA-Land-Jahr-Panel fuer H2-H4
- `data_with_cond_types.csv`: Inhalts- und Bedingungsdaten

## Verifiziert
Die Identität wurde mit dem aktuellen Datensatz geprüft: `identical(resource_dep, Rohstoffabhängigkeit) == TRUE`.



## Wichtige Variable: UNSC-Mitgliedschaft

Im aktuellen Projekt gibt es 3 unsc-Variablen:

- `unsc`: Das Land ist im aktuellen Jahr Mitglied des UN-Sicherheitsrats
- `unsc_t1`: Das Land war im Vorjahr UNSC-Mitglied
- `unsc3`: Das Land war entweder im aktuellen Jahr oder im Vorjahr Mitglied im UNSC

## Hinweis zur Verwendung
`unsc` = Mitgliedschaftsstatus, wie im UNSC-Rohfile codiert
`unsc_t1` = lagged/zeitlich verschobene Form, falls so definiert
`unsc3` = die relevante Dummy-Variante für die FE-Regressionsanalyse

Die UNSC-Variable ist auf eine kleine Gruppe von Ländern begrenzt, da nur wenige Staaten im UN-Sicherheitsrat vertreten sind. In diesem globalen Panel treten daher nur 22 Länder mit unsc3 = 1 auf, was der begrenzten Mitgliedschaft im UNSC entspricht.

## Begründung
Die Definition von unsc3 beruht auf der Erkenntnis, dass politische und wirtschaftlich Effekte eines Sicherheitsratsmandats nicht immer nur im selben Jahr sichtbar sind. Ein Land kann in Jahr t noch Einfluss ausüben, auch wenn die Mitgliedschaft bereits im Vorjahr begonnen hat. Deshalb wird in vielen Studien eine breitere Definition verwendet, die das aktuelle und das vorherige Jahr zusammenfasst. 

## Berechnung
unsc_t1 = lag(unsc, 1, default = 0)
unsc3 = 1, falls unsc == 1 oder unsc_t1 == 1, sonst 0