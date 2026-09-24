# Tagesplan 2026-09-25: Datenbeschaffung, Literatur, LaTeX-Start

> Gesamtumfang ca. 6-7 Stunden. Reihenfolge bewusst: erst Daten (Block 1),
> denn lesende Blocks parallel zum Schreiben.

## 1) Tagesablauf

| Block | Zeit | Aufgabe | Ergebnis |
|---|---|---|---|
| 1 | 60-90 Min | **(c) Datenbeschaffung:** MONA-Export der vor-2000 genehmigten Arrangements (gleiche Spalten wie `Combined_ISO.xlsx`) + WDI-Neudownload ab 1992 mit `BN.CAB.XOKA.GD.ZS` (Außenbilanz %BIP) und `NE.GDI.TOTL.ZS` (Investitionsquote). Beide Codes gegen das Originalpapier prüfen. Dateien nach `data/raw/` | 1992-2025-Panel wird möglich; danach Drei-Fenster-Zerlegung (1992-2001 / 2002-2008 / 2009-2025) |
| 2 | 90 Min | **Dreher/Sturm/Vreeland (2015) gezielt lesen:** nur Methods + Table 2 + Variablendefinitionen. Mitnehmen: Definition von `avgareaclass_*`, genaue Kovariaten-Definitionen, GLS-Spezifikation (VCOV) | Replikationskapitel absichern; Kovariaten-Codes verifizieren |
| 3 | 60 Min | **Dependenz-Theorie rekapitulieren:** Exzerpte stehen in `docs/original_study_dep_specs.md` (Amin, Frank, Wallerstein, Emmanuel, Rodney, Dos Santos, Marini). Nur festigen und je 2-3 zitierfähige Aussagen markieren — nicht die Originalbücher lesen | Material für Theoriekapitel |
| 4 | 45 Min | **Sekundärliteratur selektiv:** aus `Hausarbeit_Literatur.bib`: Kentikelenis et al. 2016 (Kritik an IWF-Konditionalität), Barro 2005 (IMF-Programmwirkung) — je nur Abstract/Intro/Conclusion | Forschungsstand für Einleitung + Diskussion |
| 5 | 90-120 Min | **LaTeX: Kapitel "Daten und Methodik" + Hypothesen** schreiben (siehe Abschnitt 3 — Inhalte sind final) | Kapitel 1.2 und 2 weitgehend fertig |
| 6 | 45 Min | **Selbsttest:** die 8 Erklärungen aus dem Sitzungsprotokoll frei wiedergeben. Kernzahlen, die sitzen müssen: **−2.1** (Original-Benchmark), **−4.65/p=0.04** (1992-2001 auf Originaldaten), **+3.11/p=0.07** (eigenes Panel, alle Jahre), **25** (behandelte Land-Jahre) | Verteidigungssicherheit |

## 2) Literatur: Umfang und Lesezeit

| Text | Lesezeit | Wofür |
|---|---|---|
| Dreher, Sturm & Vreeland 2015 (nur Methods + Tab. 2) | 90 Min | Replikationskapitel, GLS-Spezifikation, Kovariaten für (c) |
| Dependenz-Exzerpte (bereits in `docs/original_study_dep_specs.md`) | 60 Min | Theoriekapitel, Herleitung von H2/H4 |
| Kentikelenis et al. 2016 | 20-30 Min | Einleitung (Forschungsstand), Diskussion |
| Barro 2005 | 20-30 Min | Einleitung, Diskussion |
| Bib-Einträge für Amin 1974, Frank 1967, Wallerstein 1974, Emmanuel 1972, Rodney 1972, Dos Santos 1970 | — | **fehlen noch in `Hausarbeit_Literatur.bib`** (17 Einträge vorhanden, keine Dependenz-Klassiker); können vorgeneriert werden |

## 3) Jetzt schon in LaTeX möglich (Vorlage: `latex/Vorlage.tex`)

| Kapitel | Status | Quelle der Inhalte |
|---|---|---|
| Hypothesen (1.2) | sofort schreibbar | `Neu.md` (H1-H4 final formuliert) |
| Daten und Methodik (2, ca. 3 Seiten) | sofort schreibbar | Datenquellen (MONA/WDI/UNSC-DPPA), 99 Länder, Zeitraum, beide Depvars mit Validierungszahlen (Panel-Mittel 8.3 vs. Original 8.2), Complete-Cases-Logik, Within-Schätzer, Zwei-Spur-Design — alles in `docs/session_protokoll_2026-09-24.md` |
| Ergebnisse, Hauptbefunde (3.1) | sofort schreibbar | `results/tables/original_replication.csv` (Spur A), `results/validation_repl.csv` (Spur B), `results/tables/robustness_checks.tex` (liegt als fertige LaTeX-Tabelle vor), `results/tables/krisen_robustheit.csv`, `results/tables/results_h1_h4.csv`, `results/tables/h1_sample_zerlegung.csv` |
| Ergebnisse, Interpretation (3.2) | weitgehend schreibbar | 1990er-Einsicht + Power-Vorbehalt, ausformuliert im Sitzungsprotokoll Abschnitt 5 |
| Diskussion (6) | Argumentation steht | Sitzungsprotokoll Abschnitt 5 ("Fazit H1") und Krisen-Robustheit |
| Theorie (2. Kapitel) | erst nach Block 3-4 | Literaturableseung morgen |
| Einleitung (1.1) | erst nach Block 4 | Forschungsstand |
| Fazit (7) | zuletzt | erst wenn Ergebnisse fixiert |

## 4) Offene Punkte danach (Stand nach diesem Plan)

1. Sobald (c)-Daten in `data/raw/` liegen: 1992-2025-Panel bauen, Drei-Fenster-Zerlegung auf beiden Spuren (Abstimmung mit KI-Assistenz).
2. Original-`.dta` NICHT mit eigenem Panel mergen (Doppelzählung 2000-2008, unterschiedliche Variablenkonstruktion).
3. Theoriekapitel und Einleitung schreiben, danach Fazit.
4. Hinweis der Dozentin beachten: KI für Code erlaubt, aber jede Entscheidung selbst erklären können (siehe Selbsttest, Block 6).
