# H2/H4 und Review-Join in der Replication

## 1) Was ist ein Review-Join?

Ein Review-Join ist ein Daten-Join zwischen:

- der Original-MONA-Tabelle mit den Bedingungstexten und
- der Review-Datei `data/processed/bedingungsbeschreibungen_review.csv`

In der Review-Datei steht für jede eindeutige Bedingungsbeschreibung eine manuell geprüfte Klassifikation, z. B.:

- `rohstoff_final`
- `stabil_final`
- `energie_vorschlag`

Im Skript `code/analysis/hypothesen_original_basis.R` passiert das so:

- Jede MONA-Zeile bekommt aus `areadescription` einen Textwert `desc`
- Die Review-Datei wird auf `desc` gemerged
- Dadurch bekommt jede ursprüngliche Bedingung die Review-Klassifikation mit

Das ist der relevante Code-Pfad:

- `mona <- mona %>% mutate(desc = tolower(trimws(as.character(areadescription))))`
- `left_join(rev %>% select(desc, rohstoff_final, stabil_final, energie_vorschlag), by = "desc")`
- danach werden Variablen wie `rohstoff_cond`, `stabil_cond`, `energie_cond` erzeugt

Kurz gesagt:

- Originaltext: "oil price stabilization fund"
- Review-Tabelle: für genau diese Beschreibung → `rohstoff_final = 1`
- Join: diese 1 wird auf alle passenden MONA-Zeilen übertragen

So wird aus rohen Texten eine belastbare Ressourcen-Klassifikation.

## 2) Was bedeutet „H2/H4 laufen durch“?

Das bedeutet nicht, dass die Hypothesen schon endgültig bestätigt oder widerlegt sind.

Es bedeutet nur:

- der Datenfluss funktioniert,
- alle Variablen für H2/H4 wurden korrekt erzeugt,
- die Regressionsmodelle konnten erfolgreich berechnet werden,
- der Code lief ohne Fehler durch und erzeugte die Output-Datei.

In der letzten Ausführung war der Exit-Code 0, und der Output enthielt:

- `results/tables/hypothesen_original_basis.csv`

## 3) Was sind H2 und H4?

Die zentralen Hypothesen lauten hier:

### H2
`avgcondtype_all ~ unsc3 * resource_dep + Kontrollen`

Interpretation:

- `unsc3` = Dummy für staatliche UNSC-Fälle
- `resource_dep` = Rohstoffabhängigkeit des Landes
- `unsc3 * resource_dep` = Interaktion

Frage:

> Ist der Effekt von UNSC auf die Gesamtzahl an Konditionalitäten stärker, wenn ein Land rohstoffabhängig ist?

### H4
`rohstoff_cond_share ~ unsc3 * resource_dep + Kontrollen`

Interpretation:

- `rohstoff_cond_share` = Anteil rohstoffbezogener Konditionalitäten an allen Konditionalitäten

Frage:

> Ist der Anteil rohstoffbezogener Konditionalitäten in UNSC-Fällen in rohstoffabhängigen Ländern höher?

## 4) Was bedeutet die Interaktion `unsc3 * resource_dep`?

Das ist der wichtigste Term.

Er zeigt, ob der UNSC-Effekt je nach Rohstoffabhängigkeit anders ausfällt.

- Wenn der Koeffizient positiv ist, dann wirkt UNSC in rohstoffabhängigen Ländern stärker
- Wenn der Koeffizient null oder nicht signifikant ist, dann gibt es keinen statistischen Hinweis darauf, dass der Effekt variiert

## 5) Ergebnis der letzten Ausführung

In der letzten erfolgreichen Ausführung wurden folgende Interaktionskoeffizienten berichtet:

- H2: `unsc3:resource_dep = 0.1344`, p = 0.156
- H4: `unsc3:resource_dep = 0.000025`, p = 0.934

Das bedeutet:

- keine signifikante Interaktion
- keine empirische Unterstützung für die Hypothese, dass der UNSC-Effekt in rohstoffabhängigen Ländern systematisch stärker ist

## 6) Fazit

Der Review-Join ist der entscheidende Datenvorbereitungsschritt, der die Rohstoffklassifikation aus der geprüften Review-Datei in die Hypothesentests einbettet.

Die Hypothesen wurden in diesem Lauf tatsächlich geschätzt und getestet. Die Ergebnisse sind aber nicht signifikant. Das bedeutet nicht, dass der Code kaputt ist; es bedeutet nur, dass die empirische Evidenz für den postulierten Rohstoffmechanismus in diesem Datensatz und Modellrahmen schwach ist.
