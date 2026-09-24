# Aktualisiertes Untersuchungsdesign: globaler Länderpool + regionale Differenzierung

## 1. Ziel des Designs

Das ursprüngliche SSA-Fokus-Design dient als erste explorative Spezifikation. Für die finale empirische Analyse wird der Länderpool erweitert und nach Regionen bzw. regionalen Gruppen differenziert, um zu prüfen, ob der Effekt von UNSC-Mitgliedschaft und Rohstoffabhängigkeit wirklich nur in SSA auftritt oder ob er auch außerhalb Afrikas sichtbar ist.

Das zentrale Ziel ist nicht, vorab eine Region zu privilegieren, sondern empirisch zu testen, wo die stärksten Muster auftreten und ob regionale Heterogenität die Ergebnisse treibt.

---

## 2. Forschungsfrage und Hypothesen

### Forschungsfrage
> Inwiefern beeinflusst UNSC-Mitgliedschaft die IMF-Konditionalität, und ist dieser Effekt in rohstoffabhängigen Kontexten stärker ausgeprägt? Ist die Beziehung regional heterogen?

### Hypothesen

| Hypothese | Formulierung | Test | Theoretische Grundlage |
|-----------|--------------|------|------------------------|
| H1 | UNSC-Mitgliedschaft ist mit geringerem Maß an IMF-Konditionalität verbunden. | Replikation mit globalem bzw. erweitertem Panel | Politische Ökonomie / Originalstudie |
| H2 | Rohstoffabhängigkeit verstärkt den Effekt von UNSC-Mitgliedschaft auf IMF-Konditionalität. | Interaktionsmodell `unsc3 * resource_dep` | Dependenz-/Neokolonialismus-Argument |
| H3 | Die Beziehung ist nicht global identisch, sondern variiert nach Region/Typ von Ländern. | Regionale Interaktionen bzw. Subgroup-Modelle | Regionaler Kontext und Heterogenität |
| H4 | Der Effekt ist besonders stark in Rohstoff- bzw. geopolitisch exponierten Regionen. | Regionale Gruppen, Ländervergleiche, Ausreißeranalyse | Rohstoffabhängigkeit, Peripherie, geopolitische Einflussnahme |

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

### Phase 3: Regionale Gruppierung definieren
- Regionen nicht voraussetzen, sondern empirisch bestimmen
- Grundstruktur: SSA vs. Other oder mehrere Gruppen, falls sinnvoll
- zusätzliche regionale Unterteilungen nur dann, wenn die Datenlage dies zulässt

### Phase 4: Deskriptive Prüfung regionaler Muster
- Durchschnittswerte nach Region berechnen
- Rohstoffabhängigkeit, UNSC-Mitgliedschaft und Konditionalität vergleichen
- Länder mit herausragenden Rohstoffwerten oder hohen Konditionalitätswerten identifizieren

### Phase 5: Interaktionsmodelle schätzen
- globales Modell mit `unsc3 * resource_dep`
- erweitert um regionale Interaktion `unsc3 * region` bzw. `resource_dep * region`
- Modellvergleich zwischen Gesamtpool und Teilmengen

### Phase 6: Subgroup-Analysen
- getrennte Modelle für auffällige Regionen schätzen
- besonders stark herausstechende Regionen gesondert analysieren
- gezielte Ländervergleiche innerhalb auffälliger Regionen durchführen

### Phase 7: Robustheitschecks
- unterschiedliche Zeitfenster prüfen
- fehlende Werte/Extreme Werte prüfen
- alternative Spezifikationen der Rohstoffabhängigkeit testen
- Standardfehler robustifizieren
- ggf. year fixed effects ergänzen

### Phase 8: Interpretation und Schlussfolgerung
- Effekt nicht nur als statistisch signifikant, sondern als kontextabhängig interpretieren
- regionale Heterogenität als zentrale Erkenntnis behandeln
- falls SSA nicht auffällt, andere Regionen als relevanter Kontext identifizieren

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

### Schritt 3: Regionale Gruppierung erstellen
- Liste der Länder pro Region definieren
- `region`-Variable erzeugen
- nicht vorab auf SSA fixieren, sondern empirische Auffälligkeit prüfen

### Schritt 4: Deskriptive Analyse ausführen
- regionale Mittelwerte berechnen
- Ländervergleiche durchführen
- Ausreißer identifizieren

### Schritt 5: Basismodell schätzen
- H1-Modell im erweiterten Pool schätzen
- Parameter prüfen und mit Originaldesign vergleichen

### Schritt 6: Interaktionsmodelle testen
- `avgcondtype_all ~ unsc3 * resource_dep + Kontrollen`
- `avgcondtype_all ~ unsc3 * resource_dep * region + Kontrollen`
- ggf. alternative Spezifikation mit regionalen Interaktionen

### Schritt 7: Subgroup-Analyse durchführen
- auffällige Regionen einzeln schätzen
- Vergleich zwischen SSA und anderen Regionen
- ggf. Länder mit extrem hohen Rohstoffwerten zusätzlich analysieren

### Schritt 8: Robustheitschecks und Validierung
- Heteroskedastizität prüfen
- Extreme Werte / Ausreißer behandeln
- Zeitauswahl prüfen
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
| 2 | Rohstoff- und Regionen-Variablen definieren | `resource_dep`, `region` |
| 3 | Deskriptive Landes-/Regionalanalyse | Muster und Ausreißer |
| 4 | Basismodell und Interaktionsmodelle schätzen | H1/H2/H3-Modelle |
| 5 | Regionale Subgroup-Modelle | Regionale Differenzierung |
| 6 | Robustheitschecks | Validierung und Stabilität |
| 7 | Ergebnisse interpretieren und dokumentieren | Schlussfolgerung für die Hausarbeit |

---

## 6. Wichtige methodische Note

Das neue Design ist bewusst nicht auf SSA festgelegt. SSA bleibt ein möglicher Vergleichsraum, aber nicht der automatische Fokus. Das entscheidende Kriterium ist empirische Auffälligkeit: Wenn andere Regionen im erweiterten Pool klarer hervortreten, werden diese als zentrale Vergleichsgruppen behandelt. Das ist methodisch sauberer als ein vorab bestimmtes regionales Design zu privilegieren.

---

## 7. Kurzform des Projektvorhabens

- Erweiterte Analyse über den H1-Länderpool
- Prüfung auf regionale Heterogenität
- Identifikation auffälliger Regionen
- gezielter Ländervergleich in besonders starken Regionen
- Ergebnis: empirisch fundierte Aussage zur Rolle von Rohstoffabhängigkeit und UNSC-Mitgliedschaft, nicht nur eine rein regionale SSA-These

---

## 8. Nächste konkrete Aufgaben

1. Globalen Datensatz in die Analyse integrieren
2. `resource_dep` und `region` definieren
3. Deskriptive regionale Vergleichsstatistiken ausführen
4. Basismodell im globalen Pool schätzen
5. Interaktionsmodelle mit Regioneneffekten laufen lassen
6. Entscheiden, welche Region / welche Länder im Finalmodell besonders relevant sind
7. Robustheitschecks dokumentieren
8. Ergebnisse auf die Hausarbeit vorbereiten

