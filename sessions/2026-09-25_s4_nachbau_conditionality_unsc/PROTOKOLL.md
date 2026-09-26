# Session 4 (2026-09-25): Nachbau des Konditionalitaets- und UNSC-Blocks

**Ziel:** Original-Konditionalitaet 1992-2008 vollstaendig aus den
Konstruktionsdaten nachbauen (kein neuer MONA-Export noetig).

**Skripte:** rebuild_conditionality_1992_2008.R, build_unsc_dsv_rule.R

**Verifizierte Regeln:** Programm = Land x Approval-Datum; Zeilenzahl ohne
Dedup; Joint-Typ SB+PA doppelt; zwei Jahresverschiebungen (Senegal
29.08.1994 -> 1995, Uganda 15.12.2006 -> 2007); Quartale =
round((min(Enddatum, 28.09.2008) - max(Approval, 31.03.1992))/90);
unsc3 = UNSC t ODER t+1 (Wahljahr = LEAD); nrcntprogram-Rang je idcnt-Gruppe
(YUG/Serbien-Montenegro gemeinsam).

**Ergebnisse:** conditionality_dsv_1992_2008.csv mit 314/314 identisch in
ALLEN acht Vergleichsvariablen gegen das Original; crosswalk_dsv_iso3.csv
(102 Laender); unsc_dsv_rule_1946_2026.csv.

**Gate gegen das eigene Panel:** GEFAILED (Median 2,1, 0% exakt) - eigene
MONA-Extraktion muss vor Erweiterungsnutzung ausgerichtet werden.
