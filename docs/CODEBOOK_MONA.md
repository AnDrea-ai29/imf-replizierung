# CODEBOOK: IMF Conditionality Database (Dreher, Sturm, Vreeland 2009)

**Quelle**: `JCR_MONA_usage/JCR-MONA_Data/txt2dta7.do`  
**Studie**: Dreher, Axel; Sturm, Jan-Egbert; Vreeland, James Raymond. "Politics and IMF Conditionality." *Journal of Conflict Resolution*, 2009.  
**Datenbasis**: MONA (Monitoring of Fund Arrangements) Database  
**Erstellt**: 14.09.2026  
**Zweck**: Dokumentation aller Variablen für die Replikation der Studie

---

## 📋 Inhaltsverzeichnis

1. [Einführung](#1-einführung)
2. [Datenstruktur](#2-datenstruktur)
3. [Variablenkatalog](#3-variablenkatalog)
   - [3.1 Identifikationsvariablen](#31-identifikationsvariablen)
   - [3.2 Programm- und Arrangement-Variablen](#32-programm--und-arrangement-variablen)
   - [3.3 Bedingungsvariablen (Conditions)](#33-bedingungsvariablen-conditions)
   - [3.4 Policy-Areas](#34-policy-areas)
   - [3.5 Review-Typen](#35-review-typen)
   - [3.6 Aggregierte Bedingungsvariablen](#36-aggregierte-bedingungsvariablen)
   - [3.7 Scope-Variablen](#37-scope-variablen)
   - [3.8 Arrangement-Typen](#38-arrangement-typen)
   - [3.9 Zeitvariablen](#39-zeitvariablen)
   - [3.10 Externe Daten (WDI, Polity, DPI)](#310-externe-daten-wdi-polity-dpi)
   - [3.11 Dummy-Variablen](#311-dummy-variablen)
4. [Methodische Hinweise](#4-methodische-hinweise)
5. [Datenpipeline](#5-datenpipeline)
6. [Fehlende Werte & Korrekturen](#6-fehlende-werte--korrekturen)
7. [Dateien & Verzeichnisstruktur](#7-dateien--verzeichnisstruktur)

---

---

## 1. Einführung

Dieses Codebook dokumentiert die **IMF Conditionality Database**, die für die Studie "Politics and IMF Conditionality" (Dreher, Sturm, Vreeland 2009) erstellt wurde. Die Daten basieren auf der **MONA-Datenbank** (Monitoring of Fund Arrangements) des Internationalen Währungsfonds (IMF) und wurden durch externe Quellen (WDI, Polity IV, DPI, etc.) ergänzt.

### Hintergrund
Die Studie untersucht den Einfluss politischer Faktoren auf die **Strenge der IMF-Konditionalität**. Die zentraler abhängigen Variablen sind:
- **Anzahl der Bedingungen** (`nrcondtype_*`)
- **Scope der Bedingungen** (`scope_*`) – Vielfalt der Policy-Areas

### Datenumfang
- **Zeitraum**: 1993–2008 (MONA-Daten)
- **Länder**: Alle Länder mit IMF-Programmen im Sample
- **Programme**: Alle IMF-Arrangements (EFF, PRGF, ESAF, SBA, etc.)

---

## 2. Datenstruktur

### Hauptdatensätze
| Datei | Beschreibung | Quelle |
|-------|--------------|--------|
| `Data IMF Conditions Country-Arrangements at Approval.dta` | Hauptdatensatz für Analysen | Output von `txt2dta7.do` |
| `conditionality database.dta` | Vollständige Datenbank mit allen Variablen | Endgültiger Output |
| `MONA/Data MONA.dta` | Rohdaten aus MONA (bereinigt) | Zwischenoutput |

### Verarbeitungsstufen
1. **Rohdaten**: `MONA/Data Structural 1993-2001.txt`, `Data Performance 1993-2001.txt`, etc.
2. **Vorbereitung**: `MergeActionImplementation.do` → `ActionImplementation.dta`
3. **Hauptverarbeitung**: `txt2dta7.do` → Aggregation und Labeling
4. **Externe Daten**: Merge mit WDI, Polity IV, DPI, etc.
5. **Finaler Datensatz**: `Dreher_Sturm_Vreeland_JCR.dta` (für Regressionen)

---

---

## 3. Variablenkatalog

---

### 3.1 Identifikationsvariablen

| Variable      | Beschreibung                                    | Typ     | Beispielwerte             | Herkunft                   |
|---------------|-------------------------------------------------|---------|---------------------------|----------------------------|
| `orderorg`    | Identifier zur Rückverfolgung der Originaldaten | String  | `"S9301-001"`             | `orgorder` (bereinigt)     |
| `countryname` | Name des Landes                                 | String  | `"Germany"`, `"Ethiopia"` | MONA                       |
| `wdicode`     | Ländercode (World Development Indicators)       | String  | `"DEU"`, `"ETH"`          | `country_codes.csv`        |
| `code`        | Alternativer Ländercode                         | String  | `"DEU"`                   | `wdicode` (synonym)        |
| `aclpcode`    | IMF-interne Ländernummer                        | Numeric | `123`, `456`              | MONA                       |
| `idS9301`     | Temporäre ID für Daten 1993–2001                | Numeric | `1`, `2`, ...             | `id` (aus Structural Data) |
| `idcnt`       | Länderspezifische Gruppen-ID 					  | Numeric | `1`–`N`				    | `egen group(countryname)`  |
| `programnr`   | Eindeutige Nummer für jedes IMF-Programm 		  | Numeric | `1`, `2`, ... 			| Generiert in Zeile 252–257 |
| `orgorder`    | Original-Identifier aus MONA 					  | String  | `"S9301-001"` 			| MONA 						 |

---

### 3.2 Programm- und Arrangement-Variablen

| Variable 			  | Beschreibung 							| Typ 				| Werte | Definition |
|---------------------|-----------------------------------------|-------------------|-------|------------|
| `arrtype`			  | Typ des IMF-Programms 					| String 			| `"EFF"`, `"PRGF"`, `"ESAF"`, `"SBA"`, `"SAF"`, `"PSI"`, `"PRGF-EFF"` | MONA |
| `arrprogram` 		  | Programmnummer (alternativ) 			| String/Numeric 	| `1`, `2`, ... | `arrnum` (falls vorhanden) |
| `programtype`       | Typ des Programms 						| String 			| `"EFF"`, `"PRGF"` | MONA |
| `approvaldate`      | Genehmigungsdatum 						| String 			| `"15.01.2000"` | MONA |
| `approvaldatestata` | Genehmigungsdatum (Stata-Format) 		| Numeric 			| `18262` (01.01.2000) | `date(approvaldate,"DMY")` |
| `approvalyear`      | Genehmigungsjahr 						| Numeric 			| `2000` | `year(approvaldatestata)` |
| `initialenddate`    | Anfangliches Enddatum 					| Date 				| `"31.12.2002"` | `enddate` (erstes verfügbares Feld) |
| `enddate`			  | Enddatum des Programms 					| Date 				| `"31.12.2002"` | `revisedenddate` → `initialenddate` → `durationto` → `actualenddate` |
| `enddatestata`      | Enddatum (Stata-Format) 				| Numeric 			| `19358` | `date(enddate,"DMY")` |
| `finalenddate`	  | Finales Enddatum (korrigiert)			| Numeric 			| Stata-Format | `egen max(enddatestata), by(programnr)` |
| `testdate` 		  | Testdatum für Bedingungen 				| String 			| `"Continuous"`, `"31.12.2000"` | MONA |
| `testdatestata` 	  | Testdatum (Stata-Format) 				| Numeric 			| `18262` | `date(testdate,"MDY")` |
| `lasttestdate`	  | Letztes Testdatum im Programm 			| Numeric 			| Stata-Format | `egen max(ftestdatestata), by(programnr)` |
| `fstartdate`		  | Korrigiertes Startdatum (≥31.03.1992) 	| Numeric 			| Stata-Format | `approvaldatestata` (oder `11778` für frühere) |
| `fenddate` 		  | Korrigiertes Enddatum (Sample-Periode)	| Numeric 			| Stata-Format | `finalenddate` (oder `17713+90` für spätere) |

---

### 3.3 Bedingungsvariablen (Conditions)

#### 3.3.1 Bedingungstypen (`condtype`)

| Variable 		| Beschreibung | Kodierung | Definition |
|---------------|--------------|-----------|------------|
| `condtype` 	| Typ der IMF-Bedingung | String | `"Performance Criteria"`, `"Prior Action"`, `"Structural Benchmark"`, `"Struct.Benchmark and Prior Action"` | Vereinheitlicht aus `spc_pa_sb`, `keycode` |
| `strucperf` 	| Struktur vs. Performance | String | `"structural"`, `"performance"` | MONA |
| `structcond` 	| Dummy: Strukturelle Bedingung | Binary | `1` = strukturell, `0` = Performance | `strucperf=="structural"` |
| `quantperf` 	| Dummy: Quantitative/Performance-Bedingung | Binary | `1` = Performance, `0` = strukturell | `strucperf=="performance"` |

##### Aggregierte Bedingungstypen
| Code | Label | Beschreibung |
|------|-------|--------------|
| `0`  | Alle Bedingungen | Summe aller Bedingungstypen |
| `1`  | Performance Criteria | Quantitative + strukturelle Performance Criteria |
| `2`  | Prior Action | Bedingungen für Review-Abschluss |
| `3`  | Structural Benchmark | Strukturelle Meilensteine |

---

#### 3.3.2 Bedingungsstatus (`revstatus`)

| Variable | Beschreibung | Originalwerte | Bereinigte Werte |
|----------|--------------|---------------|------------------|
| `revstatus` | Status der Bedingungsüberprüfung | `"M"`, `"NM"`, `"DL"`, `"W"`, `"PM"`, `"CAN"`, `"MOD"`, `"MD"`, `"NMod"`, `"WM"`, `"AC"`, `"PA"`, `"PC"`, `"SB"`, `"n.a."` | `"Met (M)"`, `"Not Met (NM)"`, `"Delayed (DL)"`, `"Waived (W)"`, `"Partly Met (PM)"`, `"Cancelled (CAN)"`, `"Modified (MOD)"`, `"Met With Delay (MD)"`, `"??? (NMOD)"`, `"??? (WM)"`, `"NA"` |

##### Numerische Kodierung des Review-Status
| Code 	| Label | Status |
|-------|-------|--------|
| `1` 	| ??? (NMOD) | Unklar (ursprünglich "NMod") |
| `2` 	| ??? (WM) | Unklar (ursprünglich "WM") |
| `3` 	| Cancelled (CAN) | Abgebrochen |
| `4` 	| Delayed (DL) | Verzögert |
| `5` 	| Met (M) | Erfüllt |
| `6` 	| Met With Delay (MD) | Mit Verzögerung erfüllt |
| `7` 	| Modified (MOD) | Modifiziert |
| `8` 	| NA | Nicht verfügbar |
| `9` 	| Not Met (NM) | Nicht erfüllt |
| `10` 	| Partly Met (PM) | Teilweise erfüllt |
| `11` 	| Waived (W) | Erlassen |

---

### 3.4 Policy-Areas

#### Klassifikation der 20 Policy-Bereiche

| Code | Variable 							| Beschreibung 				| Herkunft |
|------|------------------------------------|---------------------------|---------|
| `1`  | `areaclass_1` / `nrareaclass_1` 	| Arrears 					| `areaclass` |
| `2`  | `areaclass_2` / `nrareaclass_2` 	| BOP / Reserves 			| MONA |
| `3`  | `areaclass_3` / `nrareaclass_3` 	| Capital Account 			| `econdescrpt`, `dqpc`, `description` |
| `4`  | `areaclass_4` / `nrareaclass_4` 	| Central Bank Reform 		| Manuell kodiert (`Desc2AreaClass.csv`) |
| `5`  | `areaclass_5` / `nrareaclass_5` 	| Credit to Government 		| |
| `6`  | `areaclass_6` / `nrareaclass_6` 	| Debt 						| |
| `7`  | `areaclass_7` / `nrareaclass_7` 	| Exchange System 			| |
| `8`  | `areaclass_8` / `nrareaclass_8` 	| Financial Sector 			| |
| `9`  | `areaclass_9` / `nrareaclass_9` 	| Governance 				| |
| `10` | `areaclass_10` / `nrareaclass_10` 	| Government Budget 		| |
| `11` | `areaclass_11` / `nrareaclass_11` 	| Monetary Ceiling 			| |
| `12` | `areaclass_12` / `nrareaclass_12` 	| Other 					| |
| `13` | `areaclass_13` / `nrareaclass_13` 	| Pricing 					| |
| `14` | `areaclass_14` / `nrareaclass_14` 	| Private Sector Reforms 	| |
| `15` | `areaclass_15` / `nrareaclass_15` 	| Privatization 			| |
| `16` | `areaclass_16` / `nrareaclass_16` 	| Public Sector 			| |
| `17` | `areaclass_17` / `nrareaclass_17` 	| Social 					| |
| `18` | `areaclass_18` / `nrareaclass_18` 	| Systemic 					| |
| `19` | `areaclass_19` / `nrareaclass_19` 	| Trade 					| |
| `20` | `areaclass_20` / `nrareaclass_20` 	| Wages & Pensions 			| |

> **Hinweis**: `areaclass` wird aus `areadescription` (zuvor `econdescrpt`, `dqpc`, `description`) abgeleitet und manuell in `Desc2AreaClass.csv` kodiert.

---

### 3.5 Review-Typen

| Variable | Beschreibung | Kodierung | Definition |
|----------|--------------|-----------|------------|
| `revtypenr` | Numerische Kodierung des Review-Typs | Numeric | `0`–`9.5` | |
| `revtype_r0` | Dummy: Review-Typ 0 | Binary | `1` wenn `revtypenr==0` | `tabulate revtypenr, gen(revtype_r*)` |
| `revtype_r1` | Dummy: Review-Typ 1 | Binary | `1` wenn `revtypenr==1` | |
| `revtype_r11` | Dummy: Review-Typ 11 | Binary | `1` wenn `revtypenr==11` | |
| `revtype_r2` | Dummy: Review-Typ 2 | Binary | `1` wenn `revtypenr==2` | |
| `revtype_r2r3` | Dummy: Review-Typ 2.5 | Binary | `1` wenn `revtypenr==2.5` | |
| `revtype_r3` | Dummy: Review-Typ 3 | Binary | `1` wenn `revtypenr==3` | |
| `revtype_r3r4` | Dummy: Review-Typ 3.5 | Binary | `1` wenn `revtypenr==3.5` | |
| `revtype_r4` | Dummy: Review-Typ 4 | Binary | `1` wenn `revtypenr==4` | |
| `revtype_r4r5` | Dummy: Review-Typ 4.5 | Binary | `1` wenn `revtypenr==4.5` | |
| `revtype_r5` | Dummy: Review-Typ 5 | Binary | `1` wenn `revtypenr==5` | |
| `revtype_r5r6` | Dummy: Review-Typ 5.5 | Binary | `1` wenn `revtypenr==5.5` | |
| `revtype_r6` | Dummy: Review-Typ 6 | Binary | `1` wenn `revtypenr==6` | |
| `revtype_r7` | Dummy: Review-Typ 7 | Binary | `1` wenn `revtypenr==7` | |
| `revtype_r8` | Dummy: Review-Typ 8 | Binary | `1` wenn `revtypenr==8` | |
| `revtype_r9` | Dummy: Review-Typ 9 | Binary | `1` wenn `revtypenr==9` | |

##### Mapping der Review-Typen (Originalwerte → Numerisch)
| Originalwert  | Numerischer Code |
|---------------|-------------------|
| `OC` 			| `0` |
| `R0` 			| `0` |
| `R1` 			| `1` |
| `R11` 		| `11` |
| `R2` 			| `2` |
| `R2R3` 		| `2.5` |
| `R3` 			| `3` |
| `R3R4` 		| `3.5` |
| `R4` 			| `4` |
| `R4R5` 		| `4.5` |
| `R5` 			| `5` |
| `R5R6` 		| `5.5` |
| `R6` 			| `6` |
| `R7` 			| `7` |
| `R8` 			| `8` |
| `R9` 			| `9` |

---

### 3.6 Aggregierte Bedingungsvariablen

#### 6.1 Anzahl der Bedingungen

| Variable 			| Beschreibung 											| Typ 	  | Berechnung |
|-------------------|-------------------------------------------------------|---------|-------------|
| `programentries` 	| Anzahl der Einträge pro Programm 						| Numeric | `1` pro Beobachtung |
| `nrtests` 		| Anzahl der Tests im Programm 							| Numeric | `egen count(temp), by(programnr)` (nur für `quantperf==1`) |
| `nrreviews` 		| Anzahl der Reviews im Programm 						| Numeric | `egen count(temp), by(programnr)` (für `revtypenr`) |
| `nrcondtype_0` 	| Anzahl aller Bedingungen 								| Numeric | Summe über `condtype_0` pro `programnr` |
| `nrcondtype_1` 	| Anzahl Performance Criteria 							| Numeric | Summe über `condtype_1` pro `programnr` |
| `nrcondtype_2` 	| Anzahl Prior Actions 									| Numeric | Summe über `condtype_2` pro `programnr` |
| `nrcondtype_3` 	| Anzahl Structural Benchmarks 							| Numeric | Summe über `condtype_3` pro `programnr` |
| `nrcondtype_all` 	| Anzahl aller Bedingungen (synonym zu `nrcondtype_0`) 	| Numeric | `= nrcondtype_0` |
| `nrcondtype_pc` 	| Anzahl Performance Criteria (synonym) 				| Numeric | `= nrcondtype_1` |
| `nrcondtype_pa` 	| Anzahl Prior Actions (synonym) 						| Numeric | `= nrcondtype_2` |
| `nrcondtype_sb` 	| Anzahl Structural Benchmarks (synonym) 				| Numeric | `= nrcondtype_3` |
| `nrareaclass_X` 	| Anzahl Bedingungen in Policy-Area X 					| Numeric | Summe über `areaclass_X` pro `programnr` |
| `nrc_Xa_Y` 		| Anzahl Bedingungen vom Typ X in Area Y 				| Numeric | Summe über `c_Xa_Y` pro `programnr` |

#### 6.2 Durchschnittliche Bedingungen pro Quartal

| Variable 			| Beschreibung 										| Skalierung  | Berechnung |
|-------------------|---------------------------------------------------|-------------|-------------|
| `avgcondtype_0` 	| Durchschnittliche Anzahl aller Bedingungen 		| pro Quartal | `nrcondtype_0 / nrquarterssmpl` |
| `avgcondtype_1` 	| ⌀ Performance Criteria 							| pro Quartal | `nrcondtype_1 / nrquarterssmpl` |
| `avgcondtype_2` 	| ⌀ Prior Actions 									| pro Quartal | `nrcondtype_2 / nrquarterssmpl` |
| `avgcondtype_3` 	| ⌀ Structural Benchmarks 							| pro Quartal | `nrcondtype_3 / nrquarterssmpl` |
| `avg1condtype_X` 	| ⌀ Bedingungen (Skalierung 1: `nrquarters`) 		| pro Quartal | `nrcondtype_X / nrquarters` |
| `avg2condtype_X` 	| ⌀ Bedingungen (Skalierung 2: `nrquarterstest`) 	| pro Quartal | `nrcondtype_X / nrquarterstest` |
| `avg3condtype_X` 	| ⌀ Bedingungen (Skalierung 3: `nrquarterssmpl`) 	| pro Quartal | `nrcondtype_X / nrquarterssmpl` |

> **Hinweis**: `nrquarterssmpl` wird als **"theoretisch und empirisch angemessenste Skalierungsvariable"** bezeichnet (Zeile 488 in `txt2dta7.do`).

---

### 3.7 Scope-Variablen

#### 7.1 Scope nach Bedingungstyp

| Variable | Beschreibung | Berechnung | Typ |
|----------|--------------|-------------|-----|
| `scope_0` | Scope: Vielfalt der Policy-Areas (alle Bedingungen) | `egen rcount(nrc_0a_*)` | Numeric |
| `scope_1` | Scope: Performance Criteria | `egen rcount(nrc_1a_*)` | Numeric |
| `scope_2` | Scope: Prior Actions | `egen rcount(nrc_2a_*)` | Numeric |
| `scope_3` | Scope: Structural Benchmarks | `egen rcount(nrc_3a_*)` | Numeric |
| `scope_all` | Scope: Alle Bedingungen (synonym zu `scope_0`) | `= scope_0` | Numeric |
| `scope_pc` | Scope: Performance Criteria (synonym) | `= scope_1` | Numeric |
| `scope_pa` | Scope: Prior Actions (synonym) | `= scope_2` | Numeric |
| `scope_sb` | Scope: Structural Benchmarks (synonym) | `= scope_3` | Numeric |

> **Definition**: Scope misst die **Anzahl unterschiedlicher Policy-Areas**, in denen Bedingungen gestellt wurden (nicht die absolute Anzahl).

#### 7.2 Scope nach Arrangement-Typ

| Variable | Beschreibung | Berechnung |
|----------|--------------|-------------|
| `scopearr_0` | Scope: Alle Arrangements | `scope_all if nrarrtype_0>0` |
| `scopearr_1` | Scope: EFF-Programme | `scope_all if nrarrtype_1>0` |
| `scopearr_2` | Scope: PRGF-Programme | `scope_all if nrarrtype_2>0` |
| `scopearr_all` | Scope: Alle Arrangements (synonym) | `= scopearr_0` |
| `scopearr_eff` | Scope: EFF (synonym) | `= scopearr_1` |
| `scopearr_prgf` | Scope: PRGF (synonym) | `= scopearr_2` |

#### 7.3 Scope pro Quartal

| Variable | Beschreibung | Skalierung |
|----------|--------------|------------|
| `qrtscope_0` | Scope pro Quartal (alle Bedingungen) | `scope_0 / nrquarterssmpl` |
| `qrtscope_1` | Scope pro Quartal (Performance Criteria) | `scope_1 / nrquarterssmpl` |
| `qrtscope_2` | Scope pro Quartal (Prior Actions) | `scope_2 / nrquarterssmpl` |
| `qrtscope_3` | Scope pro Quartal (Structural Benchmarks) | `scope_3 / nrquarterssmpl` |
| `qrtscope_all` | Scope pro Quartal (synonym) | `= qrtscope_0` |
| `qrtscope_pc` | Scope pro Quartal (PC, synonym) | `= qrtscope_1` |
| `qrtscope_pa` | Scope pro Quartal (PA, synonym) | `= qrtscope_2` |
| `qrtscope_sb` | Scope pro Quartal (SB, synonym) | `= qrtscope_3` |
| `qrtscopearr_all` | Scope pro Quartal (alle Arrangements) | `= qrtscopearr_0` |
| `qrtscopearr_eff` | Scope pro Quartal (EFF) | `= qrtscopearr_1` |
| `qrtscopearr_prgf` | Scope pro Quartal (PRGF) | `= qrtscopearr_2` |

---

### 3.8 Arrangement-Typen

#### 8.1 Originale Arrangement-Typen (7 Kategorien)

| Numerischer Code | Label | Beschreibung |
|------------------|-------|--------------|
| `1` | Arrangement type: EFF | Extended Fund Facility |
| `2` | Arrangement type: ESAF | Enhanced Structural Adjustment Facility |
| `3` | Arrangement type: PRGF | Poverty Reduction and Growth Facility |
| `4` | Arrangement type: PRGF-EFF | Kombiniert PRGF und EFF |
| `5` | Arrangement type: PSI | Policy Support Instrument |
| `6` | Arrangement type: SAF | Structural Adjustment Facility |
| `7` | Arrangement type: SBA | Stand-By Arrangement |

#### 8.2 Aggregierte Arrangement-Typen (2 Kategorien)

| Variable | Beschreibung | Kodierung | Definition |
|----------|--------------|-----------|------------|
| `arrtype_1` | Dummy: EFF | Binary | `1` wenn EFF, *PRGF-EFF* oder SBA | Aggregiert in Zeile 204–207 |
| `arrtype_2` | Dummy: PRGF | Binary | `1` wenn ESAF, PRGF, *PRGF-EFF* oder SAF | |
| `arrtypedum` | Numerische Kodierung (aggregiert) | Numeric | `1` = EFF, `2` = PRGF | |
| `nrarrtype_1` | Anzahl EFF-Programme pro Land | Numeric | Summe über `arrtype_1` |
| `nrarrtype_2` | Anzahl PRGF-Programme pro Land | Numeric | Summe über `arrtype_2` |


> **Hinweis**: arrtype_4 (PRGF-EFF) wurde beiden Kategorien zugeordnet, um flexible Analysen (z.B. "Alle EFF-/PRGF-ähnliche Programme") zu ermöglichen. Daher muss in der Regressionsanalyse auf **Mulitkollinearität** geachtet werden! 
---

### 3.9 Zeitvariablen

| Variable | Beschreibung | Berechnung | Einheit |
|----------|--------------|-------------|--------|
| `nrdays` | Anzahl der Tage zwischen Start und Enddatum | `finalenddate - fstartdate` | Tage |
| `nrquarters` | Anzahl der Quartale (bis Enddatum) | `round(nrdays/90)` | Quartale |
| `nrquarterssmpl` | Anzahl der Quartale (bis letztes Testdatum im Sample) | `round(nrdayssmpl/90)` | Quartale |
| `nrquarterstest` | Anzahl der Quartale (bis letztes Testdatum) | `round(nrdaystest/90)` | Quartale |
| `nrdayssmpl` | Anzahl der Tage (Sample-Periode) | `fenddate - fstartdate` | Tage |
| `nrdaystest` | Anzahl der Tage (bis Testdatum) | `lasttestdate - fstartdate` | Tage |

> **Hinweis**:
> - `nrquarterstest` ist **nicht für alle Programme verfügbar** (z. B. Äthiopien 1992, Tschad 1994).
> - `nrquarterssmpl` verwendet das **letzte aufgezeichnete Testdatum** im Sample.
> - `nrquarters` geht **über die Sample-Periode hinaus** (Zeile 442–443).

---

### 3.10 Externe Daten

#### 10.1 WDI-Variablen (World Development Indicators)

| Originalname 			| Umbenannt in 	| Beschreibung 										| Label |
|-----------------------|---------------|---------------------------------------------------|-------|
| `NE_TRD_GNFS_ZS` 		| `Openness` 	| Trade (% of GDP) 									| `"Trade (% of GDP)"` |
| `NY_GDP_FCST_CD` 		| `nomGDPUSD` 	| GDP (current US$) 								| `"Gross value added at factor cost (current US$)"` |
| `NY_GDP_PCAP_KD` 		| `GDPpc` 		| GDP per capita (constant 2000 US$) 				| `"GDP per capita (constant 2000 US$)"` |
| `NY_GDP_MKTP_KD_ZG` 	| `GDPgrowth` 	| GDP growth (annual %) 							| `"GDP growth (annual %)"` |
| `NE_CON_GOVT_ZS` 		| `GGovExpGDP` 	| General government final consumption (% of GDP) 	| `"General government final consumption expenditure (% of GDP)"` |
| `FM_LBL_MQMY_GD_ZS` 	| `M2GDP` 		| Money and quasi money (M2) as % of GDP 			| `"Money and quasi money (M2) as % of GDP"` |
| `NE_RSB_GNFS_ZS` 		| `ExtBalGDP` 	| External balance on goods and services (% of GDP) | `"External balance on goods and services (% of GDP)"` |
| `BN_CAB_XOKA_GD_ZS` 	| `CABalGDP` 	| Current account balance (% of GDP) 				| `"Current account balance (% of GDP)"` |
| `DT_DOD_DIMF_CD` 		| `UseIMFCredit`| Use of IMF credit (DOD, current US$) 				| `"Use of IMF credit (DOD, current US$)"` |
| `DT_DOD_DSTC_CD` 		| `STDebt` 		| Short-term debt outstanding (DOD, current US$) 	| `"Short-term debt outstanding (DOD, current US$)"` |
| `DT_DOD_DLXF_CD` 		| `LTDebt` 		| Long-term debt (DOD, current US$) 				| `"Long-term debt (DOD, current US$)"` |
| `DT_TDS_DECT_GN_ZS` 	| `DebtServGNI` | Total debt service (% of GNI) 					| `"Total debt service (% of GNI)"` |
| `FR_INR_DPST` 		| `DIntRate` 	| Deposit interest rate (%) 						| `"Deposit interest rate (%)"` |
| `FR_INR_LEND` 		| `LIntRate` 	| Lending interest rate (%) 						| `"Lending interest rate (%)"` |
| `BN_RES_INCL_CD` 		| `DNetRes` 	| Changes in net reserves (BoP, current US$) 		| `"Changes in net reserves (BoP, current US$)"` |
| `FI_RES_TOTL_DT_ZS` 	| `ResXDebt` 	| Total reserves (% of external debt) 				| `"Total reserves (% of external debt)"` |
| `FI_RES_TOTL_MO` 		| `ResMimp` 	| Total reserves in months of imports 				| `"Total reserves in months of imports"` |
| `DT_DOD_DECT_GN_ZS` 	| `XDebtGNI` 	| External debt, total (% of GNI) 					| `"External debt, total (% of GNI)"` |
| `NE_GDI_FTOT_ZS` 		| `GFCFGDP` 	| Gross fixed capital formation (% of GDP) 			| `"Gross fixed capital formation (% of GDP)"` |

#### 10.2 Abgeleitete wirtschaftliche Variablen

| Variable | Beschreibung | Berechnung |
|----------|--------------|-------------|
| `shSTdebt` | Anteil der kurzfristigen Schulden | `100*STDebt/(STDebt+LTDebt)` |
| `UseIMFCredGDP` | Nutzung von IMF-Krediten (% des BIP) | `100*UseIMFCredit/nomGDPUSD` |
| `lnGDPpc` | Logarithmus des BIP pro Kopf | `log(GDPpc)` |
| `DNetResGDP` | Änderung der Netto-Reserven (% des BIP) | `100*DNetRes/nomGDPUSD` |
| `USaidGDP` | US-Hilfe (% des BIP) | `100*1000000*usaid/nomGDPUSD` |
| `DIntRateScaled` | Skalierter Einlagenzinssatz | `100*(DIntRate/(100+DIntRate))` |

#### 10.3 Politische Variablen (Polity IV)

| Variable | Beschreibung | Typ | Label |
|----------|--------------|-----|-------|
| `polity2` | Demokratie-Index (Polity IV) | Numeric | `"Democracy"` |
| `execrlc` | Politische Ausrichtung der Regierung | Categorical | `"Right - Left - Center - No information - No executive"` |
| `dateleg` | Monat der Präsidentschaftswahlen | Numeric | `"Month when presidential elections were held"` |
| `legelec` | Dummy: Legislativwahlen | Binary | `"Dummy for a legislative election"` |
| `exelec` | Dummy: Exekutivwahlen | Binary | (abgeleitet aus `execrlc`) |
| `govfrac` | Wahrscheinlichkeit für Koalitionsregierung | Numeric | `"Probability of picking deputies from different parties in government"` |
| `elec` | Wahljahr-Dummy (t-1) | Binary | `legelec` oder `exelec` |
| `elec_l` | Wahljahr-Dummy (t-1, lagged) | Binary | `l.elec` |
| `legelec_l` | Legislativwahl-Dummy (t-1, lagged) | Binary | `l.legelec` |
| `exelec_l` | Exekutivwahl-Dummy (t-1, lagged) | Binary | `l.exelec` |
| `leftgov` | Linksregierungs-Dummy | Binary | `execrlcdum4` (aus `tabulate execrlc, gen(execrlcdum)`) |

#### 10.4 Governance-Variablen (ICRG)

| Variable | Beschreibung | Label |
|----------|--------------|-------|
| `gov_stab` | Regierungsstabilität | `"Government stability"` |
| `prs` 	| Korruption | `"Corruption"` |
| `law_ord` | Recht und Ordnung | `"Law and order"` |
| `inv_prof` | Investitionsprofil | `"Investment profile"` |
| `bur_qual` | Bürokratiequalität | `"Bureaucracy quality"` |
| `soc_cond` | Soziale Bedingungen | `"Social conditions"` |
| `eth_ten` | Ethnische Spannungen | `"Ethnic tension"` |

#### 10.5 UN-Sicherheitsrat-Variablen

| Variable | Beschreibung | Label | Berechnung |
|----------|--------------|-------|-------------|
| `unsc` 	| Temporäres Mitglied im UN-Sicherheitsrat | `"Temporary member of the UN Security Council"` | MONA |
| `unsc3` 	| UNSC-Mitgliedschaft (inkl. t-1) | `"Temporary member of the UN Security Council"` | `(unsc==1 | unsc_t0==1)` |
| `unsc_t0` | UNSC-Mitgliedschaft (t-1) | – | `f.unsc` (forward) |
| `unsc_t1` | UNSC-Mitgliedschaft (t+1) | – | `(unsc[_n]==1 & unsc[_n+1]==1)` |
| `unsc_t2` | UNSC-Mitgliedschaft (t-1) | – | `(unsc[_n]==1 & unsc[_n-1]==1)` |
| `unsc_t3` | UNSC-Mitgliedschaft (t-1, nicht t) | – | `(unsc[_n-1]==1 & unsc[_n]~=1)` |
| `unsc_t4` | UNSC-Mitgliedschaft (t-2, nicht t-1) | – | `(unsc[_n-2]==1 & unsc[_n-1]~=1)` |

#### 10.6 Globalisierungsvariablen (KOF)

| Variable | Beschreibung | Label |
|----------|--------------|-------|
| `a` 		| Wirtschaftliche Globalisierung | `"Economic globalization"` |
| `index` 	| Gesamtglobalisierungsindex | `"Overall globalization index"` |

#### 10.7 Weitere Variablen

| Variable | Beschreibung | Label |
|----------|--------------|-------|
| `trade_gdp` | Handel (% des BIP) | `"Trade"` |
| `school_p` | Primarschul-einschreibung | `"Education"` |
| `school_s` | Sekundarschul-einschreibung | – |
| `school_t` | Tertiäre Schulbildung | – |
| `usaid` | US-Hilfe (in US$) | `"US Aid (in current US$)"` |

---

### 3.11 Dummy-Variablen

#### 11.1 Dummy-Variablen für Bedingungstypen

| Variable | Beschreibung | Generierung |
|----------|--------------|-------------|
| `condtype_1` | Dummy: Performance Criteria | `tabulate condtype, gen(condtype_)` |
| `condtype_2` | Dummy: Prior Action | |
| `condtype_3` | Dummy: Structural Benchmark | |
| `condtype_4` | Dummy: Struct.Benchmark and Prior Action | |
| `condtype_0` | Summe aller Bedingungstypen | `condtype_1 + condtype_2 + condtype_3 + condtype_4` |

#### 11.2 Dummy-Variablen für Policy-Areas

| Variable | Beschreibung | Generierung |
|----------|--------------|-------------|
| `areaclass_1` – `areaclass_20` | Dummy für Policy-Area 1–20 | `tabulate areaclass, gen(areaclass_)` |
| `areaclass_0` | Summe aller Policy-Areas | Summe aller `areaclass_X` |

#### 11.3 Dummy-Variablen für Arrangement-Typen

| Variable | Beschreibung | Generierung |
|----------|--------------|-------------|
| `arrtype_1` – `arrtype_7` | Dummy für Arrangement-Typ 1–7 | `tabulate arrtype, gen(arrtype_)` |
| `arrtype_0` | Summe aller Arrangement-Typen | `((arrtype_1==1)+...+(arrtype_7==1))>0` |

> **Aggregration**: `arrtype_3`–`arrtype_7` werden gelöscht und zu `arrtype_1` (EFF) und `arrtype_2` (PRGF) aggregiert.

#### 11.4 Dummy-Variablen für Review-Status

| Variable | Beschreibung | Generierung |
|----------|--------------|-------------|
| `revstatus_1` – `revstatus_11` | Dummy für Review-Status 1–11 | `tabulate revstatus, gen(revstatus_)` |
| `revstatus_0` | Summe aller Review-Status | Summe aller `revstatus_X` |

---

---

## 4. Methodische Hinweise

### 4.1 Arrangement-Typen
- **Ursprünglich 7 Typen**: `EFF`, `ESAF`, `PRGF`, `PRGF-EFF`, `PSI`, `SAF`, `SBA`.
- **Aggregiert zu 2 Typen** für die Analyse:
  - `arrtype_1` = EFF + PRGF-EFF + SBA
  - `arrtype_2` = ESAF + PRGF + PRGF-EFF + SAF
  - `PSI` wird **aus der Analyse ausgeschlossen** (Zeile 204–207).

### 4.2 Bedingungstypen
- **Ursprünglich 4 Typen**:
  - Quantitative Performance Criteria
  - Structural Performance Criteria
  - Structural Benchmark
  - Prior Action
  - Struct.Benchmark and Prior Action
- **Aggregiert zu 3 Typen** für die Analyse:
  - `condtype_1` = Performance Criteria (quantitativ + strukturell)
  - `condtype_2` = Prior Action
  - `condtype_3` = Structural Benchmark

### 4.3 Scope-Definition
- **Scope** misst die **Anzahl unterschiedlicher Policy-Areas**, in denen Bedingungen gestellt wurden.
- Beispiel: Wenn ein Programm Bedingungen in den Areas "Fiscal Policy", "Monetary Policy" und "Trade" hat, ist `scope_all = 3`.
- **Nicht zu verwechseln** mit der absoluten Anzahl der Bedingungen (`nrcondtype_*`).

### 4.4 Skalierungsvariable
- `nrquarterssmpl` wird als **"theoretisch und empirisch angemessenste Skalierungsvariable"** für Durchschnittsberechnungen verwendet (Zeile 488 in `txt2dta7.do`).
- Alternative Skalierungen:
  - `nrquarters`: Anzahl Quartale bis zum offiziellen Enddatum (kann Sample-Periode überschreiten).
  - `nrquarterstest`: Anzahl Quartale bis zum letzten Testdatum (**nicht für alle Programme verfügbar**).

---

## 5. Datenpipeline

### Schritt-für-Schritt-Anleitung zur Replikation

```
1. DATENVORBEREITUNG
   ├── MergeActionImplementation.do
   │   ├── Input: Action03.txt, Implementation03.txt
   │   └── Output: ActionImplementation.dta, Data Structural 1993-2001.dta
   
2. HAUPTVERARBEITUNG
   ├── txt2dta7.do
   │   ├── Input: MONA/Data Structural 1993-2001.txt, MONA/Data Performance 1993-2001.txt
   │   ├── Input: MONA/Data Structural 2001-2008.txt, MONA/Data Performance 2001-2008.txt
   │   ├── Input: country_codes.csv, Desc2AreaClass.csv
   │   ├── Merge: WDI-Daten, Polity IV, DPI, UN-Voting, etc.
   │   └── Output: Data IMF Conditions Country-Arrangements at Approval.dta
   │               conditionality database.dta
   
3. REPLIKATION DER STUDIE
   ├── Dreher_Sturm_Vreeland_JCR.do
   │   ├── Input: Dreher_Sturm_Vreeland_JCR.dta
   │   └── Output: JCR_DSV_Table1–5 (Tabellen der Studie)
```

### Wichtige Input-Dateien
| Datei | Beschreibung | Pfad |
|-------|--------------|------|
| `country_codes.csv` | Ländercodes (WDI) | `JCR-MONA_Data/` |
| `Desc2AreaClass.csv` | Manuelle Kodierung der Policy-Areas | `JCR-MONA_Data/` |
| `MONA/Data Structural 1993-2001.txt` | Rohdaten (Strukturelle Bedingungen) | `JCR-MONA_Data/MONA/` |
| `MONA/Data Performance 1993-2001.txt` | Rohdaten (Performance-Bedingungen) | `JCR-MONA_Data/MONA/` |
| `MONA/Data Structural 2001-2008.txt` | Rohdaten (Strukturelle Bedingungen, 2001–2008) | `JCR-MONA_Data/MONA/` |
| `MONA/Data Performance 2001-2008.txt` | Rohdaten (Performance-Bedingungen, 2001–2008) | `JCR-MONA_Data/MONA/` |
| `Other sources/wdi2008/variables/*.dta` | WDI-Daten | `Other sources/wdi2008/variables/` |
| `Other sources/p4v2008.dta` | Polity IV | `Other sources/` |
| `Other sources/dpi2006_rev42008.dta` | Database of Political Institutions | `Other sources/` |

---

## 6. Fehlende Werte & Korrekturen

### 6.1 Manuelle Korrekturen in den Daten

#### Ländernamen
Die folgenden Ländernamen werden an `country_codes.csv` angepasst (Zeile 227–239 in `txt2dta7.do`):
```
"ethiopia (new)" → "ethiopia"
"afghanistan,islamic republic of" → "afghanistan"
"congo, democratic republic of" → "democratic republic of the congo"
"congo, republic of" → "congo"
"gambia, the" → "gambia"
"kyrgyz republic" → "kyrgyzstan"
"lao people's dem. rep." → "lao people's democratic republic"
"macedonia (fyr)" → "macedonia"
"moldova" → "republic of moldova"
"slovak republic" → "slovakia"
"tanzania" → "united republic of tanzania"
"venezuela" → "venezuela (bolivarian republic of)"
"vietnam" → "viet nam"
```

#### Testdatum-Korrekturen
- `testdate == "Continuous"` wird aus 15 Varianten standardisiert (Zeile 127–131):
  ```
  "Conitnuous", "Cont", "Cont.", "Conti", "Conti.", "Contin", "Contin.", "Continu", "Continue", 
  "Continuou", "continuous", "3 months after end of each quarter"
  ```

#### Review-Status-Korrekturen
- Tippfehler in `revstatus` werden bereinigt (Zeile 134–149):
  ```
  "MMOD" → "MOD"
  "Mod" → "MOD"
  "MMod" → "MOD"
  "AC", "PA", "PC", "SB", "n.a." → "NA"
  ```
- **Neue Labels** für bessere Lesbarkeit (Zeile 141–151):
  ```
  "M" → "Met (M)"
  "NM" → "Not Met (NM)"
  "DL" → "Delayed (DL)"
  "W" → "Waived (W)"
  "PM" → "Partly Met (PM)"
  "CAN" → "Cancelled (CAN)"
  "MOD" → "Modified (MOD)"
  "MD" → "Met With Delay (MD)"
  "NMod" → "??? (NMOD)"
  "WM" → "??? (WM)"
  ```

### 6.2 Fehlende Daten

| Variable | Problem | Lösung |
|----------|---------|--------|
| `nrquarterstest` | Nicht für alle Programme verfügbar (z. B. Äthiopien 1992, Tschad 1994) | `nrquarterssmpl` als Alternative verwenden |
| `imf_*` | Fehlende Werte | Mit `0` aufgefüllt (Zeile 749–751) |
| `unsc3` | Fehlende Werte für einige Länder | Manuelle Korrektur (Zeile 738–741) |
| `school_p`, `school_s`, `school_t` | Lücken in Zeitreihen | Linear interpoliert (Zeile 744–746) |

### 6.3 Besondere Fälle

- **Senegal 1995**: Zwei Programme im gleichen Jahr → Zweites Programm wird auf 1996 verschoben (Zeile 555).
- **Uganda 2006**: Zwei Programme im gleichen Jahr → Zweites Programm (15.12.2006) wird auf 2007 verschoben (Zeile 557).
- **Arrangement-Typen**: In 17 Fällen ist `arrtype` **nicht konstant innerhalb eines Programms** (z. B. CAF 1998 als ESAF und PRGF kodiert).

---

## 7. Dateien & Verzeichnisstruktur

### Verzeichnisbaum
```
JCR Replication/
├── JCR_MONA_usage/
│   ├── Dreher_Sturm_Vreeland_JCR.do          # Hauptskript für Replikation
│   ├── Dreher_Sturm_Vreeland_JCR.dta          # Fertiger Datensatz für Regressionen
│   ├── Dreher_Sturm_Vreeland_JCR.pdf          # Studie
│   ├── Dreher_Sturm_Vreeland_JCR_Supplemental_Appendix.pdf
│   ├── README_JCR_Original.txt                # Replikationsanleitung
│   ├── JCR-MONA_Data/                         # Hauptdatenverzeichnis
│   │   ├── MergeActionImplementation.do      # 1. Schritt: Action + Implementation
│   │   ├── txt2dta7.do                        # 2. Schritt: Hauptverarbeitung
│   │   ├── Action.txt, Action03.txt            # Rohdaten (Action)
│   │   ├── Implementation.txt, Implementation03.txt
│   │   ├── Data Structural 1993-2001.txt      # MONA-Daten (Struktur)
│   │   ├── Data Structural 2001-2008.txt
│   │   ├── Data Performance 1993-2001.txt     # MONA-Daten (Performance)
│   │   ├── Data Performance 2001-2008.txt
│   │   ├── country_codes.csv                  # Ländercodes
│   │   ├── Desc2AreaClass.csv                 # Manuelle Areakodierung
│   │   └── MONA/                              # Zwischenoutputs
│   │       ├── Data MONA.dta
│   │       ├── Data MONA.txt
│   │       └── Data MONA.csv
│   └── Other sources/                         # Externe Daten
│       ├── wdi2008/                          # World Development Indicators
│       ├── p4v2008.dta                       # Polity IV
│       ├── dpi2006_rev42008.dta              # Database of Political Institutions
│       ├── dpi elections.dta
│       └── ...
└── contact-info_Vreeland-00026.txt
```

---

## 📌 Zusammenfassung der zentralen Variablengruppen

| **Gruppe** | **Zweck** | **Wichtige Variablen** |
|------------|-----------|-------------------------|
| **Identifikation** | Länder- und Programm-ID | `countryname`, `wdicode`, `programnr`, `arrtype` |
| **Zeit** | Datumsangaben | `approvaldate`, `enddate`, `nrquarters`, `nrquarterssmpl` |
| **Bedingungen** | Typ und Status | `condtype`, `areaclass`, `revstatus`, `nrcondtype_*` |
| **Scope** | Vielfalt der Policy-Areas | `scope_*`, `qrtscope_*`, `scopearr_*` |
| **Wirtschaft** | Makroökonomische Daten | `GDPpc`, `Openness`, `DebtServGNI`, `UseIMFCredit` |
| **Politik** | Institutionen & Wahlen | `polity2`, `legelec_l`, `unsc3`, `leftgov` |
| **Governance** | Qualität der Institutionen | `gov_stab`, `prs`, `law_ord`, `bur_qual` |

---

---

## 📚 Literatur

- Dreher, Axel; Sturm, Jan-Egbert; Vreeland, James Raymond. "Politics and IMF Conditionality." *Journal of Conflict Resolution*, Vol. 53, No. 4, 2009, pp. 526–551.
- [JCR Supplemental Appendix](JCR_MONA_usage/Dreher_Sturm_Vreeland_JCR_Supplemental_Appendix.pdf) – Enthält detaillierte methodische Erklärungen.

---

**Hinweis**: Dieses Codebook wurde automatisch aus `txt2dta7.do` extrahiert. Für weitere Details konsultieren Sie die Originalskripte und die Studie selbst.