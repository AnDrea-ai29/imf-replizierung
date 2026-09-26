# Session 7 (2026-09-26): Kuratierte Ressourcen-Klassifikation

**Anlass:** Die Stichwort-Klassifikation (Regex auf Bedingungstexte) war
unzufriedenstellend. Diagnose bestaetigte systematische Fehltreffer: 137
Bank-Privatisierungen ("restructuring & privatization of financial
institutions") liefen wegen des Stichworts "privatization" als "rohstoff";
"nonmineral export proceeds" wurde wegen der Zeichenkette "mineral"
erfasst; breite Begriffe (export, subsidy) ueberdeckten den Extraktiv-
Sektor-Bezug voellig.

**Loesung:** Klassifikation auf Ebene der EINDEUTIGEN areadescription
(offizielle MONA-Kategorietexte; 1.636 eindeutige auf 22.810 Zeilen,
Top-200 = 90 % Zeilendeckung) per kuratiertem Woerterbuch mit manueller
Review-Moeglichkeit:
- Skript: code/data_prep/klassifikation_bedingungen.R
- Review-Datei: data/processed/bedingungsbeschreibungen_review.csv
  (Spalten rohstoff_final/stabil_final = manuell zu pruefen, initial =
  konservativer Vorschlag: nur extraktiv-spezifische Begriffe mit
  Wortgrenzen; energie_vorschlag = breitere Sensitivitaetskategorie;
  pruefhinweis-Spalte fuer Ambivalenzen wie "edible oils" = Agrar)
- hypothesen_original_basis.R klassifiziert jetzt per JOIN auf die
  Review-Datei (kein Inline-Regex mehr).

**Diagnosebefunde (alt vs. Vorschlag):**
- Alt: 446 Zeilen "rohstoff" (inkl. 137 Bank-Privatisierungen = Rauschen).
- Vorschlag: 86 Zeilen — genuine Extraktiv-Bedingungen (Oelpreis-Fonds,
  Petroleum-Pricing, Gas-Arrears, Oil-Parastatal-Zahlungen).
- DSV-areaclass-Verteilung der 86: Pricing 31, Other 12, BOP/Reserves 10 —
  plausibel (Preisregulierung dominiert).

**Inhaltliche Konsequenz (wichtig fuer die Hausarbeit):**
Rohstoffspezifische Bedingungen sind in IMF-Programmen dieser Periode
SELTEN (86 von 22.810 = 0,4 %). Der rohstoff_cond_share ist stark
null-inflatiert; H4 ist mit der engen Operationalisierung kaum testbar.
Ergebnis H4 (enge Klassifikation, N=180): unsc3 = -0.005 (n.s.),
Interaktion +0.00003 (n.s.). Sensitivitaet mit breiterer
Energie-Kategorie (H4_energie): ebenfalls n.s. Ehrliche Interpretation:
H4 findet keine Unterstuetzung — primaer weil es kaum rohstoffspezifische
Bedingungen gibt (Konstrukt-Gueltigkeitsproblem der Hypothese, nicht nur
ein Power-Problem).

**Offen (Autor):** Review der Top-200-Beschreibungen in
bedingungsbeschreibungen_review.csv; rohstoff_final/stabil_final wo noetig
korrigieren; danach hypothesen_original_basis.R neu laufen lassen und
Ergebnis vergleichen (Soll: aehnlich, da die Top-86 bereits sauber sind).
