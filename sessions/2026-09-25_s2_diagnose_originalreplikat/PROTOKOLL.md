# Session 2 (2026-09-25): Diagnose Original vs. Replikat

**Ziel:** Oeffnen des Original-Datensatzes, systematischer Vergleich mit dem
eigenen Panel, Identifikation aller Luecken.

**Skript:** s2_overlap_diagnose.R (konsolidierte persistente Fassung der
Ad-hoc-Vergleiche; laeuft laufend als Gate-Check-Werkzeug).

**Zentrale Befunde:**
- Original: 314 Zeilen, 102 Laender, 1992-2008, Schaedtprobe fullsample N=217.
- Replikat: 333 Zeilen, 99 Laender, 2000-2026; nur 88 Land-Jahre ueberlappen.
- nrcondtype_all stimmt in KEINER der 88 Ueberlappungen ueberein (Median 2,1,
  Korrelation 0,67); nrquarterssmpl Median-Verhaeltnis 2,0.
- unsc3: 4 Diskrepanzen (BFA 2007, BGR 2004, COL 2003, TZA 2007) - Panel kodiert
  zurueckliegende Mitgliedschaft statt Wahljahr (t | t+1).
- Fehlende Original-Kontrollen: ExtBalGDP, GFCFGDP, legelec_l, USaidGDP,
  imf_conc_gdp, imf_noconc_gdp. Keine ISO-Codes im Original (loesbar: wdicode
  in Data MONA.dta).
- Folge: Replikationsanleitung_Gesamtzeitraum.md erstellt (Revision 1).
