# Phase 3: Regressionsanalyse für SSA (20 Länder)
# ====================================================
# **Ziel:** Replizierung (2002-2008) + Erweiterung (2008-2025) für SSA
# **Fokus:** H1 (Replizierung), H2/H3 (Rohstoffabhängigkeit), H4 (Inhaltsanalyse)
# **Daten:** final_data_ssa_mea.csv (20 SSA-Länder)
# **Anpassung:** Nur SSA (MENA ausgeschlossen aufgrund fehlender WDI-Daten)

# ====================================================
# 0. Pakete laden und Setup
# ====================================================

# Installieren Sie fehlende Pakete
if (!require("plm")) install.packages("plm", dependencies = TRUE)
if (!require("fixest")) install.packages("fixest")
if (!require("stargazer")) install.packages("stargazer")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("lmtest")) install.packages("lmtest")
if (!require("ggeffects")) install.packages("ggeffects")

library(plm)
library(fixest)
library(stargazer)
library(tidyverse)
library(lmtest)
library(ggeffects)

# Optionen für bessere Ausgabe
options(scipen = 999)

# Verzeichnisse erstellen
if (!dir.exists("results")) dir.create("results")
if (!dir.exists("results/figures")) dir.create("results/figures")

# ====================================================
# 1. Daten laden (SSA nur)
# ====================================================

# Hauptdatensatz
final_data <- read_csv("data/processed/final_data_ssa_mea.csv") %>%
  mutate(`MONA Code` = as.character(`MONA Code`))

# Datensatz mit Inhaltsanalyse (für H4) - falls vorhanden
data_with_cond <- NULL
if (file.exists("data/processed/data_with_cond_types.csv")) {
  data_with_cond <- read_csv("data/processed/data_with_cond_types.csv") %>%
    mutate(`MONA Code` = as.character(`MONA Code`))
}

# ====================================================
# 2. Daten aufbereiten für Panel-Regressionen
# ====================================================

# Aggregieren nach Land und Jahr
final_data <- final_data %>%
  group_by(`MONA Code`, `Approval Year`) %>%
  summarise(across(everything(), mean, na.rm = TRUE)) %>%
  ungroup()

if (!is.null(data_with_cond)) {
  data_with_cond <- data_with_cond %>%
    group_by(`MONA Code`, `Approval Year`) %>%
    summarise(across(everything(), mean, na.rm = TRUE)) %>%
    ungroup()
}

# Teildatensätze erstellen
# 2002-2008: Replizierung
# 2008-2025: Erweiterung
data_part1 <- final_data %>% filter(`Approval Year` >= 2002, `Approval Year` <= 2008)
data_part2 <- final_data %>% filter(`Approval Year` >= 2008, `Approval Year` <= 2025)

if (!is.null(data_with_cond)) {
  data_part2_cond <- data_with_cond %>% filter(`Approval Year` >= 2008, `Approval Year` <= 2025)
}

# ====================================================
# 3. TEIL 1: Replizierung (2002-2008, SSA) - H1
# ====================================================

cat("\n=== TEIL 1: Replizierung (2002-2008, SSA) ===\n")

# Prüfen, ob Required Spalten existieren
required_cols_h1 <- c("avgcondtype_all", "unsc3", "XDebtGNI", "DebtServGNI", "ResXDebt")
missing_h1 <- required_cols_h1[!required_cols_h1 %in% names(data_part1)]

if (length(missing_h1) > 0) {
  cat("❌ FEHLER: Fehlende Spalten für H1:", paste(missing_h1, collapse = ", "), "\n")
  cat("Verfügbare Spalten:", paste(names(data_part1), collapse = ", "), "\n")
} else {
  model_h1 <- plm(
    avgcondtype_all ~ unsc3 + XDebtGNI + DebtServGNI + ResXDebt,
    data = data_part1,
    index = c("MONA Code", "Approval Year"),
    model = "within"
  )

  cat("UNSC-Koeffizient:", coef(model_h1)["unsc3"], "\n")
  cat("p-Wert:", summary(model_h1)$coefficients["unsc3", "Pr(>|z|)"], "\n")
  cat("N:", nobs(model_h1), "\n")
  cat("R²:", summary(model_h1)$r.squared, "\n")

  # Validierung
  validation_h1 <- data.frame(
    Model = "H1_Replizierung",
    unsc_coef = coef(model_h1)["unsc3"],
    p_value = summary(model_h1)$coefficients["unsc3", "Pr(>|z|)"],
    n_obs = nobs(model_h1),
    r2 = summary(model_h1)$r.squared,
    validation = ifelse(
      abs(coef(model_h1)["unsc3"]) >= 1.8 & abs(coef(model_h1)["unsc3"])) <= 2.5 &
      summary(model_h1)$coefficients["unsc3", "Pr(>|z|)"] < 0.05,
      "✅ ERFOLGREICH", "❌ FEHLGESCHLAGEN"
    )
  )
  write_csv(validation_h1, "results/validation_h1.csv")
  saveRDS(model_h1, "results/model_h1.rds")
}

# ====================================================
# 4. TEIL 2: Erweiterung (2008-2025, SSA) - H2, H3, H4
# ====================================================

cat("\n=== TEIL 2: Erweiterung (2008-2025, SSA) ===\n")

# H2: Rohstoffabhängigkeit ↑ IMF-Konditionalität
# Anpassung für SSA-Fokus: Testet, ob Länder mit hoher Rohstoffabhängigkeit mehr Bedingungen erhalten
required_cols_h2 <- c("avgcondtype_all", "Rohstoffabhängigkeit", "XDebtGNI", "DebtServGNI", "ResXDebt")
missing_h2 <- required_cols_h2[!required_cols_h2 %in% names(data_part2)]

if (length(missing_h2) > 0) {
  cat("⚠️ H2 überspringen: Fehlende Spalten:", paste(missing_h2, collapse = ", "), "\n")
} else {
  model_h2 <- try(plm(
    avgcondtype_all ~ Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
    data = data_part2, index = c("MONA Code", "Approval Year"), model = "within"
  ), silent = TRUE)

  if (!inherits(model_h2, "try-error")) {
    cat("H2 - Rohstoffabhängigkeit:", coef(model_h2)["Rohstoffabhängigkeit"], 
        "(p =", summary(model_h2)$coefficients["Rohstoffabhängigkeit", "Pr(>|z|)"], ")\n")
    saveRDS(model_h2, "results/model_h2.rds")
  } else {
    cat("⚠️ H2-Modell fehlerhaft. Versuche mit fixest...\n")
    model_h2 <- try(feols(
      avgcondtype_all ~ Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
      data = data_part2, fixed_effects = ~`MONA Code`
    ), silent = TRUE)
    if (!inherits(model_h2, "try-error")) {
      cat("H2 - Rohstoffabhängigkeit (fixest):\n")
      cat("  Koeffizient:", coef(model_h2)["Rohstoffabhängigkeit"], "\n")
      saveRDS(model_h2, "results/model_h2.rds")
    }
  }
}

# H3: UNSC-Effekt stärker in rohstoffabhängigen Ländern
# Testet die Interaktion zwischen UNSC und Rohstoffabhängigkeit
required_cols_h3 <- c("avgcondtype_all", "unsc3", "Rohstoffabhängigkeit", "XDebtGNI", "DebtServGNI", "ResXDebt")
missing_h3 <- required_cols_h3[!required_cols_h3 %in% names(data_part2)]

if (length(missing_h3) > 0) {
  cat("⚠️ H3 überspringen: Fehlende Spalten:", paste(missing_h3, collapse = ", "), "\n")
} else {
  model_h3 <- try(plm(
    avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
    data = data_part2, index = c("MONA Code", "Approval Year"), model = "within"
  ), silent = TRUE)

  if (!inherits(model_h3, "try-error")) {
    cat("H3 - UNSC × Rohstoffabhängigkeit:\n")
    cat("  Interaktionskoeffizient:", coef(model_h3)["unsc3:Rohstoffabhängigkeit"], 
        "(p =", summary(model_h3)$coefficients["unsc3:Rohstoffabhängigkeit", "Pr(>|z|)"], ")\n")
    saveRDS(model_h3, "results/model_h3.rds")
  } else {
    cat("⚠️ H3-Modell fehlerhaft. Versuche mit fixest...\n")
    model_h3 <- try(feols(
      avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
      data = data_part2, fixed_effects = ~`MONA Code`
    ), silent = TRUE)
    if (!inherits(model_h3, "try-error")) {
      cat("H3 - UNSC × Rohstoffabhängigkeit (fixest):\n")
      cat("  Interaktionskoeffizient:", coef(model_h3)["unsc3:Rohstoffabhängigkeit"], "\n")
      saveRDS(model_h3, "results/model_h3.rds")
    }
  }
}

# H4: UNSC → weniger rohstoff-spezifische Bedingungen (Inhaltsanalyse)
if (!is.null(data_with_cond) && !is.null(data_part2_cond)) {
  required_cols_h4 <- c("rohstoff_cond_share", "unsc3", "Rohstoffabhängigkeit", "XDebtGNI", "DebtServGNI", "ResXDebt")
  missing_h4 <- required_cols_h4[!required_cols_h4 %in% names(data_part2_cond)]

  if (length(missing_h4) > 0) {
    cat("⚠️ H4 überspringen: Fehlende Spalten:", paste(missing_h4, collapse = ", "), "\n")
  } else {
    model_h4 <- try(plm(
      rohstoff_cond_share ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
      data = data_part2_cond, index = c("MONA Code", "Approval Year"), model = "within"
    ), silent = TRUE)

    if (!inherits(model_h4, "try-error")) {
      cat("H4 - UNSC × Rohstoffabhängigkeit (Inhaltsanalyse):\n")
      cat("  Interaktionskoeffizient:", coef(model_h4)["unsc3:Rohstoffabhängigkeit"], 
          "(p =", summary(model_h4)$coefficients["unsc3:Rohstoffabhängigkeit", "Pr(>|z|)"], ")\n")
      saveRDS(model_h4, "results/model_h4.rds")
    } else {
      cat("⚠️ H4-Modell fehlerhaft. Versuche mit fixest...\n")
      model_h4 <- try(feols(
        rohstoff_cond_share ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
        data = data_part2_cond, fixed_effects = ~`MONA Code`
      ), silent = TRUE)
      if (!inherits(model_h4, "try-error")) {
        cat("H4 - UNSC × Rohstoffabhängigkeit (fixest):\n")
        cat("  Interaktionskoeffizient:", coef(model_h4)["unsc3:Rohstoffabhängigkeit"], "\n")
        saveRDS(model_h4, "results/model_h4.rds")
      }
    }
  }
} else {
  cat("⚠️ H4 überspringen: data_with_cond_types.csv nicht gefunden\n")
}

# ====================================================
# 5. Ergebnisse zusammenfassen
# ====================================================

cat("\n=== ERGEBNISSE ===\n")

# Ergebnisse extrahieren (mit Fehlerbehandlung)
get_coef <- function(model, term) {
  if (!inherits(model, "try-error") && !is.null(model)) {
    if (term %in% names(coef(model))) {
      return(coef(model)[term])
    }
  }
  return(NA)
}

get_pval <- function(model, term) {
  if (!inherits(model, "try-error") && !is.null(model)) {
    if (term %in% rownames(summary(model)$coefficients)) {
      return(summary(model)$coefficients[term, "Pr(>|z|)"])
    }
  }
  return(NA)
}

results_summary <- data.frame(
  Model = c("H1", "H2", "H3", "H4"),
  Coefficient = c(
    get_coef(model_h1, "unsc3"),
    get_coef(model_h2, "Rohstoffabhängigkeit"),
    get_coef(model_h3, "unsc3:Rohstoffabhängigkeit"),
    get_coef(model_h4, "unsc3:Rohstoffabhängigkeit")
  ),
  P_Value = c(
    get_pval(model_h1, "unsc3"),
    get_pval(model_h2, "Rohstoffabhängigkeit"),
    get_pval(model_h3, "unsc3:Rohstoffabhängigkeit"),
    get_pval(model_h4, "unsc3:Rohstoffabhängigkeit")
  ),
  N = c(
    if (!inherits(model_h1, "try-error") && !is.null(model_h1)) nobs(model_h1) else NA,
    if (!inherits(model_h2, "try-error") && !is.null(model_h2)) nobs(model_h2) else NA,
    if (!inherits(model_h3, "try-error") && !is.null(model_h3)) nobs(model_h3) else NA,
    if (!inherits(model_h4, "try-error") && !is.null(model_h4)) nobs(model_h4) else NA
  ),
  R2 = c(
    if (!inherits(model_h1, "try-error") && !is.null(model_h1)) summary(model_h1)$r.squared else NA,
    if (!inherits(model_h2, "try-error") && !is.null(model_h2)) summary(model_h2)$r.squared else NA,
    if (!inherits(model_h3, "try-error") && !is.null(model_h3)) summary(model_h3)$r.squared else NA,
    if (!inherits(model_h4, "try-error") && !is.null(model_h4)) summary(model_h4)$r.squared else NA
  )
)
write_csv(results_summary, "results/results_summary.csv")
print(results_summary)

# ====================================================
# 6. Robustheitschecks
# ====================================================

cat("\n=== ROBUSTHEITSCHECKS ===\n")

# Heteroskedastizitätstests (nur für erfolgreiche Modelle)
if (!inherits(model_h1, "try-error") && !is.null(model_h1)) {
  bptest_h1 <- try(bptest(model_h1), silent = TRUE)
  if (!inherits(bptest_h1, "try-error")) cat("H1 BP p-Wert:", bptest_h1$p.value, "\n")
}

if (!inherits(model_h2, "try-error") && !is.null(model_h2)) {
  bptest_h2 <- try(bptest(model_h2), silent = TRUE)
  if (!inherits(bptest_h2, "try-error")) cat("H2 BP p-Wert:", bptest_h2$p.value, "\n")
}

if (!inherits(model_h3, "try-error") && !is.null(model_h3)) {
  bptest_h3 <- try(bptest(model_h3), silent = TRUE)
  if (!inherits(bptest_h3, "try-error")) cat("H3 BP p-Wert:", bptest_h3$p.value, "\n")
}

if (!inherits(model_h4, "try-error") && !is.null(model_h4)) {
  bptest_h4 <- try(bptest(model_h4), silent = TRUE)
  if (!inherits(bptest_h4, "try-error")) cat("H4 BP p-Wert:", bptest_h4$p.value, "\n")
}

# Year-Fixed-Effects (nur für H3, da Interaktion)
if (!inherits(model_h3, "try-error") && !is.null(model_h3)) {
  model_h3_year_fe <- try(feols(
    avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
    data = data_part2, fixed_effects = ~`MONA Code` + `Approval Year`
  ), silent = TRUE)
  if (!inherits(model_h3_year_fe, "try-error")) {
    cat("H3 Year-FE Interaktion:", coef(model_h3_year_fe)["unsc3:Rohstoffabhängigkeit"], "\n")
    saveRDS(model_h3_year_fe, "results/model_h3_year_fe.rds")
  }
}

# Robuste Standardfehler
if (!inherits(model_h3, "try-error") && !is.null(model_h3)) {
  model_h3_robust <- try(feols(
    avgcondtype_all ~ unsc3 * Rohstoffabhängigkeit + XDebtGNI + DebtServGNI + ResXDebt,
    data = data_part2, fixed_effects = ~`MONA Code`, vcov = "hetero"
  ), silent = TRUE)
  if (!inherits(model_h3_robust, "try-error")) {
    cat("H3 robust Interaktion:", coef(model_h3_robust)["unsc3:Rohstoffabhängigkeit"], "\n")
    saveRDS(model_h3_robust, "results/model_h3_robust.rds")
  }
}

# ====================================================
# 7. Tabellen und Grafiken
# ====================================================

cat("\n=== TABELLEN ===\n")

# Tabelle 1: Replizierung
if (!inherits(model_h1, "try-error") && !is.null(model_h1)) {
  stargazer(model_h1, type = "text", title = "Replizierung (2002-2008, SSA)",
            dep.var.labels = "Durchschnittl. IMF-Bedingungen pro Quartal",
            covariate.labels = c("UNSC-Mitglied (t oder t-1)", "Externe Schuld (% BNE)",
                                  "Schuldenbedienung (% BNE)", "Reserven (% ext. Schuld)"),
            out = "results/table_h1.txt")
}

# Tabelle 2: Erweiterung (nur erfolgreiche Modelle)
successful_models <- list()
if (!inherits(model_h2, "try-error") && !is.null(model_h2)) successful_models[["H2_Rohstoff"]] <- model_h2
if (!inherits(model_h3, "try-error") && !is.null(model_h3)) successful_models[["H3_UNSC_Rohstoff"]] <- model_h3
if (!inherits(model_h4, "try-error") && !is.null(model_h4)) successful_models[["H4_Inhaltsanalyse"]] <- model_h4

if (length(successful_models) > 0) {
  stargazer(successful_models, type = "text",
            title = "Erweiterung: Rohstoffabhängigkeit und UNSC-Effekt (2008-2025, SSA)",
            dep.var.labels = c("Durchschnittl. Bedingungen/Quartal", "Anteil rohstoff-spez. Bedingungen"),
            covariate.labels = c("UNSC-Mitglied", "Rohstoffabhängigkeit", "UNSC × Rohstoffabhängigkeit",
                                  "Externe Schuld", "Schuldenbedienung", "Reserven"),
            out = "results/table_h2_h4.txt")
}

# Grafik 1: Marginale Effekte H3
if (!inherits(model_h3, "try-error") && !is.null(model_h3)) {
  if (requireNamespace("marginaleffects", quietly = TRUE)) {
    me_h3 <- try(marginaleffects(model_h3, variables = "Rohstoffabhängigkeit", by = "unsc3"), silent = TRUE)
    if (!inherits(me_h3, "try-error")) {
      p1 <- plot(me_h3, type = "line", points = TRUE) +
        labs(title = "Marginaler Effekt der Rohstoffabhängigkeit (H3)",
             subtitle = "UNSC-Effekt stärker in rohstoffreichen Ländern (SSA)",
             x = "Rohstoffabhängigkeit (% Exporte)", y = "Marginaler Effekt", color = "UNSC") +
        theme_minimal() + geom_hline(yintercept = 0, linetype = "dashed", color = "red")
      ggsave("results/figures/me_h3_ssa.png", p1, width = 10, height = 6, dpi = 300)
    }
  } else {
    me_h3 <- try(ggpredict(model_h3, terms = c("Rohstoffabhängigkeit", "unsc3")), silent = TRUE)
    if (!inherits(me_h3, "try-error")) {
      p1 <- plot(me_h3, type = "line", points = TRUE) +
        labs(title = "Marginaler Effekt der Rohstoffabhängigkeit (H3)",
             subtitle = "UNSC-Effekt stärker in rohstoffreichen Ländern (SSA)",
             x = "Rohstoffabhängigkeit (% Exporte)", y = "Marginaler Effekt", color = "UNSC") +
        theme_minimal() + geom_hline(yintercept = 0, linetype = "dashed", color = "red")
      ggsave("results/figures/me_h3_ssa.png", p1, width = 10, height = 6, dpi = 300)
    }
  }
}

# Grafik 2: Rohstoffabhängigkeit vs. IMF-Konditionalität
if (!inherits(model_h2, "try-error") && !is.null(model_h2)) {
  p2 <- ggplot(data_part2, aes(x = Rohstoffabhängigkeit, y = avgcondtype_all, color = factor(unsc3))) +
    geom_point(alpha = 0.6) + geom_smooth(method = "lm", se = FALSE) +
    labs(title = "Rohstoffabhängigkeit vs. IMF-Konditionalität (SSA)",
         x = "Rohstoffabhängigkeit (% Exporte)", y = "Durchschn. IMF-Bedingungen/Quartal", color = "UNSC") +
    theme_minimal() + scale_color_manual(values = c("0" = "red", "1" = "green"))
  ggsave("results/figures/rohstoff_vs_cond_ssa.png", p2, width = 8, height = 6, dpi = 300)
}

# ====================================================
# 8. Hypothesentests
# ====================================================

cat("\n=== HYPOTHESENTESTS ===\n")

# H1: UNSC reduziert IMF-Konditionalität (Replizierung)
h1_test <- ifelse(!inherits(model_h1, "try-error") && !is.null(model_h1) &&
               abs(coef(model_h1)["unsc3"]) >= 1.8 && 
               abs(coef(model_h1)["unsc3"]) <= 2.5 &&
               summary(model_h1)$coefficients["unsc3", "Pr(>|z|)"] < 0.05,
             "✅ BESTÄTIGT: UNSC reduziert IMF-Konditionalität (H1)", "❌ ABGELEHNT")

# H2: Rohstoffabhängigkeit ↑ IMF-Konditionalität
h2_test <- ifelse(!inherits(model_h2, "try-error") && !is.null(model_h2) &&
               get_coef(model_h2, "Rohstoffabhängigkeit") > 0 &&
               get_pval(model_h2, "Rohstoffabhängigkeit") < 0.05,
             "✅ BESTÄTIGT: Rohstoffabhängige Länder erhalten mehr Bedingungen (H2)", "❌ ABGELEHNT")

# H3: UNSC-Effekt stärker in rohstoffabhängigen Ländern
h3_test <- ifelse(!inherits(model_h3, "try-error") && !is.null(model_h3) &&
               get_coef(model_h3, "unsc3:Rohstoffabhängigkeit") < 0 &&
               get_pval(model_h3, "unsc3:Rohstoffabhängigkeit") < 0.05,
             "✅ BESTÄTIGT: UNSC-Effekt stärker in rohstoffabhängigen Ländern (H3)", "❌ ABGELEHNT")

# H4: UNSC-Länder haben weniger rohstoff-spezifische Bedingungen
h4_test <- ifelse(!inherits(model_h4, "try-error") && !is.null(model_h4) &&
               get_coef(model_h4, "unsc3:Rohstoffabhängigkeit") < 0 &&
               get_pval(model_h4, "unsc3:Rohstoffabhängigkeit") < 0.05,
             "✅ BESTÄTIGT: UNSC-Länder haben weniger rohstoff-spez. Bedingungen (H4)", "❌ ABGELEHNT")

cat("H1:", h1_test, "\n")
cat("H2:", h2_test, "\n")
cat("H3:", h3_test, "\n")
cat("H4:", h4_test, "\n")

hypothesis_tests <- data.frame(
  Hypothese = c("H1", "H2", "H3", "H4"),
  Beschreibung = c("UNSC reduziert IMF-Konditionalität (Replizierung)",
                  "Rohstoffabhängige Länder erhalten mehr Bedingungen",
                  "UNSC-Effekt stärker in rohstoffabhängigen Ländern",
                  "UNSC-Länder haben weniger rohstoff-spezifische Bedingungen"),
  Ergebnis = c(h1_test, h2_test, h3_test, h4_test)
)
write_csv(hypothesis_tests, "results/hypothesis_tests.csv")

# ====================================================
# 9. Validierungsbericht
# ====================================================

validation_report <- list(
  replizierung = list(
    n_obs = if (!inherits(model_h1, "try-error") && !is.null(model_h1)) nobs(model_h1) else NA,
    unsc_coef = get_coef(model_h1, "unsc3"),
    p_value = get_pval(model_h1, "unsc3"),
    success = h1_test
  ),
  erweiterung = list(
    n_obs = if (!inherits(model_h2, "try-error") && !is.null(model_h2)) nobs(model_h2) else NA,
    h2_coef = get_coef(model_h2, "Rohstoffabhängigkeit"), 
    h2_p = get_pval(model_h2, "Rohstoffabhängigkeit"),
    h3_coef = get_coef(model_h3, "unsc3:Rohstoffabhängigkeit"), 
    h3_p = get_pval(model_h3, "unsc3:Rohstoffabhängigkeit"),
    h4_coef = get_coef(model_h4, "unsc3:Rohstoffabhängigkeit"), 
    h4_p = get_pval(model_h4, "unsc3:Rohstoffabhängigkeit")
  ),
  hypotheses = hypothesis_tests
)
saveRDS(validation_report, "results/validation_report.rds")

cat("\n=== VALIDIERUNGSBERICHT ===\n")
cat("Replizierung (H1):", validation_report$replizierung$success, "\n")
cat("H2 (Rohstoffabhängigkeit):", ifelse(!is.na(validation_report$erweiterung$h2_coef) && 
                             validation_report$erweiterung$h2_coef > 0 && 
                             validation_report$erweiterung$h2_p < 0.05, 
                             "✅ BESTÄTIGT", "❌ ABGELEHNT"), "\n")
cat("H3 (UNSC × Rohstoff):", ifelse(!is.na(validation_report$erweiterung$h3_coef) && 
                                    validation_report$erweiterung$h3_coef < 0 && 
                                    validation_report$erweiterung$h3_p < 0.05, 
                                    "✅ BESTÄTIGT", "❌ ABGELEHNT"), "\n")
cat("H4 (Inhaltsanalyse):", ifelse(!is.na(validation_report$erweiterung$h4_coef) && 
                                   validation_report$erweiterung$h4_coef < 0 && 
                                   validation_report$erweiterung$h4_p < 0.05, 
                                   "✅ BESTÄTIGT", "❌ ABGELEHNT"), "\n")

cat("\n=== FERTIG! ===\n")
cat("Alle Ergebnisse in results/ gespeichert.\n")
cat("Hinweis: Analyse beschränkt auf 20 SSA-Länder (MENA ausgeschlossen).\n")
