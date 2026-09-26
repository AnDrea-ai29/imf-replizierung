# Session 1 (2026-09-24): Globales Spur-B-Panel (alter Stand, teils ueberholt)

**Ziel:** Eigenes 2000-2026-Panel aus MONA + WDI + UNSC bauen und H1-H4 im
globalen Pool schaetzen. Protokoll im Detail: `docs/session_protokoll_2026-09-24.md`.

**Skripte (Kopien; kanonisch unter code/):** erstellen_mona_all.r,
create_unsc_correct.R, phase1_replizierung.r, phase2_erweiterung.R,
h1_sample_zerlegung.R, laender_ausreisser_analyse.R,
zeitraeume_krisen_robustheit.R, final_robustness_check.R

**Ergebnisse (damaliger Stand):** Panel 333 Land-Jahre, 99 Laender. H1 count
+3.11 (p=0.073) - VORZEICHENPROBLEM, spaeter geklaert (Session 2-4): falsche
MONA-GGranularitaet + unsc3 in falsche Richtung kodiert.

**Warnung:** Diese Session ist durch die spaeteren Befunde UEBERHOLT:
- unsc3 des Panels zaehlt zurueckliegende Mitgliedschaft (4 falsch-positive/
  falsch-negative Faelle gegenueber DSV-Regel t | t+1)
- nrcondtype_all zaehlt 2,1x zu viel (modernes MONA-Exportformat)
- Vor Verwendung fuer die Hausarbeit: Gate mit
  sessions/2026-09-25_s2_diagnose_originalreplikat/s2_overlap_diagnose.R
  bestehen lassen.
