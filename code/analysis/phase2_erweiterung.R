# H1-H4 im globalen Laenderpool (ALLE Laender aus Combined_ISO.xlsx, ALLE Jahre)
# Kein SSA-Filter, keine Jahr-Beschraenkung.
# Modelle (Neu.md Schritt 5-6):
#   M1 (H1): avgcondtype_all ~ unsc3 + Kontrollen
#   M2 (H2): avgcondtype_all ~ unsc3 * resource_dep + Kontrollen
#   M3 (H3): + regionale Interaktionen (unsc3 * region, resource_dep * region)
#   M4 (H4): rohstoff_cond_share ~ unsc3 * resource_dep + Kontrollen

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(fixest)

d <- read.csv("data/processed/final_data_panel_ALL.csv",
              stringsAsFactors = FALSE)

d <- d %>%
  mutate(
    region = factor(region),
    resource_dep = FuelExportPct + MineralExportPct
  )

cat("Panel:", nrow(d), "Beobachtungen,",
    n_distinct(d$ISO3), "Laender, Jahre",
    min(d$Year), "-", max(d$Year), "\n")

ctrl <- "XDebtGNI + DebtServGNI + ResXDebt"

# ---------------------------------------------------------------------------
# Deskriptive Regionalanalyse (Neu.md Phase 4)
# ---------------------------------------------------------------------------
region_summary <- d %>%
  group_by(region) %>%
  summarise(
    n_countries = n_distinct(ISO3),
    n_obs = n(),
    n_unsc3 = sum(unsc3 == 1, na.rm = TRUE),
    unsc_share = round(mean(unsc3, na.rm = TRUE), 3),
    avg_cond = round(mean(avgcondtype_all, na.rm = TRUE), 3),
    avg_resource_dep = round(mean(resource_dep, na.rm = TRUE), 1),
    n_resource_obs = sum(!is.na(resource_dep)),
    .groups = "drop"
  ) %>%
  arrange(desc(n_obs))

write.csv(region_summary, "results/tables/region_summary.csv", row.names = FALSE)
cat("\n=== Regionale Deskriptive ===\n")
print(as.data.frame(region_summary), row.names = FALSE)

# ---------------------------------------------------------------------------
# Modelle
# ---------------------------------------------------------------------------
cat("\n=== M1 (H1-Basis): global, alle Jahre ===\n")
model_h1 <- feols(
  as.formula(paste("avgcondtype_all ~ unsc3 +", ctrl, "| ISO3 + Year")),
  data = d, vcov = "hetero"
)
print(summary(model_h1))

cat("\n=== M2 (H2): unsc3 * resource_dep ===\n")
model_h2 <- feols(
  as.formula(paste("avgcondtype_all ~ unsc3 * resource_dep +", ctrl, "| ISO3 + Year")),
  data = d, vcov = "hetero"
)
print(summary(model_h2))

cat("\n=== M3 (H3): mit regionalen Interaktionen ===\n")
model_h3 <- feols(
  as.formula(paste("avgcondtype_all ~ unsc3 * resource_dep + unsc3 * region + resource_dep * region +",
                   ctrl, "| ISO3 + Year")),
  data = d, vcov = "hetero"
)
print(summary(model_h3))

cat("\n=== M4 (H4): rohstoff_cond_share ~ unsc3 * resource_dep ===\n")
model_h4 <- feols(
  as.formula(paste("rohstoff_cond_share ~ unsc3 * resource_dep +", ctrl, "| ISO3 + Year")),
  data = d, vcov = "hetero"
)
print(summary(model_h4))

# ---------------------------------------------------------------------------
# Speichern
# ---------------------------------------------------------------------------
saveRDS(model_h1, "results/models/model_h1.rds")
saveRDS(model_h2, "results/models/model_h2.rds")
saveRDS(model_h3, "results/models/model_h3.rds")
saveRDS(model_h4, "results/models/model_h4.rds")

get_term <- function(m, term) {
  ct <- coeftable(m)
  if (term %in% rownames(ct)) c(coef = ct[term, 1], p = ct[term, 4]) else c(coef = NA, p = NA)
}

results <- data.frame(
  Modell = c("H1 (Basis)", "H2 (unsc3 x resource_dep)",
             "H3 (regionale Interaktionen)", "H4 (rohstoff_cond_share)"),
  n_obs = sapply(list(model_h1, model_h2, model_h3, model_h4), nobs),
  unsc_coef = sapply(list(model_h1, model_h2, model_h3, model_h4),
                     function(m) get_term(m, "unsc3")["coef"]),
  unsc_p = sapply(list(model_h1, model_h2, model_h3, model_h4),
                 function(m) get_term(m, "unsc3")["p"]),
  resource_coef = sapply(list(model_h1, model_h2, model_h3, model_h4),
                         function(m) get_term(m, "resource_dep")["coef"]),
  interaction_coef = sapply(list(model_h1, model_h2, model_h3, model_h4),
                            function(m) get_term(m, "unsc3:resource_dep")["coef"]),
  interaction_p = sapply(list(model_h1, model_h2, model_h3, model_h4),
                         function(m) get_term(m, "unsc3:resource_dep")["p"])
)

write.csv(results, "results/tables/results_h1_h4.csv", row.names = FALSE)
cat("\n=== Ergebnisuebersicht H1-H4 ===\n")
print(results, row.names = FALSE)
