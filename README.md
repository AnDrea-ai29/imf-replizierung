# IMF-Konditionalität und UNSC-Mitgliedschaft: globale Replizierung

**Design (siehe `Neu.md`):** Replizierung von Dreher, Sturm & Vreeland (2015, JCR) im erweiterten, globalen Laenderpool. Analyse-Reihenfolge: erst globale Durchschnittsergebnisse, dann einzelne Laenderergebnisse und Ausreisser. **Regionen werden NICHT vorab definiert** — sie sind allein ein spaeteres, deskriptives Hilfsmittel; welche Gruppen sinnvoll sind, entscheidet sich an den Laender- und Ausreisserbefunden.

**Datenbasis:** `Combined_ISO.xlsx` (MONA, alle Laender, alle Jahre), WDI (2002-2025), UNSC-Mitgliedschaft (DPPA, 1946-heute).

---

## Hypothesen

| Hypothese | Aussage | Test |
|-----------|---------|------|
| H1 | UNSC-Mitgliedschaft ist mit geringerer IMF-Konditionalitaet verbunden. | `avgcondtype_all ~ unsc3 + Kontrollen`, globaler Pool |
| H2 | Rohstoffabhaengigkeit verstaerkt den UNSC-Effekt. | `avgcondtype_all ~ unsc3 * resource_dep + Kontrollen` |
| H3 | Die Beziehung ist heterogen. | Zunaechst Laenderergebnisse/Ausreisser; regionale Gruppen erst danach, deskriptiv |
| H4 | Der Effekt ist in rohstoff-/geopolitisch exponierten Kontexten besonders stark. | `rohstoff_cond_share ~ unsc3 * resource_dep`, Laender-/Ausreisseranalyse |

---

## Datenpipeline (alle Laender, alle Jahre)

```
data/raw/mona/Combined_ISO.xlsx
    -> code/data_prep/erstellen_mona_all.r   (Klassifizierung, Land-Jahr-Aggregation,
                                              Joins mit WDI/UNSC; KEINE Regionsvariable)
    -> data/processed/final_data_panel_ALL.csv   (99 Laender, 2000-2026)

data/raw/unsc/DPPA-SCMembership.csv
    -> code/data_prep/create_unsc_correct.R (robustes Namensmapping, vollstaendiges Panel)
    -> data/raw/unsc/unsc_membership_ISO3_correct.csv
```

Wichtige Datenkorrekturen (dokumentiert in den Skripten):

1. **ISO-Korrektur:** `KANN` in Combined_ISO.xlsx ist St. Kitts und Nevis und wird auf `KNA` korrigiert.
2. **UNSC-Namensmapping:** DPPA-Schreibweisen wie "Bolivia (Plurinational State of)", "United Republic of Tanzania", "Tuerkiye" fielen aus der ISO-Zuordnung heraus; 37 Laender (darunter tatsaechliche UNSC-Mitglieder im Zeitraum: TUR, BOL, CAF, CIV, EGY, TZA) fehlten komplett und waren durch Null-Ersetzung als "kein Mitglied" falschkodiert. Jetzt: Override-Tabelle + vollstaendiges Panel aller WDI-Laender.
3. **Keine Null-Ersetzung fehlender WDI-Werte:** Fehlende Rohstoff-/Kontrollwerte bleiben NA; alle Modelle schaetzen auf Complete Cases.

---

## Analyse-Skripte und Ergebnisse

| Skript | Inhalt | Output |
|--------|--------|--------|
| `code/replication/phase1_replizierung.r` | H1 global: alle Jahre + Vergleichsfenster 2002-2008 | `results/model_repl.rds`, `results/model_repl_2002_2008.rds`, `results/validation_repl.csv` |
| `code/analysis/phase2_erweiterung.R` | Globale Durchschnittsmodelle H1, H2, H4 (ohne Regionen) | `results/models/model_h1/h2/h4.rds`, `results/tables/results_h1_h4.csv` |
| `code/analysis/laender_ausreisser_analyse.R` | Laenderuebersicht, Extremwerte, Leave-one-out-Einfluss auf unsc3 | `results/tables/country_summary.csv`, `outlier_extremewerte.csv`, `influence_unsc3.csv` |
| `code/analysis/h1_sample_zerlegung.R` | Dokumentation: Woher kam das fruehere negative H1-Vorzeichen? (Reproduktion des alten SSA-Befunds + Stufung nach Laenderpool und Zeitfenster) | `results/tables/h1_sample_zerlegung.csv` |
| `code/replication/final_robustness_check.R` | Pooled OLS, Year FE, Two-way FE, BP-/White-Tests, HC1-SE | `results/tables/robustness_checks.csv/.tex` |
| `R/regional_effect_summary.R` | Optionale Helferfunktion: erst NUTZBAR, wenn der Autor selbst Regionsgruppen festgelegt hat | (Rueckgabeobjekt) |

### Kernergebnisse (Stand 2026-09-24, globaler Pool, alle Jahre)

- **H1 (Durchschnitt):** unsc3-Koeffizient positiv und nicht signifikant (2002-2025: +0.076, p=0.12; 2002-2008: +0.018, p=0.91). Die Original-Evidenz laesst sich im globalen MONA-Panel nicht reproduzieren.
- **H2 (Durchschnitt):** Interaktion unsc3 x resource_dep insignifikant (+0.0012, p=0.60).
- **H4 (Durchschnitt):** resource_dep ist marginal positiv mit dem Anteil rohstoffspezifischer Bedingungen assoziiert (p=0.078); die UNSC-Interaktion ist insignifikant.
- **Laenderergebnisse/Ausreisser:** Hoechste Rohstoffabhaengigkeit: AGO, IRQ, COG, MNG, YEM, PAN. Hoechste Konditionalitaet: COG, TCD, COD, CAF, YEM. Leave-one-out: Kein einzelnes Land dominiert den H1-Koeffizienten (groesstes |Delta|: TZA, 0.029 gegenueber einem Koeffizienten von 0.045); die Durchschnittsbefunde sind nicht auf ein Land zurueckzufuehren.

**Stichprobengroessen:** Panel 333 Land-Jahr-Beobachtungen (99 Laender); Complete Cases H1: 214 (FE-Modell: 204 nach Singleton-Entfall), H2/H4: 171 (FE-Modell: 158).

---

## Naechste Schritte

1. Laender- und Ausreisserbefunde sichten (`results/tables/country_summary.csv`, `outlier_extremewerte.csv`, `influence_unsc3.csv`).
2. Erst danach: eigene, deskriptive Regionsgruppierung festlegen (z. B. mit `R/regional_effect_summary.R`) und Heterogenitaet beschreiben.
3. Ergebnisse in die Hausarbeit ueberfuehren (LaTeX-Geruest in `latex/`).

## Archiv

- `archive/ssa_legacy/`: komplette alte SSA-Pipeline (20-Laender-Fokus).
- `archive/superseded/`: durch die aktuelle Pipeline ersetzte Skripte.
