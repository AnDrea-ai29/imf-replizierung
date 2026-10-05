# Startreihenfolge für die Hausarbeit

## Kurzfassung

Für deine eigenen Hypothesen ist **Phase B** relevant. Der verbindliche
Analysezeitraum ist **1992–2023**; Beobachtungen aus 2024 und 2025 werden
trotz ihres Vorhandenseins im zugrunde liegenden Panel ausgeschlossen.
Phase A ist die
separate Replikation der veröffentlichten Originalstudie und keine
Voraussetzung für die Hypothesentests.

Die Phase-B-Zielvariable `avgcondtype_count` wird im zugrunde liegenden Panel
für 1992–2025 nach einer gemeinsamen Regel gebaut. Die statistische Analyse
und die explorativen H3-Länderprofile verwenden daraus ausschließlich
1992–2023:

- Eine Zeile in der jeweiligen MONA-Quelle zählt als eine Bedingungszeile;
  es wird nicht nachträglich dedupliziert.
- Die Zeilen werden je Programm und anschließend je Land und
  Bewilligungsjahr gezählt.
- Die Quartalsdauer je Programm ist `round(Tage/90)`, begrenzt auf das
  gemeinsame Analysefenster 31.03.1992–31.12.2025.
- Der Länder-Jahres-Wert ist die Summe der Bedingungszeilen geteilt durch
  die längste Programmlaufzeit dieses Länder-Jahres.

Für 1992–2008 stammen die Eingabezeilen aus dem historischen DSV-MONA-Auszug,
für 2009–2025 aus `Combined_ISO.xlsx`. Die Rechenregel ist dieselbe; die
Quellvintage wechselt aber 2009. Das neue Ergebnis ist daher keine
unveränderte Kopie der Original-AV `avgcondtype_all`: insbesondere wird die
Laufzeit hier einheitlich bis zum Ende des Gesamtzeitraums berechnet. Die
Zählung der historischen Bedingungszeilen wird beim Erstellen gegen den
validierten DSV-Nachbau geprüft.

Das zugrunde liegende Panel umfasst 1992–2025, aber die Analyse schließt
2024 und 2025 bewusst aus und begrenzt jedes Modell auf 1992–2023. Innerhalb
dieses festgelegten Fensters verwenden Modelle vollständige Fälle der jeweils
benötigten Variablen; ihre tatsächlichen Schätzstichproben können daher
weiterhin kleiner sein. Signifikanz kann nicht garantiert oder durch
Modellauswahl hergestellt werden.

## Phase B: Hypothesen ausführen

Alle Befehle im Projektstamm
`C:\Users\HP\io\imf-replizierung` ausführen. Bei einem vollständigen
Neuaufbau die folgenden Skripte **in dieser Reihenfolge** starten:

1. `Rscript "code\shared\data_prep\create_unsc_correct.R"`
2. `Rscript "code\shared\data_prep\build_unsc_dsv_rule.R"`
3. `Rscript "code\shared\data_prep\rebuild_conditionality_1992_2008.R"`
4. `Rscript "code\shared\data_prep\build_controls_wdi.R"`
5. `Rscript "code\phase_b\data_prep\build_phase_b_identical_measurement.R"`
6. `Rscript "code\shared\data_prep\build_phase_a_definition_crosswalk.R"`
7. `Rscript "code\phase_b\data_prep\build_phase_b_h4_panel.R"`
8. `Rscript "code\phase_b\analysis\phase_b_hypothesen_robustheit.R"`
9. `Rscript "code\phase_b\analysis\phase_b_h3_exploration.R"`
10. `Rscript "code\phase_b\analysis\export_phase_b_tables.R"`

Die ersten vier Skripte erzeugen die UNSC-Zuordnung, den validierten
historischen Zählvergleich und das Kontrollpanel.
`build_phase_b_identical_measurement.R` baut direkt aus den historischen und
aktuellen MONA-Rohdaten die einheitliche Zähl-AV und speichert:

- `data\processed\phase_b_panel_identical_measurement_1992_2025.csv`

Das Analyseskript (`phase_b_hypothesen_robustheit.R`) liest ausschließlich dieses neue Panel für die
Zähl-AV. H1, H2 und ihre Robustheitsspezifikationen verwenden dieselben
neun Kontrollvariablen wie das DSV-Vollmodell:
`legelec_l`, `XDebtGNI`, `DebtServGNI`, `ResXDebt`, `ExtBalGDP`, `GFCFGDP`,
`USaidGDP`, `imf_conc_gdp` und `imf_noconc_gdp`. Zusätzlich wird, wie im
DSV-Modell, `nrquarterssmpl` als Laufzeitkontrolle aufgenommen. Phase B
behält Länder- und Jahres-Fixed-Effects bei; die DSV-Originaltabelle enthält
keine Jahres-Fixed-Effects. Beobachtungen mit fehlenden Werten in den
jeweiligen Kontrollen werden aus dem betreffenden Modell ausgeschlossen.

Die Analyse berechnet H1/H2 und deren Robustheiten. Schritt 6 erstellt den
Crosswalk, indem dieselbe operationalisierte Phase-A-Definitionsregel auf
alle modernen MONA-Beschreibungen angewandt wird. Dabei gilt `cooking oil`
ausdrücklich nicht als Rohstoff; weitere Rohstoffsignale im selben Text
bleiben wirksam.
Schritt 7 klassifiziert mit derselben Funktion auch die historischen
`areadescription`-Texte und erstellt das H4-Panel. Damit gilt für 1992–2025
eine einheitliche, deterministische Regelversion. `Conddisc_final.csv` bleibt
die kuratierte Phase-A-Referenz; H4 verwendet jedoch bewusst für beide
Zeiträume dieselbe Operationalisierung der Phase-A-Definitionsvorschläge.
Die 417 historischen Zeilen ohne `areadescription` erhalten mangels Textsignal
den Wert 0 und werden in
`data\processed\phase_b_h4_missing_description_audit.csv` ausgewiesen.
Das H4-Modell testet
`unsc3 × resource_dep` mit den vollständigen Kontrollen sowie Länder- und
Jahres-FE. Robustheiten umfassen Fuel-/Mineral-Abhängigkeit, Winsorisierung,
beide Quellenzeitfenster und Leave-one-country-out.
Zusätzlich berechnet das Analyseskript für H1/H2 und H4 einen
Spezifikationsvergleich: Basismodell nur mit `nrquarterssmpl` und
Länder-FE, Vollmodell mit Länder-FE, Vollmodell mit Länder- und Jahres-FE
sowie für H1/H2 ein DSV-nahes GLS-Vollmodell mit länderspezifischer
Fehlervarianz. Für H4 ist die GLS-Variante wegen einer singulären
Spezifikation nicht enthalten.
Die zusätzliche Modelltabelle wird unter
`results\phase_b\tables\phase_b_modellvergleich.csv` gespeichert. Die Outputs sind:

- `results\phase_b\tables\phase_b_hypothesen_robustheit.csv`
- `results\phase_b\tables\phase_b_modellvergleich.csv`
- `results\phase_b\tables\phase_b_h2_leave_one_country_out.csv`
- `results\phase_b\tables\phase_b_h4_leave_one_country_out.csv`
- `results\phase_b\models\phase_b_h2_main.rds`
- `results\phase_b\models\phase_b_h4_main.rds`

Schritt 10 erstellt getrennte Ergebnis- und Modellvergleichstabellen für
H1, H2 und H4 als LaTeX-Fragmente und Word-Dokumente unter
`results\phase_b\publication\`. H3 erhält eine deskriptive Länderprofil-
Tabelle, aber keinen Modellvergleich, da H3 explorativ ist. Die CSV-Dateien
mit voller numerischer Präzision bleiben unter `results\phase_b\tables\`;
H3-Profile stehen unter `results\phase_b\exploration\`. Ergänzend werden
zusammenfassende Ergebnis- und Modellvergleichstabellen für den Anhang unter
den bisherigen Dateinamen `phase_b_hypothesen_robustheit.*` und
`phase_b_modellvergleich.*` aktualisiert. Die LaTeX-Fragmente setzen
alle Tabellen werden standardmäßig im Querformat ausgegeben. Für LaTeX
benötigen die Fragmente `booktabs`, `longtable`, `array` und `pdflscape`;
der Dateikopf nennt die Pakete.

Die Klassifikationswerte aus dem alten globalen MONA-Panel dürfen nicht als
H4-Ergebnisse berichtet werden. Die aktuellen H1/H2-Tests nutzen
`avgcondtype_count`; H4 nutzt `rohstoff_cond_share` aus dem dedizierten
klassifizierten Panel. Der vollständige DSV-Kontrollsatz verkleinert die
tatsächlich schätzbare Stichprobe gegenüber dem Panelzeitraum.

Die Robustheits-Zeitfenster 1992–2008 und 2009–2023 liegen beiderseits des
MONA-Quellenwechsels. Sie helfen zu beurteilen, ob Resultate von einer
Teilperiode abhängen; sie ändern nicht nachträglich die Hauptspezifikation.

## H3

H3 wird zunächst explorativ und ohne vorab festgelegte Regionen bearbeitet.
Schritt 9 erstellt für jedes Land ein deskriptives Profil mit Datenumfang,
UNSC-Jahren, durchschnittlicher Konditionalität insgesamt und getrennt nach
`unsc3`, der deskriptiven Differenz sowie mittlerer Rohstoffabhängigkeit. Die
Profile stehen in `results\phase_b\exploration\h3_country_profiles.csv`.

Die Profile dienen dem manuellen Ländervergleich und der Suche nach möglichen
regionalen Mustern oder anderen Länderbesonderheiten. Sie berechnen keine
Signifikanztests, markieren keine Ausreißer automatisch und weisen keine
Regionen zu. Die Unterschiede sind deskriptiv, nicht kausal; insbesondere
sind Länder mit wenigen UNSC-Jahren vorsichtig zu interpretieren. Aus den
Profilen abgeleitete Gruppen oder Auffälligkeiten sind als explorativ zu
kennzeichnen und nicht mit einer unabhängigen Bestätigungshypothese
gleichzusetzen.

## Phase A: optionale Originalreplikation

Phase A beantwortet eine andere Frage: Reproduziert die Auswertung den
publizierten Originalbefund mit dessen Datensatz und dessen ursprünglichem
Beobachtungsfenster? Dafür dienen die Schritte 1–4 oben als Vorbereitung;
danach `Rscript "code\phase_a\replication\phase0_replikation_original.R"` ausführen.
Das Skript lässt die unveränderte DSV-Replikation in
`results\phase_a\tables\original_replication.csv` bestehen und berechnet zusätzlich
die entsprechenden Länder-FE-Modelle mit Jahres-FE in
`results\phase_a\tables\original_replication_jahres_fe.csv`. So bleibt die
Originalspezifikation als Referenz erhalten und die Jahres-FE-Erweiterung
wird separat verglichen. Die eigenen Hypothesen müssen dafür nicht auf dem
Originaldatensatz getestet werden.

## Was „fertig“ bedeutet

- **Phase-B-Hauptanalyse:** H1/H2 samt Robustheiten sind auf der gemeinsamen
  Zählregel gerechnet und mit Koeffizienten, Unsicherheit,
  Beobachtungsumfang und tatsächlich verwendeten Jahren zu berichten.
- **H4 und alternative Anteils-AV:** gesondert als klassifikationsbasierte
  Analysen kennzeichnen; ihre Stichprobe beginnt später.
- **H3:** Länderprofile und manuelle Vergleiche explorativ berichten; ein
  bestätigender Regionaltest ist nicht Teil des aktuellen H3-Plans.
- **Originalreplikation:** nur erforderlich, wenn sie als separater Vergleich
  Teil der Hausarbeit sein soll.
