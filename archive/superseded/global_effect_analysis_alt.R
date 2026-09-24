# Globaler Effekt: erweiterter Länderpool mit regionaler Differenzierung
# Zweck: H1-Länderpool erweitern, regionale Unterschiede prüfen,
# auffällige Regionen bzw. Länder genauer analysieren.

library(tidyverse)
library(fixest)

# 1) Datensatz laden ---------------------------------------------------------
# Verwende den globalen H1-Panel, falls verfügbar
if (!file.exists("data/processed/final_data_panel_ALL.csv")) {
  stop("final_data_panel_ALL.csv fehlt. Bitte H1-Datensatz erzeugen oder anpassen.")
}

global_data <- read.csv("data/processed/final_data_panel_ALL.csv",
                        stringsAsFactors = FALSE)

# Resource dependency standardisieren
if (!"resource_dep" %in% names(global_data)) {
  if ("Rohstoffabhängigkeit" %in% names(global_data)) {
    global_data <- global_data %>% rename(resource_dep = Rohstoffabhängigkeit)
  } else if (all(c("FuelExportPct", "MineralExportPct") %in% names(global_data))) {
    global_data <- global_data %>%
      mutate(resource_dep = FuelExportPct + MineralExportPct)
  } else {
    stop("resource_dep konnte nicht rekonstruiert werden.")
  }
}

# 2) Kein vordefinierter Regionendummy; nur globale Analyse + Ländervergleich
global_data <- global_data %>%
  mutate(
    resource_high = ifelse(resource_dep >= median(resource_dep, na.rm = TRUE), 1, 0)
  )

# 3) Globaler Überblick ohne feste Regionen
country_summary <- global_data %>%
  group_by(ISO3) %>%
  summarise(
    avg_cond = mean(avgcondtype_all, na.rm = TRUE),
    avg_resource = mean(resource_dep, na.rm = TRUE),
    unsc_share = mean(unsc3, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resource))

print(country_summary)

# 4) Ausreißer / auffällige Länder identifizieren
top_resource_countries <- country_summary %>%
  filter(avg_resource > quantile(avg_resource, 0.75, na.rm = TRUE))

print(top_resource_countries)

# 5) Reines globales Gesamtmodell ohne vordefinierte Regionen
model_global <- feols(
  avgcondtype_all ~ unsc3 * resource_dep +
    XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = global_data,
  vcov = "hetero"
)

summary(model_global)

# 6) Alternative globale Spezifikation ohne Regionendummy
model_global_2 <- feols(
  avgcondtype_all ~ unsc3 + resource_dep + unsc3:resource_dep +
    XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = global_data,
  vcov = "hetero"
)

summary(model_global_2)

# 8) Ergebnisobjekte ---------------------------------------------------------
# Datengetriebene globale Analyse ohne feste Regionen
saveRDS(model_global, "results/models/model_global_region.rds")
write.csv(country_summary, "results/tables/country_summary.csv", row.names = FALSE)
write.csv(top_resource_countries, "results/tables/top_resource_countries.csv", row.names = FALSE)

