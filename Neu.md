# Aktualisiertes Untersuchungsdesign: globaler Länderpool + regionale Differenzierung

## 1. Ziel des Designs

Die Phase-B-Analyse verwendet einen globalen Länderpool und den Zeitraum 1992–2023; Panelbeobachtungen aus 2024 und 2025 werden ausgeschlossen. H1 und H2 sind die inferenziellen Analysen. Ergänzende Mustervergleiche und die ehemalige H4-Frage werden explorativ behandelt; Regionen werden nicht vorab anhand der Ergebnisse festgelegt.

Der manuelle Vergleich und die daraus entwickelten Muster sind explorativ. H3 ist daher zunächst eine Forschungsfrage und kein bestätigender statistischer Hypothesentest.

---

## 2. Forschungsfrage und Hypothesen

### Forschungsfrage
> Inwiefern beeinflusst UNSC-Mitgliedschaft die IMF-Konditionalität, und ist dieser Effekt in rohstoffabhängigen Kontexten stärker ausgeprägt? Welche Länder oder Ländergruppen zeigen dabei mögliche Auffälligkeiten?

### Hypothesen

| Hypothese | Formulierung | Test | Theoretische Grundlage |
|-----------|--------------|------|------------------------|
| H1 | UNSC-Mitgliedschaft ist mit geringerem Maß an IMF-Konditionalität verbunden. | Replikation mit globalem bzw. erweitertem Panel | Politische Ökonomie / Originalstudie |
| H2 | Rohstoffabhängigkeit verstärkt den Effekt von UNSC-Mitgliedschaft auf IMF-Konditionalität. | Interaktionsmodell `unsc3 * resource_dep` | Dependenz-/Neokolonialismus-Argument |
| H3 (explorativ) | Welche Länder oder Ländergruppen zeigen im Zusammenhang zwischen UNSC-Mitgliedschaft und IMF-Konditionalität auffällige Muster, und welche Gemeinsamkeiten könnten diese erklären? | Deskriptive Länderprofile und systematischer manueller Fallvergleich; keine inferenzielle Bestätigung | Regionaler Kontext und Heterogenität |
| Explorativ (vormals H4) | Hängen IMF-Auflagen in einem Programmjahr mit der späteren Veränderung der Rohstoffexportabhängigkeit zusammen? | Deskriptive Analyse der Veränderung von `resource_dep` zwischen Jahr t und t+3; kein bestätigender oder kausaler Test | Mögliche längerfristige Zusammenhänge zwischen IMF-Programmen und Exportstruktur |

---

## 3. Aktualisierte Vorgehensweise

### Phase 1: Datengrundlage erweitern
- H1-Datensatz aus dem erweiterten Länderpool verwenden
- Datensätze aus MONA, UNSC, WDI und ggf. kontrollierten Paneldaten harmonisieren
- globale bzw. nicht-SSA-Paneldaten mit denselben Variablen wie im SSA-Design ergänzen
- Variable `resource_dep` standardisieren und definieren

### Phase 2: Replikationsbasis sichern
- H1-Replikationsmodell zunächst mit globalem bzw. erweitertem Panel schätzen
- Vergleich mit originalem Zeitraum und mit ergänztem Zeitraum
- sicherstellen, dass die Variablen mit den zuvor verwendeten Namen konsistent sind

### Phase 3: Explorative Länderprofile erstellen
- alle Länder 1992–2023 anhand derselben Variablen und Regeln vergleichen
- Umfang und Zeitraum der verfügbaren Beobachtungen sichtbar machen
- Konditionalität insgesamt sowie getrennt nach `unsc3` zusammenfassen
- UNSC-Jahre und mittlere Rohstoffabhängigkeit mitberichten
- keine Region und keinen Ausreißer automatisch aus den Ergebnissen ableiten

### Phase 4: Manueller Ländervergleich
- Länderprofile und Datenabdeckung nebeneinander prüfen
- auffällige Länder und mögliche Gemeinsamkeiten nachvollziehbar notieren
- mögliche Regionen oder andere Besonderheiten erst aus diesem Vergleich entwickeln

### Phase 5: Explorative Muster beschreiben
- beobachtete Unterschiede als deskriptiv und nicht kausal interpretieren
- bei wenigen UNSC-Jahren pro Land keine stabilen Ländereffekte unterstellen
- nachträglich gefundene Gruppen als explorativ kennzeichnen

### Explorative Zusatzanalyse (vormals H4)
- die frühere H4 zur Klassifikation rohstoffbezogener Auflagen und zu Regionen
  wird nicht als Hypothesentest verwendet
- stattdessen wird für Programm-Land-Jahre die Auflagenintensität pro Quartal
  im Bewilligungsjahr t der Veränderung von `resource_dep` von t bis t+3
  gegenübergestellt
- `resource_dep` misst Treibstoff- und Mineralexporte als Anteil der
  Warenexporte; die Veränderung wird in Prozentpunkten ausgewiesen
- ausgewertet werden nur Programm-Land-Jahre mit vollständigen Werten zu t
  und t+3; Länder-Jahre ohne IMF-Programm sind keine Vergleichsgruppe
- die Ausgabe umfasst eine Beobachtungstabelle, eine Übersicht mit Fallzahlen
  und Spearman-Korrelation sowie ein Streudiagramm mit deskriptiver
  Trendlinie; es werden keine kausalen Effekte behauptet
- da das Auflagenmaß dem Bewilligungsjahr eines Programms zugeordnet ist und
  Programmzeiträume länger dauern können, ist der Dreijahreszeitraum nicht
  zwingend vollständig nach Ende des Programms
- Umsetzung: `code/phase_b/analysis/phase_b_h4_exploration.R`

### Phase 6: Optionaler nächster Forschungsschritt
- falls ein bestätigender Test gewünscht ist, Gruppen unabhängig von diesen Ergebnissen festlegen
- einen solchen Test oder eine Prüfung an neuen Daten als separate Analyse planen

### Phase 7: Robustheitschecks
- unterschiedliche Zeitfenster prüfen
- fehlende Werte/Extreme Werte prüfen
- alternative Spezifikationen der Rohstoffabhängigkeit testen
- IMF-Kreditbestand (`UseIMFCredGDP`, WDI `DT.DOD.DIMF.CD`) als alternative
  Kontrolle anstelle der beiden IMF-Nettoflussmaße (`imf_conc_gdp`,
  `imf_noconc_gdp`) testen
- Standardfehler robustifizieren
- ggf. year fixed effects ergänzen

### Phase 8: Interpretation und Schlussfolgerung
- Effekt nicht nur als statistisch signifikant, sondern als kontextabhängig interpretieren
- explorative H3-Muster nicht als bestätigte regionale Heterogenität ausgeben

---

## 4. Notwendige Schritte zur Ausführung des Untersuchungsdesigns

### Schritt 1: Datensatz finalisieren
- globalen H1-Panel oder erweiterten Länderpool laden
- gemeinsame Variablen vereinheitlichen
- `ISO3`, `Year`, `avgcondtype_all`, `unsc3`, `resource_dep`, Kontrollvariablen validieren

### Schritt 2: Rohstoffvariable sicherstellen
- `resource_dep` definieren
- falls nötig mit `FuelExportPct + MineralExportPct` rekonstruieren
- fehlende Werte kontrollieren

### Schritt 3: Explorative Länderprofile erstellen
- zunächst keine Region festlegen und keine `region`-Variable aus den Ergebnissen ableiten
- Profile aller Länder mit denselben Kriterien erstellen

### Schritt 4: Deskriptive Analyse ausführen
- `code/phase_b/analysis/phase_b_h3_exploration.R` ausführen
- `results/phase_b/exploration/h3_country_profiles.csv` manuell vergleichen
- Auffälligkeiten und Auswahlkriterien transparent protokollieren; keine automatische Ausreißerklassifikation

### Schritt 5: Basismodell schätzen
- H1-Modell im erweiterten Pool schätzen
- Parameter prüfen und mit Originaldesign vergleichen

### Schritt 6: Interaktionsmodelle testen
- `avgcondtype_all ~ unsc3 * resource_dep + Kontrollen`
- dies ist der H2-Test; er bestätigt H3 nicht
- keine nachträglich aus den Profilen abgeleitete H3-Regionen inferenziell testen

### Schritt 7: Subgroup-Analyse durchführen
- auffällige Länder deskriptiv miteinander vergleichen
- mögliche Gemeinsamkeiten oder Regionen als explorative Beobachtung beschreiben
- keine kausalen oder bestätigenden Aussagen aus nachträglich gebildeten Gruppen ableiten

### Schritt 8: Robustheitschecks und Validierung
- Heteroskedastizität prüfen
- Extreme Werte / Ausreißer behandeln
- Zeitauswahl prüfen
- Sensitivität gegenüber IMF-Nettoflüssen versus ausstehendem IMF-Kreditbestand
  prüfen; den Kreditbestand als alternative Spezifikation und nicht als
  zusätzliche Hauptkontrolle behandeln
- Ergebnisse konsistent mit Theorie und Datenlage interpretieren

### Schritt 9: Ergebnisse dokumentieren
- Schätzergebnisse zusammenfassen
- relevante regionale Muster festhalten
- finalen Datensatz und finalen Analysepfad dokumentieren

---

## 5. Übersichtlicher Ablaufplan

| Phase | Aufgabe | Ergebnis |
|-------|---------|----------|
| 1 | Globalen Datensatz vorbereiten | konsistenter H1-Panel |
| 2 | Rohstoffvariable definieren | `resource_dep` |
| 3 | Deskriptive Länderprofile vergleichen | Auffälligkeiten und mögliche Gemeinsamkeiten |
| 4 | H1/H2-Modelle schätzen | H1/H2-Modelle |
| 5 | Explorative H3-Muster interpretieren | Länderbesonderheiten, ggf. mögliche Regionen |
| 6 | Robustheitschecks | Validierung und Stabilität |
| 7 | Ergebnisse interpretieren und dokumentieren | Schlussfolgerung für die Hausarbeit |

---

## 6. Wichtige methodische Note

Das Design legt für H3 keine Region vorab fest. Die Länderprofile dienen der systematischen Exploration; mögliche Regionen oder Ländergruppen werden erst im manuellen Vergleich erkannt und als explorative Muster berichtet. Weil Auswahl und Musterentdeckung auf denselben Daten beruhen, gelten sie nicht als unabhängige statistische Bestätigung.

---

### IMF-Kreditbestand als Robustheitsvariante

Die Phase-B-Modelle verwenden im Hauptmodell weiterhin die getrennten
IMF-Nettoflussmaße `imf_conc_gdp` und `imf_noconc_gdp`, entsprechend der
Originalspezifikation. Als Sensitivitätsprüfung wurden diese beiden Maße
gemeinsam durch `UseIMFCredGDP` ersetzt. `UseIMFCredGDP` basiert auf dem
WDI-Indikator `DT.DOD.DIMF.CD` („Use of IMF credit (DOD, current US$)“),
geteilt durch das nominale BIP und in Prozent ausgedrückt; er misst den
ausstehenden Kreditbestand und nicht jährliche Nettoauszahlungen abzüglich
Rückzahlungen. Die alternative Schätzung ändert das Hauptmodell nicht und
ist nicht als „bessere“ Kontrolle zu interpretieren.

Die erneute Schätzung mit Länder- und Jahres-Fixed-Effects ergab:

| Modell | Fokus-Effekt | Koeffizient | Robuster SE | p-Wert | N |
|--------|--------------|------------:|------------:|-------:|--:|
| H1: `unsc3` auf Bedingungen pro Quartal | `unsc3` | -0.787 | 1.919 | 0.682 | 281 |
| H2: `unsc3 × resource_dep` | Interaktion | -0.104 | 0.101 | 0.302 | 212 |
| H4: `unsc3 × resource_dep` auf Rohstoffanteil | Interaktion | -0.000092 | 0.000410 | 0.823 | 212 |

Alle drei Schätzungen decken 1992–2023 ab. Die Ergebnisse unterscheiden sich
nicht wesentlich von der Hauptspezifikation mit Nettoflüssen; keiner der
Fokus-Effekte ist in dieser Robustheitsvariante statistisch signifikant.
Eine zusätzliche Prüfung, die fehlende Bestandswerte als fehlend statt als
Null behandelt, ergab dieselben Complete-Case-Stichproben und Schätzungen.
Details und die maschinenlesbare Ergebnistabelle stehen in
`results/phase_b/tables/phase_b_hypothesen_robustheit.csv`.

## 7. Kurzform des Projektvorhabens

- Erweiterte Analyse über den H1-Länderpool
- explorativer Vergleich von Länderprofilen
- Identifikation möglicher Länderbesonderheiten und Gemeinsamkeiten
- mögliche regionale Muster vorsichtig und deskriptiv einordnen

---

## 8. Nächste konkrete Aufgaben

1. Globalen Datensatz für 1992–2023 in die Analyse integrieren; 2024–2025 ausschließen
2. `resource_dep` definieren
3. Explorative Länderprofile erstellen und manuell vergleichen
4. Basismodell im globalen Pool schätzen
5. Auffälligkeiten und mögliche Gemeinsamkeiten dokumentieren, ohne H3-Bestätigung zu behaupten
6. Falls später gewünscht, einen unabhängigen bestätigenden Regionaltest planen
7. Robustheitschecks dokumentieren
8. Ergebnisse auf die Hausarbeit vorbereiten
