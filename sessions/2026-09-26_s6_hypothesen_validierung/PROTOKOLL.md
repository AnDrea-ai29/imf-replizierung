# Session 6 (2026-09-26): H1-H4 auf Original-Zaehlbasis + Schritt-6-Abschluss

**Skripte:** hypothesen_original_basis.R, phase1_replikation_gesamtzeitraum.R

**H1-H4 (Original-Zaehlbasis 1992-2008, Kontrollen Original-.dta bzw. neue WDI):**
- M1_base (Sanity): -2.410 exakt.
- H1 (Two-way FE, N=266): unsc3 = -2.43 (p=0.095) - Vorzeichenproblem des
  alten Panels (+3.11) geklaert.
- H1_wdi (5 WDI-Kontrollen, N=175): -3.11 (p=0.095); H1_voll8: -3.85
  (p=0.097); H1_voll9 (alle 9 Kontrollen, eigene Basis, N=165): -4.40
  (p=0.056) vs. Original-Benchmark -3.329.
- H2 (volle Periode, 13 UNSC-Faelle, N=180): unsc3 = -4.59 (p=0.058),
  Interaktion +0.134 (p=0.156) - Richtung wie hypothetisiert, n.s.
- H4 (N=180): insignifikant - kein Beleg.
- Offen: Placebo-Test unsc3 x ExportGDP parallel zu H2.

**Schritt-6-Abschluss (phase1_replikation_gesamtzeitraum.R):** alle 5
Tabellen-2-Varianten je FE und GLS auf Spur-B-Basis; dreispaltige
Validierungstabelle replication_gesamtzeitraum.csv:
Basis-FE Spur B = Spur A = publiziert (-2.410, Abweichung 0); Vollmodell-FE
Spur B -4.40 vs. -3.329; Vollmodell-GLS Spur B -1.90 vs. -2.096 (+9%).

**Damit abgeschlossen:** Replikationsanleitung Schritte 1-6 alle UMGESETZT.
