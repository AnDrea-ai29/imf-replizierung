# Notizblatt: Beispiel für `code/analysis/hypothesen_original_basis.R`

## 1) Skriptname

- Datei: `code/analysis/hypothesen_original_basis.R`
- Zweck: Schätzung der Hypothesen H1 bis H4 auf der Original-Zählbasis 1992–2008
- Wichtig für: Reproduktion der Originalbasis und Test der Ressourcen-Hypothesen mit validierter Klassifikation

## 2) Ziel des Skripts

Dieses Skript baut das Datenpanel für die Original-Zählbasis auf, hängt die Review-Klassifikation an die MONA-Bedingungen an und schätzt anschließend die Regressionsmodelle H1, H2 und H4.

Es ist der zentrale Schritt, der zeigt:

- ob die Datenbasis korrekt ist,
- ob die Ressourcen-Klassifikation sauber eingebunden ist,
- ob die Hypothesen empirisch unterstützt werden.

## 3) Input-Dateien

- `data/processed/conditionality_dsv_1992_2008.csv`
- `data/final/Dreher_Sturm_Vreeland_JCR.dta`
- `data/raw/original/construction/Data MONA.dta`
- `data/processed/bedingungsbeschreibungen_review.csv`
- `data/processed/controls_wdi_1990_2025.csv`

Wichtige Fragen:

- Woher kommen die ursprünglichen Konditionalitäten?
- Welche Datei liefert die Review-Klassifikation?
- Welche Variablen müssen aus dem Originaldatensatz übernommen werden?

## 4) Output-Dateien

- `results/tables/hypothesen_original_basis.csv`
- `results/models/model_origbasis_m1base.rds`
- `results/models/model_origbasis_h1.rds`
- `results/models/model_origbasis_h2.rds`
- `results/models/model_origbasis_h4.rds`
- `results/models/model_origbasis_h4_energie.rds`

Wichtige Fragen:

- Welche Ergebnisse werden hier gespeichert?
- Wofür werden die Dateien später benutzt?
- Ist das das Endergebnis oder nur ein Zwischenprodukt?

## 5) Zentrale Logik

1. Laden des Originalpanels und der Kontrollvariablen.
2. Laden der REVIEW-Datei mit `rohstoff_final`, `stabil_final`, `energie_vorschlag`.
3. Join der Klassifikation auf die MONA-Bedingungstexte per `desc`.
4. Erzeugen der Dummy-Variablen: `rohstoff_cond`, `stabil_cond`, `energie_cond`, `sonstige_cond`.
5. Aggregation auf Land-Jahr-Ebene.
6. Berechnung von Konditionalitätsanteilen wie `rohstoff_cond_share`.
7. Hinzufügen von `resource_dep` aus dem WDI-Panel.
8. Schätzung von H1, H2, H4 und Sensitivität H4_energie.
9. Schreiben der Ergebnisdatei und Modellobjekte.

Wichtige Fragen:

- Warum ist der Join entscheidend?
- Warum müssen die Zeilen auf Land-Jahr-Ebene aggregiert werden?
- Welche Variable ist der eigentliche Test in H4?

## 6) Kritische Begriffe

- Gate: Qualitätskontrolle vor weiterem Modellbau; hier: richtige Datenbasis und richtige Klassifikation
- Granularität: gleiche Datenebene; hier: einzelne Bedingungen vs. Land-Jahr-Aggregate
- unsc3: UNSC-Mitgliedschaft, im Originalzeitraum nach DSV-Regel `t | t+1`
- Review-Join: Verbindung von Bedingungstext und manuell geprüfter Klassifikation
- resource_dep: Rohstoffabhängigkeit aus WDI (Fuel/Mineral Export Anteil)
- Rohstoff-Klassifikation: Zuordnung zur extraktiven Sektorlogik, nicht breit gestreut

## 7) Wichtige Formeln / Variablen

- Hauptmodell H1: `avgcondtype_all ~ unsc3 + Kontrollen`
- Interaktion H2: `avgcondtype_all ~ unsc3 * resource_dep + Kontrollen`
- Hauptmodell H4: `rohstoff_cond_share ~ unsc3 * resource_dep + Kontrollen`
- Sensitivität: `energie_cond_share ~ unsc3 * resource_dep + Kontrollen`

## 8) Was ich hier verstanden habe

Dieses Skript ist der Kern der Hypothesenprüfung auf der Originalbasis. Es zieht zunächst die geeigneten Daten zusammen, verbindet die manuell geprüfte Klassifikation mit den MONA-Bedingungen und erzeugt dann die abhängigen Variablen. Der entscheidende Punkt ist, dass die Ressourcenklassifikation nicht mehr inline mit Regex gemacht wird, sondern per Review-Join auf die eindeutige Beschreibung. Dadurch werden typische Fehltreffer wie Bank-Privatisierungen vermieden.

## 9) Das ist noch unklar

1. Warum ist H4 mit der engen Klassifikation so null-inflatiert?
2. Welche Bedeutung hat die DSV-Regel bei `unsc3` exakt?
3. Warum sind H2/H4 trotz gültiger Join-Logik insgesamt nicht signifikant?

## 10) Kurzfazit

Dieses Skript ist wichtig, weil es die Datenbasis, die Ressourcen-Klassifikation und die Hypothesentests an einem Punkt zusammenführt und damit die zentrale empirische Prüfung der Replikation bildet.
