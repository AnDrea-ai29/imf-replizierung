# IMF-Studie Replizierung mit SSA-Fokus + Dependenz-Theorie

**Vollständige Replizierung der Originalstudie Dreher et al. (2015) für 2002-2008 (SSA)**  
**+ Erweiterung für SSA 2008-2025 mit Inhaltsanalyse der Bedingungen**

---

## 📚 Projektübersicht

**Originalstudie:** Dreher, A., Sturm, J.E., & Vreeland, J.R. (2015). *Politics and IMF Conditionality*. **Journal of Conflict Resolution**.

**Eigene Erweiterung (10-Tage-Plan):** 
- **Replizierung:** 2002-2008 (**SSA**) - Originalstudie nachbilden
- **Erweiterung:** 2008-2025 (**SSA**) mit **Inhaltsanalyse der IMF-Bedingungen**
- **Neuer Fokus:** Test, ob UNSC-Länder **weniger rohstoff-spezifische Bedingungen** erhalten
- **Anpassung:** Fokus auf **20 SSA-Länder** (MENA ausgeschlossen aufgrund fehlender WDI-Daten)

---

## 🎯 Forschungsfragen & Hypothesen

### Kernforschungsfrage:
> **"Wie beeinflusst UNSC-Mitgliedschaft die IMF-Konditionalität in rohstoffabhängigen Ländern (SSA), und zeigt sich dies im Inhalt der Bedingungen?"**

### Hypothesen (für **20 SSA-Länder**):
| **Hypothese** | **Beschreibung** | **Testmethode** | **Theoretische Grundlage** |
|-------------|------------------|-----------------|-----------------------------|
| **H1** | UNSC-Mitgliedschaft eines Landes reduziert seine IMF-Konditionalität (Replizierung Originalstudie 2002–2008) | `avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt` | Politische Ökonomie (Dreher et al. 2015) |
| **H2** | **Länder mit hoher Rohstoffabhängigkeit** haben einen **verstärkten UNSC-Effekt** | `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | Dependenz-Theorie (Amin 1974) |
| **H3** | **Rohstoffabhängigkeit verstärkt UNSC-Effekt** | `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | Neokolonialismus (Emmanuel 1972) |
| **H4** | UNSC-Länder haben **weniger rohstoff-spezifische Bedingungen** | `rohstoff_cond_share ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | **Weltsystemtheorie (Wallerstein 1974)** |

---

## 📊 Projektstatus (10-Tage-Plan)

| **Phase** | **Zeitraum** | **Status** | **Ergebnis** | **Fokus** |
|-----------|--------------|------------|--------------|------------|
| **Phase 1** | Datenbeschaffung & Aufbereitung | ✅ **Tag 1–3 ABGESCHLOSSEN** | `final_data_ssa_mea.csv` + Inhaltsanalyse | **20 SSA-Länder** |
| **Phase 2** | Analyse | ⏳ **Tag 4–6** | Modelle H1–H4 + Robustheitschecks | **20 SSA-Länder** |
| **Phase 3** | Schreiben | ⏳ **Tag 7–10** | 20-seitige Hausarbeit | **SSA + H4** |

---

## 🎯 Aktueller Fokus (10-Tage-Plan)

### **Region:**
- **Sub-Saharan Africa (SSA):** 20 Länder - Klassische Peripherie (Amin 1974)

### **Inhaltsanalyse (H4 - Alleinstellungsmerkmal!)**
- **Rohstoff-spezifische Bedingungen:** Privatisierung Ölsektor, Liberalisierung Bergbau, Subventionsabbau Brennstoffe
- **Stabilisierungsbedingungen:** Haushaltsdefizit, Inflation, Schuldenstand
- **Ziel:** Testen, ob UNSC-Länder **weniger rohstoff-spezifische Bedingungen** erhalten
- **Datenbasis:** 20 SSA-Länder

---

## 📂 Verzeichnisstruktur (10-Tage-Version)

```
imf-replizierung/
├── data/
│   ├── raw/                       # Rohdaten (nur **20 SSA-Länder**)
│   │   ├── mona/
│   │   │   └── Combined_ISO.xlsx      # Mit ISO3 und iso_numeric
│   │   ├── unsc/
│   │   │   └── unsc_membership_2002_2025.csv  # Panel mit unsc3
│   │   └── wdi/
│   │       └── wdi_2002_2025_dep.csv       # Rohstoffabhängigkeit
│   │
│   └── processed/                     # Aufbereitete Datensätze (nur **20 SSA-Länder**)
│       ├── final_data_ssa_mea.csv          # Finaler Datensatz
│       └── data_with_cond_types.csv        # + klassifizierte Bedingungen
│
├── code/
│   ├── data_prep/
│   │   └── prepare_ssa_mea_data.R         # Datenaufbereitung (Tag 1–3)
│   │
│   └── analysis/
│       ├── phase1_replizierung.R        # Replizierung (Tag 4)
│       ├── phase2_erweiterung.R           # H2–H4 (Tag 5)
│       └── phase3_robustness.R            # Robustheitschecks (Tag 6)
│
├── results/                           # Ergebnisse
│   ├── model_repl.rds                    # Replizierungsmodell
│   ├── model_h2.rds                      # H2: Rohstoffabhängigkeit
│   ├── model_h3.rds                      # H3: UNSC-Effekt
│   ├── model_h4.rds                      # H4: Inhaltsanalyse
│   ├── results_summary.csv               # Zusammenfassung
│   ├── regression_table.txt               # Ergebnistabelle
│   └── figures/                          # Grafiken
│
├── docs/
│   ├── session_10Tage_SSA_MENA.md        # ⭐ Hauptdokument (10-Tage-Plan)
│   └── README_Aufgabenplan_10TAGE.md     # ⭐ Aufgabenplan (dieses Dokument)
│
└── README.md                         # ✅ Aktualisiert (17.09.2026)
```

---

## 📊 Datenquellen (10-Tage-Version)

| **Datensatz** | **Datei** | **Beschreibung** | **Variablen** | **Status** |
|---------------|-----------|------------------|---------------|------------|
| **MONA** | `data/raw/mona/Combined_ISO.xlsx` | Enthält **ISO3** und **iso_numeric** (manuell ergänzt) | IMF-Programme, Bedingungen | ✅ Vorhanden |
| **UNSC** | `data/raw/unsc/unsc_membership_2002_2025.csv` | Panel mit **`unsc3`** (Mitglied in t oder t-1) | UNSC-Mitgliedschaft | ✅ Vorhanden |
| **WDI** | `data/raw/wdi/wdi_2002_2025_dep.csv` | Rohstoffabhängigkeit: **`FuelExportPct` + `MineralExportPct`** | `TX.VAL.FUEL.ZS.UN`, `TX.VAL.MMTL.ZS.UN` | ✅ Vorhanden |
| **MONA (SSA)** | `data/processed/mona_ssa_mea.csv` | **Gefiltert für 20 SSA-Länder** | IMF-Programme für SSA | ✅ **Tag 1** |
| **WDI (SSA)** | `data/processed/wdi_ssa_mea.csv` | **Gefiltert für 20 SSA-Länder** | Rohstoffdaten für SSA | ✅ **Tag 1** |
| **UNSC (SSA)** | `data/processed/unsc_ssa_mea.csv` | **Gefiltert für 20 SSA-Länder** | UNSC-Mitgliedschaft für SSA | ✅ **Tag 1** |
| **Final (SSA)** | `data/processed/final_data_ssa_mea.csv` | **Kombinierter Datensatz für Analyse** | MONA + WDI + UNSC | ✅ **Tag 2** |
| **Inhaltsanalyse** | `data/processed/data_with_cond_types.csv` | Klassifizierte Bedingungen | `rohstoff_cond`, `stabil_cond` | ⏳ Tag 3 |

---

## 🔧 Anpassungen für 10-Tage-Plan

### ✅ **Vorhanden:**
- **ISO-Codes:** `Combined.xlsx` → **`Combined_ISO.xlsx`** (manuelles Mapping)
- **WDI-Variablen:**
  - `FuelExportPct = TX.VAL.FUEL.ZS.UN` (Exporte)
  - `MineralExportPct = TX.VAL.MMTL.ZS.UN` (Exporte)
- **Verknüpfungen:** Alle Joins laufen über **`ISO3`**

### 🟡 **Für 20 SSA-Länder (Tag 1–3):**
1. **Daten filtern:**
   - MONA, UNSC, WDI auf **20 SSA-Länder** beschränken
   - Ergebnis: `final_data_ssa_mea.csv`

2. **Inhaltsanalyse (H4):**
   - **Manuelle Klassifizierung** der MONA Key Codes:
     - **Rohstoff-spezifisch:** *"fuel"*, *"mineral"*, *"oil"*, *"privatization"*, *"subsidy"*
     - **Stabilisierend:** *"fiscal"*, *"inflation"*, *"budget"*, *"debt"*
   - Ergebnis: `data_with_cond_types.csv`



---

## 📈 Modelle (10-Tage-Version - **20 SSA-Länder**)

### Teil 1: Replizierung (2002-2008, SSA)
| **Modell** | **Spezifikation** | **Testet Hypothese** | **Erwartetes Ergebnis** |
|-----------|------------------|----------------------|------------------------|
| **M1** | `avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt` | **H1: Replizierung** | `unsc3` = −1.8 bis −2.5 |

### Teil 2: Erweiterung (2008-2025, SSA)
| **Modell** | **Spezifikation** | **Testet Hypothese** | **Erwartetes Ergebnis** |
|-----------|------------------|----------------------|------------------------|
| **M2** | `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt` | **H2: UNSC × Rohstoffabhängigkeit** | `unsc3:Rohstoffabhängigkeit` ≠ 0 |
| **M3** | `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt` | **H3: Verstärkter UNSC-Effekt** | `unsc3:Rohstoffabhängigkeit` < 0 |
| **M4** | `rohstoff_cond_share ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt` | **H4: Inhaltsanalyse** | `unsc3:Rohstoffabhängigkeit` < 0 |

### Robustheitschecks
- **Heteroskedastizität:** Breusch-Pagan-Test (`bptest()`) für alle Modelle
- **Year-fixed-effects:** `feols(..., fixed_effects = ~Year)`
- **Robuste Standardfehler:** `vcov = "hetero"` in `feols()`

---

## 📚 Theoretische Einordnung

### Dependenz-Theorie (Amin 1974, Frank 1967, Wallerstein 1974)
- **Zentrum-Peripherie-Dynamik:** Entwicklung des Zentrums (Globaler Norden) ist abhängig von der Unterentwicklung der Peripherie
- **Neokolonialismus:** Formale Unabhängigkeit, aber informelle Kontrolle durch wirtschaftliche/finanzielle Mechanismen
- **Ungleicher Austausch (Emmanuel 1972):** Rohstoffreiche Länder erhalten ungleiche Tauschverhältnisse

### Anwendung auf IMF:
- IMF-Konditionalität erzwingt **Liberalisierung und Rohstofffokus** → Reproduktion von Abhängigkeit
- UNSC-Mitgliedschaft gibt **kurzfristige Spielräume**, ändert aber keine strukturellen Machtverhältnisse
- **Regionale Unterschiede:** Rohstoffreiche Regionen (SSA, Naher Osten) sind besonders anfällig für neokoloniale Einflussnahme

---

## 🎯 Nächste Schritte (10-Tage-Plan)

### **📅 Tagesplan (heute beginnen!)**
| **Priorität** | **Tag** | **Aufgabe** | **Ergebnis** |
|---------------|---------|-------------|--------------|
| ⭐⭐⭐ | **Tag 1** | Rohdaten für **20 SSA-Länder** filtern | `mona_ssa_mea.csv`, `unsc_ssa_mea.csv`, `wdi_ssa_mea.csv` |
| ⭐⭐⭐ | **Tag 2** | Finalen Datensatz erstellen | `final_data_ssa_mea.csv` |
| ⭐⭐⭐ | **Tag 3** | Inhaltsanalyse (rohstoff-spezifische Bedingungen klassifizieren) | `data_with_cond_types.csv` |
| ⭐⭐⭐ | **Tag 4** | Replizierung (2002–2008, H1) | `model_repl.rds` + Validierung |
| ⭐⭐⭐ | **Tag 5** | Erweiterung (2008–2025, H2–H4) | `model_h2.rds`, `model_h3.rds`, `model_h4.rds` |
| ⭐⭐ | **Tag 6** | Robustheitschecks + Grafiken | `regression_table.txt`, `figures/*.png` |
| ⭐⭐ | **Tag 7** | Einleitung + Theorie (Kapitel 1) | 4 Seiten |
| ⭐⭐ | **Tag 8** | Daten + Methodik (Kapitel 2) | 3 Seiten |
| ⭐⭐ | **Tag 9** | Ergebnisse (Kapitel 3–5) | 8 Seiten |
| ⭐⭐ | **Tag 10** | Diskussion + Fazit (Kapitel 6–7) | 5 Seiten |

**💡 Tipp:** Beginne heute mit **Tag 1** und arbeite dich strikt durch die Checkliste in [`session_10Tage_SSA_MENA.md`](session_10Tage_SSA_MENA.md)!

---

## 📖 Dokumentation (10-Tage-Version)

| **Dokument** | **Beschreibung** | **Status** | **Priorität** |
|--------------|------------------|------------|--------------|
| `Neu.md` | Ursprüngliche Änderungen (17.09.2026) | ⚠️ Veraltet |
| `session_10Tage_SSA_MENA.md` | **⭐ Hauptdokument: 10-Tage-Fahrplan** | ✅ **AKTUELL** | ⭐⭐⭐ |
| `README_Aufgabenplan_10TAGE.md` | **⭐ Aufgabenplan für 10 Tage** | ✅ **AKTUELL** | ⭐⭐⭐ |
| `session_stand_2026-09-20.md` | **⭐ Aktueller Projektstand (Datenaufbereitung abgeschlossen, 20 SSA-Länder)** | ✅ **NEU** | ⭐⭐⭐ |
| `README_Aufgabenplan_AKTUALISIERT.md` | Veraltet (2-Wochen-Plan) | ❌ Veraltet |
| `session_neu_final_2Wochen_AKTUALISIERT.md` | Veraltet (2-Wochen-Plan) | ❌ Veraltet |

---

## 🔗 Nützliche Links

- **World Bank WDI:** [https://data.worldbank.org/indicator](https://data.worldbank.org/indicator)
  - Rohstoffindikatoren: `TX.VAL.FUEL.ZS.UN`, `TX.VAL.MMTL.ZS.UN`
- **UN Security Council Membership:** [https://www.un.org/securitycouncil/en/content/member-states](https://www.un.org/securitycouncil/en/content/member-states)
- **IMF MONA Database:** [https://www.imf.org/en/Publications/MONA](https://www.imf.org/en/Publications/MONA)

---

---

## 📌 **Zusammenfassung: 10-Tage-Plan für 20 Seiten**

### **🎯 Ihr Fokus:**
- **Region:** **Nur SSA** (**20 Länder**: AGO, CAF, CMR, COM, CPV, GAB, GHA, GIN, KEN, LSO, MDG, MOZ, MRT, MWI, RWA, SLE, SLV, TZA, UGA, ZMB)
- **Inhaltsanalyse (H4):** **Alleinstellungsmerkmal** – Test, ob UNSC-Länder weniger rohstoff-spezifische Bedingungen erhalten
- **Zeitplan:** **10 Tage** (täglich 4–5 Stunden)
- **Anpassung:** Fokus auf **20 SSA-Länder** aufgrund fehlender WDI-Daten für MENA-Länder

### **📅 Tagesplan:**
- **Tag 1–3:** Daten (Filtern, Aufbereiten, Inhaltsanalyse) – ✅ **Abgeschlossen**
- **Tag 4–6:** Analyse (Replizierung + H2–H4 + Robustheitschecks)
- **Tag 7–10:** Schreiben (20 Seiten)

### **📊 Seitenverteilung:**
- Kapitel 1 (Einleitung + Theorie): **4 Seiten**
- Kapitel 2 (Daten + Methodik): **3 Seiten**
- Kapitel 3–5 (Ergebnisse): **8 Seiten**
- Kapitel 6–7 (Diskussion + Fazit): **5 Seiten**

**Letzte Aktualisierung:** 2026-09-20 (korrigiert 20.09.2026)  
**Status:** ✅ **Datenaufbereitung abgeschlossen** (Tag 1–3) - **Fokus auf 20 SSA-Länder** (MENA ausgeschlossen) | ⏳ **Analyse in Arbeit**  
**Nächster Schritt:** **Tag 4 starten** – Replizierung (H1) mit Phase-3_SSA_only.R ausführen!
