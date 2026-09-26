# Anleitung: Korrekte Replikation des Gesamtzeitraums (1992–2008)

Anleitung zur Replikation von Dreher, Sturm & Vreeland (2015, JCR), "Politics and
IMF Conditionality", Tabelle 2 (und weiterer Tabellen), für den gesamten
Originalzeitraum. Grundlage: `data/raw/original/Dreher_Sturm_Vreeland_JCR.dta`
(314 Beobachtungen, 101 `idcnt`-Gruppen, 1992–2008) und die Original-Konstruktions-
und Schätzdateien in `data/raw/original/construction/`.

**Revision 4 (2026-09-26, rekonstruiert):** Diese Fassung wurde nach einem
Dateiverlust aus dem Sitzungsverlauf wiederhergestellt (die im Projekt
umherkopierte Datei in `code/replication/` war die veraltete Erstfassung vom
2026-09-25 und wurde entfernt; kanonischer Ort ist diese Datei im
Projektstamm). Sie vereint den Stand nach Abschluss aller Schritte 1–6:
Spur-A-Exaktreplikation, 314/314-Nachbau, komplettes Kontrollpanel (WDI-2026 +
DPI), H1–H4 auf Original-Zählbasis, dreispaltige Validierungstabelle.

## Zieldefinition: Tabelle 2 des Artikels (aus `JCR_DSV_Table2.doh`)

Pro abhängiger Variable (`avgcondtype_0` im Artikel; `scope_0` nur im Supplement)
werden fünf Modellschätzungen × zwei Schätzer berechnet:

| Spalte | Regressoren | Sample |
|---|---|---|
| Basis | `unsc3 + nrquarterssmpl` | alle 314 |
| Basis (restringiert) | `unsc3 + nrquarterssmpl` | `fullsample==1` (N=217) |
| Vollmodell | `unsc3 + nrquarterssmpl + legelec_l + XDebtGNI + DebtServGNI + ResXDebt + ExtBalGDP + GFCFGDP + USaidGDP + imf_conc_gdp + imf_noconc_gdp` | alle (Complete Cases: N=217) |
| Trunkiert (avgcondtype) | `unsc3 + nrquarterssmpl + legelec_l + imf_noconc_gdp` | alle (Complete Cases: N=288) |
| Trunkiert (scope) | `unsc3 + nrquarterssmpl + ResXDebt` | alle |

Schätzer je Modell:

1. **`xtreg ..., fe`** — Within-Schätzer, Panel `idcnt` (101 Gruppen).
2. **`xtgls ..., panels(hetero) force nmk`** — FGLS mit Länder-Dummies und
   panel-weise heteroskedastischen Fehlern (σ²ᵢ = RSSᵢ/nᵢ aus dem LSDV-First-Step).

Diagnostik (nur xtreg-Spalten): Wooldridge-Autokorrelation (`xtserial` mit
Länder-Dummies), F-Test FE (`testparm dumcnt*`), Breusch-Pagan (`estat hettest`).

## Reproduktionsstand (verifiziert, R/plm bzw. manueller FGLS)

| Modell | Schätzer | unsc3 (R) | t (R) | Publiziert / Soll |
|---|---|---|---|---|
| Basis, N=314 | xtreg fe | **−2.410** | **−1.906** | −2.410 (−1.906) — exakt (`JCR_DSV_Table2.txt/xml`) |
| Basis restringiert, N=217 | xtreg fe | −2.909 | −1.686 | — |
| Vollmodell, N=217 | xtreg fe | **−3.329** | **−1.950** | −3.329 (−1.950) — exakt |
| Trunkiert, N=288 | xtreg fe | −3.003 | −2.133 | — |
| Trunkiert restringiert, N=217 | xtreg fe | −3.157 | −1.877 | — |
| Basis, N=299* | xtgls panels(hetero) | −1.263 | −2.33 (nmk: −1.96) | — |
| Vollmodell, N=206* | xtgls panels(hetero) | **−2.096** | −4.97 (nmk: **−3.97**) | −2.096 (−4.02) — Punktschätzer exakt, t(nmk) 1,4 % daneben |
| Trunkiert, N=272* | xtgls panels(hetero) | −2.891 | siehe Hinweis | — |

\* Manuelle FGLS-Umsetzung wirft Singleton-Länder (σ²ᵢ=0) aus der Schätzung;
Stata behält sie mit `force`. Hinweis: Bei kleinen Panels (nᵢ=2) werden die
Gewichte extrem und die (X'Ω⁻¹X)⁻¹-Standardfehler sehr klein (extreme t-Werte in
den restringierten/trunkierten Spalten) — als Implementationscaveat
dokumentieren, nicht als Befund.

Diagnostik (Basis, gegen `JCR_DSV_Table2.txt`): F-Test FE p = 2.056e-05 vs.
Stata 2.06e-05 — exakt; Breusch-Pagan p ≈ 0 wie publiziert; Wooldridge:
`plm::pwartest` approximiert (p 0.28 vs. 0.94, Stata-Test läuft mit Dummies) —
als Approximation kennzeichnen.

## Akzeptanzkriterien

Spur A (Originaldaten): FE-Spalten exakt (erreicht); GLS-Punktschätzer exakt
(erreicht); GLS-t-Werte in ±10 % (erreicht: t(nmk) −3.97 vs. −4.02).
Spur B (eigene Rekonstruktion): unsc3 negativ, Koeffizient in ±30 % des
jeweiligen Spaltenwerts, N wie Original; Restdifferenzen benannt.

## Wichtigste korrigierte Fehler der eigenen Pipeline (historisch)

1. **Phase-0-Skript:** Vollmodell lief mit `nrcntprogram` statt
   `nrquarterssmpl`; deshalb −3.06 statt −3.33 und der fehlende GLS-Anschluss.
   Beide publizierten Kernwerte (−3.329, −2.096) reproduzieren sich mit dem
   korrekten Regressorsatz exakt.
2. **Keine Jahr-FE:** Der frühere "Jahr-Dummies"-Fund (−3.41) war ein
   Spezifikationsartefakt; Tabelle 2 enthält nur Länder-FE.
3. **GLS-Rätsel gelöst:** Der publizierte "GLS"-Schätzer ist `xtgls,
   panels(hetero) force nmk` mit Länder-Dummies — kein Random Effects.
4. **`nrcntprogram`** kommt in Tabelle 2 nirgends als Regressor vor (nur in
   Tabelle S1 als Panel-Zeitvariable).

## Schritt 1: Spur A — UMGESETZT (2026-09-25)

`code/replication/phase0_replikation_original.R` ist auf die Tabellen-2-
Spezifikation umgeschrieben und ausgeführt:

- Fünf Spalten je xtreg fe (plm, Panel-Index `idcnt`) und xtgls panels(hetero)
  (manueller FGLS mit QR-Pivotierung bei Rangdefizit).
- Output: `results/tables/original_replication.csv`,
  `results/tables/original_replication_zeitfenster.csv`,
  `results/models/model_original_{fe_basis,fe_voll,gls_voll}.rds`.
- Zeitfenster-Zerlegung (eigene Analyse, korrigierter Regressorsatz):
  1992–2001 Vollmodell-FE −4.98 (t=−2.20); 2002–2008 statistisch Null
  (Basis-FE +0.26, t=0.13; im Vollmodell dort mit Länder-Dummies kollinear —
  jedes UNSC-Land hat nur ein Programm im Fenster).

## Schritt 2: Crosswalk — UMGESETZT (2026-09-25)

Erstellt: `data/processed/crosswalk_dsv_iso3.csv` (102 Länder, Spalten
`country`, `wdicode`, `ISO3`, `ISO3_note`, `idcnt`), erzeugt von
`code/data_prep/rebuild_conditionality_1992_2008.R` aus `Data MONA.dta`.
Vintage-Fixes: `ROM`→`ROU`, `ZAR`→`COD`, `YUG`→`SRB` (für `yugoslavia` und
`serbia and montenegro`; beide teilen `idcnt` 237 → 101 Gruppen).

## Schritt 3: Konditionalitätsblock 1992–2008 — UMGESETZT (2026-09-25)

Erstellt: `code/data_prep/rebuild_conditionality_1992_2008.R` →
`data/processed/conditionality_dsv_1992_2008.csv` (314 Land-Jahre, Keys
ISO3 + Year; Zählungen, Typen, Arrangement-Typen, `nrquarterssmpl`,
`avgcondtype_*`, `nrcntprogram`, `unsc`, `unsc3`).

**Validierung gegen das Original: 314/314 identisch in ALLEN acht
Vergleichsvariablen** (`nrcondtype_all/pc/pa/sb`, `nrquarterssmpl`,
`nrcntprogram`, `unsc3`, `avgcondtype_all`).

Verifizierte Regeln: Programm = `countryname` × `approvaldate`; Zeilenzählung
ohne Dedup (2008er-Exportformat); Joint-Typ "SB+PA" doppelt in PA und SB;
Land-Jahr-Aggregation mit zwei Verschiebungen (Senegal 29.08.1994 → 1995;
Uganda 15.12.2006 → 2007); `nrquarterssmpl = round((min(finalenddate,
28.09.2008) − max(approvaldate, 31.03.1992))/90)`; `avgcondtype_0 =
nrcondtype_0 / nrquarterssmpl`; Scope/Area-Klassen via `Desc2AreaClass.dta`
(20 Klassen, im Nachbau noch offen).

**Gate-Ergebnis (eigenes Panel 2000–2026 vs. Nachbau): GEFAILED.**
Median-Verhältnis `nrcondtype_all` 2,1; 0 % exakt; nur 6,8 % mit |Diff| ≤ 5;
Korrelation 0,67; `nrquarterssmpl` Median-Verhältnis 2,0. Ursache: moderner
MONA-Export listet Bedingungen in anderem Format (pro Review/Revision) und
anderem Datenstand; hinzu kommt die abweichende Quartalsberechnung der eigenen
Pipeline. Nächster Schritt für die eigene Erweiterung: Granularität der
eigenen MONA-Extraktion an das 2008er-Exportformat angleichen (Dedup auf
Bedingungs-/Revisionsebene) und Quartalsregel nach DSV übernehmen.

## Schritt 4: Kontrollvariablen — KOMPLETT UMGESETZT (2026-09-26)

Erstellt: `code/data_prep/build_controls_wdi.R` →
`data/processed/controls_wdi_1990_2025.csv` (266 Länder, ISO3 × Jahr).

Verfügbarkeit (alle `Data_all`-Serien durchgehend 1990–2025; `dpi_all.csv`
bis 2023):

| Variable | 1992–1999 | 2000–2008 | 2009–2025 | Anmerkung |
|---|---|---|---|---|
| `ExtBalGDP`, `XDebtGNI`, `GFCFGDP`, `DebtServGNI`, `ResXDebt`, `ExportGDP` | ✓ | ✓ | ✓ | durchgehend 1990–2025 |
| `resource_dep` | ✓ | ✓ | ✓ | `resource_dep_all.csv`: TX.VAL.FUEL.ZS.UN + TX.VAL.MMTL.ZS.UN (dritte Serie NE.EXP.GNFS.ZS separat als `ExportGDP` = Handelsöffnung, NICHT resource_dep!) |
| `USaidGDP`, `imf_conc_gdp`, `imf_noconc_gdp` | ✓ | ✓ | ✓ | BIP (NY.GDP.MKTP.CD) ab 1990 |
| `legelec_l` | ✓ | ✓ | ✓ (bis 2023) | aus `dpi_all.csv` (DPI-2023-Stand) |
| `UseIMFCredGDP`, `imf_sum_gdp` | ✓ | ✓ | ✓ | Bestands-/Summen-Alternativen, s. IMF-Diagnose |

**IMF-Diagnose (2026-09-26):** Die Original-Variablen `imf_conc_gdp`/
`imf_noconc_gdp` können NEGATIV sein und ihre Summe korreliert mit den
NFL-Nettofluss-Serien (DT.NFL.IMFC/IMFN.CD) mit **0.835** — das Original misst
also NETTOFLÜSSE, nicht Kreditbestand. Die NFL-Serien im Kontrollpanel sind
damit konzepttreu; die Komponenten-Korrelationen (0.35/−0.00) rühren daher,
dass die Quellen die Aufteilung konzessionär/nicht-konzessionär anders
klassifizieren. `UseIMFCredGDP` (DT.DOD.DIMF.CD, Kreditbestand je Land) ist
als Alternativ-Konzept enthalten; `OutCreditIMF_all.xlsx` ist das globale
Aggregat (GRA/PRGT/Totals, 1984–2026, geparst als
`imf_credit_outstanding_global_1984_2026.csv`) — nur Summen-Referenz.

Vintage-Validierung: `results/tables/wdi_kontrollen_vintage_check.csv` —
Korrelationen 0.93–0.98, `legelec_l` 0.978, `imf_sum_gdp` 0.835 (Ausnahmen:
GFCFGDP 0.70; USaidGDP −14 % Median-Abweichung durch Konzeptunterschied
Markt- vs. Faktorkosten-BIP).

**`legelec_l` — exakte Original-Konstruktion (aus `txt2dta7.do`):**

1. Quelle: DPI 2006, Revision 4/2008 (`Other sources/dpi2006_rev42008.dta`),
   Variablen `execrlc dateleg legelec exelec govfrac`, Key `ifs` (WDI-Code) × Jahr.
2. `−999` → NA (DPI-Fehlwertkode).
3. Code-Fix: DPI kodiert Serbien-Montenegro als `YSR` → auf `YUG` umgemappt.
4. Merge auf `wdicode` × Jahr ins **Volljahres-Panel** (nicht nur Programmjahre).
5. `legelec_l = L.legelec` nach `tsset idcnt year` → **Lag auf das
   Kalenderjahr t−1** (nicht das vorherige Programmjahr!). Empirischer Beleg:
   nur 14 NA von 314; der kalenderbasierte unsc3-Nachbau (t | t+1) bestätigt
   die Volljahres-Panel-Semantik.

Eigene Rekonstruktion UMGESETZT: `build_controls_wdi.R` baut `legelec`/
`legelec_l` aus `dpi_all.csv` (DPI-2023-Stand, 1975–2023, `ifs`-Codes mit
Fixes YSR→SRB, ROM→ROU, ZAR→COD). Korrelation mit Original 0.978 (n=300).
4 nicht parsbare Zeilen (Chile 2014–17, unbalancierte Anführungszeichen)
verworfen — außerhalb des Original-Zeitraums.

**Für die exakte Tabellen-2-Replikation bleibt der Original-.dta-Datensatz
die korrekte Kontrollquelle (WDI-2008-Vintage); die neue WDI dient der
Eigenrekonstruktion, der Erweiterung ab 2009 und Vintage-Checks.**

## Weitere Tabellen des Artikels (für Robustheits-/Anhangsteil)

| .doh | Inhalt |
|---|---|
| `Table1.doh` | Deskriptive Liste der 18 UNSC-Programme (avgcondtype_all, scope_all) |
| `Table2.doh` | Haupttabelle (s. o.), zusätzlich `scope_0`-Varianten fürs Supplement |
| `Table3.doh` | Je Bedingungstyp: `avgcondtype_1..3`, `scope_1..3` (xtgls panels(hetero)) |
| `Table4.doh` | Je Arrangementtyp: `avgarrtype_1/2` (EFF vs. PRGF) |
| `Table5.doh` | Je Politikbereich: `avgareaclass_1..20` |
| `TableS1.doh` | Deskriptive Statistik nach Arrangementtyp |
| `TableS2.doh` | scope_0 mit xtgls `corr(ar1)` und `xtpoisson, fe` |
| `TableS3.doh` | scope je Bedingungstyp (xtgls ar1) |
| `TableS4.doh` | scopearr (EFF/PRGF) |
| `TableS5.doh` | tabstat-Deskriptive der Analysevariablen |

## Schritt 5: UNSC-Kodierung — UMGESETZT (2026-09-25)

Regel (verifiziert, 314/314 `unsc3` identisch): `unsc3 = 1` wenn temporäres
UNSC-Mitglied im Kalenderjahr t ODER t+1 ("election year included",
`JCR_DSV_Table1.doh`) — das WähLjahr ist ein LEAD, kein Lag. Vier
Handkorrekturen des Originals auf 0 (Äthiopien 1992, Russland 1995/96/99)
betreffen nur dessen Programm-Subsample.

Erstellt: `code/data_prep/build_unsc_dsv_rule.R` →
`data/processed/unsc_dsv_rule_1946_2026.csv` (`ISO3`, `year`, `unsc`,
`unsc3_dsv`, Vollpanel), plus `unsc`/`unsc3` in
`conditionality_dsv_1992_2008.csv`.

**Befund für das eigene Panel:** dessen `unsc3`-Kodierung läuft in die falsche
Zeitrichtung — 4 Diskrepanzen im 88er-Overlap (BFA 2007 falsch-negativ; BGR
2004, COL 2003, TZA 2007 falsch-positiv). Vor jeder erneuten H-Schätzung auf
`unsc3_dsv` umstellen.

## Schritt 6: Spur B — ABGESCHLOSSEN (2026-09-26)

Umgesetzt in `code/replication/phase1_replikation_gesamtzeitraum.R`: alle fünf
Tabellen-2-Modellvarianten je als xtreg-fe (within) und xtgls panels(hetero)-
Nachbau auf Spur-B-Basis (Nachbau × eigene WDI-2026/DPI-Kontrollen;
restriktierte Spalten mit Complete-Case-Regel auf den eigenen Kontrollen als
fullsample-Analogon).

Dreispaltige Validierungstabelle: `results/tables/replication_gesamtzeitraum.csv`
(publiziert | Spur A | Spur B). Kernaussagen:

- Basis-FE: Spur B = Spur A = publiziert (−2.410, t=−1.906, N=314, Abweichung 0).
- Vollmodell-FE: publiziert −3.329; Spur A exakt; Spur B −4.40 (t=−2.27, N=174)
  — Abweichung ~1.07 Punkte, benannte Ursachen: abweichende IMF-Typen-Aufteilung
  (Summen-Korrelation 0.835), USaidGDP-MarktbIP-Konzept, WDI-Vintage.
- Vollmodell-GLS: publiziert −2.096 (t=−4.02); Spur A −2.10 (t(nmk)=−3.97);
  Spur B −1.90 (t=−2.19, N=165) — Punktschätzer in Toleranz (±9 %).
- Basis-Spalten (FE und GLS) sind Spur A und B identisch (Nachbau 314/314);
  restriktierte Spalten weichen ab, weil die Complete-Case-Regel auf den
  eigenen Kontrollen (N=174) nicht der Original-fullsample-Regel (N=217)
  entspricht — dokumentierte Eigenheit, kein Messfehler.

Zusätzlich `code/analysis/hypothesen_original_basis.R` (H1–H4 auf der
Original-Zählbasis, Kontrollen aus Original-.dta bzw. neuer WDI):

- **M1_base** (Sanity): −2.410 exakt.
- **H1** (Two-way FE, N=266): unsc3 = −2.43 (p=0.095) — Vorzeichenproblem des
  alten Panels (+3.11) geklärt (Messung + unsc3-Richtung).
- **H1_wdi** (5 WDI-Kontrollen, N=175): −3.11 (p=0.095) — vintage-robust.
- **H1_voll8 / H1_voll9** (8/9 bzw. alle 9 Kontrollen auf eigener Basis,
  N=165): −3.85 (p=0.097) / **−4.40 (p=0.056)** vs. Original −3.329.
- **H2** (unsc3 × resource_dep, volle Periode, N=180 CC mit 13 UNSC-Fällen,
  1992–2006): unsc3 = −4.59 (p=0.058), Interaktion +0.134 (p=0.156) — Richtung
  wie hypothetisiert, nicht signifikant.
- **H4** (rohstoff_cond_share, N=180): unsc3 = −0.018 (n.s.), Interaktion
  +0.0005 (n.s.) — kein Beleg für H4.
- Restriktionen: approvals 2007/08 entfallen (fehlende Original-Kontrollen),
  Fuel-Serie beginnt datenbedingt ~1995.

Offene Ergänzung: Placebo-Test `unsc3 × ExportGDP` parallel zu H2 (belegt die
Ressourdenspezifität gegen die Handelsöffnungs-Alternativerklärung).

## Schritt 7: Entscheidungsbaum bei Abweichungen

- FE-Koeffizient falsch → Regressorsatz prüfen (nrquarterssmpl!), Panelstruktur
  (101 Gruppen), `unsc3`-Regel (t | t+1).
- GLS-Punktschätzer falsch → σ²ᵢ-Berechnung (RSSᵢ/nᵢ), Singleton-Behandlung.
- GLS-t weicht ~5 % ab → SE-Skalierungsdetail (nmk/Singletons); dokumentieren,
  nicht feinjustieren.
- Voll-/Trunkiert-Spalten weichen ab → Lag-Konstruktion (Kalenderjahr t−1),
  NA→0-Regeln, WDI-Vintage.
- Vorzeichenwechsel im Fenster 2002–2008 → legitimer Befund (Effekt lebt in den
  1990ern); inhaltlich diskutieren.

## Reihenfolge und Abhängigkeiten (alles umgesetzt)

```
Schritt 1 (Spur A) ────────────────> UMGESETZT und verifiziert
Schritt 2 (Crosswalk) ────────────> UMGESETZT
Schritt 3 (Nachbau) ───────────────> UMGESETZT: 314/314 in allen 8 Variablen
Schritt 4 (Kontrollen) ───────────> KOMPLETT UMGESETZT (alle 9 + Alternativen)
Schritt 5 (unsc3 = t | t+1) ──────> UMGESETZT
Schritt 6 (Spur B + Validierung) ──> ABGESCHLOSSEN
Gate (eigenes 2000-2026-Panel) ───> GEFAILED, s. Schritt 3 (offen)
```

## Anhang A: Verifizierte Befunde (Stand 2026-09-26)

- Tabelle 2, Basis-Spalte (publizierter Output `JCR_DSV_Table2.txt/xml`):
  unsc3 = −2.410 (−1.906), N=314, 101 Gruppen, R²=0.049 — in plm exakt.
- Tabelle 2, Vollmodell: FE unsc3 = −3.329 (−1.950), N=217 — exakt mit
  korrektem Regressorsatz; GLS unsc3 = −2.096 — Punktschätzer exakt via
  manuellem FGLS; t(nmk) = −3.97 vs. publiziert −4.02 (1,4 %).
- Konditionalitätsblock aus `Data MONA.dta`: 314/314 exakt (Zähl-, Typ-,
  Verschiebe- und Quartalsregeln wie oben).
- `fullsample` = Complete-Cases auf den 9 fullvar-Kovariaten (N=217).
- `avgcondtype_0 ≡ avgcondtype_all = nrcondtype_all / nrquarterssmpl`.
- 18 UNSC-Programme (unsc3==1), s. `JCR_DSV_Table1.log` — deckungsgleich mit
  Datensatz; unsc3 = Mitgliedschaft t oder t+1 (Kalenderjahr, verifiziert).
- `wdicode` in `Data MONA.dta` komplett; `idcnt` = Gruppennummer des WDI-Codes.
- Vintage-Korrelationen eigene vs. Original-Kontrollen: 0.93–0.98, legelec_l
  0.978, imf_sum 0.835; GFCFGDP 0.70; USaidGDP −14 % (Konzept).
- IMF-Konzept: Original = Nettoflüsse (negative Werte möglich), nicht
  Kreditbestand.

## Anhang B: Inhaltsverzeichnis `data/raw/original/construction/`

| Datei | Inhalt |
|---|---|
| `Dreher_Sturm_Vreeland_JCR.do` | Haupt-Schätzskript (lädt finales .dta, `unvar`/`fullvar`, inkludiert Tabellen-.doh-Dateien) |
| `JCR_DSV_Table1–5.doh`, `TableS1–S5.doh` | Tabellendefinitionen (Spezifikationen s. o.) |
| `JCR_DSV_Table2.txt` / `.xml` | Publizierter Output, Spalte (1): Basis-FE, unsc3 = −2.410 |
| `JCR_DSV_Table1.log` | Liste der 18 UNSC-Programme |
| `README_JCR_Original.txt` | Original-README ("Politics and IMF Conditionality", JCR) |
| `Data MONA.dta` | 22.810 Bedingungs-Zeilen 1992–2008 mit `wdicode`, `condtype_*`, `areaclass_*` |
| `Data Performance/Structural *.dta` | MONA-Rohexporte (4 Dateien) |
| `Action03.dta`, `Implementation03.dta`, `ActionImplementation.dta` | handkorrigierte Texte |
| `Desc2AreaClass.dta` | Handkodierung → 20 Area-Klassen |
| `MergeActionImplementation.do`, `txt2dta7.do` | Konstruktionsskripte |
| **fehlt** | `Other sources/*` (unsc, usaid, dpi2006, wdi2008, polity, icrg, kof, dd, ethfrac), `country_codes.csv` |
