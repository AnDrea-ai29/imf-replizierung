# IMF-Konditionalität und UNSC-Mitgliedschaft: globale Replizierung mit regionaler Differenzierung

**Design (siehe `Neu.md`):** Replizierung von Dreher, Sturm & Vreeland (2015, JCR) im erweiterten, globalen Laenderpool mit regionaler Differenzierung. SSA ist keine Fokusregion mehr, sondern eine von sechs Vergleichsregionen. Welche Regionen empirisch auffaellig sind, entscheidet sich an den Daten, nicht a priori.

**Datenbasis:** `Combined_ISO.xlsx` (MONA, alle Laender, alle Jahre), WDI (2002-2025), UNSC-Mitgliedschaft (DPPA, 1946-heute).

---

## Hypothesen

| Hypothese | Aussage | Test |
|-----------|---------|------|
| H1 | UNSC-Mitgliedschaft ist mit geringerer IMF-Konditionalitaet verbunden. | `avgcondtype_all ~ unsc3 + Kontrollen`, globaler Pool |
| H2 | Rohstoffabhaengigkeit veraerkt den UNSC-Effekt. | `avgcondtype_all ~ unsc3 * resource_dep + Kontrollen` |
| H3 | Die Beziehung variiert regional. | Regionale Interaktionen bzw. Subgroup-Modelle |
| H4 | Der Effekt ist in rohstoff-/geopolitisch exponierten Regionen besonders stark. | `rohstoff_cond_share ~ unsc3 * resource_dep`, Ausreisser-/Laenderanalyse |

---

## Datenpipeline (alle Laender, alle Jahre)

```
data/raw/mona/Combined_ISO.xlsx
    -> code/data_prep/erstellen_mona_all.r   (Klassifizierung, Land-Jahr-Aggregation,
                                              Joins mit WDI/UNSC, region-Variable)
    -> data/processed/final_data_panel_ALL.csv   (99 Laender, 2000-2026, inkl. region)

data/raw/unsc/DPPA-SCMembership.csv
    -> code/data_prep/create_unsc_correct.R (robustes Namensmapping, vollstaendiges Panel)
    -> data/raw/unsc/unsc_membership_ISO3_correct.csv
```

Wichtige Datenkorrekturen (dokumentiert in den Skripten):

1. **ISO-Korrektur:** `KANN` in Combined_ISO.xlsx ist St. Kitts and Nevis und wird auf `KNA` korrigiert.
2. **UNSC-Namensmapping:** DPPA-Schreibweisen wie "Bolivia (Plurinational State of)", "United Republic of Tanzania", "Tuerkiye" fielen bisher aus der ISO-Zuordnung heraus; 37 Laender (darunter tatsaechliche UNSC-Mitglieder im Zeitraum: TUR, BOL, CAF, CIV, EGY, TZA) fehlten komplett und wurden durch Null-Ersetzung als "kein Mitglied" falschkodiert. Jetzt: Override-Tabelle + vollstaendiges Panel aller WDI-Laender (unsc=0 ist korrekt statt NA).
3. **Keine Null-Ersetzung fehlender WDI-Werte mehr:** Fehlende Rohstoff-/Kontrollwerte bleiben NA; alle Modelle schaetzen auf Complete Cases. Zuvor waren 71 Zeilen mit `resource_dep == 0` in Wirklichkeit fehlende WDI-Daten.

**Regionen** (in `final_data_panel_ALL.csv`, Spalte `region`): SSA (40 Laender), ECA (22), LAC (22), MENA (6), SA (6), EAP (3).

---

## Analyse-Skripte und Ergebnisse

| Skript | Inhalt | Output |
|--------|--------|--------|
| `code/replication/phase1_replizierung.r` | H1 global: alle Jahre + Vergleichsfenster 2002-2008 | `results/model_repl.rds`, `results/model_repl_2002_2008.rds`, `results/validation_repl.csv` |
| `code/analysis/phase2_erweiterung.R` | H1-H4 global, alle Jahre, inkl. Regionsinteraktion (H3) | `results/models/model_h1-h4.rds`, `results/tables/results_h1_h4.csv`, `results/tables/region_summary.csv` |
| `R/global_effect_analysis.R` | Globales Interaktionsmodell, Laenderuebersicht, Ausreisser | `results/models/model_global_region.rds`, `results/tables/country_summary.csv`, `results/tables/top_resource_countries.csv` |
| `R/regional_effect_summary.R` | Funktion: Regionsdeskriptive, 3-Wege-Interaktion, Subgroup-Modelle | (Rueckgabeobjekt) |
| `code/replication/final_robustness_check.R` | Pooled OLS, Year FE, Two-way FE, BP-/White-Tests, HC1-SE | `results/tables/robustness_checks.csv/.tex` |

### Kernergebnisse (Stand 2026-09-24, globaler Pool, alle Jahre)

- **H1:** unsc3-Koeffizient positiv und nicht signifikant (2002-2025: +0.076, p=0.12; 2002-2008: +0.018, p=0.91). Die Original-Evidenz laesst sich in diesem globalen MONA-Panel nicht reproduzieren.
- **H2:** Interaktion unsc3 x resource_dep insignifikant (+0.0012, p=0.60).
- **H3:** In den Subgroup-Modellen ist **Lateinamerika (LAC) die auffaellige Region**: unsc3 = -0.71 (p < 0.001), waehrend SSA (-0.10, p=0.55) und ECA (-0.07, p=0.79) unauffaellig bleiben. EAP/MENA/SA sind mit zu wenigen Beobachtungen nicht einzeln schaetzbar.
- **H4:** resource_dep ist marginal positiv mit dem Anteil rohstoffspezifischer Bedingungen assoziiert (p=0.078); die UNSC-Interaktion ist insignifikant.

**Stichprobengroessen:** Panel 333 Land-Jahr-Beobachtungen (99 Laender); Complete Cases H1: 214, mit resource_dep (H2-H4): 171 (vor Singleton-Entfall in fixest: 158).

---

## Naechste Schritte (Neu.md Phase 6-8)

1. LAC als auffaellige Region vertiefen: Laendervergleiche innerhalb LAC (wer treibt den Effekt?), Ausreisser pruefen.
2. Robustheit des LAC-Befunds: Zeitfenster, alternative resource_dep-Spezifikationen, Clustering der Standardfehler.
3. Ergebnisse in die Hausarbeit ueberfuehren (LaTeX-Geruest in `latex/`).

## Archiv

`archive/ssa_legacy/` enthaelt die vollstaendige alte SSA-Pipeline (Skripte und Datensaetze, 20-Laender-Fokus). Sie wird von keinem aktiven Skript mehr verwendet.
