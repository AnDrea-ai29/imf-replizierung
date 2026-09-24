# Projektstand: IMF-Replizierung mit SSA-Fokus

**Projekt:** Replizierung von Dreher, Sturm & Vreeland (2015), *Politics and IMF Conditionality* (Journal of Conflict Resolution), erweitert um eine Inhaltsanalyse für 20 Sub-Saharan-Africa-Länder (SSA). MENA wurde wegen fehlender WDI-Daten ausgeschlossen.

**Stand:** Tag 4 von 10 (Stand: 2026-09-23)

---

## 1. Aktueller Fortschritt (10-Tage-Plan)

| Phase 											| Status 			| Ergebnis |
|---------------------------------------------------|-------------------|----------|
| Tag 1-3: Datenaufbereitung 						| Abgeschlossen 	| `final_data_ssa_mea.csv` (900 Arrangements), `data_with_cond_types.csv` (480 Land-Jahr-Beobachtungen), `final_data_panel_SSA.csv` (Panel für Fixed Effects) |
| Tag 4: Replizierung (H1) 							| Abgeschlossen 	| `model_repl.rds`, `validation_repl.csv` |
| Tag 5-6: Erweiterung H2-H4 + Robustheitschecks 	| Ausstehend 		| `phase2_erweiterung.R` existiert, aber keine `model_h2/h3/h4.rds` |
| Tag 7-10: Schreiben (20 Seiten) 					| Nicht begonnen 	| - |

### Zwischenergebnis Replizierung (H1)

| Kennzahl | Wert |
|---|---|
| `unsc3`-Koeffizient | -1.25 |
| p-Wert | 0.685 |
| N | 97 Beobachtungen |
| R² | 0.019 |
| Länder | 20 SSA-Länder |
| Validierung | **Nicht bestätigt** (nicht signifikant, außerhalb des Original-Bereichs -1.8 bis -2.5); als Replizierungsversuch mit allen verfügbaren Daten akzeptiert |

**Plausible Gründe für die Abweichung:**
- MONA-Daten beginnen erst 2002 (Originalstudie: ab 1992)
- Kleines SSA-Sample
- Wenige UNSC-Mitgliedschaften im Zeitraum 2002-2008

---

## 2. Methoden

### 2.1 Panel-Fixed-Effects-Regression
- `plm` (within-Modelle), alternativ `fixest::feols` mit Land- und Jahr-Fixed-Effects
- Arrangement-Ebene mit Quartals-Normalisierung der Bedingungen (`avgcondtype_all` = Bedingungen pro Quartal)

### 2.2 Inhaltsanalyse der MONA-Bedingungen
**Hierarchische regelbasierte Klassifizierung** (3 Stufen, umgesetzt 2026-09-23; Skript: `code/data_prep/klassifizierung_hierarchisch.R`, Dokumentation: `code/data_prep/klassifizierung_dokumentation.md`):

- **Stufe 1 - Economic Descriptor (numerierte IMF-Kategorien, primär):**
  - **Rohstoff-spezifisch:** Kategorie 11.2 (natural resource and agricultural policies: Mining, Forst), Kategorie 5.1 (public enterprise pricing and subsidies: Petroleum-Preise, Brennstoffsubventionen)
  - **Stabilisierend:** Kategorien 1.x (Fiskal: Haushalt, Steuern, Schulden), 2.x (Zentralbank/monetär)
  - Der Key Code (PA, SAC, SB, SPC) wird nicht verwendet - Instrumententyp, keine Inhaltskategorie
- **Stufe 2 - Description (Text-Matching):** 16 Rohstoff-Keywords (fuel, mineral, oil, gas, extractive, petroleum, crude, hydrocarbon, mining, privatization, subsidy, energy, resource, commodity, export, tax.*resource) und 11 Stabilisierungs-Keywords (fiscal, inflation, budget, debt, deficit, surplus, reserve, monetary, interest, exchange, balance)
- **Stufe 3 - Kombination via `pmax()`:** 1, wenn mindestens eine Stufe positiv; `sonstige_cond` = weder-noch. Kategorien nicht exklusiv (851 Bedingungen beides)
- Abhängige Variable: `rohstoff_cond_share` (Anteil rohstoff-spezifischer Bedingungen je Land-Jahr)

**Ergebnis (15.404 Bedingungen):** 1.521 rohstoff-spezifisch (9,9%), 11.163 stabilisierend (72,5%), 3.571 sonstige (23,2%); Stufe 1 erkennt 207 Rohstoff-Bedingungen zusätzlich zur Keyword-Suche.

**Korrigierter Fehler:** Die vorherige Version berechnete `rohstoff_cond_share` innerhalb von `summarise()` fehlerhaft (dplyr-Sequenzsemantik: `mean()` griff auf die erzeugte Summe zu), sodass die "Anteile" Anzahlwerte enthielten (z.B. CAF 2006: 53 statt 0.27). Anteile werden jetzt als `cond / total_cond` berechnet. Dies betraf nur die H4-Variable; Panel-Spalten und H1 (`model_repl.rds`) sind unverändert. Bedingungsebene mit allen Stufenvariablen: `data/processed/conditions_classified_hierarchisch.csv`.

### 2.3 Geplante Robustheitschecks (Tag 6)
- Breusch-Pagan-Test auf Heteroskedastizität (`bptest()`)
- Robuste Standardfehler (`vcov = "hetero"` in `feols()`)
- Jahr-Fixed-Effects

---

## 3. Hypothesen

| H | Aussage | Spezifikation | Theorie | Status |
|---|---|---|---|---|
| **H1** | UNSC-Mitgliedschaft reduziert IMF-Konditionalität (Replizierung 2002-2008) | `avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt` | Politische Ökonomie (Dreher et al. 2015) | Getestet, nicht bestätigt |
| **H2** | Höhere Rohstoffabhängigkeit führt zu mehr Bedingungen | `avgcondtype_all ~ Rohstoffabhängigkeit + Kontrollen` | Dependenz-Theorie (Amin 1974, Frank 1967) | Ausstehend |
| **H3** | UNSC-Effekt verstärkt sich in rohstoffabhängigen Ländern | `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | Neokolonialismus (Emmanuel 1972) | Ausstehend |
| **H4** | UNSC-Länder erhalten weniger rohstoff-spezifische Bedingungen | `rohstoff_cond_share ~ unsc3 * Rohstoffabhängigkeit + Kontrollen` | Weltsystemtheorie (Wallerstein 1974) | Ausstehend (Alleinstellungsmerkmal der Arbeit) |

**Erwartete Richtungen:** H2 > 0, H3-Interaktion < 0, H4-Interaktion < 0.

**Kontrollvariablen:** `XDebtGNI`, `DebtServGNI`, `ResXDebt` (alle aus WDI).

**Rohstoffabhängigkeit:** `FuelExportPct + MineralExportPct` (Anteil Brennstoffe und Metalle/Erze an Gesamtexporten, WDI: `TX.VAL.FUEL.ZS.UN`, `TX.VAL.MMTL.ZS.UN`).

---

## 4. Datenquellen

| Datensatz | Datei | Inhalt | Status |
|---|---|---|---|
| MONA | `data/raw/mona/Combined_ISO.xlsx` | IMF-Programme und Bedingungen (mit ISO3-Codes) | Vorhanden |
| UNSC | `data/raw/unsc/unsc_membership_2002_2025.csv` | UNSC-Mitgliedschaft, `unsc3` (Mitglied in t oder t-1) | Vorhanden |
| WDI | `data/raw/wdi/wdi_2002_2025_dep.csv` | Rohstoffabhängigkeit und Kontrollvariablen | Vorhanden |
| Finaler Datensatz | `data/processed/final_data_ssa_mea.csv` | MONA + UNSC + WDI kombiniert | Abgeschlossen (Tag 2) |
| Inhaltsanalyse | `data/processed/data_with_cond_types.csv` | Hierarchisch klassifizierte Bedingungen (korrigiert 2026-09-23) | Abgeschlossen (Tag 3, überarbeitet) |

**Regionsauswahl (20 SSA-Länder):** AGO, CAF, CMR, COM, CPV, GAB, GHA, GIN, KEN, LSO, MDG, MOZ, MRT, MWI, RWA, SLE, SLV, TZA, UGA, ZMB

---

## 5. Nächste Schritte

1. **Tag 5:** `phase2_erweiterung.R` für 2008-2025 ausführen und H2-H4 testen (`model_h2.rds`, `model_h3.rds`, `model_h4.rds`, `results_summary.csv`)
2. **Tag 6:** Robustheitschecks (Breusch-Pagan, robuste Standardfehler, Jahr-FE) und Ergebnistabellen/Grafiken
3. **Tag 7-10:** Hausarbeit schreiben (Kapitel 1-7, 20 Seiten)

**Hinweis zu H3/H4:** Fuer 2008-2025 mit nur 20 SSA-Laendern duerfte die Zahl der UNSC-Jahre gering sein, was die Interaktionsterme instabil machen kann. Bei der Interpretation ist Vorsicht bei der Fallzahl geboten.

---

**Zuletzt aktualisiert:** 2026-09-23
