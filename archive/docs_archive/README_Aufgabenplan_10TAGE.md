# README: 10-Tage-Fahrplan für IMF-Replizierung (SSA + MENA Fokus)

**Projekt:** Replizierung der Studie *"Politics and IMF Conditionality"* (Dreher et al. 2015) + **Erweiterung für SSA + MENA (2008–2025)** mit Inhaltsanalyse der Bedingungen  
**Ziel:** **20-seitige Seminararbeit in 10 Tagen** mit Note 1,3–1,7  
**Erstellt:** 2026-09-12  
**Aktualisiert:** 2026-09-17 (10-Tage-Optimierung für SSA + MENA)

---

---

## 🎯 **Projektübersicht (10-TAGE-VERSION)**

Dieses Dokument ist Ihr **Master-Plan für 10 Tage**. **Fokus auf SSA + MENA** (ca. 60 Länder) statt aller Länder, um die Arbeit **in 20 Seiten machbar** zu machen.

### **Neuerungen gegenüber vorherigen Versionen:**
1. **Fokus auf 2 Regionen:** **Sub-Saharan Africa (SSA) + Middle East & North Africa (MENA)**
2. **Inhaltsanalyse:** Klassifizierung der IMF-Bedingungen nach **Rohstoff-Relevanz**
3. **10-Tage-Zeitplan:** Ultra-komprimiert, mit klaren täglichen Zielen
4. **Empirische Kernfragen:**
   - H1: Replizierung (UNSC-Effekt)
   - H2: Rohstoffabhängigkeit ↑ IMF-Konditionalität
   - H3: UNSC-Effekt stärker in rohstoffabhängigen Ländern
   - **H4: UNSC-Länder haben weniger rohstoff-spezifische Bedingungen** (Inhaltsanalyse!)

---

---

## 🗂️ **Verzeichnis der Sessions (10-Tage-Optimiert)**

### **📌 Hauptdokument (Ihr Arbeitsplan)**
- **📄 [`session_10Tage_SSA_MENA.md`](session_10Tage_SSA_MENA.md)**
  *Inhalt:* **Detaillierter 10-Tage-Fahrplan** mit allen Schritten, R-Code-Snippets und Zeitangaben.
  *Wichtig für:* **Ihr täglicher Leitfaden!** Enthält alles für Datenaufbereitung, Analyse und Schreiben.

### **📌 Theoretische Grundlagen**
- **📄 [`session_Gen_Original.md`](session_Gen_Original.md)**
  *Inhalt:* Originalstudie Dreher et al. (2015) – nur für **Validierungszwecke** (H1).
  *Wichtig für:* Vergleich Ihrer Replizierungsergebnisse.

### **📌 Dependenz-Theorie**
- **📄 [`session_MONA_kolonial.md`](session_MONA_kolonial.md)**
  *Inhalt:* Theoretische Einbettung Ihrer Ergebnisse (H2–H4).
  *Wichtig für:* Diskussion (Kapitel 6).

---

---

## 🚀 **Arbeitsablauf (10 Tage)**

### **1. Lesen Sie zuerst diese Datei:**
📌 **[`session_10Tage_SSA_MENA.md`](session_10Tage_SSA_MENA.md)** → **Ihr täglicher Plan!**

### **2. Datenbeschaffung (Tag 1):**
- **MONA-Daten:** `Combined_ISO.xlsx` für **SSA + MENA** filtern
- **UNSC-Daten:** `unsc_membership_2002_2025.csv` für SSA + MENA
- **WDI-Daten:** `wdi_2002_2025_dep.csv` für SSA + MENA + **Regionscodes**

### **3. Nutzen Sie die R-Code-Snippets:**
- Alle Codes finden Sie in **[`session_10Tage_SSA_MENA.md`](session_10Tage_SSA_MENA.md)**
- **Kopieren & anpassen** – keine Neuentwicklung nötig!

### **4. Bei Problemen:**
- **R-Fehler?** → Fehlermeldung + Code schicken → Hilfe innerhalb von **1 Stunde**!
- **Daten fehlen?** → In `session_10Tage_SSA_MENA.md` nach Lösungen suchen

---

---

## 📂 **Wichtigste Dateipfade (10-Tage-Version)**

| **Kategorie** | **Pfad** | **Beschreibung** | **Priorität** |
|---------------|----------|-----------------|--------------|
| **📁 MONA-Daten** | `data/raw/mona/Combined_ISO.xlsx` | Rohdaten für SSA + MENA | ⭐⭐⭐ |
| **📁 UNSC-Daten** | `data/raw/unsc/unsc_membership_2002_2025.csv` | UNSC-Mitgliedschaft (alle Länder) | ⭐⭐⭐ |
| **📁 WDI-Daten** | `data/raw/wdi/wdi_2002_2025_dep.csv` | Rohstoffabhängigkeit + Regionscodes | ⭐⭐⭐ |
| **📁 Aufbereitete Daten** | `data/processed/final_data_ssa_mea.csv` | **Finaler Datensatz (SSA + MENA)** | ⭐⭐⭐ |
| **📁 Inhaltsanalyse** | `data/processed/data_with_cond_types.csv` | Klassifizierte Bedingungen | ⭐⭐⭐ |
| **📁 Modelle** | `results/model_*.rds` | Gespeicherte Regressionsergebnisse | ⭐⭐⭐ |
| **📁 Ergebnisse** | `results/results_summary.csv` | Zusammenfassung aller Ergebnisse | ⭐⭐⭐ |

---

---

## 📌 **Aktualisierte Hypothesen (für SSA + MENA)**

| **Hypothese** | **Fokus** | **Formulierung (Landesebene)** | **Testmodell** | **Theorie** |
|-------------|----------|--------------------------------|----------------|-------------|
| **H1** | Replizierung | UNSC-Mitgliedschaft eines Landes reduziert seine IMF-Konditionalität | `avgcondtype_all ~ unsc3 + Kontrollen` | Politische Ökonomie (Dreher et al.) |
| **H2** | Rohstoffabhängigkeit | Länder mit hoher Rohstoffabhängigkeit erhalten mehr IMF-Bedingungen | `avgcondtype_all ~ Rohstoffabhängigkeit + Kontrollen` | Extraktivismus (Frank 1967) |
| **H3** | UNSC × Rohstoff | In Ländern mit hoher Rohstoffabhängigkeit ist der UNSC-Effekt stärker (reduziert Konditionalität mehr) | `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | Neokolonialismus (Emmanuel 1972) |
| **H4** | **Inhaltsanalyse** | UNSC-Länder haben **weniger rohstoff-spezifische Bedingungen** | `rohstoff_cond_share ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | **Weltsystemtheorie (Wallerstein 1974)** |

---

---

## 💡 **Tipps für effizientes Arbeiten (10-Tage-Version)**

1. **📌 Halten Sie sich strikt an den Zeitplan** in [`session_10Tage_SSA_MENA.md`](session_10Tage_SSA_MENA.md).
2. **📌 Nutzen Sie die R-Code-Snippets** direkt aus der Session – keine Neuentwicklung!
3. **📌 Speichern Sie Zwischenergebnisse** täglich (z. B. in `data/processed/` und `results/`).
4. **📌 Schreiben Sie parallel zur Analyse** (ab Tag 7), um Zeit zu sparen.

---

---

## 📋 **Checkliste: 10-Tage-Plan**

### **🔴 Phase 1: Daten (Tag 1–3)**
| **Tag** | **Aufgabe** | **Ergebnis** | **Status** |
|---------|------------|--------------|------------|
| Tag 1 | Rohdaten für SSA + MENA vorbereiten | `mona_ssa_mea.csv`, `unsc_ssa_mea.csv`, `wdi_ssa_mea.csv` |⬜  |
| Tag 2 | Finalen Datensatz erstellen | `final_data_ssa_mea.csv` | ⬜ |
| Tag 3 | Inhaltsanalyse der Bedingungen | `data_with_cond_types.csv` | ⬜ |

### **🟡 Phase 2: Analyse (Tag 4–6)**
| **Tag** | **Aufgabe** | **Ergebnis** | **Status** |
|---------|------------|--------------|------------|
| Tag 4 | Replizierung (2002–2008) | `model_repl.rds`, `validation_repl.csv` | ⬜ |
| Tag 5 | Erweiterung (2008–2025, H2–H4) | `model_h2.rds`, `model_h3.rds`, `model_h4.rds`, `results_summary.csv` | ⬜ |
| Tag 6 | Robustheitschecks + Grafiken | `regression_table.txt`, Grafiken | ⬜ |

### **🟢 Phase 3: Schreiben (Tag 7–10)**
| **Tag** | **Aufgabe** | **Seiten** | **Ergebnis** | **Status** |
|---------|------------|------------|--------------|------------|
| Tag 7 | Einleitung + Theorie | 4 | Kapitel 1 | ⬜ |
| Tag 8 | Daten + Methodik | 3 | Kapitel 2 | ⬜ |
| Tag 9 | Ergebnisse | 8 | Kapitel 3–5 | ⬜ |
| Tag 10 | Diskussion + Fazit | 5 | Kapitel 6–7 | ⬜ |

---

---

## 🎯 **Zusammenfassung: Was sich gegen vorherige Versionen geändert hat**

| **Aspekt** | **Alte Version** | **10-Tage-Version** |
|------------|------------------|----------------------|
| **Regionen** | Alle Länder oder nur Afrika | **Nur SSA + MENA** (ca. 60 Länder) |
| **Inhaltsanalyse** | ❌ Nicht vorgesehen | ✅ **Klassifizierung der Bedingungen** (H4) |
| **Zeitplan** | 2 Wochen | **10 Tage** (täglich 4–5 Stunden) |
| **Seitenumfang** | 15–20 Seiten | **20 Seiten** (fix) |
| **Hypothesen** | H2 (Regionen) | **H4 (Inhaltsanalyse)** als Kern |
| **Datenaufbereitung** | Alle Länder | **Nur SSA + MENA** |
| **Modelle** | Komplexe Interaktionen | **Fokus auf H1–H4** |

---

---

## 🔗 **Nützliche Links (für Datenbeschaffung)**

- **World Bank WDI:** [https://data.worldbank.org/indicator](https://data.worldbank.org/indicator)
  - Rohstoffindikatoren: `TX.VAL.FUEL.ZS.UN`, `TX.VAL.MMTL.ZS.UN`
  - Regionscodes: In Metadata verfügbar
- **UN Security Council:** [https://www.un.org/securitycouncil](https://www.un.org/securitycouncil)
- **IMF MONA Database:** [https://www.imf.org/en/Publications/MONA](https://www.imf.org/en/Publications/MONA)

---

---

## 📌 **GitHub-Issues (für 10-Tage-Plan)**

### **🔴 Priorität 1: Daten (Tag 1–3)**
1. **Issue #1: Rohdaten für SSA + MENA vorbereiten**
   - **Beschreibung:** MONA, UNSC, WDI für SSA + MENA filtern
   - **Ergebnis:** `mona_ssa_mea.csv`, `unsc_ssa_mea.csv`, `wdi_ssa_mea.csv`
   - **Due:** Tag 1

2. **Issue #2: Finalen Datensatz erstellen**
   - **Beschreibung:** Daten aufbereiten (Bedingungstypen, unsc3, Rohstoffabhängigkeit)
   - **Ergebnis:** `final_data_ssa_mea.csv`
   - **Due:** Tag 2

3. **Issue #3: Inhaltsanalyse durchführen**
   - **Beschreibung:** MONA Key Codes klassifizieren (rohstoff-spezifisch vs. stabilisierend)
   - **Ergebnis:** `data_with_cond_types.csv`
   - **Due:** Tag 3

### **🟡 Priorität 2: Analyse (Tag 4–6)**
4. **Issue #4: Replizierung (2002–2008)**
   - **Beschreibung:** Modell 1 testen, Validierung durchführen
   - **Ergebnis:** `model_repl.rds`, `validation_repl.csv`
   - **Due:** Tag 4

5. **Issue #5: Erweiterung (2008–2025, H2–H4)**
   - **Beschreibung:** Modelle H2–H4 für SSA + MENA testen
   - **Ergebnis:** `model_h2.rds`, `model_h3.rds`, `model_h4.rds`
   - **Due:** Tag 5

6. **Issue #6: Robustheitschecks + Grafiken**
   - **Beschreibung:** Heteroskedastizität, Year-FE, Ergebniszusammenfassung
   - **Ergebnis:** `regression_table.txt`, Grafiken
   - **Due:** Tag 6

### **🟢 Priorität 3: Schreiben (Tag 7–10)**
7. **Issue #7: Einleitung + Theorie (Kapitel 1)**
   - **Beschreibung:** Forschungsfrage, Theorie, Hypothesen
   - **Ergebnis:** 4 Seiten
   - **Due:** Tag 7

8. **Issue #8: Daten + Methodik (Kapitel 2)**
   - **Beschreibung:** Datenquellen, Variablen, Modelle
   - **Ergebnis:** 3 Seiten
   - **Due:** Tag 8

9. **Issue #9: Ergebnisse (Kapitel 3–5)**
   - **Beschreibung:** Replizierung, Erweiterung, Robustheitschecks
   - **Ergebnis:** 8 Seiten
   - **Due:** Tag 9

10. **Issue #10: Diskussion + Fazit (Kapitel 6–7)**
    - **Beschreibung:** Interpretation, Limitationen, Ausblick
    - **Ergebnis:** 5 Seiten
    - **Due:** Tag 10

---

---

## 📊 **Verzeichnisstruktur (10-Tage-Version)**

```
imf-replizierung/
├── data/
│   ├── raw/
│   │   ├── mona/
│   │   │   └── Combined_ISO.xlsx          # Rohdaten (alle Länder)
│   │   ├── unsc/
│   │   │   └── unsc_membership_2002_2025.csv  # UNSC-Mitgliedschaft
│   │   └── wdi/
│   │       └── wdi_2002_2025_dep.csv       # Rohstoffabhängigkeit + Regionscodes
│   │
│   └── processed/
│       ├── final_data_ssa_mea.csv          # Finaler Datensatz (SSA + MENA)
│       └── data_with_cond_types.csv        # + klassifizierte Bedingungen
│
├── code/
│   ├── data_prep/
│   │   └── prepare_ssa_mea_data.R         # Datenaufbereitung (Tag 1–3)
│   │
│   └── analysis/
│       ├── phase1_replizierung.R        # Replizierung (Tag 4)
│       ├── phase2_erweiterung.R           # Erweiterung (Tag 5)
│       └── phase3_robustness.R            # Robustheitschecks (Tag 6)
│
├── results/
│   ├── model_repl.rds                    # Replizierungsmodell
│   ├── model_h2.rds                      # H2: Rohstoffabhängigkeit
│   ├── model_h3.rds                      # H3: UNSC-Effekt
│   ├── model_h4.rds                      # H4: Inhaltsanalyse
│   ├── results_summary.csv               # Zusammenfassung
│   ├── regression_table.txt               # Ergebnistabelle
│   └── figures/                          # Grafiken
│       ├── me_h3.png                     # Marginale Effekte (H3)
│       └── rohstoff_cond_share_boxplot.png # Inhaltsanalyse (H4)
│
├── docs/
│   ├── session_10Tage_SSA_MENA.md        # ⭐ Hauptdokument (10-Tage-Plan)
│   └── README_Aufgabenplan_10TAGE.md     # ⭐ Dieses Dokument
│
└── README.md                            # Projektübersicht (aktualisiert)
```

---

---

## 🎯 **Zusammenfassung: Ihr 10-Tage-Plan**

### **📅 Zeitplan:**
- **Tag 1–3:** Daten (SSA + MENA vorbereiten + Inhaltsanalyse)
- **Tag 4–6:** Analyse (Replizierung + H2–H4 + Robustheitschecks)
- **Tag 7–10:** Schreiben (Einleitung → Fazit)

### **📊 Seitenverteilung:**
- **Kapitel 1 (Einleitung + Theorie):** 4 Seiten
- **Kapitel 2 (Daten + Methodik):** 3 Seiten
- **Kapitel 3–5 (Ergebnisse):** 8 Seiten
- **Kapitel 6–7 (Diskussion + Fazit):** 5 Seiten
- **Gesamt:** **20 Seiten**

### **🎯 Kern Ihrer Arbeit:**
- **Inhaltsanalyse (H4):** Ihr **Alleinstellungsmerkmal** – zeigt, dass UNSC-Länder **weniger rohstoff-spezifische Bedingungen** haben.
- **Fokus auf SSA + MENA:** **Überschaubar** und theoretisch relevant.
- **10 Tage:** **Realistisch** mit klarem Zeitplan.

---

---

**Letzte Aktualisierung:** 2026-09-17  
**Status:** ✅ **10-Tage-Plan bereit** | ⏳ **Umsetzung in Arbeit**  
**Nächster Schritt:** **Issue #1 (Datenbeschaffung) anlegen und mit Tag 1 beginnen!**

---

**Viel Erfolg! Mit diesem Plan schaffen Sie die Arbeit in 10 Tagen.** 🎯
