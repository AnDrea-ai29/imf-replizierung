# 📊 Projektstand: IMF-Studie Replizierung mit SSA Fokus

**Datum:** 20. September 2026  
**Phase:** Datenaufbereitung abgeschlossen (Tag 1–3)  
**Nächste Phase:** Analyse (Tag 4–6)  
**Anpassung:** Fokus auf **20 SSA-Länder** (MENA ausgeschlossen aufgrund fehlender WDI-Daten)  

---

## 🎯 Zusammenfassung des aktuellen Stands

### ✅ **Abgeschlossene Aufgaben (Tag 1–3)**

| **Tag** | **Aufgabe** | **Status** | **Ergebnis** | **Datei** |
|---------|-------------|------------|--------------|-----------|
| **Tag 1** | Rohdaten für SSA filtern | ✅ **Abgeschlossen** | **20 SSA-Länder** gefiltert | `mona_ssa_mea.csv`, `wdi_ssa_mea.csv`, `unsc_ssa_mea.csv` |
| **Tag 2** | Finalen Datensatz erstellen | ✅ **Abgeschlossen** | MONA + WDI + UNSC kombiniert | `final_data_ssa_mea.csv` |
| **Tag 2 (Anpassung)** | Fokus auf SSA (20 Länder) | ✅ **Entschieden** | MENA-Länder ausgeschlossen | `final_data_ssa_mea.csv` (angepasst) |

### 📂 **Erstellte Dateien**

```
 data/processed/
 ├── mona_ssa_mea.csv          # IMF-Programme für **20 SSA-Länder** (2002–2025)
 ├── wdi_ssa_mea.csv           # Rohstoffdaten für **20 SSA-Länder** (FuelExportPct, MineralExportPct)
 ├── unsc_ssa_mea.csv         # UNSC-Mitgliedschaft für **20 SSA-Länder** (unsc3)
 └── final_data_ssa_mea.csv   # Kombinierter Datensatz (**20 SSA-Länder**, Basis für Analyse)
```

### 🎯 **Gefilterte Länder (Nur SSA - 20 Länder)**

| **Region** | **Anzahl** | **ISO3-Codes** |
|------------|-----------|----------------|
| **SSA** | **20** | AGO, CAF, CMR, COM, CPV, GAB, GHA, GIN, KEN, LSO, MDG, MOZ, MRT, MWI, RWA, SLE, SLV, TZA, UGA, ZMB |

**Hinweis:** Ursprünglich waren 39 Länder (5 MENA + 34 SSA) geplant. Aufgrund fehlender Daten in der WDI-Datei (keine Rohstoffdaten für EGY, YEM, COD, COG, GNQ, STP, BDI, BEN, BFA, CIV, DJI, ETH, GMB, GNB, LBR, MLI, NER, NGA, SDN, SEN, SOM, SUR, TCD, TGO) wurden **nur die 20 SSA-Länder** beibehalten, für die in **allen drei Datensätzen** (MONA, WDI, UNSC) Daten vorliegen.

---

## 📈 Aktualisierte Hypothesen (aus Neu.md & README.md)

### **Forschungsfrage:**
> "Wie beeinflusst UNSC-Mitgliedschaft die IMF-Konditionalität in rohstoffabhängigen Ländern (SSA & MENA), und zeigt sich dies im Inhalt der Bedingungen?"

### **Hypothesen-Tabelle (angepasst für SSA-Fokus)**

| **Hypothese** | **Beschreibung** | **Testmethode** | **Theoretische Grundlage** | **Status** |
|--------------|------------------|-----------------|-----------------------------|------------|
| **H1** | UNSC-Mitgliedschaft reduziert IMF-Konditionalität (Replizierung Originalstudie 2002–2008) | `avgcondtype_all ~ unsc3 + Kontrollen` | Politische Ökonomie (Dreher et al. 2015) | ⏳ **Tag 4** |
| **H2** | Länder mit hoher Rohstoffabhängigkeit haben verstärkten UNSC-Effekt | `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | Dependenz-Theorie (Amin 1974) | ⏳ **Tag 5** |
| **H3** | Rohstoffabhängigkeit verstärkt UNSC-Effekt | `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | Neokolonialismus (Emmanuel 1972) | ⏳ **Tag 5** |
| **H4** | UNSC-Länder haben weniger rohstoff-spezifische Bedingungen | `rohstoff_cond_share ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | Weltsystemtheorie (Wallerstein 1974) | ⏳ **Tag 5** |

**Anmerkung zu H2/H3:** 
Da nur SSA analysiert wird (kein Regionalvergleich), wurden H2 und H3 angepasst. Beide testen den **Interaktionseffekt zwischen UNSC und Rohstoffabhängigkeit**, wobei H2 den **direkten Effekt der Rohstoffabhängigkeit** und H3 den **verstärkten UNSC-Effekt in rohstoffreichen Ländern** betont.

---

## 📊 Datenquellen & Variablen

### **1. MONA-Daten (IMF-Programme)**
| **Variable** | **Beschreibung** | **Typ** |
|-------------|------------------|---------|
| `ISO3` | Ländercode (ISO3) | Character |
| `Approval Year` | Jahr der Genehmigung | Integer |
| `avgcondtype_all` | Durchschnittl. IMF-Bedingungen pro Quartal | Numeric |
| `nrcondtype_all` | Anzahl aller Bedingungen | Integer |
| `XDebtGNI` | Externe Schuld (% BNE) | Numeric |
| `DebtServGNI` | Schuldenbedienung (% BNE) | Numeric |
| `ResXDebt` | Devisenreserven (% externe Schuld) | Numeric |

### **2. WDI-Daten (Rohstoffabhängigkeit)**
| **Variable** | **Beschreibung** | **Code** | **Typ** |
|-------------|------------------|----------|---------|
| `country_code` | Ländercode (ISO3) | - | Character |
| `year` | Jahr | - | Integer |
| `FuelExportPct` | Rohstoffabhängigkeit (Brennstoffe, % Exporte) | `TX.VAL.FUEL.ZS.UN` | Numeric |
| `MineralExportPct` | Rohstoffabhängigkeit (Mineralien, % Exporte) | `TX.VAL.MMTL.ZS.UN` | Numeric |
| `Rohstoffabhängigkeit` | Kombinierter Rohstoffindex | - | Numeric |

### **3. UNSC-Daten (Mitgliedschaft)**
| **Variable** | **Beschreibung** | **Typ** |
|-------------|------------------|---------|
| `wdicode` | Ländercode (ISO3) | Character |
| `year` | Jahr | Integer |
| `unsc` | UNSC-Mitglied (0/1) | Integer |
| `unsc_t1` | UNSC-Mitglied in t-1 (0/1) | Integer |
| `unsc3` | UNSC-Mitglied in t oder t-1 (0/1) | Integer |

---

## 🎯 Nächste Schritte (Tag 4–6)

### **📅 Tagesplan (angepasst für SSA-Fokus)**

| **Tag** | **Aufgabe** | **Skript** | **Ergebnis** |
|---------|-------------|------------|--------------|
| **Tag 4** | Replizierung (2002–2008, H1) | `Phase-3_SSA_only.R` | `model_h1.rds`, `validation_h1.csv` |
| **Tag 5** | Erweiterung (2008–2025, H2–H4) | `Phase-3_SSA_only.R` | `model_h2.rds`, `model_h3.rds`, `model_h4.rds` |
| **Tag 6** | Robustheitschecks + Grafiken | `Phase-3_SSA_only.R` | `table_h1.txt`, `table_h2_h4.txt`, `figures/*.png` |

### **📌 Wichtige Hinweise für Tag 4–6:**
- **Arbeitsverzeichnis:** `C:/Users/HP/io/imf-replizierung/`
- **Eingabedatei:** `data/processed/final_data_ssa_mea.csv` (**20 SSA-Länder**: AGO, CAF, CMR, COM, CPV, GAB, GHA, GIN, KEN, LSO, MDG, MOZ, MRT, MWI, RWA, SLE, SLV, TZA, UGA, ZMB)
- **Ausgabeverzeichnis:** `results/` (wird automatisch erstellt)
- **Benötigte Pakete:** `plm`, `fixest`, `lmtest`, `tidyverse`, `stargazer`
- **Anpassung:** Nur SSA-Länder (20) - MENA ausgeschlossen

---

## 📂 Verzeichnisstruktur (Stand: 20.09.2026)

```
imf-replizierung/
├── data/
│   ├── raw/
│   │   ├── mona/
│   │   │   └── Combined_ISO.xlsx
│   │   ├── unsc/
│   │   │   └── unsc_membership_2002_2025.csv
│   │   └── wdi/
│   │       └── wdi_2002_2025_dep.csv
│   │
│   └── processed/
│       ├── mona_ssa_mea.csv          # ✅ Tag 1 (**20 SSA-Länder**)
│       ├── wdi_ssa_mea.csv           # ✅ Tag 1 (**20 SSA-Länder**)
│       ├── unsc_ssa_mea.csv         # ✅ Tag 1 (**20 SSA-Länder**)
│       └── final_data_ssa_mea.csv   # ✅ Tag 2 (**20 SSA-Länder**)
│
├── code/
│   ├── filter_working.R            # ✅ Tag 1 (MONA filtern)
│   ├── filter_all_ssa_mea.R        # ✅ Tag 1 (alle 3 Dateien filtern)
│   ├── create_final_data.R         # ✅ Tag 2 (Finalen Datensatz erstellen)
│   └── Phase-3_SSA_only.R           # ⏳ Tag 4–6 (Analyse für **20 SSA-Länder**)
│
├── docs/
│   ├── session_10Tage_SSA_MENA.md   # 10-Tage-Plan
│   ├── README_Aufgabenplan_10TAGE.md
│   └── session_stand_2026-09-20.md # ✅ Aktueller Stand (diese Datei)
│
└── README.md                       # Hauptdokumentation
```

---

## 🔧 Technische Hinweise

### **1. Datenlücken in WDI**
- **Problem:** Die WDI-Datei enthält keine Daten für: EGY, YEM, COD, COG, GNQ, STP, BDI, BEN, BFA, CIV, DJI, ETH, GMB, GNB, LBR, MLI, NER, NGA, SDN, SEN, SOM, SUR, TCD, TGO
- **Lösung:** Analyse auf **20 SSA-Länder** beschränkt, für die in allen drei Datensätzen Daten vorliegen
- **Vorteil:** Vollständige Panel-Daten ohne fehlende Werte

### **2. Anpassung der Hypothesen**
- **H2:** Ursprünglich als Regionalvergleich (SSA vs. MENA) geplant
- **Neu:** Fokus auf **Rohstoffabhängigkeit** (ohne Regionalvergleich)
- **Begründung:** Mit nur 2 MENA-Ländern ist ein Regionalvergleich statistisch nicht robust

### **3. Merge-Strategie**
- **Methode:** `merge(..., by = c("ISO3", "Year"), all.x = TRUE)` + `na.omit()`
- **Ergebnis:** Nur Länder mit Daten in **allen drei Dateien** bleiben erhalten
- **Effekt:** 20 SSA-Länder (statt 39 geplant)

---

## 📌 Offene Punkte & Aufgaben

### **🔴 Hochpriorität (für Tag 4–6)**
- [ ] **Phase-3_SSA_only.R erstellen/ausführen** (Analyse für 20 SSA-Länder)
- [ ] **Robustheitschecks durchführen** (Heteroskedastizität, Year-FE)
- [ ] **Ergebnisse interpretieren** (H1–H4 validieren)

### **🟡 Mittlere Priorität (optional)**
- [ ] **Inhaltsanalyse (H4) vervollständigen** (`data_with_cond_types.csv`)
- [ ] **Regionsvariable erstellen** (SSA vs. MENA als Dummy)
- [ ] **Interaktionsterms in Modellen prüfen** (`unsc3 * Region`, `unsc3 * Rohstoffabhängigkeit`)

### **🟢 Niedrige Priorität (für Dokumentation)**
- [ ] **Ergebnisse in Tabellen zusammenfassen** (für Anhang)
- [ ] **Grafiken für Präsentation erstellen**
- [ ] **Literaturrecherche abschließen**

---

## 💾 GitHub-Aktualisierungen (empfohlen)

### **1. Commit-Nachricht für diesen Stand:**
```bash
git add data/processed/mona_ssa_mea.csv data/processed/wdi_ssa_mea.csv \
     data/processed/unsc_ssa_mea.csv data/processed/final_data_ssa_mea.csv \
     docs/session_stand_2026-09-20.md

git commit -m "Datenaufbereitung abgeschlossen: Fokus auf 20 SSA-Länder

- mona_ssa_mea.csv: IMF-Programme für 20 SSA-Länder (ursprünglich 39 geplant)
- wdi_ssa_mea.csv: Rohstoffdaten für 20 SSA-Länder
- unsc_ssa_mea.csv: UNSC-Mitgliedschaft für 20 SSA-Länder
- final_data_ssa_mea.csv: Kombinierter Datensatz
- session_stand_2026-09-20.md: Dokumentation (SSA-Fokus)

Anpassung: MENA-Länder ausgeschlossen (keine vollständigen Daten in WDI).
Hypothesen H2/H3 angepasst für SSA-Fokus."

Generated by Mistral Vibe.
Co-Authored-By: Mistral Vibe <vibe@mistral.ai>
```

### **2. Empfohlene GitHub-Issues:**
| **#** | **Titel** | **Label** | **Status** |
|-------|-----------|-----------|------------|
| #1 | Datenfilterung SSA (20 Länder) | `daten` | ✅ **Closed** |
| #2 | Replizierung H1 (2002–2008, SSA) | `analyse` | ⏳ **To Do** |
| #3 | Erweiterung H2–H4 (2008–2025, SSA) | `analyse` | ⏳ **To Do** |
| #4 | Robustheitschecks | `validierung` | ⏳ **To Do** |
| #5 | Hausarbeit schreiben | `dokumentation` | ⏳ **To Do** |

---

## 📅 Zeitplan (10-Tage-Plan)

| **Phase** | **Zeitraum** | **Status** | **Aufgabe** |
|-----------|--------------|------------|-------------|
| **Phase 1** | Tag 1–3 | ✅ **Abgeschlossen** | Datenaufbereitung (Filterung + Kombination, **20 SSA-Länder**) |
| **Phase 2** | Tag 4–6 | ⏳ **In Arbeit** | Analyse (H1–H4 + Robustheitschecks) |
| **Phase 3** | Tag 7–10 | ⏳ **Geplant** | Hausarbeit schreiben (20 Seiten) |

---

## 📚 Letzte Aktualisierung
- **Datum:** 20. September 2026
- **Status:** ✅ Datenaufbereitung abgeschlossen (Tag 1–3) - **Fokus auf 20 SSA-Länder** (MENA ausgeschlossen wegen fehlender WDI-Daten)
- **Nächster Schritt:** **Tag 4 – Replizierung (H1) mit Phase-3_SSA_only.R**
- **Verantwortlich:** User
- **Priorität:** ⭐⭐⭐ **Hoch**
- **Anmerkung:** Analyse auf SSA beschränkt (20 Länder) aufgrund fehlender WDI-Daten für MENA-Länder
