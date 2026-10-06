library(sess package)

setwd("C:/Users/HP/io/imf-replizierung")

## Erzeugen die UNSC-Zuordnung, den validierten historischen Zählvergleich und das Kontrollpanel
Rscript "code/shared/data_prep/create_unsc_correct.R"
Rscript "code/shared/data_prep/build_unsc_dsv_rule.R"
Rscript "code/shared/data_prep/rebuild_conditionality_1992_2008.R"
Rscript "code/shared/data_prep/build_controls_wdi.R"

## baut direkt aus den historischen und aktuellen MONA-Rohdaten die einheitliche Zähl-AV
## und speichert: `data\processed\phase_b_panel_identical_measurement_1992_2025.csv`
Rscript "code/phase_b/data_prep/build_phase_b_identical_measurement.R"


## Aufbau der Klassifikationsdaten für H4
    # Anwendung der gemeinsamen Klassifikationsregel auf modernen MONA-Datensatz (Comined_ISO.xlsx) an
    # Ergebnis: data/processed/phase_b_classification_crosswalk.csv
Rscript "code/shared/data_prep/build_phase_a_definition_crosswalk.R"
    # Anwendung der gemeinsamen Klassifikationsregel auf historischen und modernen MONA-Datensatz 
    # + Aggregations zu Land-Jahr-Werten 
    # + Erstellen des Prüfprotokolls für historische Bedingungen
    # Ergebnis: data/processed/phase_b_h4_panel_1992_2025.csv
Rscript "code/phase_b/data_prep/build_phase_b_h4_panel.R"

## Analyseskript
Rscript "code/phase_b/analysis/phase_b_hypothesen_robustheit.R"


## Aufbereitung für manuelle Exploration der H3-Ergebnisse
Rscript "code/phase_b/analysis/phase_b_h3_exploration.R"