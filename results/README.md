# Ergebnisdateien

Die Ergebnisordner spiegeln die Phasenstruktur von `code/` wider. Skripte
werden aus dem Projektstamm gestartet; die Pfade unten sind relativ zum
Projektstamm.

```text
results/
  README.md
  ERgebnismatrix.md
  shared/
    tables/                 # gemeinsame Datenprüfungen
  phase_a/
    tables/                 # DSV-Replikation und Originalbasis-Analysen
    models/
  phase_b/
    tables/                 # aktuelle Hypothesen- und Robustheitsergebnisse
    models/
    replication_comparison/ # gesonderter globaler Vergleichspfad
      tables/
      models/
  legacy/
    tables/                 # ältere, nicht aktualisierte Analysen
    models/
  figures/                  # Abbildungen nach Bedarf
```

H4 verwendet für historische und moderne MONA-Beschreibungen dieselbe
Operationalisierung der Phase-A-Definitionsvorschläge.
`Conddisc_final.csv` bleibt die kuratierte
Phase-A-Referenz; die historischen H4-Werte können davon abweichen, weil die
einheitliche Regel für beide Zeiträume angewandt wird. Der moderne Crosswalk
und das resultierende H4-Panel dokumentieren Regelversion und Eingabequellen.
417 historische Bedingungen ohne `areadescription` werden mangels Textsignal
als 0 geführt und in `phase_b_h4_missing_description_audit.csv` ausgewiesen.
Das neu berechnete H4-Hauptmodell schätzt `unsc3 × resource_dep` mit
β = −0,0000019 (robuster SE = 0,0004957, p = 0,997; N = 212,
1992–2023). Alternative Fuel-/Mineral-Maße, Winsorisierung,
Quellenzeitfenster und Leave-one-country-out-Diagnosen stehen in den
H4-Ergebnistabellen. Diese Resultate ersetzen den früheren Lauf mit
gemischter Klassifikation.

Die [Ergebnismatrix](./ERgebnismatrix.md) dokumentiert pro Datei Phase,
Erzeugerskript, Aktualitätsstatus und vorgesehene Verwendung. „Legacy“
bedeutet nicht automatisch wertlos: diese Ausgaben sind lediglich keine
Ergebnisse des derzeitigen Hauptanalysepfads.

Ergebnisse werden durch die jeweiligen Skripte erzeugt und nicht manuell
bearbeitet. Vor dem Archivieren oder Entfernen ist die Matrix auf
Abhängigkeiten zu prüfen. Rohdaten in `data/raw/` sind von dieser
Ordnerstruktur nicht betroffen.
