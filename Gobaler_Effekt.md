# Globaler Effekt: Erweiterter Länderpool und regionale Differenzierung

## Ziel

Der bisherige SSA-Fokus für H2 und H3 kann durch einen erweiterten Länderpool aus H1 ergänzt werden. Dadurch lässt sich prüfen, ob ein möglicher Effekt zwischen UNSC-Mitgliedschaft, Rohstoffabhängigkeit und IMF-Konditionalität wirklich regional begrenzt ist oder auch außerhalb SSA auftritt.

## Schritt 1: Daten für den erweiterten Pool laden

Wenn der globale H1-Datensatz vorliegt, wird dieser geladen. Der relevante Datensatz sollte die im Panel enthaltenen Variablen für ISO3, Year, avgcondtype_all, unsc3, Rohstoffabhängigkeit sowie die Kontrollvariablen umfassen.

```r
library(tidyverse)
library(fixest)

global_data <- read.csv("data/processed/final_data_panel_ALL.csv",
                        stringsAsFactors = FALSE)

# Falls die Variable anders heißt
if (!"resource_dep" %in% names(global_data)) {
  if ("Rohstoffabhängigkeit" %in% names(global_data)) {
    global_data <- global_data %>% rename(resource_dep = Rohstoffabhängigkeit)
  } else if (all(c("FuelExportPct", "MineralExportPct") %in% names(global_data))) {
    global_data <- global_data %>%
      mutate(resource_dep = FuelExportPct + MineralExportPct)
  }
}
```

Wenn kein globaler Datensatz vorliegt, muss dieser zunächst aus den vorhandenen Rohdaten bzw. dem H1-Panel rekonstruiert werden.

## Schritt 2: Regionale Gruppen definieren

Das Ziel ist nicht, SSA als festen Fokus zu nehmen, sondern empirisch zu prüfen, welche Regionen im erweiterten Pool auffällig sind.

```r
ssa_countries <- c("AGO", "CAF", "CMR", "COM", "CPV", "GAB", "GHA", "GIN",
                   "KEN", "LSO", "MDG", "MOZ", "MRT", "MWI", "RWA",
                   "SLE", "SLV", "TZA", "UGA", "ZMB")

global_data <- global_data %>%
  mutate(
    region = case_when(
      ISO3 %in% ssa_countries ~ "SSA",
      TRUE ~ "Other"
    ),
    resource_high = ifelse(resource_dep >= median(resource_dep, na.rm = TRUE), 1, 0)
  )
```

Falls weitere Regionen separat betrachtet werden sollen, kann die Regionendefinition erweitert werden.

## Schritt 3: Regionale Unterschiede deskriptiv prüfen

Zuerst sollten die deskriptiven Muster betrachtet werden, bevor Regressionsmodelle interpretiert werden.

```r
region_summary <- global_data %>%
  group_by(region) %>%
  summarise(
    n_countries = n_distinct(ISO3),
    avg_cond = mean(avgcondtype_all, na.rm = TRUE),
    avg_resource = mean(resource_dep, na.rm = TRUE),
    unsc_share = mean(unsc3, na.rm = TRUE),
    .groups = "drop"
  )

print(region_summary)
```

Ziel: herausfinden, welche Regionen besonders stark von der allgemeinen Beziehung abweichen, z. B. hohe Rohstoffabhängigkeit oder hohe IMF-Konditionalität.

## Schritt 4: Ländervergleich auf Ebene einzelner Länder

Ein Ländervergleich kann zeigen, welche Länder als Ausreißer oder starke Kontraste die durchschnittlichen Effekte treiben.

```r
country_summary <- global_data %>%
  group_by(ISO3, region) %>%
  summarise(
    avg_cond = mean(avgcondtype_all, na.rm = TRUE),
    avg_resource = mean(resource_dep, na.rm = TRUE),
    unsc_share = mean(unsc3, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resource))

print(country_summary)
```

Auffällige Länder sollten anschließend genauer analysiert werden.

## Schritt 5: Globales Modell mit regionalen Interaktionen

Der globale Vergleich kann mit Interaktionen getestet werden:

```r
model_global <- feols(
  avgcondtype_all ~ unsc3 * resource_dep * region +
    XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = global_data,
  vcov = "hetero"
)

summary(model_global)
```

Diese Spezifikation prüft, ob der Effekt von UNSC-Mitgliedschaft und Rohstoffabhängigkeit je nach Region unterschiedlich ist.

## Schritt 6: Alternative, lesbarere Interaktionsspecifikation

Wenn die 3-Wege-Interaktion zu komplex ist, kann eine weniger direkte Form verwendet werden:

```r
model_global_2 <- feols(
  avgcondtype_all ~ unsc3 * resource_dep + unsc3 * region + resource_dep * region +
    XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = global_data,
  vcov = "hetero"
)

summary(model_global_2)
```

Damit ist leichter erkennbar, in welchen Regionen der Effekt stärker oder schwächer ist.

## Schritt 7: Regionenspezifische Subset-Modelle

Wenn eine Region auffällt, sollte sie separat modelliert werden:

```r
ssa_model <- feols(
  avgcondtype_all ~ unsc3 * resource_dep + XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = subset(global_data, region == "SSA"),
  vcov = "hetero"
)

other_model <- feols(
  avgcondtype_all ~ unsc3 * resource_dep + XDebtGNI + DebtServGNI + ResXDebt | ISO3 + Year,
  data = subset(global_data, region == "Other"),
  vcov = "hetero"
)

summary(ssa_model)
summary(other_model)
```

Dies erlaubt einen direkten Vergleich, ob der Effekt in einer Region tatsächlich stärker oder anders ausgeprägt ist.

## Interpretation

Die regionale Differenzierung sollte nicht a priori auf SSA festgelegt werden. Stattdessen sollten empirisch auffällige Regionen identifiziert werden. Falls eine Region im globalen Pool deutlich hervortritt, können anschließend einzelne Länder bzw. regionale Cluster näher untersucht werden, um zu prüfen, ob die Beziehung auf eine kleine Zahl von Ausreißern zurückzuführen ist oder ein breiteres regionales Muster darstellt.

Das Vorgehen ist methodisch sauber und vermeidet eine vorurteilsbehaftete Regionalisierung.
