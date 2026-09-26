# Projektaufraeumen und Fahrplan (Stand 2026-09-26)

Diese Anleitung ersetzt `Hausarbeit_12_Tage_Plan.md` und
`docs/tagesplan_2026-09-25.md` als Arbeitsplan (beide sind durch die
Datenkorrekturen ueberholt). Sie beantwortet drei Fragen:

1. Welche Dateien existieren, und welchen Status haben sie?
2. Was ist aufzuraeumen (mit konkreten Befehlen)?
3. Welche Schritte fehlen bis zur fertigen Hausarbeit?

**Lektion aus diesem Aufräumen:** Die aktuelle Replikationsanleitung ging
kurzzeitig verloren, weil sie nie committet wurde und beim Umsortieren eine
alte Fassung an ihren Ort gelegt wurde. **Nach jeder Arbeitssession committen**
(`git add -A && git commit -m "..."`) — der letzte Commit im Repo ist
noch vom 2026-09-25 vormittags.

---

## 1. Zielstruktur des Projekts

```
imf-replizierung/
├── README.md                       <- Projekt-Uebersicht (aktuell halten!)
├── Replikationsanleitung_Gesamtzeitraum.md   <- KANONISCH, nur hier (Rev. 4)
├── Neu.md                          <- Forschungsdesign H1-H4 (aktiv)
├── sessions/                       <- NEU: Arbeitssessions mit Code-Kopien
│   └── <datum>_s<n>_<thema>/       <- PROTOKOLL.md + Skript-Kopien
├── docs/                           <- Referenz- und Hintergrund-Dokumente
├── code/                           <- KANONISCHE Skripte (Einzelquelle)
├── data/raw/                       <- Rohdaten (nie anfassen/loeschen)
├── data/processed/                 <- verarbeitete Daten (per Skript erzeugbar)
├── results/                        <- Tabellen/Modelle (per Skript erzeugbar)
├── latex/                          <- Hausarbeit
├── R/                              <- Helfer
└── archive/                        <- Ueberholtes (nur Nachschlag)
```

**Regeln:**
- Skripte: kanonisch nur in `code/`; `sessions/` enthält **Kopien als
  Stand der jeweiligen Session** + PROTOKOLL.md.
- Anleitung: nur im **Projektstamm** (nicht zusätzlich nach code/ kopieren —
  das war die Ursache des Versionsverlusts).
- Alles in `data/processed/` und `results/` ist per Skript reproduzierbar —
  Dateien dort duerfen geloescht und neu erzeugt werden; `data/raw/` nie.

## 2. Das Session-Konzept (neu etabliert)

Jede Arbeitssession bekommt einen Ordner `sessions/<datum>_s<n>_<thema>/`:

- `PROTOKOLL.md`: Datum, Ziel, Skripte (mit kanonischem Pfad), zentrale
  Befunde, Outputs, offene Punkte. Wer Deutsch schreibt, kann dies direkt
  in die Hausarbeit (Methodenteil/Anhang) uebernehmen.
- Skript-**Kopien** des Session-Stands (Snapshot; kanonisch bleibt `code/`).
- Ggf. Kopien der erzeugten Ergebnis-Tabellen.

Vorhanden (2026-09-26):

| Session | Thema | Status |
|---|---|---|
| `2026-09-24_s1_spur_b_panel` | Altes globales Panel (333 Zeilen) + H1-H4 | **UEBERHOLT** — Panel faellt durchs Gate, unsc3 falsch kodiert |
| `2026-09-25_s2_diagnose_originalreplikat` | Vergleich Original vs. Replikat; Gate-Check-Skript | abgeschlossen |
| `2026-09-25_s3_spur_a_tabelle2` | Exaktreplikation Tab. 2 (Phase 0) | abgeschlossen |
| `2026-09-25_s4_nachbau_conditionality_unsc` | 314/314-Nachbau + Crosswalk + unsc3-Regel | abgeschlossen |
| `2026-09-26_s5_kontrollpanel_wdi_dpi` | controls_wdi_1990_2025.csv + Diagnosen | abgeschlossen |
| `2026-09-26_s6_hypothesen_validierung` | H1-H4 Original-Zaehlbasis + 3-Spur-Tabelle | abgeschlossen |

Naechste Sessions anlegen als `sessions/2026-09-XX_s7_...` usw.

## 3. Datei-Inventar und Aufraeum-Aktionen

### 3a. Sofort erledigt (durch Aufraeum-Session)

- [x] `scratch_*.R` im Stamm geloescht (Ad-hoc-Reste).
- [x] Veraltete Anleitungs-Kopie `code/replication/Replikationsanleitung_...md`
      (Revision 1) entfernt; kanonische Fassung Rev. 4 im Stamm
      rekonstruiert.
- [x] `sessions/` mit 6 Session-Ordnern + Protokollen + Skript-Kopien
      aufgebaut; `s2_overlap_diagnose.R` als persistente Gate-Diagnose
      angelegt (laeuft, Ergebnis: GEFAILED wie dokumentiert).

### 3b. Empfohlene Loeschungen (Restmuel; vorher kurz pruefen)

| Datei | Grund | Befehl (Git Bash im Projektstamm) |
|---|---|---|
| `Untitled.do` (73 B, leer) | Stata-Rest | `rm Untitled.do` |
| `.Rhistory`, `code/.Rhistory`, `data/.Rhistory` | Session-Reste | `rm .Rhistory code/.Rhistory data/.Rhistory` |
| `latex/Vorlage.aux .log .bbl .blg .toc .run.xml .synctex.gz .blx.bib` | LaTeX-Build-Artefakte (erzeugbar) | `cd latex && rm Vorlage.aux Vorlage.log Vorlage.bbl Vorlage.blg Vorlage.toc Vorlage.run.xml Vorlage.synctex.gz Vorlage-blx.bib` |
| `results/regression_output/` (leer) | leerer Ordner | `rmdir results/regression_output` |

### 3c. Archiv-Kandidaten (nach `archive/` verschieben, NICHT loeschen)

| Datei | Grund | Ziel |
|---|---|---|
| `Gobaler_Effekt.md` | Tippfehler-Titel; Inhalt von Neu.md/phase2-Skript abgelöst | `archive/docs_archive/` |
| `Hausarbeit_12_Tage_Plan.md` | durch diese Datei ersetzt | `archive/docs_archive/` |
| `docs/tagesplan_2026-09-25.md` | erledigt/ueberholt | `archive/docs_archive/` |
| `Probleme.md` | pruefen: falls Liste alter Blocker (alle geloest), archivieren | `archive/docs_archive/` |
| `R/global_effect_validation_checklist.md` | falls SSA-Alt-Checkliste | `archive/ssa_legacy/` |
| `results/validation_repl.csv`, `results/model_repl*.rds`, `results/models/model_h1/h2/h4.rds` | Ergebnisse des UEBERHOLTEN Panels (Session 1) | `archive/superseded/ergebnisse_altes_panel/` |

**Nicht archivieren** (trotz Namensaehnlichkeit): `Neu.md` (aktives Design),
`docs/session_protokoll_2026-09-24.md` (Quelle fuer Session 1), `R/regional_effect_summary.R`.

### 3d. Duplikate/Konventionen (wissen, nicht loeschen)

- `data/final/Dreher_Sturm_Vreeland_JCR.dta` = Kopie von
  `data/raw/original/Dreher_Sturm_Vreeland_JCR.dta`. Die Skripte
  (phase0, hypothesen) lesen `data/final/` — **so lassen**; nur dokumentieren.
- `sessions/*/…R` sind Kopien; **immer nur `code/` editieren**.

### 3e. Git (dringend!)

Nach dem Aufraeumen einmal festhalten:

```bash
git add -A
git commit -m "Aufraeumen: sessions/ etabliert, Anleitung Rev. 4 rekonstruiert, Reste entfernt"
```

## 4. Aktueller Daten- und Ergebnisstand (was ist belastbar?)

**Belastbar (fuer die Hausarbeit nutzbar):**
- Spur A: Tabellen-2-Exaktreplikation (Basis −2.410, Voll-FE −3.329,
  Voll-GLS −2.096; `original_replication.csv`).
- Spur B: 314/314-Nachbau (`conditionality_dsv_1992_2008.csv`), komplettes
  Kontrollpanel (`controls_wdi_1990_2025.csv`), unsc3-Regel
  (`unsc_dsv_rule_1946_2026.csv`).
- H1-H4 auf Original-Zaehlbasis (`hypothesen_original_basis.csv`):
  H1 −2.43 (p=0.095); H1_voll9 −4.40 (p=0.056); H2 Interaktion +0.134
  (p=0.156, N=180, 13 UNSC-Faelle); H4 n.s.
- Dreispaltige Validierung (`replication_gesamtzeitraum.csv`).

**NICHT belastbar (nur mit Caveat erwaehnbar):**
- Altes 2000-2026-Panel (`final_data_panel_ALL.csv`): faellt durchs Gate
  (Median 2,1, 0 % exakt) und hat falsch kodiertes unsc3. Alle alten
  Ergebnisse daraus (+3.11 etc.) nur noch als "Herkunft des
  Vorzeichenproblems" erwaehnen — nicht als Befund.

## 5. Aktueller Hausarbeit-Fahrplan (ersetzt alle alten Plane)

### Block A — Analyse abschliessen (ca. 1 Arbeitstag)
1. **Placebo-Test H2:** `avgcondtype_all ~ unsc3 * ExportGDP + Kontrollen`
   parallel zu H2 in `hypothesen_original_basis.R`; Vergleich der
   Interaktionen (belegt Ressourdenspezifitaet). [KI kann ausführen]
2. **Robustheit H2:** Alternative Operationalisierungen (nur Fuel; Fuel+Mineral;
   Winsorizing von resource_dep; Zeitfenster 1992-2001 vs. 2002-2008).
3. **Landebene:** Ausreisser-/Leave-one-out fuer H2-Interaktion (analog
   `laender_ausreisser_analyse.R`, aber auf Original-Zaehlbasis). [KI]
4. **H3/H4-Regionales:** erst NACH Landebefunden deskriptiv gruppieren
   (Neu.md-Prinzip); keine vorab fixierten Regionen.

### Block B — Eigenes Erweiterungspanel (nur wenn Zeit; ca. 1-2 Tage)
5. Eigene MONA-Extraktion auf 2008er-Granularitaet ausrichten (Dedup auf
   Bedingungs-/Revisionsebene) + DSV-Quartalsregel; dann Gate mit
   `sessions/.../s2_overlap_diagnose.R` bestehen lassen (Ziel: Median
   0.8-1.2, ≥50 % exakt).
6. Nur danach: Erweiterung 2009-2025 (unsc3_dsv, controls_wdi, DPI bis 2023
   beachten) und Drei-Fenster-Zerlegung.

### Block C — Schreiben (Hauptarbeit, beginnt parallel zu A)
7. **Sofort schreibbar** (Daten stehen fest): Daten&Methodik (Quellen,
   zwei Spuren, Stichprobenregel, Zaehlregeln), Ergebnisse 3.1 (Tabellen:
   replication_gesamtzeitraum, hypothesen_original_basis,
   original_replication_zeitfenster), Interpretation 3.2 (1990er-Befund,
   H2-Richtung, H4-Null), Robustheitschecks (vintage-check,
   H1_wdi/voll8/voll9-Stufenleiter).
8. Theoriekapitel (Dependenz-Exzerpte in
   `docs/original_study_dep_specs.md`; Bib-Eintraege Amin, Frank,
   Wallerstein, Emmanuel, Rodney, Dos Santos fehlen noch in
   `latex/literatur.bib`).
9. Einleitung/Forschungsstand (Kentikelenis 2016, Barro 2005).
10. Diskussion: Replikationsbefund (Effekt lebt in den 1990ern) +
    H2-Richtung + H4-Null + Limitationen (NFL-Typen-Split, USaidGDP-Konzept,
    Fuel ab ~1995, Wooldridge-Approximation).
11. Fazit zuletzt.

### Kernzahlen fuer den Selbsttest
−2.410 (Tab.-2-Basis, exakt) · −3.329 (Vollmodell-FE, exakt) · −2.096
(Vollmodell-GLS, exakt) · −2.43 (H1 eigene Basis) · +0.134 (H2-Interaktion,
p=0.156, 13 UNSC-Faelle) · 314/314 (Nachbau) · 0.835 (IMF-Summen-Korrelation)
· 88 (Overlap, Gate GEFAILED).

## 6. Routine fuer weitere Sessions

1. Ordner `sessions/<datum>_s<n>_<thema>/` anlegen.
2. Arbeiten (Skripte kanonisch in `code/`).
3. `PROTOKOLL.md` schreiben (Vorlage: bestehende Sessions).
4. Skript-Stand + Ergebnis-Tabellen hineinkopieren.
5. `README.md` bei Bedarf aktualisieren (neue Skripte/Ergebnisse).
6. `git add -A && git commit` — ohne Ausnahme.
