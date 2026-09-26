# IMF-Konditionalität und UNSC-Mitgliedschaft: globale Replizierung

**Projektstruktur und Arbeitsplan:** `docs/projektaufraeumen_2026-09-26.md` (ersetzt die alten Tages-/12-Tage-Plane). **Arbeitssessions** mit Protokollen und Code-Staenden: `sessions/` (Session 1-6 dokumentiert; neue Sessions nach dem dortigen Muster anlegen; Skripte kanonisch NUR in `code/`). **Replikationsanleitung** (kanonisch, nur im Projektstamm): `Replikationsanleitung_Gesamtzeitraum.md` (Rev. 4 — nicht nach `code/` kopieren; Versionsverlust-Gefahr).

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

## Replikations-Fundament (Spur A / Originalzeitraum, Stand 2026-09-25)

Aus den Original-Konstruktionsdateien (`data/raw/original/construction/`) ist der Konditionalitaets- und UNSC-Block des Originals vollstaendig nachgebaut und gegen den Originaldatensatz validiert (314/314 identisch in `nrcondtype_all/pc/pa/sb`, `nrquarterssmpl`, `nrcntprogram`, `unsc3`, `avgcondtype_all`):

```
data/raw/original/construction/Data MONA.dta
    -> code/data_prep/rebuild_conditionality_1992_2008.R
       (Crosswalk, Zaehlung, Quartalsregel, Jahresverschiebungen, unsc3)
    -> data/processed/crosswalk_dsv_iso3.csv           (102 Laender -> ISO3)
    -> data/processed/conditionality_dsv_1992_2008.csv (314 Land-Jahre)

data/raw/unsc/unsc_membership_ISO3_correct.csv
    -> code/data_prep/build_unsc_dsv_rule.R
    -> data/processed/unsc_dsv_rule_1946_2026.csv      (unsc3 = t | t+1)

data/raw/wdi/Data_all/*.csv + data/raw/wdi/wdi_*.csv
    -> code/data_prep/build_controls_wdi.R
    -> data/processed/controls_wdi_1990_2025.csv       (266 Laender)
```

**WDI-/DPI-Kontrollpanel (2026-09-26, final):** Alle Einzelserien in `data/raw/wdi/Data_all/` laufen durchgehend 1990-2025 (`dpi_all.csv` bis 2023); `resource_dep_all.csv` enthaelt drei Serien (NE.EXP.GNFS.ZS = Exporte % BIP als `ExportGDP` gefuehrt, sowie TX.VAL.FUEL.ZS.UN und TX.VAL.MMTL.ZS.UN -> `resource_dep` ab 1990). Damit alle 9 DSV-Kontrollen 1992-2025 verfuegbar, inkl. `legelec_l` aus DPI. Caveats (dokumentiert in `build_controls_wdi.R` und `results/tables/wdi_kontrollen_vintage_check.csv`): **IMF-Diagnose (korrigiert 2026-09-26):** Die Original-Variablen `imf_conc_gdp`/`imf_noconc_gdp` koennen NEGATIV sein und ihre Summe korreliert mit den NFL-Nettofluesse-Serien (DT.NFL.IMFC/IMFN.CD) mit **0.835** — das Original misst also NETTOFLUESSE, nicht Kreditbestand. Die NFL-Serien im Kontrollpanel sind damit konzepttreu; die Komponenten-Korrelationen (0.35/-0.00) ruehren daher, dass die Quellen die Aufteilung konzessionaer/nicht-konzessionaer anders klassifizieren. `UseofIMFCredit_all.csv` (DT.DOD.DIMF.CD, Kreditbestand je Land 1990-2025) ist als `UseIMFCredGDP` im Panel enthalten — ein sauber definierter, aber ANDERER Konzept (Bestand statt Fluss), als Alternative/Kontrollgroesse, nicht als Ersatz. `OutCreditIMF_all.xlsx` bleibt das globale Aggregat (nur Summen-Referenz). Vintage-Vergleich gegen Original: Korrelationen 0.93-0.98, legelec_l 0.978 (Ausnahmen: GFCFGDP 0.70; USaidGDP -14% Median-Abweichung durch Konzeptunterschied Markt- vs. Faktorkosten-BIP).

Wichtige verifizierte Regeln: `unsc3` = UNSC-Mitgliedschaft im Jahr t ODER t+1 ("election year included", LEAD); `nrquarterssmpl = round((min(Enddatum, 28.09.2008) - max(Approval, 31.03.1992))/90)`; Bedingungenzaehlung = Zeilenzahl des 2008er-Exportformats (kein Dedup); zwei dokumentierte Jahresverschiebungen (Senegal 29.08.1994 -> 1995, Uganda 15.12.2006 -> 2007). Voller Katalog: `Replikationsanleitung_Gesamtzeitraum.md`.

**Gate-Status des eigenen Panels (2000-2026):** faellt gegen den Nachbau durch (88 Ueberlappungen, Median-Verhaeltnis 2.1, 0% exakt) und muss vor der Hypothesenpruefung neu ausgerichtet werden: (a) `unsc3` auf die DSV-Regel umstellen (das eigene Panel kodiert zurueckliegende Mitgliedschaft, 4 Diskrepanzen im Ueberlapp), (b) MONA-Granularitaet an das 2008er-Exportformat angleichen, (c) Quartalsregel uebernehmen.

---

## Analyse-Skripte und Ergebnisse

| Skript | Inhalt | Output |
|--------|--------|--------|
| `code/replication/phase0_replikation_original.R` | **Spur A (Benchmark):** Reproduktion von Tabelle 2 auf dem Original-Datensatz (5 Spalten je xtreg fe und xtgls panels(hetero)) plus Zeitfenster-Zerlegung 1992-2001/2002-2008 | `results/tables/original_replication.csv`, `results/tables/original_replication_zeitfenster.csv`, `results/models/model_original_*.rds` |
| `code/replication/phase1_replizierung.r` | **Spur B:** H1 global in BEIDEN Operationalisierungen (count + share) und zwei Kontrollsaetzen (Basis / + nrcntprogram), jeweils alle Jahre + Vergleichsfenster 2002-2008 | `results/model_repl*.rds`, `results/validation_repl.csv` |
| `code/analysis/phase2_erweiterung.R` | Globale Durchschnittsmodelle H1, H2, H4 (ohne Regionen) | `results/models/model_h1/h2/h4.rds`, `results/tables/results_h1_h4.csv` |
| `code/replication/phase1_replikation_gesamtzeitraum.R` | **Schritt-6-Abschluss:** alle 5 Tabellen-2-Varianten je FE und GLS auf Spur-B-Basis; dreispaltige Validierungstabelle publiziert \| Spur A \| Spur B | `results/tables/replication_gesamtzeitraum.csv` |
| `code/analysis/hypothesen_original_basis.R` | **H1–H4 auf der Original-Zaehlbasis 1992–2008** (validierter Nachbau, unsc3 = t \| t+1, Kontrollen aus Original-.dta; H2/H4 nur Ueberlapp 2002–2006 mit 2 UNSC-Faellen, s. Kernergebnisse) | `results/tables/hypothesen_original_basis.csv`, `results/models/model_origbasis_*.rds` |
| `code/analysis/laender_ausreisser_analyse.R` | Laenderuebersicht, Extremwerte, Leave-one-out-Einfluss auf unsc3 | `results/tables/country_summary.csv`, `outlier_extremewerte.csv`, `influence_unsc3.csv` |
| `code/analysis/h1_sample_zerlegung.R` | Dokumentation: Woher kam das fruehere negative H1-Vorzeichen? (Reproduktion des alten SSA-Befunds + Stufung nach Laenderpool und Zeitfenster) | `results/tables/h1_sample_zerlegung.csv` |
| `code/analysis/zeitraeume_krisen_robustheit.R` | Krisen-Robustheit: Ausschlussfenster 2008-2010/2020-2022, Jahres-FE, unsc3 x Krise | `results/tables/krisen_robustheit.csv` |
| `code/replication/final_robustness_check.R` | Pooled OLS, Year FE, Two-way FE, BP-/White-Tests, HC1-SE | `results/tables/robustness_checks.csv/.tex` |
| `R/regional_effect_summary.R` | Optionale Helferfunktion: erst NUTZBAR, wenn der Autor selbst Regionsgruppen festgelegt hat | (Rueckgabeobjekt) |

### Kernergebnisse (Stand 2026-09-24, globaler Pool, alle Jahre)

- **Spur A, Benchmark (Originaldatensatz, `original_replication.csv`):** Reproduktion von Tabelle 2 nach den Original-Schaetzdateien (`data/raw/original/construction/JCR_DSV_Table2.doh`), fuenf Spalten je FE (xtreg fe) und GLS (xtgls panels(hetero) force nmk, manueller FGLS-Nachbau): Basis-FE unsc3 = -2.410 (t=-1.906, N=314, identisch mit `JCR_DSV_Table2.txt`); Vollmodell-FE unsc3 = -3.329 (t=-1.950, N=217, exakt wie publiziert); Vollmodell-GLS unsc3 = -2.096 (Punktschätzer exakt; t(nmk) = -3.97 vs. publiziert -4.02, SE-Skalierungsdetail). Die fruehere Abweichung (-3.06/-2.45) beruhte auf falschem Regressorsatz (nrcntprogram statt nrquarterssmpl) und Random Effects statt xtgls. Zeitfenster-Zerlegung (korrigierter Regressorsatz, `original_replication_zeitfenster.csv`): 1992-2001 Vollmodell-FE unsc3 = -4.98 (t=-2.20); 2002-2008 statistisch Null (Basis-FE +0.26, t=0.13; im Vollmodell dort mit den Laender-Dummies kollinear). Der Befund lebt in den 1990ern.
- **H1-H4 auf der Original-Zaehlbasis (`hypothesen_original_basis.R`, `hypothesen_original_basis.csv`, aktualisiert 2026-09-26):** Basis: der 314/314-validierte Nachbau (`conditionality_dsv_1992_2008.csv`), unsc3 nach DSV-Regel (t | t+1), Kontrollen aus dem Original-.dta, resource_dep aus neuer WDI (TX.VAL.FUEL.ZS.UN + TX.VAL.MMTL.ZS.UN, ab 1990). Ergebnisse: (M1_base, Sanity) Tabellen-2-Spezifikation reproduziert unsc3 = -2.410 exakt; **H1** (avgcondtype_all, Two-way FE, N=266): unsc3 = -2.43 (p=0.095) — der negative UNSC-Effekt bestaetigt sich auf der korrekt gemessenen Basis, das Vorzeichenproblem des alten Panels (+3.11) ist geklaert (Messung + unsc3-Richtung). **H1-WDI-Variante** (5 Kontrollen aus neuer WDI statt Original-.dta, N=175): unsc3 = -3.11 (p=0.095) — vintage-robust. **H2** (unsc3 * resource_dep, volle Periode, N=180 CC mit 13 unsc3-Faellen, 1992-2006): unsc3 = -4.59 (p=0.058), Interaktion +0.134 (p=0.156) — Richtung wie hypothesisiert (Rohstoffabhaengigkeit abschwaeecht den UNSC-Rabatt), aber nicht signifikant. **H4** (rohstoff_cond_share, N=180): mit der KURIERTEN Ressourcen-Klassifikation (Session 7: Join auf die Review-Datei `bedingungsbeschreibungen_review.csv`, kein Inline-Regex mehr) unsc3 = -0.005 (n.s.), Interaktion +0.00003 (n.s.); Sensitivitaet mit breiterer Energie-Kategorie (H4_energie) ebenfalls n.s. Diagnose: rohstoffspezifische Bedingungen sind in dieser Periode SELTEN (82 von 22.810 = 0.4 % nach abgeschlossenem Autor-Review; die alte breite Keyword-Regel zaehlte 446 Zeilen inkl. 137 Bank-Privatisierungen als "rohstoff") — H4 ist damit vor allem ein Konstrukt-Gueltigkeitsproblem, kein blosses Power-Problem. Autor-Review der Top-200-Beschreibungen abgeschlossen: Vorschlag bestaetigt, Agrar-Korrekturen (edible/cooking oil -> 0) und 5 Grenzfall-Entscheide (Gas-Anteil zaehlt) angewendet und in der Review-Datei dokumentiert. Erste belastbare Hypothesentests; Restriktionen: approvals 2007/08 entfallen (fehlende Original-Kontrollen), fuel-Serie beginnt ~1995. **Dreispaltige Validierungstabelle** (`replication_gesamtzeitraum.csv`, 2026-09-26): Basis-FE Spur B = Spur A = publiziert (-2.410, Abweichung 0); Vollmodell-FE Spur B -4.40 (t=-2.27, N=174) vs. publiziert -3.329 (Abweichung ~1.1 Punkte, benannte Ursachen: IMF-NFL-Konzept, USaidGDP-BIP-Definition, WDI-Vintage); Vollmodell-GLS Spur B -1.90 (t=-2.19, N=165) vs. publiziert -2.096 (+9%, in Toleranz). `legelec_l` rekonstruiert aus `dpi_all.csv` (DPI-2023-Stand; Lag auf Kalenderjahr t-1, Korrelation mit Original 0.978; 4 nicht parsbare Chile-Zeilen 2014-17 verworfen, ausserhalb des Original-Zeitraums). IMF-Serien (NFL-Nettofluesse) sind konzepttreu: Diagnose 2026-09-26 zeigt, dass das Original ebenfalls Nettofluesse misst (Summen-Korrelation 0.835); nur die Typen-Aufteilung weicht ab. `UseIMFCredGDP` (DT.DOD.DIMF.CD, Bestand) als Alternativ-Konzept im Panel.
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
