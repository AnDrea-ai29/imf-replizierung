# IMF-Konditionalität und UNSC-Mitgliedschaft: globale Replizierung

**Design (siehe `Neu.md`):** Replizierung von Dreher, Sturm & Vreeland (2015, JCR) im erweiterten, globalen Laenderpool. Analyse-Reihenfolge: erst globale Durchschnittsergebnisse, dann einzelne Laenderergebnisse und Ausreisser. **Regionen werden NICHT vorab definiert** — sie sind allein ein spaeteres, deskriptives Hilfsmittel; welche Gruppen sinnvoll sind, entscheidet sich an den Laender- und Ausreisserbefunden.

**Datenbasis:** `Combined_ISO.xlsx` (MONA, alle Laender, alle Jahre), WDI (2002-2025), UNSC-Mitgliedschaft (DPPA, 1946-heute). Original-Replikationsdatensatz: `data/final/Dreher_Sturm_Vreeland_JCR.dta`.

**Abhaengige Variable in zwei Operationalisierungen:**
- `avgcondtype_count` — durchschnittliche Anzahl Bedingungen pro Quartal (anzahlbasiert wie im Original; dort heisst die Variable `avgcondtype_all`, Benchmark unsc3 = -2.1 GLS / -3.3 OLS)
- `avgcondtype_share` — Anteil der als rohstoff-/stabilisierend klassifizierten Bedingungen (eigene Erweiterung fuer H2/H4)

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
| `code/replication/phase0_replikation_original.R` | **Spur A (Benchmark):** Reproduktion von Tabelle 2 auf dem Original-Datensatz (FE-OLS + GLS) plus Zeitfenster-Zerlegung 1992-2001/2002-2008 | `results/tables/original_replication.csv`, `results/models/model_original_*.rds` |
| `code/replication/phase1_replizierung.r` | **Spur B:** H1 global in BEIDEN Operationalisierungen (count + share) und zwei Kontrollsaetzen (Basis / + nrcntprogram), jeweils alle Jahre + Vergleichsfenster 2002-2008 | `results/model_repl*.rds`, `results/validation_repl.csv` |
| `code/analysis/phase2_erweiterung.R` | Globale Durchschnittsmodelle H1, H2, H4 (ohne Regionen) | `results/models/model_h1/h2/h4.rds`, `results/tables/results_h1_h4.csv` |
| `code/analysis/laender_ausreisser_analyse.R` | Laenderuebersicht, Extremwerte, Leave-one-out-Einfluss auf unsc3 | `results/tables/country_summary.csv`, `outlier_extremewerte.csv`, `influence_unsc3.csv` |
| `code/analysis/h1_sample_zerlegung.R` | Dokumentation: Woher kam das fruehere negative H1-Vorzeichen? (Reproduktion des alten SSA-Befunds + Stufung nach Laenderpool und Zeitfenster) | `results/tables/h1_sample_zerlegung.csv` |
| `code/replication/final_robustness_check.R` | Pooled OLS, Year FE, Two-way FE, BP-/White-Tests, HC1-SE | `results/tables/robustness_checks.csv/.tex` |
| `R/regional_effect_summary.R` | Optionale Helferfunktion: erst NUTZBAR, wenn der Autor selbst Regionsgruppen festgelegt hat | (Rueckgabeobjekt) |

### Kernergebnisse (Stand 2026-09-24, globaler Pool, alle Jahre)

- **Spur A, Benchmark (Originaldatensatz, `original_replication.csv`):** Reproduktion von Tabelle 2: FE-OLS unsc3 = -3.06 (p=0.076) vs. publiziert -3.329; GLS (RE) unsc3 = -2.45 (p=0.076) vs. publiziert -2.096. Zeitfenster-Zerlegung: Der Effekt lebt in den 1990ern (1992-2001: FE -4.65, p=0.042; 2002-2008: GLS -1.86, n.s., FE kollinear). Ab 2002 ist der Befund auch auf den Originaldaten statistisch Null.
- **H1 (Replikationsspezifikation, avgcondtype_count):** unsc3 = +3.11 (p=0.073) ueber alle Jahre; im Originalzeitraum 2002-2008: +3.45 (p=0.48). Der negative Original-Befund (ca. 2 Bedingungen pro Quartal weniger fuer UNSC-Mitglieder) laesst sich in diesem Panel nicht reproduzieren; der Punktcoeffizient zeigt tendenzmaessig in die Gegenrichtung. (Caveat: Das Originalmodell nutzt zusaetzliche Kovariaten — Wahljahr, US-Hilfe, IWF-Kredite — und den Zeitraum 1992-2008.)
- **H1 mit erweiterten Kontrollen (+ nrcntprogram):** +2.93 (p=0.090) ueber alle Jahre — das Ergebnis ist gegen die Programmhistorien-Kontrolle robust (Original-Kontrolle "count" analog nachgebaut; die uebrigen Original-Kovariaten benoetigen zusaetzliche Datenquellen, siehe Beschaffungsliste).
- **H1 (Anteilsspezifikation, avgcondtype_share):** unsc3 = +0.076, p=0.12 (alle Jahre) bzw. +0.018, p=0.91 (2002-2008). Ebenfalls kein negativer Effekt.
- **H2 (Durchschnitt):** Interaktion unsc3 x resource_dep insignifikant (+0.0012, p=0.60).
- **H4 (Durchschnitt):** resource_dep ist marginal positiv mit dem Anteil rohstoffspezifischer Bedingungen assoziiert (p=0.078); die UNSC-Interaktion ist insignifikant.
- **Herkunft des frueheren negativen Vorzeichens** (`h1_sample_zerlegung.csv`): Der alte Wert (-1.25) beruhte auf dem 20-SSA-Subsample und einer anders berechneten anzahlbasierten Variable; selbst im SSA-Subsample ist die Count-Metrik des neuen Panels positiv (+4.93 bzw. +3.53, n.s.).
- **Laenderergebnisse/Ausreisser:** Hoechste Rohstoffabhaengigkeit: AGO, IRQ, COG, MNG, YEM, PAN. Hoechste Konditionalitaet: COG, TCD, COD, CAF, YEM. Leave-one-out: Kein einzelnes Land dominiert den H1-Koeffizienten; die Durchschnittsbefunde sind nicht auf ein Land zurueckzufuehren.

**Stichprobengroessen:** Panel 333 Land-Jahr-Beobachtungen (99 Laender); Complete Cases H1: 214 (FE-Modell: 204 nach Singleton-Entfall), H2/H4: 171 (FE-Modell: 158).

---

## Naechste Schritte

1. Laender- und Ausreisserbefunde sichten (`results/tables/country_summary.csv`, `outlier_extremewerte.csv`, `influence_unsc3.csv`).
2. Erst danach: eigene, deskriptive Regionsgruppierung festlegen (z. B. mit `R/regional_effect_summary.R`) und Heterogenitaet beschreiben.
3. Ergebnisse in die Hausarbeit ueberfuehren (LaTeX-Geruest in `latex/`).

## Archiv

- `archive/ssa_legacy/`: komplette alte SSA-Pipeline (20-Laender-Fokus).
- `archive/superseded/`: durch die aktuelle Pipeline ersetzte Skripte.
