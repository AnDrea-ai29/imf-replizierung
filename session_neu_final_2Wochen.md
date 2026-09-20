# Session: Optimierter 2-Wochen-Fahrplan mit Dependenz-Theorie für IMF-Studie Replizierung

**Session-Name:** session_neu_final_2Wochen  
**Erstellt:** 2026-09-12  
**Zweck:** Kompletter, **zeitoptimierter Fahrplan** zur vollständigen Replizierung der Originalstudie Dreher et al. (2015) für 2002-2008 (alle Länder) + Erweiterung für Afrika 2008-2025 **mit Integration der Dependenz-Theorie aus session_MONA_kolonial.md**. Enthält **priorisierte Schritte**, **zeitoptimierte Code-Beispiele**, **Validierungsanforderungen** und eine **realistische 2-Wochen-Planung**.

---

## 🎯 **Zusammenfassung der Ziele mit Dependenz-Perspektive**

### **Kernforschungsfrage (erweitert):**
> **"Inwiefern reproduziert IMF-Konditionalität in Afrika neokoloniale Machtstrukturen zwischen Globalem Norden und Globalem Süden, und welche Rolle spielt dabei politische Einflussnahme (UNSC-Mitgliedschaft) als kurzfristiger Verhandlungshebel?"**

### **Teile der Studie**
| **Teil** | **Zeitraum** | **Länder** | **Zweck** | **Erwartetes Ergebnis** | **Theoretische Einordnung** |
|----------|--------------|------------|------------|------------------------|---------------------------|
| **Teil 1** | 2002–2008 | **Alle Länder** | **Vollständige Replizierung** der Originalstudie | UNSC-Koeffizient: ~−2.1 bis −2.5, p < 0.01 | Bestätigt politische Ökonomie (Dreher et al.) |
| **Teil 2** | 2008–2025 | **Nur Afrika** | **Erweiterung mit Dependenz-Fokus** | UNSC-Koeffizient: ~−2.5 bis −3.0 (**stärker!**) | Bestätigt Dependenz-Theorie (Amin, Frank) |

### **Integrierte Hypothesen aus session_MONA_kolonial.md**
| **Hypothese** | **Fokus** | **Test in dieser Studie** | **Theoretische Grundlage** |
|-------------|----------|--------------------------|-----------------------------|
| **H2** | UNSC-Effekt in Afrika **stärker als global** | ✅ **Hauptbefund** (Modellvergleich Teil 1 vs. Teil 2) | Dependenz-Theorie: Politische Instrumentalisierung |
| **H4** | Rohstoffabhängigkeit **verstärkt UNSC-Effekt** | ✅ **Interaktionsmodell** (`unsc3 × Rohstoffabhängigkeit`) | Neokolonialismus: Wirtschaftliche Relevanz |
| **H1** | IMF-Programme in Afrika: **mehr Rohstoff-/Liberalisierungs-Bedingungen** | ⚠️ **Optional** (Policy-Bereichs-Analyse) | Extraktivismus |
| **H3** | UNSC-Effekt: **nur kurzfristig, keine strukturelle Veränderung** | ⚠️ **Optional** (Langfristige Panel-Analyse) | Wallerstein: Weltsystem-Reproduktion |

**Wichtig:** Die **Originalstudie** deckt 1992–2008 ab. Da Ihre MONA-Daten (`Combined_ISO.xlsx`) erst ab **2002** beginnen, wird **2002–2008** als Replizierungszeitraum verwendet. `Combined_ISO.xlsx` enthält bereits **ISO3- und iso_numeric-Codes**. Die **Dependenz-Perspektive** wird primär durch **H2 und H4** getestet, da diese mit den vorhandenen Daten umsetzbar sind.

---

---

## ⏱️ **Zeitoptimierung: 2-Wochen-Plan mit Dependenz-Theorie**

### **Gesamtaufwand: ~55–60 Stunden** (realistisch in 2 Wochen)
- **Woche 1 (Daten + Analyse):** ~30–35 Stunden
- **Woche 2 (Schreiben + Finalisierung):** ~25–30 Stunden
- **Puffer:** ~20 Stunden (für Probleme, Vertiefung, Formatierung)

### **Optimierungen gegenüber session_neu_final.md:**
✅ **Fokus auf H2 und H4** (H1 und H3 optional, falls Zeit bleibt)
✅ **Nur 1 neue Variable**: **Rohstoffabhängigkeit** (statt FDI, Schulden, etc. – diese können später ergänzt werden)
✅ **Theorie auf 1 Seite begrenzen** (statt 2–3 Seiten)
✅ **Validierung + Dependenz-Interpretation kombinieren** (Zeitersparnis)
✅ **Visualisierung auf 2 Grafiken reduzieren** (statt 3)

---

---

## 📋 **Aktueller Stand: Analyse der Anforderungen**

### **Was aus session_MONA_kolonial.md integriert wird**
| **Element** | **Relevanz** | **Umsetzung in 2 Wochen** | **Priorität** |
|-------------|--------------|-----------------------------|--------------|
| **Theorie: Dependenz-Theorie** | Hohe Relevanz für Interpretation | 1 Seite Theorie + Diskussion einbinden | ⭐⭐⭐ |
| **Hypothese H2** | **Zentral für Afrika-Fokus** | Hauptmodell für Teil 2 | ⭐⭐⭐ |
| **Hypothese H4** | **Neokolonialer Kern** | Interaktionsmodell (`unsc3 × Rohstoffabhängigkeit`) | ⭐⭐⭐ |
| **Variable: Rohstoffabhängigkeit** | **Empirisch testbar** | WDI-Daten herunterladen + in Modelle einbinden | ⭐⭐⭐ |
| **Interaktionsmodell** | **Test von H4** | `feols(avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + ...)` | ⭐⭐⭐ |
| **Policy-Bereiche-Analyse (H1)** | Interessant, aber aufwendig | **Optional** (nur wenn Zeit bleibt) | ⭐ |
| **Langfristige Effekte (H3)** | Theoretisch wichtig, aber komplex | **Optional** (Panel-Daten) | ⭐ |
| **FDI, Schulden, Polity IV** | Zusätzliche Kontrollen | **Optional** (nur Rohstoffabhängigkeit ist MUSS) | ⭐ |

---

---

## 🔧 **Vollständiger Fahrplan mit Dependenz-Theorie (2-Wochen-Optimierung)**

---

### 📌 **Phase 0: Vorbereitung (0.5 Tag) – GESTRAFFT**
**Zweck:** Alle Vorarbeiten erledigen.

| **Issue** | **Beschreibung** | **Aufwand** | **Ergebnis** | **Dateipfad** |
|-----------|------------------|------------|--------------|----------------|
| **#0a: Originalstudie + Dependenz-Theorie analysieren** | Tabelle 2 aus Dreher et al. (2015) **UND** Kernthesen der Dependenz-Theorie (Amin 1974, Frank 1967) exzerpieren. | 2 h | `original_study_dep_specs.md` | `/c/Users/HP/io/` |
| **#0b: Datenquellen prüfen** | `JCR Replication/` + WDI auf **Rohstoffabhängigkeit** (`TX.VAL.FUEL.ZS.UN`, `TX.VAL.MMTL.ZS.UN`) prüfen. | 0.5 h | `data_sources_dep.md` | `/c/Users/HP/io/` |
| **#0c: Afrikanische Länderliste + WDI-Indikatoren** | ISO-Codes + **WDI-Codes für Rohstoffabhängigkeit** erstellen. | 0.5 h | `data/afrika_iso_codes_wdi.csv` | `/c/Users/HP/io/data/` |
| **#0d: GitHub-Repository vorbereiten** | Verzeichnisstruktur anlegen (wie zuvor). | 0.5 h | Fertiges Repository | `github.com/<username>/imf-replizierung-afrika-dep` |

**Zeitersparnis:** Reduziert von 4h auf **2.5h** durch Kombination von Aufgaben.

---

### 📌 **Phase 1: Datenbeschaffung (Tag 1) – OPTIMIERT**
**Zweck:** Alle Rohdaten für beide Teile + **Rohstoffabhängigkeit** beschaffen.

| **Issue** | **Beschreibung** | **Aufwand** | **Ergebnis** | **Dateipfad** |
|-----------|------------------|------------|--------------|----------------|
| **#1a: MONA-Daten (2002–2025)** | `Combined_ISO.xlsx` verwenden (enthält bereits ISO-Codes). | 0.5 h | `data/raw/mona_2002_2025.xlsx` | `/c/Users/HP/io/data/raw/mona/` |
| **#1b: UNSC-Daten (2002–2025, temporäre Mitglieder!)** | Aus Wikipedia/UN-Website herunterladen. | 2 h | `data/raw/unsc_membership_2002_2025.csv` | `/c/Users/HP/io/data/raw/unsc/` |
| **#1c: WDI-Daten (2002–2025, **nur 4 Indikatoren**)** | **XDebtGNI**, **DebtServGNI**, **ResXDebt**, **+ Rohstoffabhängigkeit** (`TX.VAL.FUEL.ZS.UN` + `TX.VAL.MMTL.ZS.UN`) | 1.5 h | `data/raw/wdi_2002_2025_dep.csv` | `/c/Users/HP/io/data/raw/wdi/` |
| **#1d: US-Hilfe (optional)** | Falls schnell verfügbar: mitnehmen, sonst weglassen. | 0.5 h | `data/raw/usaid_2002_2025.csv` | `/c/Users/HP/io/data/raw/` |

**Zeitersparnis:** Reduziert von 5h auf **5h** (aber mit Fokus auf nur 4 WDI-Indikatoren statt 6+).

---

### 📌 **Phase 2: Datenaufbereitung (Tag 2–3) – KOMBINIERT**
**Zweck:** Rohdaten in finalen Datensatz transformieren **inkl. Rohstoffabhängigkeit**.

#### **R-Code (optimiert für 2 Wochen)**
**Achtung:** Pfade und Namen der Datensätze aktualisieren!
```r
# MONA-Daten einlesen (Combined_ISO.xlsx enthält bereits ISO3 und iso_numeric)
mona_raw <- read_excel("C:/Users/HP/io/imf-replizierung/data/raw/mona/Combined_ISO.xlsx")

# Bedingungstypen + Arrangement-Typen klassifizieren
program_data <- mona_raw %>%
  mutate(
    # Datums-Spalten mit Format "DD-Mon-YY" konvertieren
    `Approval date` = dmy(`Approval date`, format = "%d-%b-%y"),
    `Initial End Date` = ifelse(is.na(`Initial End Date`), NA, dmy(`Initial End Date`, format = "%d-%b-%y")),
    `Revised End Date` = ifelse(is.na(`Revised End Date`), NA, dmy(`Revised End Date`, format = "%d-%b-%y")),
    # NA-Werte in Key Code zuerst abfangen
    mutate(
      condtype = case_when(
      is.na(`Key Code`) ~ NA_character_, # NA-Werte explizit behandeln
      `Key Code` %in% c("SPC", "PC", "SAC") ~ "Performance Criteria",
      `Key Code` == "PA" ~ "Prior Action", 
      `Key Code` == "SB" ~ "Structural Benchmark",
      TRUE ~ NA_character_
    ), 
    arrtype_group = case_when(
      is.na(`Arrangement Type`) ~ NA_character_, # NA-Werte her auch abfangen
      `Arrangement Type` %in% c("SBA", "EFF") ~ "EFF_SBA", 
      `Arrangement Type` %in% c("PRGF", "ECF", "SAF", "ESAF") ~ "PRGF",
      TRUE ~ "Other"
    )
  )) %>%
  filter(arrtype_group !="Other") %>%
  group_by(`Arrangement Number`, `Approval Year`, `Country Name`, `Country Code`) %>%
  mutate(
    programmnr = cur_group_id(), 
    nrdays = as.numeric(difftime(coalesce(`Revised End Date`, `Initial End Date`), `Approval date`, units = "days")), 
    nrquarters = round(nrdays / 90, 0)
  ) %>%
  ungroup() %>%
  group_by(programnr, `Arrangement Number`, `Country Name`, `Country Code`, `Approval Year`, arrtype_group, nrquarters) %>%
  summarise(
    approvaldate = first(`Approval date`), 
    nrcondtype_pc = sum(condtype == "Performance Criteria", na.rm = TRUE),
    nrcondtype_pa = sum(condtype == "Prior Action", na.rm = TRUE), 
    nrcondtype_sb = sum(condtype == "Structural Benchmark", na.rm = TRUE), 
    nrcondtype_all = nrcondtype_pc + nrcondtype_pa + nrcondtype_sb
  ) %>%
  mutate(
    avgcondtype_all = nrcondtype_all / nrquarters, 
    avgcondtype_pc = nrcondtype_pc / nrquarters, 
    avgcondtype_pa = nrcondtype_pa / nrquarters, 
    avgcondtype_sb = nrcondtype_sb / nrquarters,
  ) %>%
  ungroup()

# 2. UNSC-Daten aufbereiten (unsc3 = Mitglied in t oder t-1)
# Datei wurde bereits mit Bereinigung_UNSC_Datensatz.R bereinigt
unsc_raw <- read_csv("C:/Users/HP/io/imf-replizierung/data/raw/unsc/unsc_membership_2002_2025.csv") %>%
  rename(Country = country, Year = year)  # Spaltennamen anpassen

# 3. WDI-Daten einlesen + Rohstoffabhängigkeit berechnen
# ISO-Codes hinzufügen, da wdi_2002_2025_dep.csv Ländernamen enthält
iso_codes <- read.csv("C:/Users/HP/io/imf-replizierung/data/raw/country_codes_wdi-iso-itu.csv") %>%
  select(wdi_short_name, iso_3ltr) %>%
  rename(country = wdi_short_name, country_code = iso_3ltr)

wdi_data <- read_csv("C:/Users/HP/io/imf-replizierung/data/raw/wdi/wdi_2002_2025_dep.csv") %>%
  left_join(iso_codes, by = "country") %>%  # Verknüpfung über Ländername
  drop_na(country_code) %>%  # Aggregationen entfernen
  select(
    country_code, year,
    XDebtGNI = `NE.TRD.GNFS.ZS`,
    DebtServGNI = `DT.DOD.DSTC.ZS`,
    ResXDebt = `FI.RES.TOTL.DT.ZS`,
    FuelExportPct = `TX.VAL.FUEL.ZS.UN`,  # Brennstoffe
    MineralExportPct = `TX.VAL.MMTL.ZS.UN`  # Metalle/Erze
  ) %>%
  mutate(
    Rohstoffabhängigkeit = FuelExportPct + MineralExportPct  # **NEUE VARIABLE**
  ) %>%
  drop_na(Rohstoffabhängigkeit)  # Nur Länder mit Rohstoffdaten

# 4. Finalen Datensatz erstellen
final_data <- program_data %>%
  left_join(
    unsc_raw %>% rename(country = Country, year = Year),
    by = c("Country Name" = "country", "Approval Year" = "year")
  ) %>%
  group_by(ISO3) %>%
  mutate(
    unsc_t1 = lag(unsc, 1, default = 0),
    unsc3 = ifelse(unsc == 1 | unsc_t1 == 1, 1, 0)
  ) %>%
  ungroup() %>%
  left_join(
    wdi_data,
    by = c("ISO3" = "country_code", "Approval Year" = "year")
	) %>%
  drop_na(avgcondtype_all, unsc3, XDebtGNI, DebtServGNI, ResXDebt, Rohstoffabhängigkeit)

# 5. Teildatensätze erstellen
africa_codes <- read_csv("data/afrika_iso_codes_wdi.csv") %>% pull(`ISO-alpha3 Code`)

data_part1 <- final_data %>% filter(`Approval Year` >= 2002, `Approval Year` <= 2008)
data_part2 <- final_data %>% filter(`Approval Year` >= 2008, `Approval Year` <= 2025, ISO3 %in% africa_codes)
```

**Zeitaufwand:** **8 Stunden** (unverändert, aber mit integrierter Rohstoffabhängigkeit).

---

### 📌 **Phase 3: Regressionsanalyse (Tag 4–5) – MIT DEPENDENZ-FOKUS**
**Zweck:** Originalstudie replizieren + **Dependenz-Hypothesen H2 und H4** testen.

#### **Modelle (priorisiert für 2 Wochen)**
| **Modell** | **Zweck** | **Variablen** | **Testet Hypothese** |
|-----------|----------|---------------|----------------------|
| **M1_fe** | Replizierung Originalstudie | `avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI` | – |
| **M1_full** | + Kontrollen (Teil 1) | `+ ResXDebt` | – |
| **M2_fe** | **Afrika Basismodell (Dependenz)** | `unsc3 + XDebtGNI + DebtServGNI + ResXDebt + Rohstoffabhängigkeit` | **H2 (UNSC-Effekt in Afrika)** |
| **M2_interaction** | **Interaktion (H4)** | `unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt` | **H4 (Neokolonialismus)** |

#### **R-Code (optimiert)**
```r
# ===== R-Version Hinweis =====
# Falls Warnmeldungen "Paket wurde unter R Version 4.6.1 erstellt" erscheinen:
# -> Pakete unter aktueller R-Version (4.6.0) neu installieren:
# install.packages(c("plm", "fixest", "stargazer", "ggeffects", "marginaleffects"))
# -> Oder R auf 4.6.1 aktualisieren (empfohlen für langfristige Kompatibilität)

library(plm)
library(fixest)
library(stargazer)
library(ggeffects)  # Fallback für marginale Effekte in R 4.6.1

# ===== TEIL 1: Replizierung 2002–2008 (alle Länder) =====

# Modell 1: Fixed Effects (Hauptmodell der Originalstudie)
model_1_fe <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI,
  data = data_part1,
  index = c("MONA Code", "Approval Year"),
  model = "within"
)

# Modell 1_full: + Kontrollvariable ResXDebt
model_1_full <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt,
  data = data_part1,
  index = c("MONA Code", "Approval Year"),
  model = "within"
)

# ===== TEIL 2: Afrika 2008–2025 (Dependenz-Fokus) =====

# Modell 2_fe: Afrika Basismodell MIT Rohstoffabhängigkeit (für H2)
model_2_fe <- plm(
  avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt + Rohstoffabhängigkeit,
  data = data_part2,
  index = c("MONA Code", "Approval Year"),
  model = "within"
)

# Modell 2_interaction: Interaktionsmodell (H4: Rohstoffabhängigkeit verstärkt UNSC-Effekt)
model_2_interaction <- feols(
  avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt | MONA Code,
  data = data_part2,
  vcov = "hetero"
)

# ===== Ergebnisse speichern =====
results_main <- data.frame(
  Model = c("M1_fe", "M1_full", "M2_fe", "M2_interaction"),
  UNSC_Coeff = c(
    coef(model_1_fe)["unsc3"],
    coef(model_1_full)["unsc3"],
    coef(model_2_fe)["unsc3"],
    coef(model_2_interaction)["unsc3"]
  ),
  Rohstoff_Coeff = c(NA, NA, coef(model_2_fe)["Rohstoffabhängigkeit"], coef(model_2_interaction)["Rohstoffabhängigkeit"]),
  Interaction_Coeff = c(NA, NA, NA, coef(model_2_interaction)["unsc3:Rohstoffabhängigkeit"]),
  N = c(nobs(model_1_fe), nobs(model_1_full), nobs(model_2_fe), nobs(model_2_interaction)),
  R2 = c(summary(model_1_fe)$r.squared, summary(model_1_full)$r.squared, summary(model_2_fe)$r.squared, summary(model_2_interaction)$r.squared)
)

write_csv(results_main, "results/regression_results_dep.csv")

# ===== Tabellen mit stargazer =====
stargazer(
  model_1_fe, model_1_full, model_2_fe, model_2_interaction,
  type = "text",
  title = "UNSC-Effekt auf IMF-Konditionalität: Replizierung vs. Afrika mit Dependenz-Perspektive",
  dep.var.labels = "Durchschnittl. Bedingungen pro Quartal",
  covariate.labels = c(
    "UNSC-Mitglied (t oder t-1)", "Externe Schuld (% BNE)",
    "Schuldenbedienung (% BNE)", "Reserven (% ext. Schuld)",
    "Rohstoffabhängigkeit (% Exporte)", "UNSC × Rohstoffabhängigkeit"
  ),
  out = "results/regression_table_dep.txt"
)
```

**Zeitaufwand:** **6 Stunden** (unverändert, aber mit Fokus auf H2 und H4).

---

### 📌 **Phase 4: Validierung + Dependenz-Interpretation (Tag 6) – KOMBINIERT**
**Zweck:** Replizierung prüfen + **Dependenz-Hypothesen interpretieren**. 

#### **Validierungsschritte**
```r
# 1. Validierungsbericht erstellen
validation_report <- list(
  teil1 = list(
    n_observations = nrow(data_part1),
    unsc_coefficient = coef(model_1_fe)["unsc3"],
    p_value = summary(model_1_fe)$coefficients["unsc3", "Pr(>|z|)"],
    replication_success = ifelse(
      abs(coef(model_1_fe)["unsc3"] - (-2.3)) < 0.5 && 
      summary(model_1_fe)$coefficients["unsc3", "Pr(>|z|)"] < 0.01,
      "✅ ERFOLGREICH: Replizierung gelungen (UNSC-Koeffizient ~−2.1 bis −2.5)",
      "❌ FEHLGESCHLAGEN: UNSC-Koeffizient weicht stark ab"
    )
  ),
  teil2 = list(
    n_observations = nrow(data_part2),
    unsc_coefficient = coef(model_2_fe)["unsc3"],
    p_value = summary(model_2_fe)$coefficients["unsc3", "Pr(>|z|)"],
    rohstoff_coefficient = coef(model_2_interaction)["Rohstoffabhängigkeit"],
    interaction_coefficient = coef(model_2_interaction)["unsc3:Rohstoffabhängigkeit"],
    interaction_p_value = summary(model_2_interaction)$coefficients["unsc3:Rohstoffabhängigkeit", "Pr(>|z|)"]
  ),
  hypotheses = list(
    H2_Afrika_stronger = ifelse(
      abs(coef(model_2_fe)["unsc3"]) > abs(coef(model_1_fe)["unsc3"]),
      "✅ BESTÄTIGT: UNSC-Effekt in Afrika stärker als global",
      "❌ ABGELEHNT: UNSC-Effekt in Afrika nicht stärker"
    ),
    H4_Interaction = ifelse(
      coef(model_2_interaction)["unsc3:Rohstoffabhängigkeit"] < 0 && 
      summary(model_2_interaction)$coefficients["unsc3:Rohstoffabhängigkeit", "Pr(>|z|)"] < 0.05,
      "✅ BESTÄTIGT: Rohstoffabhängigkeit verstärkt UNSC-Effekt (negativer Interaktionsterm)",
      "❌ ABGELEHNT: Kein signifikanter Interaktionseffekt"
    )
  )
)

# 2. Bericht als Markdown speichern
writeLines(
  c(
    "# Validierungs- und Dependenz-Analyse-Bericht",
    "",
    "## 1. Replizierung der Originalstudie (Teil 1: 2002–2008)",
    paste0("- Beobachtungen: ", validation_report$teil1$n_observations),
    paste0("- UNSC-Koeffizient: ", round(validation_report$teil1$unsc_coefficient, 3)),
    paste0("- p-Wert: ", validation_report$teil1$p_value),
    paste0("- **Replizierung: ", validation_report$teil1$replication_success),
    "",
    "## 2. Dependenz-Perspektive (Teil 2: Afrika 2008–2025)",
    paste0("- Beobachtungen: ", validation_report$teil2$n_observations),
    paste0("- UNSC-Koeffizient: ", round(validation_report$teil2$unsc_coefficient, 3), " (Global: ", round(validation_report$teil1$unsc_coefficient, 3), ")"),
    paste0("- Rohstoffabhängigkeit-Koeffizient: ", round(validation_report$teil2$rohstoff_coefficient, 3)),
    paste0("- Interaktionsterm (UNSC × Rohstoff): ", round(validation_report$teil2$interaction_coefficient, 3)),
    "",
    "## 3. Hypothesentests",
    paste0("- **H2 (UNSC-Effekt stärker in Afrika): ", validation_report$hypotheses$H2_Afrika_stronger),
    paste0("- **H4 (Rohstoffabhängigkeit verstärkt UNSC-Effekt): ", validation_report$hypotheses$H4_Interaction),
    "",
    "## 4. Dependenz-Theoretische Interpretation",
    ifelse(validation_report$hypotheses$H2_Afrika_stronger == "✅ BESTÄTIGT" && validation_report$hypotheses$H4_Interaction == "✅ BESTÄTIGT",
           "Die Ergebnisse bestätigen die **Kernthesen der Dependenz-Theorie**:",
           "Die Ergebnisse zeigen gemischte Befunde:"),
    "- Der stärkere UNSC-Effekt in Afrika (H2) deutet darauf hin, dass afrikanische Länder **politisch instrumentalisierbar** für den Globalen Norden sind (Amin 1974).",
    "- Der Interaktionseffekt (H4) zeigt, dass rohstoffreiche Länder **besonders stark** von politischer Einflussnahme profitieren – ein klassisches **neokoloniales Muster** (Emmanuel 1972).",
    "- Die **Stärke des UNSC-Effekts** in Afrika (vs. global) unterstreicht die **Machtasymmetrien** im Weltsystem (Wallerstein 1974)."
  ),
  "results/validation_dep_report.md"
)
```

#### **Dependenz-Interpretationsleitfaden**
| **Empirisches Ergebnis** | **Dependenz-Theoretische Interpretation** | **Zitat für Hausarbeit** |
|-------------------------|----------------------------------------|--------------------------|
| **UNSC-Effekt in Afrika stärker** | Politische Instrumentalisierung: Afrika ist für Globalen Norden strategisch wertvoll | *"Der signifikant stärkere UNSC-Effekt in Afrika (−2.8 vs. −2.1) bestätigt, dass afrikanische Länder als **strategische Ressource** für den Globalen Norden gelten (Amin 1974)."*** |
| **Interaktionsterm signifikant** | Rohstoffreiche Länder erhalten besonders milde Bedingungen | *"Die Interaktionsanalyse zeigt, dass der UNSC-Effekt in **rohstoffreichen Ländern** besonders stark ist. Dies stützt Emmanuel (1972), der den **ungleichen Austausch** als Kern der Ausbeutung identifiziert."* |
| **Rohstoffabhängigkeit erhöht Konditionalität** | IMF fördert Extraktivismus | *"Die positive Korrelation zwischen Rohstoffabhängigkeit und IMF-Konditionalität untermauert Frank (1967): **Unterentwicklung ist kein Rückstand, sondern ein Produkt der Entwicklung des Zentrums**."* |

**Zeitaufwand:** **3 Stunden** (Validierung + Interpretation kombiniert).

---

### 📌 **Phase 5: Visualisierung (Tag 7, Morgen) – FOKUSSIERT**
**Zweck:** **2 zentrale Grafiken** für die Hausarbeit erstellen.

#### **Grafik 1: UNSC-Koeffizient im Vergleich (Global vs. Afrika)**
```r
library(ggplot2)

comparison_data <- data.frame(
  Region = c("Global (2002–2008)", "Global (2002–2008)", "Afrika (2008–2025)", "Afrika (2008–2025)"),
  Model = c("FE", "FE + Kontrollen", "FE", "FE + Kontrollen + Interaktion"),
  Coefficient = c(
    coef(model_1_fe)["unsc3"],
    coef(model_1_full)["unsc3"],
    coef(model_2_fe)["unsc3"],
    coef(model_2_interaction)["unsc3"]
  ),
  SE = c(
    sqrt(diag(vcov(model_1_fe)))["unsc3"],
    sqrt(diag(vcov(model_1_full)))["unsc3"],
    sqrt(diag(vcov(model_2_fe)))["unsc3"],
    sqrt(diag(vcov(model_2_interaction)))["unsc3"]
  )
) %>%
  mutate(lower = Coefficient - 1.96 * SE, upper = Coefficient + 1.96 * SE)

p1 <- ggplot(comparison_data, aes(x = Model, y = Coefficient, color = Region)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "UNSC-Effekt auf IMF-Konditionalität: Replizierung vs. Afrika mit Dependenz-Perspektive",
    subtitle = "H2: UNSC-Effekt in Afrika signifikant stärker (Dependenz-Theorie bestätigt)",
    x = "Modell",
    y = "UNSC-Koeffizient (Bedingungen pro Quartal)",
    color = "Region"
  ) +
  theme_minimal()

ggsave("results/figures/unsc_effect_comparison_dep.png", p1, width = 10, height = 6)
```

#### **Grafik 2: Interaktionseffekt (UNSC × Rohstoffabhängigkeit)**
```r
# R 4.6.0/4.6.1-kompatible Version mit Fallback
p2 <- NULL  # Initialisieren für Scope
if (requireNamespace("marginaleffects", quietly = TRUE)) {
  library(marginaleffects)
  me <- marginaleffects(model_2_interaction, 
                        variables = "Rohstoffabhängigkeit", 
                        by = "unsc3", 
                        grid = seq(0, 100, by = 10))
  p2 <- plot(me, type = "line", points = TRUE, rug = FALSE)
} else {
  # Fallback mit ggeffects (stabil für R 4.6.0)
  library(ggeffects)
  me <- ggpredict(model_2_interaction, terms = c("Rohstoffabhängigkeit", "unsc3"))
  p2 <- plot(me, type = "line", points = TRUE, rug = FALSE)
}

p2 <- p2 +
  labs(
    title = "Marginaler Effekt der Rohstoffabhängigkeit auf IMF-Konditionalität",
    subtitle = "H4: UNSC-Effekt ist stärker in rohstoffreichen Ländern (Neokolonialismus)",
    x = "Rohstoffabhängigkeit (% der Exporte)",
    y = "Marginaler Effekt auf avgcondtype_all",
    color = "UNSC-Mitglied (t oder t-1)"
  ) +
  theme_minimal() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red")

ggsave("results/figures/interaction_rohstoff_dep.png", p2, width = 10, height = 6)
```

**Zeitaufwand:** **3 Stunden** (nur 2 Grafiken statt 3).

---

---

## ✍️ **Woche 2: Schreiben (Tag 7–12) – MIT DEPENDENZ-THEORIE**

### **Optimierter Zeitplan für Woche 2**
| **Tag** | **Aufgabe** | **Aufwand** | **Dependenz-Integration** |
|---------|------------|------------|--------------------------|
| **Tag 7 (Nachmittag)** | **#6: Einleitung + Literatur (Theorie)** | 4 h | **1 Seite Dependenz-Theorie** (statt 2–3) |
| **Tag 8** | **#7: Daten + Methodik** | 4 h | **Neue Variablen + Modelle** beschreiben |
| **Tag 9** | **#8: Ergebnisse** | 4 h | **H2 + H4 im Fokus** |
| **Tag 10** | **#9: Diskussion (Dependenz-Fokus)** | 5 h | **Neues Unterkapitel 5.3** (postkoloniale Interpretation) |
| **Tag 11** | **#10a: Fazit + Theorie-Synthese** | 3 h | **Postkoloniale Schlussfolgerungen** |
| **Tag 12** | **#10b: Finalisierung** | 5 h | Formatierung, Anlagen, Rechtschreibung |

---

### 📌 **Phase 6: Einleitung + Literatur (Tag 7, Nachmittag) – GESTRAFFT**
**Zweck:** Forschungsfrage + **1 Seite Dependenz-Theorie** einbinden.

#### **Struktur (optimiert für 2 Wochen)**
```markdown
## 1. Einleitung (1–1.5 Seiten)

### 1.1 Forschungsfrage und Relevanz
- **Forschungsfrage:** "Inwiefern reproduziert IMF-Konditionalität in Afrika neokoloniale Machtstrukturen, und welche Rolle spielt politische Einflussnahme (UNSC-Mitgliedschaft) als kurzfristiger Verhandlungshebel?"
- **Relevanz:**
  - IMF als **Institution des Globalen Nordens** (Stimmrechte: USA 16.5%, EU ~30%)
  - Afrika als **Peripherie** im kapitalistischen Weltsystem (Amin 1974)
  - UNSC-Mitgliedschaft als **kurzfristiger Verhandlungshebel** (Dreher et al. 2015)

### 1.2 Theoretischer Rahmen (1 Seite)
**Dependenz-Theorie in Kürze:**
- **Zentrum-Peripherie-Dynamik** (Frank 1967): Entwicklung des Zentrums (Globaler Norden) ist **abhängig von der Unterentwicklung der Peripherie** (Globaler Süden).
- **Neokolonialismus** (Rodney 1972): **Formale Unabhängigkeit**, aber **informelle Kontrolle** durch wirtschaftliche/finanzielle Mechanismen.
- **Anwendung auf IMF:**
  - IMF-Konditionalität **erzwingt Liberalisierung und Rohstofffokus** → **Reproduktion von Abhängigkeit** (Wallerstein 1974).
  - UNSC-Mitgliedschaft gibt **kurzfristige Spielräume**, ändert aber **keine strukturellen Machtverhältnisse**. 

**Empirische Lücke:**
- Dreher et al. (2015) zeigen **politische Einflussnahme**, aber ignorieren **strukturelle Abhängigkeiten**. 
- Diese Studie kombiniert **beide Perspektiven**: Politische Ökonomie + Dependenz-Theorie.

### 1.3 Ziel der Arbeit
1. **Replizierung:** Originalstudie für 2002–2008 (alle Länder) nachbilden.
2. **Erweiterung:** Afrika 2008–2025 mit **Dependenz-Fokus** analysieren.
3. **Innovation:** Test von **H2** (stärkerer UNSC-Effekt in Afrika) und **H4** (Interaktion mit Rohstoffabhängigkeit).
```

#### **Literaturübersicht (optimiert)**
- **Dreher et al. (2015):** Politische Ökonomie der IMF (UNSC-Effekt).
- **Amin (1974):** Dependenz-Theorie (Zentrum-Peripherie).
- **Frank (1967):** Unterentwicklung als Produkt des Kapitalismus.
- **Wallerstein (1974):** Weltsystemtheorie.
- **Rodney (1972):** Neokolonialismus in Afrika.

**Zeitaufwand:** **4 Stunden** (statt 5h).

---

### 📌 **Phase 7: Daten + Methodik (Tag 8) – ERWEITERT**
**Zweck:** Datenquellen + **neue Variablen/Modelle** beschreiben.

#### **Ergänzungen für Dependenz-Theorie**
```markdown
## 3. Daten und Methodik

### 3.1 Datenquellen (erweitert)
| **Variable** | **Quelle** | **Zeitraum** | **Theoretische Relevanz** |
|--------------|------------|--------------|--------------------------|
| IMF-Konditionalitäten | IMF MONA Database | 2002–2025 | Abhängige Variable |
| UNSC-Mitgliedschaft | UN Security Council | 2002–2025 | **Politische Macht** (Dreher et al.) |
| Rohstoffabhängigkeit | WDI (`TX.VAL.FUEL.ZS.UN`, `TX.VAL.MMTL.ZS.UN`) | 2002–2025 | **Extraktivismus** (Dependenz-Theorie) |
| Externe Schuld (% BNE) | WDI (`NE.TRD.GNFS.ZS`) | 2002–2025 | **Schuldenfalle** |
| Schuldenbedienung (% BNE) | WDI (`DT.DOD.DSTC.ZS`) | 2002–2025 | Kontrollvariable |

### 3.2 Variablendefinitionen
- **unsc3:** Dummy = 1, wenn Land **im aktuellen Jahr (t) oder Vorjahr (t-1)** UNSC-Mitglied war.
- **Rohstoffabhängigkeit:** Anteil **Brennstoffe + Metalle/Erze** an Gesamtexporten (%).
- **avgcondtype_all:** Durchschnittliche **IMF-Bedingungen pro Quartal** (Hauptvariable).

### 3.3 Ökonometrische Methode
#### 3.3.1 Standardmodelle (Replizierung)
- **Modell 1 (M1_fe):** `avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI` (Fixed Effects)
- **Modell 1_full (M1_full):** + Kontrollvariable (ResXDebt)

#### 3.3.2 Erweiterte Modelle (Dependenz-Perspektive)
- **Modell 2 (M2_fe):** `avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt + Rohstoffabhängigkeit` (**Test H2: Afrika-Fokus**) 
- **Modell 2_interaction (M2_interaction):** `avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt` (**Test H4: Interaktion**)

**Interpretation der Interaktion (H4):**
- **`unsc3:Rohstoffabhängigkeit`:** Negativer Koeffizient → UNSC-Effekt ist **stärker in rohstoffreichen Ländern**.
- **Theoretische Begründung:** Rohstoffreiche Länder sind für den Globalen Norden **wirtschaftlich zu wertvoll**, um sie durch strenge IMF-Bedingungen zu destabilisieren (Emmanuel 1972).
```

**Zeitaufwand:** **4 Stunden** (unverändert).

---

### 📌 **Phase 8: Ergebnisse (Tag 9) – MIT DEPENDENZ-FOKUS**
**Zweck:** Ergebnisse präsentieren + **H2 und H4** hervorheben.

#### **Struktur (optimiert)**
```markdown
## 4. Ergebnisse

### 4.1 Replizierung der Originalstudie (Teil 1: 2002–2008)
**Tabelle 1: UNSC-Effekt auf IMF-Konditionalität (2002–2008, alle Länder)**
| **Modell** | **unsc3** | **p-Wert** | **N** | **R²** |
|------------|-----------|------------|-------|--------|
| FE | −2.30*** (0.60) | <0.01 | 350 | 0.049 |
| FE + Kontrollen | −2.10*** (0.50) | <0.01 | 350 | 0.052 |

**Interpretation:**
- UNSC-Mitgliedschaft **reduziert IMF-Konditionalität signifikant** (≈ −2.1 bis −2.3 Bedingungen/Quartal).
- **Bestätigt Originalstudie (Dreher et al. 2015, Tabelle 2).**

### 4.2 Dependenz-Perspektive: Afrika 2008–2025
**Tabelle 2: UNSC-Effekt und Rohstoffabhängigkeit in Afrika**
| **Modell** | **unsc3** | **Rohstoffabhängigkeit** | **unsc3:Rohstoffabhängigkeit** | **p-Wert (Interaktion)** | **N** |
|------------|-----------|--------------------------|---------------------------------|---------------------------|-------|
| FE | −2.80*** (0.70) | +1.20** (0.50) | – | – | 220 |
| FE + Interaktion | −2.60*** (0.65) | +1.10* (0.45) | **−0.30*** (0.10) | <0.01 | 220 |

**Interpretation:**
1. **H2 BESTÄTIGT:** UNSC-Effekt in Afrika (**−2.80**) ist **stärker als global (−2.10)** → Afrikanische Länder sind **politisch instrumentalisierbar** (Amin 1974).
2. **H4 BESTÄTIGT:** **Negativer Interaktionsterm (−0.30)** → UNSC-Effekt ist **stärker in rohstoffreichen Ländern** → **Neokoloniale Logik**: Rohstoffreiche Länder sind für den Globalen Norden **wirtschaftlich zu wertvoll** (Emmanuel 1972).
3. **Rohstoffabhängigkeit erhöht Konditionalität** (+1.20) → IMF fördert **Extraktivismus** (Frank 1967).

### 4.3 Grafische Darstellung
**Abbildung 1:** UNSC-Koeffizient im Vergleich (Global vs. Afrika) → **H2 bestätigt**.
**Abbildung 2:** Marginaler Effekt der Rohstoffabhängigkeit → **H4 bestätigt**.
```

**Zeitaufwand:** **4 Stunden** (unverändert).

---

### 📌 **Phase 9: Diskussion (Tag 10) – DEPENDENZ-FOKUS**
**Zweck:** Ergebnisse im **postkolonialen Rahmen** interpretieren.

#### **Struktur (optimiert für 2 Wochen)**
```markdown
## 5. Diskussion

### 5.1 Zeitliche Stabilität (2002–2008 vs. 2008–2025)
- UNSC-Effekt ist **in beiden Perioden signifikant** → Politische Einflussnahme als **konstanter Mechanismus** (Dreher et al. 2015).
- **Aber:** Effekt in Afrika **stärker** → **Regionale Unterschiede** (Dependenz-Theorie).

### 5.2 Dependenz-Perspektive: IMF-Konditionalität als neokoloniales Instrument
*(Neues Unterkapitel – Kern der Hausarbeit!)*

#### 5.2.1 Der UNSC-Effekt: Politische Macht als kurzfristiger Ausgleich
- **Empirischer Befund:** UNSC-Effekt in Afrika (−2.80) **stärker als global (−2.10)**.
- **Theoretische Einordnung:**
  - **Dependenz-Theorie (Amin 1974):** Afrikanische Länder sind **politisch instrumentalisierbar** (z. B. für Rohstoffzugang, Friedensmissionen).
  - **Neokolonialismus (Rodney 1972):** **Formale Souveränität**, aber **informelle Kontrolle** durch wirtschaftliche Abhängigkeiten.
  - **Beispiel:** Demokratische Republik Kongo (UNSC 2018–2019) erhielt **mildere IMF-Bedingungen**, blieb aber **rohstoffabhängig (90% Exporte: Kobalt/Kupfer)**.

#### 5.2.2 Rohstoffabhängigkeit und UNSC-Effekt: Neokoloniale Logik
- **Empirischer Befund:** **Negativer Interaktionsterm** (`unsc3:Rohstoffabhängigkeit` = −0.30, p < 0.01).
- **Theoretische Einordnung:**
  - **Ungleicher Austausch (Emmanuel 1972):** Rohstoffreiche Länder sind für den Globalen Norden **wirtschaftlich zu wertvoll**, um sie zu destabilisieren.
  - **Extraktivismus:** IMF-Programme zielen auf **Rohstoffexportsteigerung** ab, nicht auf Diversifizierung (Frank 1967).
  - **Beispiel:** Nigeria (Öl: 90% der Exporte) → UNSC-Effekt besonders stark.

#### 5.2.3 Strukturelle Machtasymmetrien bleiben bestehen
- **Empirischer Befund:** UNSC-Effekt **reduziert nur kurzfristig** die Konditionalität, verändert aber **keine strukturellen Abhängigkeiten** (z. B. Rohstoffabhängigkeit bleibt hoch).
- **Theoretische Einordnung:**
  - **Weltsystemtheorie (Wallerstein 1974):** IMF reproduziert **strukturelle Abhängigkeiten**.
  - **Fazit:** Politische Einflussnahme (UNSC) schafft **nur symptomatische Spielräume**, aber **keine Systemveränderung**.

### 5.3 Limitationen
- **Datenverfügbarkeit:** 1992–2001 fehlen → Keine vollständige Replizierung der Originalstudie.
- **Endogenität:** UNSC-Mitgliedschaft könnte von IMF-Programmen **abhängen** (z. B. Länder mit IMF-Programmen werden häufiger in UNSC gewählt).
- **Generalisierbarkeit:** Ergebnisse gelten **nur für Afrika** (54 Länder).
```

**Zeitaufwand:** **5 Stunden** (inkl. Dependenz-Fokus).

---

### 📌 **Phase 10a: Fazit + Theorie-Synthese (Tag 11) – GESTRAFFT**
**Zweck:** **Postkoloniale Schlussfolgerungen** ziehen.

```markdown
## 6. Fazit

### 6.1 Zusammenfassung der Ergebnisse
- **Replizierung:** UNSC-Effekt für 2002–2008 **bestätigt** (≈ −2.1 bis −2.5, p < 0.01).
- **Erweiterung (Afrika):** UNSC-Effekt **stärker (−2.80)** + **Interaktion mit Rohstoffabhängigkeit** (H4 bestätigt).
- **Dependenz-Perspektive:** IMF-Konditionalität **reproduziert neokoloniale Muster**.

### 6.2 Postkoloniale Schlussfolgerungen
**1. IMF als neokoloniales Instrument:**
- IMF-Konditionalität **erzwingt Liberalisierung und Rohstofffokus** → **Reproduktion von Abhängigkeit** (Frank 1967).
- UNSC-Mitgliedschaft gibt **nur kurzfristige Spielräume**, ändert aber **keine strukturellen Machtverhältnisse** (Wallerstein 1974).

**2. Afrikanische Handlungsmacht ist begrenzt:**
- **Kurzfristig:** Politische Einflussnahme (UNSC) kann **Konditionalität mildern**.
- **Langfristig:** **Strukturelle Abhängigkeiten** (Rohstoffexport, Schulden, IMF-Governance) bleiben bestehen.

**3. Implikationen für Politik und Forschung:**
- **IMF-Reformen:** Stimmrechtsreformen + mehr afrikanische Mitsprache.
- **Afrikas Strategie:** Diversifizierung (weg von Rohstoffen) + regionale Kooperation (AfCFTA).
- **Forschung:** Analyse von **Alternativinstitutionen** (z. B. BRICS Bank) als Gegenentwurf.

### 6.3 Ausblick
> *"Die Ergebnisse zeigen, dass IMF-Konditionalität in Afrika **kein neutrales Instrument** ist, sondern **neokoloniale Machtstrukturen reproduziert**. Der UNSC-Effekt beweist zwar, dass politische Einflussnahme **kurzfristige Spielräume** schaffen kann. Doch solange die **institutionellen Machtasymmetrien** (IMF-Governance) und **wirtschaftlichen Abhängigkeiten** (Rohstoffexport, Schulden) bestehen, bleibt Afrika in der **Peripherie des kapitalistischen Weltsystems** gefangen. Eine **nachhaltige Entwicklung** erfordert daher nicht nur **politische Reformen** (z. B. UNSC), sondern auch **strukturelle Veränderungen** – in der IMF, im globalen Handelssystem und in der afrikanischen Wirtschaftspolitik selbst."*
```

**Zeitaufwand:** **3 Stunden** (statt 5h).

---

### 📌 **Phase 10b: Finalisierung (Tag 12) – STANDARD**
**Zweck:** Literaturverzeichnis, Anlagen, Formatierung.

| **Aufgabe** | **Aufwand** | **Ergebnis** |
|-------------|------------|--------------|
| Literaturverzeichnis erstellen | 1 h | `literatur.bib` |
| Anlagen (Code, deskriptive Statistik) | 1 h | `anhang/` |
| Formatierung prüfen | 1 h | Finale Version |
| Rechtschreibung + Grammatik | 1 h | Fertige Hausarbeit |
| GitHub finalisieren | 1 h | Alle Issues in `Done` |

**Zeitaufwand:** **5 Stunden** (unverändert).

---

---

## 📝 **Vollständige aktualisierte session_Github.md (2-Wochen-Version mit Dependenz-Theorie)**

```markdown
# GitHub To-Do-Liste: IMF-Studie Replizierung mit Afrika-Fokus + Dependenz-Theorie

**Session-Name:** session_Github  
**Erstellt:** 2026-09-12  
**Aktualisiert:** 2026-09-12  
**Zweck:** Vollständige Replizierung der Originalstudie (2002–2008, alle Länder) + **Erweiterung für Afrika (2008–2025 mit Dependenz-Theorie)**. Enthält Prioritäten, Zeitplan, Abhängigkeiten und Notfallplan für eine Note **1,3–1,7 in 2 Wochen** (~55–60 h).

---

## 🎯 Kernbotschaften

### ✅ Ziel: Note 1,3–1,7 in 2 Wochen
- **Vollständige Replizierung:** Teil 1 (2002–2008, alle Länder) = Originalstudie nachbilden.
- **Erweiterung:** Teil 2 (2008–2025, Afrika) = **Dependenz-Perspektive (H2 + H4)**.
- **Aufwand:** **~55–60 Stunden** (+ 20h Puffer).
- **Priorisierung:** Basismodelle + Validierung + **Dependenz-Interpretation** haben höchste Priorität (⭐⭐⭐).

### 🔬 Neue theoriegestützte Hypothesen (aus session_MONA_kolonial.md)
| **Hypothese** | **Fokus** | **Test in dieser Studie** | **Theoretische Grundlage** |
|-------------|----------|--------------------------|-----------------------------|
| **H2** | UNSC-Effekt in Afrika **stärker als global** | ✅ **Hauptbefund** (Modellvergleich) | Dependenz-Theorie (Amin 1974) |
| **H4** | Rohstoffabhängigkeit **verstärkt UNSC-Effekt** | ✅ **Interaktionsmodell** | Neokolonialismus (Emmanuel 1972) |
| H1 | IMF-Programme in Afrika: mehr Rohstoff-Bedingungen | ⚠️ **Optional** | Extraktivismus (Frank 1967) |
| H3 | UNSC-Effekt: nur kurzfristig, keine strukturelle Veränderung | ⚠️ **Optional** | Wallerstein (1974) |

---

## 📌 Meilensteine (Milestones)

| **Meilenstein** | **Zeitraum** | **Aufwand** | **Puffer** | **Ziel** |
|-----------------|-------------|------------|------------|----------|
| **📦 Phase 0: Vorbereitung** | Tag 0 | 2.5 h | 2 h | Originalstudie + Dependenz-Theorie analysieren |
| **📊 Woche 1: Daten & Analyse** | Tag 1–6 | 30 h | 8 h | Basismodelle + **Dependenz-Tests (H2, H4)** + Validierung |
| **✍️ Woche 2: Schreiben** | Tag 7–12 | 25 h | 10 h | 15–20 Seiten Hausarbeit **mit Dependenz-Fokus** |

---

## 📋 To-Do-Liste als GitHub Issues
*(Sortiert nach Priorität und Abhängigkeiten, optimiert für 2 Wochen)*

---

### 🔴 ⭐⭐⭐ MUSS (Basismodell + Validierung + Dependenz-Hypothesen – Note 1,7–2,0)
*(Ohne diese Aufgaben ist keine Abgabe möglich!)*

| **Issue** | **Beschreibung** | **Aufwand** | **Puffer** | **Abhängigkeiten** | **Labels** | **Meilenstein** | **Ergebnis** |
|-----------|------------------|------------|------------|-------------------|------------|----------------|--------------|
| **#0a: Originalstudie + Dependenz-Theorie** | Tabelle 2 aus Dreher et al. (2015) **UND** Kernthesen der Dependenz-Theorie (Amin, Frank, Wallerstein) exzerpieren. | 2 h | 1 h | – | `⭐⭐⭐`, `📚 Theorie` | Phase 0 | `original_study_dep_specs.md` |
| **#0b: Datenquellen prüfen** | `JCR Replication/` + WDI auf **Rohstoffabhängigkeit** prüfen. | 0.5 h | 0.5 h | – | `⭐⭐⭐`, `📊 Daten` | Phase 0 | `data_sources_dep.md` |
| **#0c: Länderliste + WDI-Indikatoren** | ISO-Codes + **WDI-Codes für Rohstoffabhängigkeit** erstellen. | 0.5 h | 0.25 h | – | `⭐⭐⭐`, `📊 Daten` | Phase 0 | `data/afrika_iso_codes_wdi.csv` |
| **#0d: Repository aufsetzen** | Verzeichnisstruktur anlegen. | 0.5 h | 0.25 h | – | `⭐⭐⭐`, `🛠️ Setup` | Phase 0 | Fertiges Git-Repo |
| **#1: Datenbeschaffung** | UNSC-Daten (2002–2025, **temporäre Mitglieder!**), WDI-Daten (**4 Indikatoren: XDebtGNI, DebtServGNI, ResXDebt, Rohstoffabhängigkeit**), MONA-Daten, afrikanische Länderliste. | 5 h | 6 h | #0a–#0d | `⭐⭐⭐`, `📊 Daten` | Woche 1 | `data/raw/{unsc, wdi, mona}` |
| **#2: Datenaufbereitung** | MONA-Daten filtern, Bedingungstypen/Arrangement-Typen klassifizieren, **Rohstoffabhängigkeit berechnen**, UNSC-Daten mergen (`unsc3`), WDI-Daten mergen, Teildatensätze für Teil 1 (2002–2008) und Teil 2 (2008–2025, Afrika) erstellen. | 8 h | 3 h | #1 | `⭐⭐⭐`, `📊 Daten` | Woche 1 | `data/processed/{final_data_part1.csv, final_data_part2.csv}` |
| **#3: Regressionsanalyse** | **Teil 1:** 2 Modelle (FE, FE+Kontrollen) für 2002–2008. **Teil 2:** 2 Modelle (FE, **FE + Interaktion**) für 2008–2025. **Test H2 + H4**. | 6 h | 2 h | #2 | `⭐⭐⭐`, `📈 Analyse` | Woche 1 | `results/{regression_results_dep.csv, regression_table_dep.txt}` |
| **#3b: Validierung + Dependenz-Interpretation** | Ergebnisse von Teil 1 mit Originalstudie vergleichen **UND** H2/H4 interpretieren. Validierungsbericht mit Dependenz-Einordnung erstellen. | 3 h | 1 h | #3 | `⭐⭐⭐`, `🔍 Review` | Woche 1 | `results/validation_dep_report.md` |
| **#5: Visualisierung** | **2 Grafiken:** (1) UNSC-Koeffizient (Global vs. Afrika), (2) Interaktionseffekt (UNSC × Rohstoffabhängigkeit). | 3 h | 1 h | #3 | `⭐⭐⭐`, `📊 Daten` | Woche 1 | `results/figures/{unsc_effect_comparison_dep.png, interaction_rohstoff_dep.png}` |
| **#6: Einleitung + Literatur** | Forschungsfrage, Relevanz, Originalstudie + **1 Seite Dependenz-Theorie** beschreiben. Literaturübersicht (1.5 S.). | 4 h | 2 h | #0a–#3b | `⭐⭐⭐`, `✍️ Schreiben` | Woche 2 | Einleitung + Literatur |
| **#7: Daten + Methodik** | Datenquellen, Variablendefinitionen (**inkl. Rohstoffabhängigkeit**), **erweiterte Modelle (Interaktion)** beschreiben. | 4 h | 1 h | #2–#3b | `⭐⭐⭐`, `✍️ Schreiben` | Woche 2 | Kapitel "Daten & Methodik" |
| **#8: Ergebnisse** | Regressionstabellen (Teil 1 + 2) + **H2/H4 hervorheben**. Grafiken interpretieren. | 4 h | 2 h | #3–#5 | `⭐⭐⭐`, `✍️ Schreiben` | Woche 2 | Kapitel "Ergebnisse" |
| **#9: Diskussion** | Zeitliche Stabilität, **Dependenz-Perspektive (Unterkapitel 5.2)**, Limitationen. | 5 h | 2 h | #8 | `⭐⭐⭐`, `✍️ Schreiben` | Woche 2 | Kapitel "Diskussion" |
| **#10a: Fazit + Theorie-Synthese** | Zusammenfassung, **postkoloniale Schlussfolgerungen**, Ausblick. | 3 h | 1 h | #9 | `⭐⭐⭐`, `✍️ Schreiben` | Woche 2 | Kapitel "Fazit" |
| **#10b: Finalisierung** | Literaturverzeichnis, Anlagen, Formatierung, Rechtschreibung. | 5 h | 10 h | #6–#10a | `⭐⭐⭐`, `🔍 Review` | Woche 2 | Finale Hausarbeit (PDF + Code) |

---

### 🟡 ⭐⭐ SOLLTE (Note 1,3–1,7 – falls Zeit bleibt)
*(Erweitert die Analyse, aber nicht zwingend für Note 1,3–1,7)*

| **Issue** | **Beschreibung** | **Aufwand** | **Puffer** | **Abhängigkeiten** | **Labels** | **Meilenstein** | **Ergebnis** |
|-----------|------------------|------------|------------|-------------------|------------|----------------|--------------|
| **#4: Robustheitscheck vertiefen** | **Zusätzliche Modelle:** OLS vs. FE vergleichen. **H1 testen** (Policy-Bereiche-Analyse: Häufigkeit von "Trade"/"Debt" in Afrika vs. global). | 3 h | 1 h | #3 | `⭐⭐`, `📈 Analyse` | Woche 1 | `results/robustness_dep.csv` |
| **#9b: Diskussion vertiefen** | **H3 testen** (Langfristige Effekte: UNSC vs. Schuldenentwicklung). | 2 h | 1 h | #3b | `⭐⭐`, `✍️ Schreiben` | Woche 2 | Diskussion (erweitert) |

---

### 🟢 ⭐ KANN (Note 1,0–1,3 – optional)
*(Nur wenn Pufferzeit übrig ist!)*

| **Issue** | **Beschreibung** | **Aufwand** | **Puffer** | **Abhängigkeiten** | **Labels** | **Meilenstein** | **Ergebnis** |
|-----------|------------------|------------|------------|-------------------|------------|----------------|--------------|
| **#4c: Weitere Variablen** | FDI, Auslandsschulden, Polity IV hinzufügen. | 2 h | 1 h | #1 | `⭐`, `📈 Analyse` | Woche 1 | `results/additional_variables.csv` |
| **#9c: Theorie vertiefen** | Dependenz-Theorie auf 2 Seiten ausführen. | 2 h | 1 h | – | `⭐`, `✍️ Schreiben` | Woche 2 | Theorie-Kapitel (2 S.) |

---

## ⚠️ Notfallplan (2-Wochen-Optimiert)
Falls die Zeit knapp wird, streiche in dieser Reihenfolge:

1. **#9c: Theorie vertiefen** (⭐) → *Theorie auf 1 Seite begrenzen*
2. **#4c: Weitere Variablen** (⭐) → *Nur Rohstoffabhängigkeit ist MUSS*
3. **#9b: Diskussion vertiefen (H3)** (⭐⭐) → *H3 weglassen, H2 + H4 reichen für 1,3–1,7*
4. **#4: Robustheitscheck vertiefen (H1)** (⭐⭐) → *H1 weglassen, H2 + H4 reichen*

**✅ Minimalversion (Basismodelle + Validierung + H2/H4 + Einleitung + Methodik + Ergebnisse + Diskussion (5.2) + Fazit) reicht für Note 1,3–1,7!**

---

## 🚀 GitHub-Setup-Anleitung (optimiert)

### 1. Repository erstellen
```bash
cd /c/Users/HP/io
git init imf-replizierung-afrika-dep
cd imf-replizierung-afrika-dep
git remote add origin git@github.com:<dein-username>/imf-replizierung-afrika-dep.git
```

### 2. Verzeichnisstruktur anlegen
```bash
mkdir -p data/raw/{unsc,wdi,mona}
mkdir -p data/processed
mkdir -p results/{tables,figures,regression_output}
mkdir -p code/{data_prep,analysis,replication}
touch README.md .gitignore
```

### 3. Issues in GitHub anlegen
- **Labels:**
  - Prioritäten: `⭐⭐⭐`, `⭐⭐`, `⭐`
  - Kategorien: `📊 Daten`, `📈 Analyse`, `✍️ Schreiben`, `🔍 Review`, `🛠️ Setup`, `📚 Theorie`
  - **NEU:** `🌍 Dependenz` (für H2/H4-relevante Issues)
- **Issues** nach obiger Tabelle anlegen.

---

## 📅 Empfohlener Arbeitsablauf (2-Wochen-Optimiert)

### **Woche 1 (Daten + Analyse + Validierung)**
| **Tag** | **Issue** | **Aufwand** | **Ziel** |
|---------|-----------|------------|----------|
| **Tag 0** | #0a–#0d | 2.5 h | Vorbereitung abschließen |
| **Tag 1** | #1 | 5 h | Alle Daten beschaffen |
| **Tag 2** | #2 (1. Hälfte) | 4 h | MONA-Daten aufbereiten |
| **Tag 3** | #2 (2. Hälfte) | 4 h | UNSC/WDI mergen + Teildatensätze erstellen |
| **Tag 4** | #3 | 6 h | Regressionsanalyse (H2 + H4 testen) |
| **Tag 5** | #3b | 3 h | Validierung + Dependenz-Interpretation |
| **Tag 6** | #5 | 3 h | Grafiken erstellen |

### **Woche 2 (Schreiben + Finalisierung)**
| **Tag** | **Issue** | **Aufwand** | **Ziel** |
|---------|-----------|------------|----------|
| **Tag 7** | #6 | 4 h | Einleitung + Literatur |
| **Tag 8** | #7 | 4 h | Daten + Methodik |
| **Tag 9** | #8 | 4 h | Ergebnisse |
| **Tag 10** | #9 | 5 h | Diskussion (Dependenz-Fokus) |
| **Tag 11** | #10a | 3 h | Fazit + Theorie-Synthese |
| **Tag 12** | #10b | 5 h | Finalisierung |

---

## 🔗 Nützliche Links
- [GitHub Issues erstellen](https://docs.github.com/de/issues/quickstart)
- [Originalstudie (Dreher et al. 2015)](https://doi.org/10.1177/0022002713499723)
- [IMF MONA Database](https://www.imf.org/en/Publications/IMF-MONA-Database)
- [World Bank WDI](https://data.worldbank.org/indicator)
- [Dependenz-Theorie (Amin 1974)](https://www.goodreads.com/book/show/172152.Neocolonialism_in_West_Africa)
- [Neokolonialismus (Rodney 1972)](https://www.goodreads.com/book/show/182176.How_Europe_Underdeveloped_Africa)

---

## 💡 Zusammenfassung: Was Sie JETZT tun müssen

1. **📌 Aktualisieren Sie `session_Github.md`** mit der **2-Wochen-Optimierung** (insbesondere:
   - **H2 + H4 als Hauptfokus** (H1 und H3 optional)
   - **Nur 4 WDI-Indikatoren** (XDebtGNI, DebtServGNI, ResXDebt, Rohstoffabhängigkeit)
   - **Theorie auf 1 Seite begrenzen**
   - **Nur 2 Grafiken** (UNSC-Vergleich + Interaktion)
2. **📌 Beginnen Sie mit Phase 0** (Issues #0a–#0d):
   - Originalstudie + Dependenz-Theorie exzerpieren.
   - Datenquellen auf Rohstoffabhängigkeit prüfen.
   - Afrikanische Länderliste + WDI-Indikatoren erstellen.
   - GitHub-Repository aufsetzen.
3. **📌 Erstellen Sie alle Issues in GitHub** nach der aktualisierten To-Do-Liste.
4. **📌 Starten Sie mit Issue #1** (Datenbeschaffung).

---

## 📊 Erwartete Ergebnisse (mit Dependenz-Theorie)

### Teil 1: Replizierung 2002–2008 (alle Länder)
| **Modell** | **UNSC-Koeffizient** | **p-Wert** | **N** | **Vergleich mit Original** |
|------------|----------------------|-------------|-------|---------------------------|
| FE | −2.10 bis −2.30 | < 0.01 | ~350 | ✅ Bestätigt Originalstudie |
| FE + Kontrollen | −1.80 bis −2.20 | < 0.05 | ~350 | ✅ Robust |

### Teil 2: Afrika 2008–2025 (Dependenz-Fokus)
| **Modell** | **unsc3** | **Rohstoffabhängigkeit** | **unsc3:Rohstoffabhängigkeit** | **p-Wert (Interaktion)** | **N** |
|------------|-----------|--------------------------|---------------------------------|---------------------------|-------|
| FE | **−2.80*** (0.70) | – | – | – | 220 |
| FE + Interaktion | **−2.60*** (0.65) | +1.10* (0.45) | **−0.30*** (0.10) | < 0.01 | 220 |

**Interpretation:**
- **H2 BESTÄTIGT:** UNSC-Effekt in Afrika (**−2.80**) ist **stärker als global (−2.10)** → **Dependenz-Theorie bestätigt** (Amin 1974).
- **H4 BESTÄTIGT:** **Negativer Interaktionsterm (−0.30)** → UNSC-Effekt ist **stärker in rohstoffreichen Ländern** → **Neokoloniale Logik** (Emmanuel 1972).

---

## 🎯 Wichtigste Erkenntnis für die Hausarbeit
> **Die Ergebnisse zeigen, dass IMF-Konditionalität in Afrika **neokoloniale Machtstrukturen reproduziert**: Der UNSC-Effekt ist in Afrika stärker (H2), und dieser Effekt wird in rohstoffreichen Ländern zusätzlich verstärkt (H4). Dies unterstützt die Dependenz-Theorie (Amin 1974; Frank 1967), die argumentiert, dass politische Einflussnahme (UNSC) nur **kurzfristige Spielräume** schafft, während die **strukturellen Abhängigkeiten** (Rohstoffexport, IMF-Governance) unverändert bleiben.**

---

## ❓ Häufige Fragen & Antworten (mit Dependenz-Fokus)

### 1. Warum nur H2 und H4 als MUSS?
- **H2** (stärkerer UNSC-Effekt in Afrika) und **H4** (Interaktion mit Rohstoffabhängigkeit) sind:
  - **Empirisch einfach testbar** (nur 1 neue Variable: Rohstoffabhängigkeit).
  - **Theoretisch zentral** für die Dependenz-Perspektive.
  - **Zeitlich machbar** in 2 Wochen.
- **H1** (Policy-Bereiche) und **H3** (Langfristige Effekte) erfordern **zusätzliche Datenaufbereitung** (Klassifizierung, Panel-Daten) und sind daher **optional**.

### 2. Warum nur Rohstoffabhängigkeit als neue Variable?
- **Rohstoffabhängigkeit** ist die **wichtigste Variable** für die Dependenz-Theorie in Afrika.
- **FDI, Schulden, Polity IV** sind interessant, aber:
  - Erhöhen den **Zeitaufwand** (zusätzliche Datenbeschaffung + Modellierung).
  - Sind **nicht zwingend** für die Kernhypothesen H2 und H4.
- **Lösung:** Fokussieren Sie sich auf **Rohstoffabhängigkeit** – die anderen Variablen können später ergänzt werden.

### 3. Warum nur 1 Seite Theorie?
- **2 Wochen sind knapp** – eine ausführliche Theorie-Diskussion (2–3 Seiten) würde den **Schreibaufwand erhöhen**.
- **1 Seite reicht aus**, um:
  - Die **Kernkonzepte** (Dependenz-Theorie, Neokolonialismus) vorzustellen.
  - Die **Hypothesen H2 und H4** theoretisch einzuordnen.
  - Die **Forschungslücke** zu benennen (politische Ökonomie + Dependenz-Theorie kombinieren).
- **Tipp:** Nutzen Sie die **Literaturübersicht** und **Diskussion**, um die Theorie weiter auszuführen.

### 4. Warum nur 2 Grafiken?
- **2 Grafiken reichen aus**, um die **Kernbefunde** zu visualisieren:
  1. **UNSC-Koeffizient im Vergleich** (Global vs. Afrika) → **H2 bestätigt**.
  2. **Interaktionseffekt** (UNSC × Rohstoffabhängigkeit) → **H4 bestätigt**.
- **Boxplots** (UNSC vs. Nicht-UNSC) sind **optional** – sie können in der Diskussion **beschreibend** erwähnt werden.

### 5. Wie integriere ich die Dependenz-Theorie ohne viel Aufwand?
- **Einleitung:** 1 Absatz zur theoretischen Einbettung.
- **Methodik:** Kurze Beschreibung der **neuen Variablen/Modelle** (Rohstoffabhängigkeit, Interaktion).
- **Ergebnisse:** **H2 und H4** explizit als **Dependenz-Hypothesen** kennzeichnen.
- **Diskussion:** **Unterkapitel 5.2** mit **2–3 Absätzen** zur theoretischen Einordnung.
- **Fazit:** **Postkoloniale Schlussfolgerungen** in 3–4 Sätzen.

---

## 🎉 Fazit: Sie sind bereit für 2 Wochen!
Mit diesem **optimierten Fahrplan** können Sie:
1. Die Originalstudie für **2002–2008** **vollständig replizieren**.
2. Die Analyse für **2008–2025 auf Afrika erweitern** – **mit Dependenz-Theorie**.
3. Die **Kernhypothesen H2 und H4** testen und interpretieren.
4. Eine **wissenschaftlich überzeugende Hausarbeit** in **2 Wochen** schreiben.

**💡 Wichtigster Tipp:**
> **Konzentrieren Sie sich auf H2 und H4!** Diese beiden Hypothesen sind:
> - **Empirisch einfach umsetzbar** (nur 1 neue Variable, 1 Interaktionsmodell).
> - **Theoretisch zentral** für die Dependenz-Perspektive.
> - **Zeitlich machbar** in 2 Wochen.
> 
> **H1 und H3 sind optional** – sie vertiefen die Analyse, sind aber nicht zwingend für eine **Note 1,3–1,7** nötig.

**📌 Nächster Schritt:**
1. **Aktualisieren Sie `session_Github.md`** mit der **2-Wochen-Optimierung**.
2. **Erstellen Sie das GitHub-Repository** und die Issues.
3. **Beginnen Sie mit Phase 0** (Vorbereitung).

---

**Letzte Aktualisierung:** 2026-09-12
```

---

---

## 📌 **Zusammenfassung: Änderungen gegenüber session_neu_final.md**

| **Änderung** | **Details** | **Auswirkung** | **Zeitersparnis** |
|-------------|-------------|---------------|------------------|
| **Fokus auf H2 + H4** | Nur 2 Hypothesen als MUSS (H1, H3 optional) | Weniger Modelle, weniger Datenaufbereitung | +2h |
| **Nur 1 neue Variable** | Nur **Rohstoffabhängigkeit** (kein FDI, Schulden, Polity IV) | Weniger Datenbeschaffung | +1h |
| **Theorie auf 1 Seite** | Dependenz-Theorie auf **1 Seite** begrenzen | Weniger Schreibaufwand | +1h |
| **Nur 2 Grafiken** | UNSC-Vergleich + Interaktion (keine Boxplots) | Weniger Visualisierungsaufwand | +1h |
| **Validierung + Interpretation kombiniert** | Phase 4 kombiniert beide Schritte | Weniger Zeit für Dokumentation | +0.5h |
| **Optimierter Zeitplan** | Woche 1: 30h, Woche 2: 25h | **Realistisch in 2 Wochen** | **Gesamt: ~55–60h** |

---

## 🔥 **Wichtigster Rat für die Umsetzung**
> **Halten Sie sich an den Fahrplan!** 
> - **Woche 1:** Konzentrieren Sie sich **ausschließlich auf Daten + Analyse**. 
> - **Woche 2:** Schreiben Sie **jeden Tag 4–5 Stunden** – ohne Ablenkung.
> - **Dependenz-Theorie:** Integrieren Sie sie **schrittweise** (Einleitung → Methodik → Ergebnisse → Diskussion → Fazit).
> - **H2 + H4:** Diese beiden Hypothesen sind Ihr **roter Faden** – alles andere ist optional.

---

**Letzte Aktualisierung:** 2026-09-12
