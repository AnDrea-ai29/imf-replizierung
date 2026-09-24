# Laenderergebnisse und Ausreisseranalyse (VOR jeder Regionsdefinition)
# Zweck (Neu.md Abschnitt 6): erst globale Durchschnittsergebnisse, dann
# einzelne Laenderergebnisse und moegliche Ausreisser betrachten. Regionen
# sind allein ein spaeteres, deskriptives Hilfsmittel des Autors.
#
# Output:
# - results/tables/country_summary.csv        : Laenderuebersicht
# - results/tables/outlier_extremewerte.csv   : Extremwerte je Dimension
# - results/tables/influence_unsc3.csv       : Einfluss jedes Landes auf den
#     unsc3-Koeffizienten (Leave-one-out) in H1 und H2

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(fixest)

d <- read.csv("data/processed/final_data_panel_ALL.csv",
              stringsAsFactors = FALSE) %>%
  mutate(resource_dep = FuelExportPct + MineralExportPct)

ctrl <- "XDebtGNI + DebtServGNI + ResXDebt"

# ---------------------------------------------------------------------------
# 1) Laenderuebersicht: Ergebnisse je Land
# ---------------------------------------------------------------------------
country_summary <- d %>%
  group_by(ISO3) %>%
  summarise(
    n_obs = n(),
    jahr_von = min(Year),
    jahr_bis = max(Year),
    avg_cond = round(mean(avgcondtype_all, na.rm = TRUE), 3),
    avg_resource_dep = round(mean(resource_dep, na.rm = TRUE), 1),
    avg_rohstoff_cond_share = round(mean(rohstoff_cond_share, na.rm = TRUE), 3),
    n_unsc_jahre = sum(unsc3 == 1, na.rm = TRUE),
    unsc_jahre = paste(sort(Year[!is.na(unsc3) & unsc3 == 1]), collapse = ";"),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resource_dep))

write.csv(country_summary, "results/tables/country_summary.csv", row.names = FALSE)
cat("=== Laenderuebersicht (obere 15 nach Rohstoffabhaengigkeit) ===\n")
print(as.data.frame(head(country_summary, 15)), row.names = FALSE)

# ---------------------------------------------------------------------------
# 2) Extremwerte je Dimension
# ---------------------------------------------------------------------------
extrem <- bind_rows(
  country_summary %>%
    filter(!is.na(avg_resource_dep)) %>%
    slice_max(avg_resource_dep, n = 10) %>%
    transmute(dimension = "avg_resource_dep (hoechste)", ISO3,
              wert = avg_resource_dep),
  country_summary %>%
    filter(!is.na(avg_cond)) %>%
    slice_max(avg_cond, n = 10) %>%
    transmute(dimension = "avg_cond (hoechste)", ISO3, wert = avg_cond),
  country_summary %>%
    filter(!is.na(avg_cond)) %>%
    slice_min(avg_cond, n = 10) %>%
    transmute(dimension = "avg_cond (niedrigste)", ISO3, wert = avg_cond),
  country_summary %>%
    filter(!is.na(avg_rohstoff_cond_share)) %>%
    slice_max(avg_rohstoff_cond_share, n = 10) %>%
    transmute(dimension = "avg_rohstoff_cond_share (hoechste)", ISO3,
              wert = avg_rohstoff_cond_share)
)

write.csv(extrem, "results/tables/outlier_extremewerte.csv", row.names = FALSE)
cat("\n=== Extremwerte ===\n")
print(as.data.frame(extrem), row.names = FALSE)

# ---------------------------------------------------------------------------
# 3) Einfluss jedes Landes auf den unsc3-Koeffizienten (Leave-one-out)
# ---------------------------------------------------------------------------
cc_h1 <- d %>%
  filter(complete.cases(across(c("avgcondtype_all", "unsc3",
                                 "XDebtGNI", "DebtServGNI", "ResXDebt"))))
cc_h2 <- cc_h1 %>%
  filter(complete.cases(across(c("resource_dep"))))

m_h1_full <- feols(as.formula(paste("avgcondtype_all ~ unsc3 +", ctrl, "| ISO3 + Year")),
                   data = cc_h1, vcov = "hetero")
m_h2_full <- feols(as.formula(paste("avgcondtype_all ~ unsc3 * resource_dep +", ctrl, "| ISO3 + Year")),
                   data = cc_h2, vcov = "hetero")

cat("\nReferenz H1: unsc3 =", round(coef(m_h1_full)["unsc3"], 4),
    "| N =", nobs(m_h1_full), "\n")
cat("Referenz H2: unsc3 =", round(coef(m_h2_full)["unsc3"], 4),
    ", Interaktion =", round(coef(m_h2_full)["unsc3:resource_dep"], 4),
    "| N =", nobs(m_h2_full), "\n\n")

influence <- lapply(sort(unique(cc_h1$ISO3)), function(land) {
  h1 <- tryCatch(
    feols(as.formula(paste("avgcondtype_all ~ unsc3 +", ctrl, "| ISO3 + Year")),
          data = filter(cc_h1, ISO3 != land), vcov = "hetero", warn = FALSE),
    error = function(e) NULL
  )
  h2 <- tryCatch(
    feols(as.formula(paste("avgcondtype_all ~ unsc3 * resource_dep +", ctrl, "| ISO3 + Year")),
          data = filter(cc_h2, ISO3 != land), vcov = "hetero", warn = FALSE),
    error = function(e) NULL
  )
  data.frame(
    ISO3 = land,
    delta_unsc_h1 = if (!is.null(h1)) coef(h1)["unsc3"] - coef(m_h1_full)["unsc3"] else NA_real_,
    delta_unsc_h2 = if (!is.null(h2)) coef(h2)["unsc3"] - coef(m_h2_full)["unsc3"] else NA_real_,
    delta_interaktion_h2 = if (!is.null(h2) && "unsc3:resource_dep" %in% names(coef(h2)))
      coef(h2)["unsc3:resource_dep"] - coef(m_h2_full)["unsc3:resource_dep"] else NA_real_,
    n_unsc_jahre = sum(cc_h1$unsc3[cc_h1$ISO3 == land] == 1),
    stringsAsFactors = FALSE
  )
})

influence <- bind_rows(influence) %>%
  arrange(desc(abs(delta_unsc_h1)))

write.csv(influence, "results/tables/influence_unsc3.csv", row.names = FALSE)
cat("=== Einfluss auf unsc3-Koeffizienten (Leave-one-out, top 15 nach |Delta H1|) ===\n")
print(as.data.frame(head(influence, 15)), row.names = FALSE)

cat("\nGespeichert: country_summary.csv, outlier_extremewerte.csv, influence_unsc3.csv\n")
