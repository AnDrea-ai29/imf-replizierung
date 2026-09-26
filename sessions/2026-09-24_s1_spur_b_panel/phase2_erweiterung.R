# H1-H4 im globalen Laenderpool (ALLE Laender aus Combined_ISO.xlsx, ALLE Jahre)
# Kein SSA-Filter, keine Jahr-Beschraenkung, KEINE vordefinierten Regionen.
# Regionen werden erst spaeter als deskriptives Hilfsmittel vom Autor festgelegt;
# Heterogenitaet wird zunaechst ueber Laenderergebnisse und Ausreisser geprueft
# (siehe code/analysis/laender_ausreisser_analyse.R).
#
# Modelle (Neu.md Schritt 5-6):
#   M1 (H1): avgcondtype_share ~ unsc3 + Kontrollen
#   M2 (H2): avgcondtype_share ~ unsc3 * resource_dep + Kontrollen
#   M4 (H4): rohstoff_cond_share ~ unsc3 * resource_dep + Kontrollen

setwd("C:/Users/HP/io/imf-replizierung")

library(tidyverse)
library(fixest)

d <- read.csv("data/processed/final_data_panel_ALL.csv",
              stringsAsFactors = FALSE)

d <- d %>%
  mutate(resource_dep = FuelExportPct + MineralExportPct)

cat("Panel:", nrow(d), "Beobachtungen,",
    n_distinct(d$ISO3), "Laender, Jahre",
    min(d$Year), "-", max(d$Year), "\n")

ctrl <- "XDebtGNI + DebtServGNI + ResXDebt"

# ---------------------------------------------------------------------------
# Modelle
# ---------------------------------------------------------------------------
cat("\n=== M1 (H1-Basis): global, alle Jahre ===\n")
model_h1 <- feols(
  as.formula(paste("avgcondtype_share ~ unsc3 +", ctrl, "| ISO3 + Year")),
  data = d, vcov = "hetero"
)
print(summary(model_h1))

cat("\n=== M2 (H2): unsc3 * resource_dep ===\n")
model_h2 <- feols(
  as.formula(paste("avgcondtype_share ~ unsc3 * resource_dep +", ctrl, "| ISO3 + Year")),
  data = d, vcov = "hetero"
)
print(summary(model_h2))

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
saveRDS(model_h4, "results/models/model_h4.rds")

get_term <- function(m, term) {
  ct <- coeftable(m)
  if (term %in% rownames(ct)) c(coef = ct[term, 1], p = ct[term, 4]) else c(coef = NA, p = NA)
}

models <- list(model_h1, model_h2, model_h4)
labels <- c("H1 (Basis)", "H2 (unsc3 x resource_dep)", "H4 (rohstoff_cond_share)")

results <- data.frame(
  Modell = labels,
  n_obs = sapply(models, nobs),
  unsc_coef = sapply(models, function(m) get_term(m, "unsc3")["coef"]),
  unsc_p = sapply(models, function(m) get_term(m, "unsc3")["p"]),
  resource_coef = sapply(models, function(m) get_term(m, "resource_dep")["coef"]),
  interaction_coef = sapply(models, function(m) get_term(m, "unsc3:resource_dep")["coef"]),
  interaction_p = sapply(models, function(m) get_term(m, "unsc3:resource_dep")["p"])
)

write.csv(results, "results/tables/results_h1_h4.csv", row.names = FALSE)
cat("\n=== Ergebnisuebersicht (globale Durchschnittsergebnisse) ===\n")
print(results, row.names = FALSE)
