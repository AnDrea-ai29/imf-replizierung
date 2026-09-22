# Klassifizierung der MONA-Bedingungen

## Projekt
Tag 3: Korrigierte Panel-Erstellung + Inhaltsanalyse der Bedingungen für 20 SSA-Länder (2002-2025)

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

---

## Methodik: Hierarchische Regelbasierte Klassifizierung

### Prinzip
Die Klassifizierung erfolgt **hierarchisch in 4 Stufen** nach dem Motto:
**Strukturierte Daten → Kategorien → Text-Matching → Kombination**

---

### Stufe 1: Key Code (Primär - Strukturierte Daten)
**Direkte Zuordnung über standardisierte IMF-Codes:**

| Kategorie | Key Codes | Logik |
|-----------|-----------|-------|
| **Rohstoff-spezifisch** | SPC, PC, SAC, NRM | `ifelse(Key Code %in% c("SPC", "PC", "SAC", "NRM"), 1, 0)` |
| **Stabilisierend** | PA, QPC, MAC | `ifelse(Key Code %in% c("PA", "QPC", "MAC"), 1, 0)` |

**Variablen:** `rohstoff_keycode`, `stabil_keycode`

---

### Stufe 2: Economic Descriptor (Sekundär - Kategorien)
**Regex-Suche in der Spalte `Economic Descriptor`:**

| Kategorie | Suchmuster | Logik |
|-----------|------------|-------|
| **Rohstoff-spezifisch** | extractive, mineral, energy, fuel, oil, gas, commodity | `grepl("...", Economic Descriptor, ignore.case = TRUE)` |
| **Stabilisierend** | fiscal, monetary, budget, debt, inflation | `grepl("...", Economic Descriptor, ignore.case = TRUE)` |

**Variablen:** `rohstoff_desc`, `stabil_desc`

---

### Stufe 3: Description (Tertiär - Text-Matching)
**Keyword-basierte Suche in der Spalte `Description`:**

#### Rohstoff-Keywords (17 Begriffe):
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
stabil_text = ifelse(str_detect(desc_lower, paste(stabil_keywords, collapse = "|")), 1, 0)
```

**Variablen:** `rohstoff_text`, `stabil_text`

---

### Stufe 4: Kombination (Final)
**Hierarchische Logik mit `pmax()`:**

| Variable | Berechnung | Bedeutung |
|----------|-------------|-----------|
| `rohstoff_cond` | `pmax(rohstoff_keycode, rohstoff_desc, rohstoff_text)` | **1**, wenn **mindestens eine Stufe** positiv ist |
| `stabil_cond` | `pmax(stabil_keycode, stabil_desc, stabil_text)` | **1**, wenn **mindestens eine Stufe** positiv ist |
| `sonstige_cond` | `ifelse(rohstoff_cond == 1 | stabil_cond == 1, 0, 1)` | **1**, wenn **weder Rohstoff noch Stabilisierung** |

**Logik:** Eine Bedingung wird als **Rohstoff-spezifisch** klassifiziert, wenn **irgendeine der 3 Stufen** (Key Code, Economic Descriptor, Description) ein positives Signal liefert.

---

## Aggregation: Land-Jahr-Ebene

Die individuellen Klassifizierungen werden pro **Land-Jahr-Paar** aggregiert:

| Variable | Berechnung | Einheit | Bedeutung |
|----------|-------------|--------|-----------|
| `total_cond` | `n()` | Anzahl | Gesamtzahl der Bedingungen |
| `rohstoff_cond` | `sum(rohstoff_cond)` | Anzahl | Anzahl rohstoff-spezifischer Bedingungen |
| `stabil_cond` | `sum(stabil_cond)` | Anzahl | Anzahl stabilisierender Bedingungen |
| `sonstige_cond` | `sum(sonstige_cond)` | Anzahl | Anzahl sonstiger Bedingungen |
| `rohstoff_cond_share` | `mean(rohstoff_cond)` | 0-1 | **Anteil** rohstoff-spezifisch |
| `stabil_cond_share` | `mean(stabil_cond)` | 0-1 | **Anteil** stabilisierend |

**Gruppierung:** `group_by(ISO3, Year)`

---

## Vorteile der Methode

✅ **Robust:** Strukturierte Daten (Key Code, Economic Descriptor) haben Priorität
✅ **Hierarchisch:** Klare Regelabfolge reduziert False Positives
✅ **Flexibel:** Text-Matching nur als Fallback für unklare Fälle
✅ **Nachvollziehbar:** Transparente Logik für jede Bedingung
✅ **Anpassbar:** Keywords können einfach erweitert/angepasst werden

---

## Ergebnis
- **Ausgabedatei:** `data/processed/data_with_cond_types.csv`
- **Enthaltene Variablen:** `rohstoff_cond`, `stabil_cond`, `sonstige_cond`, `rohstoff_cond_share`, `stabil_cond_share`
- **Verwendung:** Analyse des Zusammenhangs zwischen Bedingungstypen und UNSC-Mitgliedschaft / Rohstoffabhängigkeit

---

## Code-Referenz
- **Datei:** `code/Tag-3_korrigiert_Panel_und_Klassifizierung.R`
- **Bereich:** Teil 2, Abschnitt 2.2 (Bedingungs-Klassifizierung)
- **Zeilen:** ~140-170

---

## Hinweise
- Die Klassifizierung basiert auf **IMF-MONA-Daten** (Monitoring of Arrangements)
- **Key Code** ist der zuverlässigste Indikator (IMF-interne Standardisierung)
- **Economic Descriptor** und **Description** dienen als ergänzende Informationen
- Bei Überschneidungen hat **Key Code** Vorrang vor Economic Descriptor, dieser vor Description