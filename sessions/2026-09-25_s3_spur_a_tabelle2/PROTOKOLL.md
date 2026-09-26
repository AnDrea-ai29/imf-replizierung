# Session 3 (2026-09-25): Spur A - Exaktreplikation von Tabelle 2

**Voraussetzung:** Original-Konstruktions- und Schaetzdateien bereitgestellt
(data/raw/original/construction/: txt2dta7.do, JCR_DSV_Table2.doh,
JCR_DSV_Table2.txt/.xml, Dreher_Sturm_Vreeland_JCR.do).

**Zentrale Klarungen:**
- Tabellen-2-Spezifikation aus Table2.doh: 5 Modellvarianten je xtreg fe und
  xtgls panels(hetero) force nmk. Vollmodell-Kontrollen (fullvar):
  legelec_l XDebtGNI DebtServGNI ResXDebt ExtBalGDP GFCFGDP USaidGDP
  imf_conc_gdp imf_noconc_gdp - plus nrquarterssmpl in jedem Modell.
- Fruehere Fehler gefunden: Phase 0 nutzte nrcntprogram statt
  nrquarterssmpl; "GLS" ist xtgls panels(hetero), kein Random Effects.

**Ergebnisse (phase0_replikation_original.R):**
- Basis-FE unsc3 = -2.410 (t=-1.906, N=314) - exakt wie JCR_DSV_Table2.txt.
- Vollmodell-FE unsc3 = -3.329 (t=-1.950, N=217) - exakt publiziert.
- Vollmodell-GLS unsc3 = -2.096 (Punktschaetzer exakt; t(nmk)=-3.97 vs. -4.02).
- Diagnostik: F-Test FE p=2.056e-05 exakt; Wooldridge als Approximation.
- Zeitfenster-Zerlegung: Effekt lebt in den 1990ern (1992-2001: -4.98,
  t=-2.20; 2002-2008: Null bzw. kollinear).

**Outputs:** results/tables/original_replication.csv,
original_replication_zeitfenster.csv, results/models/model_original_*.rds
