# Klassifizierung der MONA-Bedingungen

## Projekt
Tag 3: Korrigierte Panel-Erstellung + Inhaltsanalyse der Bedingungen für 20 SSA-Länder (2002-2025)
Update 2026-09-23: Angepasste hierarchische Klassifizierung implementiert (siehe Änderungshistorie unten)

---

## Ziel
Klassifizierung von IMF-Bedingungen (MONA-Daten) in **drei Kategorien**:
- Rohstoff-spezifische Bedingungen
- Stabilisierende Bedingungen  
- Sonstige Bedingungen

---

## Datenbasis
- **Quelle:** `data/raw/mona/Combined_ISO.xlsx` (MONA-Rohdaten)
- **Filter:** Nur SSA-Länder (20 Länder: AGO, CAF, CMR, COM, CPV, GAB, GHA, GIN, KEN, LSO, MDG, MOZ, MRT, MWI, RWA, SLE, SLV, TZA, UGA, ZMB)
- **Zeitraum:** 2002-2025
- **Bedingungen gesamt:** 15.404

---

## Methodik: Hierarchische Regelbasierte Klassifizierung (angepasste Version)

### Prinzip
Die Klassifizierung erfolgt **hierarchisch in 3 Stufen** nach dem Motto:
**Strukturierte Kategorien → Text-Matching → Kombination**

**Wichtige Änderung gegenüber der ursprünglichen Dokumentation:** Der **Key Code** (PA, SAC, SB, SPC) wird **nicht** als Klassifizierungsstufe verwendet. Der Key Code ist ein **Instrumententyp** (Prior Action, Structural Benchmark, Structural Performance Criterion), keine Inhaltskategorie: 85% der SPC/SAC-Bedingungen haben laut Beschreibungstext keinen Rohstoffbezug. Die Zuordnung "SPC/SAC → rohstoff" der ursprünglichen Dokumentation wäre inhaltsleer gewesen; die dort genannten Codes PC, NRM, QPC, MAC kommen in den SSA-Daten gar nicht vor.

---

### Stufe 1: Economic Descriptor (Primär - nummerierte IMF-Kategorien)
Direkte Zuordnung über die standardisierten, nummerierten MONA-Kategorien (`Economic Descriptor` / `Economic Code`):

| Kategorie | Descriptoren | Logik |
|-----------|--------------|-------|
| **Rohstoff-spezifisch** | 11.2 (natural resource and agricultural policies: Mining-Codes, Forstwirtschaft, Rohstoffpolitik), 5.1 (public enterprise pricing and subsidies: Petroleum-Preise, Brennstoffsubventionen) | `startsWith(Descriptor, "11.2") \| startsWith(Descriptor, "5.1.")` |
| **Stabilisierend** | 1.x (Fiskal: Haushalt, Steuern, Schulden, Ausgaben, Buchführung), 2.x (Zentralbank/monetär) | `startsWith(Descriptor, "1.") \| startsWith(Descriptor, "2.")` |

**Begründung der Kategorienauswahl (datenbasiert, Stichproben geprüft):**
- `11.2` (157 Bedingungen): Mining-Codes, Forstsektor, Timber-Marketing — eindeutig rohstoffbezogen
- `5.1` (319 Bedingungen):fast ausschließlich Petroleum-Produktpreise und Brennstoffsubventionen (z.B. SONARA-Raffinerie, Kamerun)
- Kategorie `5.` allgemein (Public Enterprise Law, Post/Telekom, CAMPOST/CAMTEL) bewusst **ausgeschlossen**: gemischter, überwiegend nicht-rohstoffbezogener Inhalt
- Die Stabilisierungs-Kategorien 1.x/2.x umfassen die dokumentierten Inhalte (fiscal, budget, debt, monetary)

**Variablen:** `rohstoff_desc`, `stabil_desc`
**Treffer (SSA, 2002-2025):** rohstoff = 476, stabil = 10.305

---

### Stufe 2: Description (Sekundär - Text-Matching)
Keyword-basierte Suche in der Spalte `Description`:

#### Rohstoff-Keywords (16 Begriffe):
```
fuel, mineral, oil, gas, extractive, petroleum, crude, hydrocarbon, mining, 
privatization, subsidy, energy, resource, commodity, export, tax.*resource
```

#### Stabilisierungs-Keywords (11 Begriffe):
```
fiscal, inflation, budget, debt, deficit, surplus, reserve, monetary, 
interest, exchange, balance
```

**Implementierung:**
```r
rohstoff_keywords <- c("fuel", "mineral", "oil", "gas", "extractive", "petroleum", 
                       "crude", "hydrocarbon", "mining", "privatization", "subsidy",
                       "energy", "resource", "commodity", "export", "tax.*resource")

stabil_keywords <- c("fiscal", "inflation", "budget", "debt", "deficit", "surplus",
                     "reserve", "monetary", "interest", "exchange", "balance")

desc_lower = tolower(Description)
rohstoff_text = ifelse(str_detect(desc_lower, paste(rohstoff_keywords, collapse = "|")), 1, 0)
stabil_text  = ifelse(str_detect(desc_lower, paste(stabil_keywords, collapse = "|")), 1, 0)
```

**Variablen:** `rohstoff_text`, `stabil_text`
**Treffer:** rohstoff = 1.314, stabil = 4.600

---

### Stufe 3: Kombination (Final)
**Hierarchische Logik mit `pmax()`:**

| Variable | Berechnung | Bedeutung |
|----------|-------------|-----------|
| `rohstoff_cond` | `pmax(rohstoff_desc, rohstoff_text)` | **1**, wenn **mindestens eine Stufe** positiv ist |
| `stabil_cond` | `pmax(stabil_desc, stabil_text)` | **1**, wenn **mindestens eine Stufe** positiv ist |
| `sonstige_cond` | `ifelse(rohstoff_cond == 1 \| stabil_cond == 1, 0, 1)` | **1**, wenn **weder Rohstoff noch Stabilisierung** |

**Logik:** Eine Bedingung wird als rohstoff-spezifisch klassifiziert, wenn die Kategorie (Stufe 1) **oder** der Beschreibungstext (Stufe 2) ein positives Signal liefert. Die Kategorien sind **nicht exklusiv**: eine Bedingung kann zugleich rohstoff-spezifisch und stabilisierend sein (851 Fälle, z.B. Petroleum-Preisanpassung mit Budgettransfers).

**Ergebnis (SSA, 2002-2025):**
| Kategorie | Anzahl | Anteil |
|-----------|--------|--------|
| Rohstoff-spezifisch | 1.521 | 9,9% |
| Stabilisierend | 11.163 | 72,5% |
| Beides (Überlappung) | 851 | 5,5% |
| Sonstige | 3.571 | 23,2% |
| **Gesamt** | **15.404** | |

**Zusätzlich durch Stufe 1 erkannte Rohstoff-Bedingungen** (ohne Description-Keyword-Treffer): **207** (z.B. Forstsektor-Bedingungen, Timber-Marketing-Boards)

---

## Aggregation: Land-Jahr-Ebene
Die individuellen Klassifizierungen werden pro **Land-Jahr-Paar** (ISO3, Approval Year) aggregiert:

| Variable | Berechnung | Einheit | Bedeutung |
|----------|-------------|--------|-----------|
| `total_cond` | `n()` | Anzahl | Gesamtzahl der Bedingungen |
| `rohstoff_cond` | `sum(rohstoff_cond)` | Anzahl | Anzahl rohstoff-spezifischer Bedingungen |
| `stabil_cond` | `sum(stabil_cond)` | Anzahl | Anzahl stabilisierender Bedingungen |
| `sonstige_cond` | `sum(sonstige_cond)` | Anzahl | Anzahl sonstiger Bedingungen |
| `rohstoff_cond_share` | `rohstoff_cond / total_cond` | 0-1 | **Anteil** rohstoff-spezifisch |
| `stabil_cond_share` | `stabil_cond / total_cond` | 0-1 | **Anteil** stabilisierend |

**Korrigierter Fehler:** Die vorherige Version berechnete die Anteile innerhalb von `summarise()` mit `mean(rohstoff_cond)` — wegen der dplyr-Sequenzsemantik bezog sich `mean()` dort auf die **im selben Aufruf erzeugte Summe**, sodass die "Anteile" in Wahrheit **Anzahlwerte** enthielten (z.B. CAF 2006: `rohstoff_cond_share` = 53 statt 0,27). Die Anteile werden jetzt **nach** der Aggregation als `cond / total_cond` berechnet. Der Fehler betraf die geplante abhängige Variable von H4 und ist damit behoben.

**Gruppierung:** `group_by(ISO3, Year)`, anschließend Merge auf das Land-Jahr-Panel (480 Zeilen); Land-Jahre ohne MONA-Bedingungen erhalten 0.

---

## Vorteile der Methode
- **Robust:** Strukturierte IMF-Kategorien haben Priorität, Text-Matching als Ergänzung
- **Hierarchisch:** Klare Regelabfolge reduziert False Positives
- **Flexibel:** Text-Matching nur als Fallback für unklare Fälle
- **Nachvollziehbar:** Transparente Logik für jede Bedingung
- **Anpassbar:** Kategorien und Keywords können einfach erweitert/angepasst werden

---

## Ergebnis
- **Ausgabedatei (Panel):** `data/processed/data_with_cond_types.csv` (480 Land-Jahr-Zeilen, erneuert am 2026-09-23)
- **Ausgabedatei (Bedingungsebene):** `data/processed/conditions_classified_hierarchisch.csv` (15.404 Zeilen mit allen Stufenvariablen, für Beispieltabellen und Prüfzwecke)
- **Enthaltene Variablen:** `rohstoff_cond`, `stabil_cond`, `sonstige_cond`, `rohstoff_cond_share`, `stabil_cond_share`, `total_cond`
- **Verwendung:** Analyse des Zusammenhangs zwischen Bedingungstypen und UNSC-Mitgliedschaft / Rohstoffabhängigkeit (H4)

**Validierung (2026-09-23):**
- Panel-Spalten (UNSC, WDI, `avgcondtype_all`) identisch zur Vorgängerversion — H1/`model_repl.rds` unverändert
- `rohstoff_cond_share` im Wertebereich [0, 0.35], `stabil_cond_share` in [0, 1]
- Anteilsberechnung (`share = cond/total`) für alle 480 Zeilen erfüllt
- Korrelation der rohstoff-spezifischen Anteile mit der reinen Keyword-Version: 0.94

---

## Code-Referenz
- **Datei:** `code/data_prep/klassifizierung_hierarchisch.R`
- **Ersetzt:** reine Keyword-Klassifizierung aus `Tag-3_korrigiert_Panel_und_Klassifizierung.R` (aus Git-Historie, c5daecc)
- **Vorgängerversion von `data_with_cond_types.csv`:** via `git show c5daecc:data/processed/data_with_cond_types.csv` wiederherstellbar

---

## Änderungshistorie
- **2026-09-23:** Angepasste hierarchische Klassifizierung implementiert und `data_with_cond_types.csv` neu generiert. Key-Code-Stufe entfernt (Instrumententyp, keine Inhaltskategorie), Stufe-1-Kategorien datenbasiert auf tatsächliche MONA-Deskriptoren angepasst (11.2, 5.1 / 1.x, 2.x), Anteilsberechnungs-Bug (`mean`-auf-Summe in `summarise()`) behoben.
- **Ursprüngliche Planung:** Hierarchie mit Key-Code-Primärstufe und Regex-Suche im Economic Descriptor; wörtlich nicht umsetzbar, da die dort genannten Key Codes in den Daten nicht vorkommen bzw. inhaltsleer sind und die Regex-Keywords auf die nummerierten Kategorien nicht zutreffen.
