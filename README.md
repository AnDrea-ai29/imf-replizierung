# IMF-Konditionalität und UNSC-Mitgliedschaft

## Aktueller Fokus

Die eigenen Hypothesen werden in **Phase B** für den Analysezeitraum
**1992–2023** getestet. Das zugrunde liegende Datenpanel kann Beobachtungen bis
2025 enthalten, diese Jahre werden für die berichteten Phase-B-Analysen jedoch
ausgeschlossen. **Phase A** dient der separaten Validierung bzw. Replikation
der veröffentlichten Originalstudie; die Hypothesen aus Phase B werden nicht
auf dem Original-Ergebnisdatensatz geschätzt.

Die verbindliche Ausführungsreihenfolge und Erklärungen für die einzelnen
Schritte stehen in [docs/start_reihenfolge_replikation.md](docs/start_reihenfolge_replikation.md).
H3 wird zunächst explorativ mit deskriptiven Länderprofilen und manuellen
Ländervergleichen bearbeitet; es gibt dabei keinen inferenziellen
Regionaltest.

## Phase-B-Messung

Die primäre abhängige Variable `avgcondtype_count` wird für beide
Quellperioden nach derselben Rechenregel gebildet:

- 1992–2008: historische MONA-Zeilen aus
  `data/raw/original/construction/Data MONA.dta`.
- 2009–2025: MONA-Zeilen aus `data/raw/mona/Combined_ISO.xlsx`; für Phase B
  werden daraus nur Bewilligungsjahre bis einschließlich 2023 analysiert.
- Eine MONA-Zeile zählt als Bedingungszeile; es wird nicht nachträglich
  dedupliziert. Die Zeilen werden je Programm und danach je Land und
  Bewilligungsjahr summiert.
- Die Land-Jahr-Zahl wird durch die maximale Programmlaufzeit dieses
  Länder-Jahres in gerundeten 90-Tage-Quartalen geteilt.
- Das Berechnungsfenster für die Laufzeit ist auf 31.03.1992 bis 31.12.2025
  begrenzt. Die historische Zeilenzählung wird gegen den validierten
  DSV-Nachbau geprüft. Der statistische Analysezeitraum endet unabhängig davon
  am 31.12.2023.

Die Quellvintage wechselt 2009. Gleiche Berechnungsregeln bedeuten deshalb
nicht identische Rohdaten. Außerdem ist die daraus berechnete Zielvariable
keine unveränderte Kopie der publizierten Original-AV: Die Laufzeit wird
einheitlich für das zugrunde liegende Phase-B-Datenfenster berechnet. Die
Modelle und H3-Länderprofile schließen 2024 und 2025 aus.

Die klassifikationsbasierten Zusatzmaße aus `final_data_panel_ALL.csv` stammen
aus einem alten Regelpfad und werden nicht verwendet. Die frühere H4 auf Basis
klassifizierter rohstoffbezogener Auflagen wird wegen der unsicheren
Operationalisierung nicht mehr als confirmatorischer Test ausgewertet. Die
entsprechende Klassifikationspipeline bleibt für Transparenz und Reproduzierbarkeit
dokumentiert; die explorative Zusatzanalyse verwendet stattdessen die
kontinuierliche WDI-Variable `resource_dep`.

## Datenpipeline

```text
data/raw/unsc/DPPA-SCMembership.csv
  -> code/shared/data_prep/create_unsc_correct.R
  -> code/shared/data_prep/build_unsc_dsv_rule.R
  -> data/processed/unsc_dsv_rule_1946_2026.csv

data/raw/original/construction/Data MONA.dta
  -> code/shared/data_prep/rebuild_conditionality_1992_2008.R
  -> data/processed/conditionality_dsv_1992_2008.csv

data/raw/wdi/Data_all/*.csv
  -> code/shared/data_prep/build_controls_wdi.R
  -> data/processed/controls_wdi_1990_2025.csv

Historische MONA-Daten + Combined_ISO + UNSC + WDI
  -> code/phase_b/data_prep/build_phase_b_identical_measurement.R
  -> data/processed/phase_b_panel_identical_measurement_1992_2025.csv
  -> code/phase_b/analysis/phase_b_hypothesen_robustheit.R
```

Fehlende Kontrollwerte werden als fehlend (`NA`) belassen. Modelle verwenden
vollständige Fälle; die Schätzjahre können deshalb vom Panelzeitraum
abweichen. Signifikanz wird weder garantiert noch durch nachträgliche
Modellauswahl hergestellt.

## Phase-B-Modelle und Ergebnisse

Die Phase-B-Hauptmodelle und die regulären Robustheitsvarianten verwenden die
Kontrollvariablen des DSV-Vollmodells: `legelec_l`, `XDebtGNI`,
`DebtServGNI`, `ResXDebt`, `ExtBalGDP`, `GFCFGDP`, `USaidGDP`,
`imf_conc_gdp` und `imf_noconc_gdp`. Zusätzlich wird, wie im DSV-Modell,
`nrquarterssmpl` kontrolliert. Die Hauptspezifikation in Phase B behält
Länder- und Jahres-Fixed-Effects bei. Jahres-Fixed-Effects sind eine
ausdrücklich ergänzte Kontrolle; in der ursprünglichen DSV-Tabelle gibt es
keine Jahres-FE. Die FE-Modelle nutzen heteroskedastizitätsrobuste
Standardfehler. Das GLS-Modell verwendet den DSV-nahen FGLS-Ansatz mit
länderspezifischer Fehlervarianz. Modelle verwenden jeweils vollständige
Fälle der benötigten Variablen.

Eine separate IMF-Maß-Robustheit ersetzt `imf_conc_gdp` und
`imf_noconc_gdp` durch `UseIMFCredGDP`: den WDI-Indikator
`DT.DOD.DIMF.CD` („Use of IMF credit (DOD, current US$)“), geteilt durch das
nominale BIP und in Prozent ausgedrückt. Damit wird der ausstehende
IWF-Kreditbestand statt der jährlichen Nettoflüsse kontrolliert. Es handelt
sich um eine alternative Sensitivitätsspezifikation, nicht um eine Änderung
des Hauptmodells.

Die folgenden Resultate stammen aus dem zuletzt erfolgreich ausgeführten
Lauf von `code/phase_b/analysis/phase_b_hypothesen_robustheit.R` mit dem vollständigen
Kontrollsatz. Sie ersetzen die früheren Phase-B-Ergebnisse.

| Test | Koeffizient | Robuster SE | p-Wert | N | Modelljahre |
|------|------------:|------------:|-------:|--:|-------------|
| H1: UNSC auf Bedingungen pro Quartal | -0.933 | 1.920 | 0.628 | 281 | 1992–2023 |
| H2: `unsc3 × resource_dep` | -0.111 | 0.103 | 0.286 | 212 | 1992–2023 |
| H2-Robustheit: Fuel-Exporte | -0.224 | 0.098 | 0.024 | 213 | 1992–2023 |
| H2-Robustheit: Mineral-Exporte | 0.012 | 0.113 | 0.915 | 217 | 1992–2023 |
| H2-Placebo: Gesamtexporte | -0.119 | 0.132 | 0.368 | 281 | 1992–2023 |
| H1-Robustheit: IMF-Kreditbestand statt Nettoflüsse | -0.787 | 1.919 | 0.682 | 281 | 1992–2023 |
| H2-Robustheit: IMF-Kreditbestand statt Nettoflüsse | -0.104 | 0.101 | 0.302 | 212 | 1992–2023 |
| H2-Robustheit: Winsorisierung | -0.111 | 0.103 | 0.285 | 212 | 1992–2023 |
| H1-Robustheit: Poisson-FE auf Bedingungszahl (Offset log Quartale) | -0.043 | 0.152 | 0.780 | 281 | 1992–2023 |
| H1-Robustheit: Original-Handkorrektur unsc3 (RUS 1995/96/99, ETH 1992) | -0.933 | 1.920 | 0.628 | 281 | 1992–2023 |
| H2-Robustheit: Original-Handkorrektur unsc3 (RUS 1995/96/99, ETH 1992) | -0.111 | 0.103 | 0.286 | 212 | 1992–2023 |
| H2-Robustheit: Zeitfenster 1992–2008 | 0.274 | 0.104 | 0.012 | 112 | 1992–2007 |
| H2-Robustheit: Zeitfenster 2009–2023 | -0.377 | 0.202 | 0.072 | 88 | 2009–2023 |

Als zusätzliche IMF-Maß-Robustheit werden H1 und H2 mit
`UseIMFCredGDP` (WDI `DT.DOD.DIMF.CD`) anstelle der beiden Nettoflussmaße
geschätzt. Diese Spezifikation ist sensitivitätsanalytisch und ersetzt nicht
die Hauptmodelle. Der vorhandene Aufbereitungspfad setzt fehlende WDI-Werte
für IMF-Maße gemäß der DSV-Konvention auf null. Ein zusätzlicher Lauf, der
fehlende Bestandswerte als fehlend behandelt und ausschließt, lieferte für
H1 und H2 dieselben Complete-Case-Stichproben und Schätzungen. Die
Ergebnisse stehen in derselben Hypothesen-Tabelle unter „IMF-Kreditbestand
statt Nettoflüsse“.

Als weitere Zählmodell-Robustheit wird H1 zusätzlich als Poisson-Fixed-Effects-Modell auf der Bedingungszahl `nrcondtype_all` mit dem Logarithmus der Programmlaufzeit als Offset geschätzt (analog zu `xtpoisson` in Tabelle S2 des Originals). Der Koeffizient ist eine Semi-Elastizität: temporäre UNSC-Mitgliedschaft geht mit rund 4 Prozent weniger Bedingungen pro Quartal einher und ist wie im linearen Hauptmodell nicht signifikant. Die Stichprobe entspricht dem H1-Hauptmodell (N = 281).

Als UNSC-Kodierungs-Robustheit werden die Original-Handkorrekturen
(`replace unsc3 = 0` für RUS 1995/1996/1999 und ETH 1992 in `txt2dta7.do`),
die der Phase-B-Nachbau bewusst nicht auf das Vollpanel anwendet, auf der
Schätzstichprobe nachgezogen. Ergebnis: H1 ist numerisch identisch
(-0.933), weil Russland im Modell nur Jahre mit `unsc3 = 1` beiträgt und
das Länder-FE die innerhalb Russlands konstante Behandlung aufsaugt; H2
ändert sich erst in der fünften Dezimalstelle (-0.1106 vs. -0.1106). Die
kodierungsbedingte Abweichung hat damit keinen Einfluss auf die
Phase-B-Schlüsse.

Mit dem vollständigen Kontrollsatz sind H1 und die H2-Hauptinteraktion nicht
signifikant. Die H2-Zeitfenster sind Robustheitsanalysen: im älteren Fenster
liegt p = 0.012, im neueren p = 0.072. Die Haupthypothese H2 bezieht sich
weiterhin auf den gesamten Zeitraum, für den alle erforderlichen Variablen
gemeinsam vorliegen; die Teilfenster ersetzen den Haupttest nicht.

Die frühere H4-Klassifikation wird nicht als Hypothesentest berichtet. Als
schlanke explorative Ergänzung wird stattdessen die Konditionalität pro Quartal
im Programm-Bewilligungsjahr t der Veränderung der WDI-Rohstoffexportabhängigkeit
zwischen t und t+3 gegenübergestellt. Für die 1992–2023-Auswertung ergeben sich
333 vollständige Programm-Land-Jahre aus 99 Ländern; die Spearman-Korrelation
beträgt 0,039. Das ist ein nahezu nuller deskriptiver Zusammenhang, kein
kausaler Effekt. Die Auswertung enthält keine Länder-Jahre ohne IMF-Programm
als Vergleichsgruppe; zudem kann der Dreijahreszeitraum noch in die Laufzeit
eines Programms fallen. Beobachtungsdaten, Übersicht und Grafik werden mit
`code/phase_b/analysis/phase_b_h4_exploration.R` unter
`results/phase_b/exploration/` erzeugt.

Eine rein deskriptive Zusatzauswertung zur Komposition der Bedingungen
(`code/phase_b/analysis/phase_b_komposition_exploration.R`) stellt die Anteile
rohstoff- bzw. stabilitätsklassifizierter Bedingungen nach Quartilen der
Rohstoffexportabhängigkeit gegenüber
(`results/phase_b/exploration/komposition_ressourcen_quartile.csv` und
`..._unsc3.csv`). Sie nutzt das Klassifikationspanel und ist ausdrücklich
explorativ; Arrangement-Typen werden nicht als Kontrollen verwendet.

Vorangestellte deskriptive Evidenz nach dem Vorbild der
Original-Tabelle 1 erzeugt `code/phase_b/analysis/phase_b_deskriptive_evidenz.R`:
Mittelwerte, Standardabweichungen und Welch-t-Tests für UNSC- vs.
Nicht-UNSC-Jahre (1992–2023), zusätzlich getrennt nach Median-Split der
Rohstoffexportabhängigkeit für H2. Ausdrücklich deskriptiv gekennzeichnet;
Outputs unter `results/phase_b/tables/phase_b_deskriptive_evidenz.csv` und
`..._h2_split.csv`.

Die Länderliste der temporären UNSC-Mitglieder (Wahljahr + zweijährige
Amtszeit, entsprechend dem `unsc3`-Behandlungsfenster) erzeugt
`code/phase_b/analysis/phase_b_unsc_mitgliederliste.R` nach dem Vorbild von
Tabelle 1 des Originals; nur nicht-ständige Mitglieder. Output:
`results/phase_b/tables/phase_b_unsc_mitglieder.csv`. Bekannte, dokumentierte
Abweichung: Die drei RUS-Programmjahre 1995/1996/1999 sind im Phase-B-Panel
als `unsc3 == 1` kodiert, während das Original sie per Handkorrektur auf 0
setzt (ständiges Mitglied).

### Modellvergleich zur DSV-Spezifikation

Damit sich die Schätzentscheidungen direkt nachvollziehen lassen, rechnet
Phase B vergleicht H1 und H2 in vier Varianten. Basismodelle enthalten nur die
DSV-Laufzeitkontrolle `nrquarterssmpl`; Vollmodelle ergänzen alle neun
DSV-Kontrollen. Das Jahres-FE-Modell ist die Zwei-Wege-FE-Hauptspezifikation.
Das GLS-Modell nutzt länderspezifische Fehlervarianzen nach dem DSV-nahen
FGLS-Verfahren und enthält keine Jahres-FE.

| Hypothese | Basismodell, Länder-FE | Vollmodell, Länder-FE | Vollmodell, Länder- und Jahres-FE | Vollmodell, DSV-nahes GLS |
|-----------|----------------------:|---------------------:|----------------------------------:|-------------------------:|
| H1: UNSC | -0.454 (p = 0.806; N = 514) | 0.144 (p = 0.959; N = 282) | -0.933 (p = 0.628; N = 281) | 0.046 (p = 0.974; N = 282) |
| H2: UNSC × resource_dep | 0.060 (p = 0.439; N = 380) | -0.055 (p = 0.677; N = 212) | -0.111 (p = 0.286; N = 212) | -0.014 (p = 0.841; N = 212) |

Die p-Werte ändern sich je nach Spezifikation; daher ist die Zwei-Wege-FE-
Variante nicht nach Signifikanz, sondern als vorab gewählte Hauptspezifikation
zu berichten. Die Modelle sind bestmöglich vergleichbar, aber nicht identisch
mit DSV: Die Phase-B-Zielvariable und der Zeitraum unterscheiden sich, und
nur die Zwei-Wege-FE-Variante nimmt Jahres-FE auf. Die vollständige
Vergleichstabelle mit Stichprobenjahren und allen Modellmetadaten steht in
`results/phase_b/tables/phase_b_modellvergleich.csv`.

Das zugrunde liegende Panel umfasst 543 beobachtete Land-Jahre aus 116 Ländern
zwischen 1992 und 2025. Für sämtliche Phase-B-Modelle und die H3-Profile
werden ausschließlich Jahre 1992–2023 verwendet; 2024 und 2025 sind
ausgeschlossen. Die jeweils verwendeten Länder-Jahre und Stichprobengrößen
sind in der Ergebnistabelle dokumentiert. Die vollständige
Ergebnistabelle sowie die Leave-one-country-out-Auswertung stehen in:

- `results/phase_b/tables/phase_b_hypothesen_robustheit.csv`
- `results/phase_b/tables/phase_b_modellvergleich.csv`
- `results/phase_b/tables/phase_b_h2_leave_one_country_out.csv`
- `results/phase_b/exploration/h3_country_profiles.csv` (explorative
  Länderprofile; kein inferenzieller Regionaltest)
- `results/phase_b/models/phase_b_h2_main.rds`

Für druckfertige Tabellen führt man nach den Analysen
`Rscript "code\phase_b\analysis\export_phase_b_tables.R"` aus. Das Skript
erstellt getrennte Ergebnis- und Modellvergleichstabellen für H1 und H2
als LaTeX-Fragmente und Word-Dokumente unter
`results/phase_b/publication/`. H3 erhält stattdessen eine rein deskriptive
Länderprofil-Tabelle; ein Modellvergleich ist für die explorative H3-Analyse
nicht anwendbar. Zusätzlich entstehen zusammenfassende Tabellen für den
Anhang. Die CSV-Ausgaben bleiben die Präzisionsquelle; LaTeX-Dateien sind
Fragmente und nennen ihre benötigten Pakete im Dateikopf. Word- und
LaTeX-Tabellen werden standardmäßig im Querformat ausgegeben. Die frühere H4
wird nicht mehr in diese inferenziellen Tabellen exportiert; ihre explorative
Zusatzanalyse wird separat dokumentiert.

## Phase A: separate Originalreplikation

Die historische Konstruktion ist im Skript
`code/shared/data_prep/rebuild_conditionality_1992_2008.R` dokumentiert und
gegen den Originaldatensatz validiert. Sie rekonstruiert 314 Land-Jahre,
einschließlich der historischen Zählung, Quartalsregel, Länder-Jahr-
Korrekturen und der UNSC-Regel `unsc3 = Mitgliedschaft in Jahr t oder t+1`.
Diese Validierung dient als Herkunfts- und Zählvergleich für den
Phase-B-Aufbau. Eine vollständige Replikation der veröffentlichten Studie
ist ein separater, optionaler Analysepfad. Beim Ausführen von
`code/phase_a/replication/phase0_replikation_original.R` bleibt die unveränderte
DSV-Replikation in `results/phase_a/tables/original_replication.csv` erhalten. Zusätzlich wird für
dieselben fünf Stichproben-/Kontrollvarianten ein Länder-FE-Modell mit
Jahres-FE geschätzt. Das ist die Sensitivitätsanalyse zur Frage, was sich
gegenüber der publizierten Spezifikation ändert:

- `results/phase_a/tables/original_replication_jahres_fe.csv`
- `results/phase_a/models/model_original_fe_basis_jahres_fe.rds`
- `results/phase_a/models/model_original_fe_voll_jahres_fe.rds`

Die Supplement-Tabellen S2 und S3 (Scope-Depvar) sind als separate
Validierungsreplikation mit
`code/phase_a/replication/phase0_replikation_tabelleS2S3.R` umgesetzt:
S2 schätzt `scope_0` je Spezifikation mit Länder-FE, AR(1)-GLS und Poisson-FE,
S3 schätzt `scope_1`–`scope_3` nur mit AR(1)-GLS. Das AR(1)-GLS ist ein
iterativer Prais-Winsten-FGLS-Nachbau mit gemeinsamem rho und
`nrcntprogram` als Panel-Zeitindex; da keine Stata-Sollwerte für S2/S3 im
Repo liegen, ist es dokumentiert, aber nicht zeilengleich gegen Stata
validiert. Ergebnisse:
`results/phase_a/tables/original_replication_tabelleS2.csv` und
`original_replication_tabelleS3.csv`. Der UNSC-Koeffizient auf den
Scope-Maßen ist durchweg negativ, aber in den FE- und Poisson-Schätzungen
nicht signifikant — konsistent mit dem Originalbefund, dass der Effekt
für den Konditionalitätsumfang schwächer ausfällt als für die
Bedingungszahl.

Im geprüften Lauf betrug der UNSC-Koeffizient im Basis-FE-Modell ohne
Jahres-FE -2.410 (p = 0.058); mit Jahres-FE lag er bei -2.030
(p = 0.103). Im Vollmodell änderte sich der Koeffizient von -3.329
(p = 0.053) ohne Jahres-FE auf -3.001 (p = 0.089) mit Jahres-FE. Die
Jahres-FE-Sensitivität schwächt den Befund in diesen beiden Spezifikationen
ab; die ursprüngliche DSV-Ergebnistabelle wird dadurch nicht überschrieben.

## Nächste Schritte

1. Explorative H3-Länderprofile vergleichen und mögliche Muster transparent
   dokumentieren; einen bestätigenden Regionaltest nur als separate,
   unabhängig spezifizierte Folgeanalyse planen.
2. Die aktualisierten Tabellen aus den phasenspezifischen Ordnern unter
   `results/phase_a/tables/` und `results/phase_b/tables/` in die Hausarbeit
   übernehmen; dabei Messregel, Stichprobe und Unsicherheit mitberichten.
