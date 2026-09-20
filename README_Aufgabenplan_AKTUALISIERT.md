# README: Aktualisierter Aufgabenplan für IMF-Replizierung mit Regionen- und Dependenz-Fokus

**Projekt:** Replizierung der Studie *"Politics and IMF Conditionality"* (Dreher et al. 2015) mit neuen MONA-Daten (2002–2026) + **Erweiterung für alle Länder 2008-2025 mit Regionen-Fokus** und Dependenz-Theorie  
**Ziel:** 15–20-seitige Hausarbeit in 2 Wochen mit **Note 1,3–1,7**  
**Erstellt:** 2026-09-12  
**Aktualisiert:** 2026-09-17 (basierend auf Neu.md)

---

---

## 📚 **Projektübersicht (AKTUALISIERT)**

Dieses Dokument ist ein **Master-Dokument**, das alle wichtigen Sessions und Dateien für die aktualisierte Hausarbeit verlinkt. **Neuerungen gegenüber der vorherigen Version:**

1. **Teil 2 deckt jetzt ALLE LÄNDER 2008-2025 ab** (nicht nur Afrika)
2. **Fokus auf Regionen-Interaktionen** (WDI-Regionsklassifikation)
3. **H2 angepasst:** UNSC-Effekt in **Regionen mit hoher Rohstoffabhängigkeit stärker**
4. **Zusätzliche Tests:** Heteroskedastizität (wie Originalstudie) + Year-fixed-effects

---

## 🗂️ **Verzeichnis der Sessions (Aktualisierte Wissensdatenbank)**

### **📌 Grundlagen der Originalstudie**
- **📄 [`session_Gen_Original.md`](session_Gen_Original.md)**
  *Inhalt:* Detaillierte Analyse der Original-Stata-Do-Dateien (1992–2008), inkl. aller Schritte von den Rohdaten bis zum finalen Datensatz.
  *Wichtig für:* Verständnis der Originalmethodik, Datenaufbereitung, Variablendefinitionen.

---

### **📌 Anleitung für neue MONA-Daten (2002–2026) mit Regionen-Fokus**
- **📄 [`session_MONA_neu_Anleitung.md`](session_MONA_neu_Anleitung.md)**
  *Inhalt:* Schritt-für-Schritt-Anleitung zur Nutzung der aktuellen IMF MONA-Daten, inkl. R-Code für Datenaufbereitung, Klassifizierung und Regressionen **mit Regionen-Fokus**.
  *Wichtig für:* Datenaufbereitung mit neuen MONA-Daten, UNSC-Variable `unsc3`, **Regionscodes**, Regressionsmodelle.

---

### **📌 Replizierungsanleitung (R & Python) mit Regionen-Interaktionen**
- **📄 [`session_RPC_Anleitung.md`](session_RPC_Anleitung.md)**
  *Inhalt:* Schritt-für-Schritt-Anleitung zur Replizierung der Originalstudie, inkl. R/Python-Code, erwartete Ergebnisse und Herausforderungen **mit Fokus auf Regionen-Interaktionen**.
  *Wichtig für:* Ökonometrische Methode, **Heteroskedastizitätstests**, **Year-fixed-effects**, Robustheitschecks.

---

### **📌 Strategie für Regionen-Fokus (2002–2008 + 2009–2026)**
- **📄 [`session_MONA_neu_Afrika.md`](session_MONA_neu_Afrika.md)**
  *Inhalt:* **AKTUALISIERT:** Bewertung der Machbarkeit einer Teilreplizierung (2002–2008, alle Länder) + **Erweiterung (2009–2026, ALLE LÄNDER mit Regionen-Fokus)**. Enthält Aufwandschätzung, erwartete Ergebnisse, Zeitplan und Umsetzungsanleitung.
  *Wichtig für:* **Neue Hauptstrategie!** Hier finden Sie den detaillierten Zeitplan und die Begründung, warum der **Regionen-Fokus** sinnvoll ist.

---

### **📌 Postkoloniale Analyse (Dependenz-Theorie) mit Regionen-Perspektive**
- **📄 [`session_MONA_kolonial.md`](session_MONA_kolonial.md)**
  *Inhalt:* Theoretische und empirische Integration der Dependenz-Theorie und postkolonialer Kritik in die Analyse **mit Fokus auf regionale Unterschiede**. Enthält Hypothesen, empirische Operationalisierung, R-Code für erweiterte Modelle und Interpretationsrahmen.
  *Wichtig für:* Theoretische Einbindung der Ergebnisse, Diskussion der UNSC-Effekte im Kontext neokolonialer Machtstrukturen **und regionaler Variabilität**.

---

### **📌 Aktualisierter 2-Wochen-Fahrplan**
- **📄 [`session_neu_final_2Wochen_AKTUALISIERT.md`](session_neu_final_2Wochen_AKTUALISIERT.md)**
  *Inhalt:* **NEU: Kompletter, zeitoptimierter Fahrplan** mit allen Änderungen aus Neu.md:
  - Teil 2: **Alle Länder 2008-2025** (nicht nur Afrika)
  - **Regionen-Interaktionen** (`unsc3 * Region * Rohstoffabhängigkeit`)
  - **Heteroskedastizitätstests** (wie Originalstudie)
  - **Year-fixed-effects** als Robustheitscheck
  - **Aktualisierte Hypothesen** (H2: Regionen mit hoher Rohstoffabhängigkeit)
  *Wichtig für:* **Ihr aktueller Arbeitsplan!** Enthält alle Schritte, Code-Beispiele und Zeitplan.

---

---

## 🎯 **Schnellzugriff: Wofür Sie welche Session brauchen**

| **Ihre Frage/Aufgabe** | **Relevante Session** | **Abschnitt** |
|------------------------|------------------------|--------------|
| *Wie waren die Originaldaten aufbereitet?* | [`session_Gen_Original.md`](session_Gen_Original.md) | Schritt 1–13 (txt2dta7.do) |
| *Wie bereite ich die neuen MONA-Daten mit Regionen auf?* | [`session_neu_final_2Wochen_AKTUALISIERT.md`](session_neu_final_2Wochen_AKTUALISIERT.md) | Phase 2 (Datenaufbereitung) |
| *Wie führe ich die Regressionen mit Regionen-Interaktionen durch?* | [`session_neu_final_2Wochen_AKTUALISIERT.md`](session_neu_final_2Wochen_AKTUALISIERT.md) | Phase 3 (Regressionsanalyse) |
| *Ist der Regionen-Fokus machbar?* | [`session_MONA_neu_Afrika.md`](session_MONA_neu_Afrika.md) | Abschnitt 🎯 (Warum dieser Ansatz optimal ist) |
| *Wie integriere ich die Dependenz-Theorie mit Regionen-Perspektive?* | [`session_MONA_kolonial.md`](session_MONA_kolonial.md) | Abschnitt 📚 (Theorieteil) |
| *Welcher Zeitplan ist realistisch?* | [`session_neu_final_2Wochen_AKTUALISIERT.md`](session_neu_final_2Wochen_AKTUALISIERT.md) | Abschnitt 📅 (Zeitplan für 2 Wochen) |
| *Wie teste ich auf Heteroskedastizität?* | [`session_RPC_Anleitung.md`](session_RPC_Anleitung.md) | Robustheitschecks |

---

---

## 📂 **Wichtigste Dateipfade im Projekt (AKTUALISIERT)**

| **Kategorie** | **Pfad** | **Beschreibung** |
|---------------|----------|-----------------|
| **📁 MONA-Daten** | `/c/Users/HP/io/imf-replizierung/data/raw/mona/` | Enthält `Combined_ISO.xlsx` (mit ISO3 und iso_numeric) |
| **📁 UNSC-Daten** | `/c/Users/HP/io/imf-replizierung/data/raw/unsc/` | `unsc_membership_2002_2025.csv` (Panel mit unsc3) |
| **📁 WDI-Daten** | `/c/Users/HP/io/imf-replizierung/data/raw/wdi/` | **NEU:** `wdi_2002_2025_dep_regions.csv` (inkl. Rohstoffabhängigkeit + Regionscodes) |
| **📁 Aufbereitete Daten** | `/c/Users/HP/io/imf-replizierung/data/processed/` | `final_data_2002_2025.csv`, `data_part1_2002_2008.csv`, **`data_part2_2008_2025.csv` (ALLE LÄNDER)** |
| **📄 Session-Dokumente** | `/c/Users/HP/io/imf-replizierung/` | Alle `session_*.md`-Dateien |
| **📄 Code** | `/c/Users/HP/io/imf-replizierung/code/` | R-Skripte für Datenaufbereitung und Analyse |

---

---

## 🚀 **Aktualisierter Arbeitsablauf**

### **1. Lesen Sie zuerst diese Sessions (für das Verständnis):**
1. **[`session_neu_final_2Wochen_AKTUALISIERT.md`](session_neu_final_2Wochen_AKTUALISIERT.md)** → **Ihr neuer Zeitplan mit allen Änderungen!**
2. **[`session_MONA_neu_Afrika.md`](session_MONA_neu_Afrika.md)** → **Aktualisierte Strategie mit Regionen-Fokus!**

### **2. Beginnen Sie mit der Datenbeschaffung:**
- **MONA-Daten:** `Combined_ISO.xlsx` (bereits vorhanden)
- **UNSC-Daten:** [UN Security Council Membership](https://www.un.org/securitycouncil/en/content/member-states) (bereits vorhanden als `unsc_membership_2002_2025.csv`)
- **WDI-Daten:** [World Bank WDI](https://data.worldbank.org/indicator) 
  - **NEU: Rohstoffabhängigkeit:** `TX.VAL.FUEL.ZS.UN` + `TX.VAL.MMTL.ZS.UN`
  - **NEU: Regionscodes:** Aus WDI Metadata herunterladen (z.B. `Region` Variable)
  - **Kontrollvariablen:** `NE.TRD.GNFS.ZS`, `DT.DOD.DSTC.ZS`, `FI.RES.TOTL.DT.ZS`

### **3. Nutzen Sie die R-Code-Snippets:**
- Alle wichtigen R-Befehle finden Sie in:
  - **[`session_neu_final_2Wochen_AKTUALISIERT.md`](session_neu_final_2Wochen_AKTUALISIERT.md)** (Datenaufbereitung + Regressionen mit Regionen)
  - **[`session_RPC_Anleitung.md`](session_RPC_Anleitung.md)** (Heteroskedastizitätstests, Year-fixed-effects)

### **4. Bei Problemen:**
- **R-Fehler?** → Schicken Sie **Fehlermeldung + Code** → Hilfe innerhalb von 1 Stunde!
- **Daten fehlen?** → WDI-Daten mit Regionscodes und Rohstoffindikatoren herunterladen
- **Regionscodes fehlen?** → WDI Metadata oder manuelle Zuordnung über ISO-Codes
- **Theorie unklar?** → Dependenz-Theorie mit Regionen-Perspektive in [`session_MONA_kolonial.md`](session_MONA_kolonial.md)

---

---

## 💡 **Tipps für effizientes Arbeiten (AKTUALISIERT)**

1. **📌 Erstellen Sie eine lokale Kopie aller aktualisierten Sessions** in `/c/Users/HP/io/imf-replizierung/`
2. **📌 Nutzen Sie die Suchfunktion** (Strg+F) in den Sessions, um schnell Antworten zu finden
3. **📌 Speichern Sie Ihre Fortschritte täglich** (z. B. in einer Datei `fortschritt_aktualisiert.md`)
4. **📌 Halten Sie sich an den aktualisierten Zeitplan** aus [`session_neu_final_2Wochen_AKTUALISIERT.md`](session_neu_final_2Wochen_AKTUALISIERT.md)

---

---

## 📌 **Zusammenfassung: Aktualisierte Hypothesen und Modelle**

### **Aktualisierte Hypothesen**
| **Hypothese** | **Beschreibung** | **Testmethode** | **Erwartetes Ergebnis** |
|--------------|------------------|-----------------|----------------------|
| **H2 (angepasst)** | UNSC-Effekt ist **stärker in Regionen mit hoher Rohstoffabhängigkeit** | Interaktionsmodell `unsc3 * Region * Rohstoffabhängigkeit` | Signifikanter negativer Koeffizient für rohstoffreiche Regionen |
| **H4** | Rohstoffabhängigkeit **verstärkt UNSC-Effekt** | Interaktionsmodell `unsc3 * Rohstoffabhängigkeit` | Signifikanter negativer Interaktionsterm |

### **Neue Modelle (Teil 2: 2008-2025, alle Länder)**
| **Modell** | **Spezifikation** | **Zweck** |
|------------|------------------|----------|
| **M2_fe** | `avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt + Rohstoffabhängigkeit` | Basismodell |
| **M2_region** | `avgcondtype_all ~ unsc3 * Region + XDebtGNI + DebtServGNI + ResXDebt` | **Test H2: Regionaler UNSC-Effekt** |
| **M2_interaction** | `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt` | **Test H4: Rohstoff-Interaktion** |
| **M2_full_interaction** | `avgcondtype_all ~ unsc3 * Region * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt` | **Kombinierter Test H2 + H4** |
| **M2_year_fe** | `avgcondtype_all ~ unsc3 + ... \| MONA Code + Year` | **Robustheitscheck: Year-fixed-effects** |

### **Neue Robustheitschecks**
1. **Heteroskedastizitätstest:** Breusch-Pagan-Test (`bptest()` in R) für alle Modelle
2. **Year-fixed-effects:** Kontrolle für zeitliche Effekte (`fixed_effects = ~Year`)
3. **Robuste Standardfehler:** `vcov = "hetero"` in `feols()` für Heteroskedastizitäts-korrigierte Standardfehler

---

---

## 📋 **Checkliste: Was Sie als Nächstes tun müssen**

### **🔴 Priorität 1: Datenaufbereitung (Tag 1-3)**
- [ ] WDI-Daten mit **Regionscodes** herunterladen
- [ ] Rohstoffindikatoren (`TX.VAL.FUEL.ZS.UN`, `TX.VAL.MMTL.ZS.UN`) herunterladen
- [ ] Datenaufbereitungsskript aktualisieren (Regionscodes integrieren)
- [ ] Finalen Datensatz mit Regionen erstellen (`final_data_2002_2025.csv`)
- [ ] Teildatensätze erstellen:
  - [ ] `data_part1_2002_2008.csv` (Replizierung)
  - [ ] `data_part2_2008_2025.csv` (Alle Länder mit Regionen)

### **🟡 Priorität 2: Analyse (Tag 4-5)**
- [ ] **Phase 3 R-Code aktualisieren:**
  - [ ] Modell `M2_region` implementieren
  - [ ] Modell `M2_full_interaction` implementieren
  - [ ] Modell `M2_year_fe` implementieren
- [ ] **Heteroskedastizitätstests** durchführen (`bptest()`)
- [ ] **Robuste Standardfehler** verwenden (`vcov = "hetero"`)
- [ ] Ergebnisse berechnen und speichern:
  - [ ] `results/regression_results_regions_dep.csv`
  - [ ] `results/regression_table_regions_dep.txt`

### **🟢 Priorität 3: Validierung (Tag 6)**
- [ ] Validierungsbericht erstellen (`results/validation_regions_dep_report.md`)
- [ ] Hypothesentests durchführen (H2, H4)
- [ ] Dependenz-Interpretation anpassen

### **🔵 Priorität 4: Schreiben (Tag 7-12)**
- [ ] Einleitung + Literatur (4h)
- [ ] Daten + Methodik (4h)
- [ ] Ergebnisse (5h)
- [ ] Diskussion (5h)
- [ ] Fazit + Anhang (8h)

---

---

## 🎯 **Zusammenfassung: Was sich geändert hat**

| **Aspekt** | **Alte Version** | **Neue Version (basierend auf Neu.md)** |
|------------|------------------|------------------------------------------|
| **Teil 2 Zeitraum** | 2008-2025, nur Afrika | **2008-2025, ALLE LÄNDER** |
| **Teil 2 Fokus** | Afrika | **Regionen-Fokus** |
| **H2 Hypothese** | UNSC-Effekt in Afrika stärker | **UNSC-Effekt in Regionen mit hoher Rohstoffabhängigkeit stärker** |
| **Interaktion** | `unsc3 * Rohstoffabhängigkeit` | **`unsc3 * Region * Rohstoffabhängigkeit`** |
| **Robustheitschecks** | Standard | **+ Heteroskedastizitätstests + Year-fixed-effects** |
| **Ergebnisdateien** | `regression_results_dep.csv` | **`regression_results_regions_dep.csv`** |
| **Session-Datei** | `session_neu_final_2Wochen.md` | **`session_neu_final_2Wochen_AKTUALISIERT.md`** |
| **Aufgabenplan** | `README_Aufgabenplan.md` | **`README_Aufgabenplan_AKTUALISIERT.md`** |

---

---

**Letzte Aktualisierung:** 2026-09-17  
**Status:** ✅ Pläne aktualisiert | ⏳ Implementierung in Arbeit  
**Nächster Schritt:** Datenbeschaffung (WDI mit Regionscodes) und Datenaufbereitung

---

**Viel Erfolg! Mit diesem aktualisierten Master-Dokument haben Sie alle wichtigen Informationen an einem Ort.**
