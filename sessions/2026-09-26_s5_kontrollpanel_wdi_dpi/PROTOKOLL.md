# Session 5 (2026-09-26): Kontrollpanel aus WDI-2026 + DPI

**Skript:** build_controls_wdi.R -> controls_wdi_1990_2025.csv (266 Laender).

**Beschaffungshistorie:** Data_all-Einzelserien nachgeliefert (zunaechst
Luecke 1992-1999, dann durchgehend 1990-2025); resource_dep_all.csv mit DREI
Serien (NE.EXP.GNFS.ZS = ExportGDP getrennt gefuehrt = Handelsoeffnung,
NICHT resource_dep; TX.VAL.FUEL.ZS.UN + TX.VAL.MMTL.ZS.UN = resource_dep ab
1990); NY.GDP.MKTP.CD ab 1990; dpi_all.csv (legelec, bis 2023).

**Diagnosen:**
- legelec_l = DPI-Dummy, Lag KALENDERJAHR t-1 (Original-Konstruktion aus
  txt2dta7.do verifiziert; nur 14 NA sprechen fuer Kalender-Lag).
  Rekonstruktion: Korrelation 0.978 mit Original; 4 nicht parsbare
  Chile-Zeilen 2014-17 verworfen.
- IMF-Konzept (korrigiert): Original imf_conc_gdp/imf_noconc_gdp = NETTOFLUESSE
  (negative Werte moeglich); Summen-Korrelation mit NFL-Serien 0.835.
  NFL-Serien damit konzepttreu; Komponenten-Abweichung = Typen-Klassifikation.
  UseIMFCredGDP (DT.DOD.DIMF.CD, Bestand) als Alternativ-Konzept;
  OutCreditIMF_all.xlsx = globales Aggregat (nur Summen-Referenz;
  geparst: imf_credit_outstanding_global_1984_2026.csv).
- Vintage-Korrelationen gegen Original: 0.93-0.98 (GFCFGDP 0.70; USaidGDP
  -14% Median wegen Markt- statt Faktorkosten-BIP).

**Output:** results/tables/wdi_kontrollen_vintage_check.csv
