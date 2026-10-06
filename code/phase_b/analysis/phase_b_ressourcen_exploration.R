# Explorative Sichten: Rohstoffabhaengigkeit x Konditionalitaet.
# Drei Tabellen, alle rein deskriptiv (explorativ), keine Inferenz:
#   A) ressourcen_konditionalitaet_laender.csv
#      Alle Laender sortiert nach Rohstoffabhaengigkeit (absteigend) mit
#      Gesamtbedingungen (Mittel der Programm-Gesamtzahl), Bedingungen
#      pro Quartal und mittlerer Programmlaufzeit in Quartalen.
#      Hinweis: Scope-Variablen (Anzahl unterschiedlicher Policy-Areas,
#      scope_*) existieren nur in der MONA-Rohdatenebene (CODEBOOK 3.7)
#      und sind im Phase-B-Panel nicht enthalten.
#   B) h3_ansicht_nach_ressourcen.csv
#      Die 30 UNSC-Laender der H3-Vergleichsansicht, angereichert um
#      ihre Rohstoffabhaengigkeit und sortiert danach (absteigend).
#   C) ressourcen_rangliste.csv
#      Schlichte Rangliste der Laender nach Rohstoffabhaengigkeit.
# Analysefenster und Zaehlregeln identisch zu phase_b_h3_exploration.R:
# 1992-2023, Mittelwerte ueber beobachtete Programmjahre.

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(dplyr)
})

panel_path <- "data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
if (!file.exists(panel_path)) {
  stop("Phase-B-Panel fehlt. Bitte zuerst ",
       "build_phase_b_identical_measurement.R ausfuehren: ", panel_path)
}

panel <- read.csv(panel_path, stringsAsFactors = FALSE)
required <- c("ISO3", "Year", "country", "resource_dep", "nrcondtype_all",
              "avgcondtype_count", "nrquarterssmpl", "unsc3")
if (!all(required %in% names(panel))) {
  stop("Phase-B-Panel enthaelt nicht alle benoetigten Variablen: ",
       paste(setdiff(required, names(panel)), collapse = ", "))
}

panel <- panel %>%
  filter(Year >= 1992, Year <= 2023)

mean_or_na <- function(x) {
  if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
}

output_dir <- "results/phase_b/exploration"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------------------------
# A) Rohstoffabhaengigkeit x Konditionalitaet: alle Laender, sortiert nach
#    Rohstoffabhaengigkeit (absteigend)
# ---------------------------------------------------------------------------
tabelle_a <- panel %>%
  group_by(ISO3) %>%
  summarise(
    country              = first(country),
    n_years              = sum(!is.na(resource_dep)),
    mean_resource_dep    = mean_or_na(resource_dep),
    mean_nrcondtype_all  = mean_or_na(nrcondtype_all),
    mean_count_quarter   = mean_or_na(avgcondtype_count),
    mean_quarters        = mean_or_na(nrquarterssmpl),
    .groups = "drop"
  ) %>%
  filter(!is.na(mean_resource_dep)) %>%
  arrange(desc(mean_resource_dep))

write.csv(tabelle_a,
         file.path(output_dir, "ressourcen_konditionalitaet_laender.csv"),
         row.names = FALSE, na = "")

cat("=== A) Rohstoffabhaengigkeit x Konditionalitaet (Top 12) ===\n")
print(head(tabelle_a, 12), digits = 3, row.names = FALSE)

# ---------------------------------------------------------------------------
# B) H3-Ansicht (UNSC-Laender) sortiert nach Rohstoffabhaengigkeit
# ---------------------------------------------------------------------------
tabelle_b <- panel %>%
  group_by(ISO3) %>%
  summarise(
    country              = first(country),
    n_obs_unsc3          = sum(unsc3 == 1L & !is.na(avgcondtype_count)),
    mean_count_unsc3     = mean_or_na(avgcondtype_count[unsc3 == 1L]),
    n_obs_non_unsc3      = sum(unsc3 == 0L & !is.na(avgcondtype_count)),
    mean_count_non_unsc3 = mean_or_na(avgcondtype_count[unsc3 == 0L]),
    descriptive_unsc3_gap = if (
      any(unsc3 == 1L & !is.na(avgcondtype_count)) &&
      any(unsc3 == 0L & !is.na(avgcondtype_count))
    ) {
      mean(avgcondtype_count[unsc3 == 1L], na.rm = TRUE) -
        mean(avgcondtype_count[unsc3 == 0L], na.rm = TRUE)
    } else {
      NA_real_
    },
    n_years              = sum(!is.na(resource_dep)),
    mean_resource_dep    = mean_or_na(resource_dep),
    resource_dep_percent = round(mean_or_na(resource_dep), 1),
    .groups = "drop"
  ) %>%
  filter(n_obs_unsc3 > 0L) %>%
  arrange(desc(mean_resource_dep))

write.csv(tabelle_b,
         file.path(output_dir, "h3_ansicht_nach_ressourcen.csv"),
         row.names = FALSE, na = "")

cat("\n=== B) H3-Ansicht nach Rohstoffabhaengigkeit (alle UNSC-Laender) ===\n")
print(tabelle_b[, c("ISO3", "country", "resource_dep_percent",
                    "mean_count_unsc3", "mean_count_non_unsc3",
                    "descriptive_unsc3_gap")],
      digits = 3, row.names = FALSE)

# ---------------------------------------------------------------------------
# C) Schlichte Rangliste nach Rohstoffabhaengigkeit (absteigend)
# ---------------------------------------------------------------------------
tabelle_c <- tabelle_a %>%
  transmute(
    Rang = row_number(),
    ISO3,
    Land = country,
    Rohstoffanteil_Prozent = round(mean_resource_dep, 1),
    Beobachtungsjahre = n_years
  )

write.csv(tabelle_c,
         file.path(output_dir, "ressourcen_rangliste.csv"),
         row.names = FALSE, na = "")

cat("\n=== C) Rangliste nach Rohstoffabhaengigkeit (Top 12) ===\n")
print(head(tabelle_c, 12), row.names = FALSE)

# ---------------------------------------------------------------------------
# D) Perzentile der Rohstoffabhaengigkeit auf zwei Verteilungsebenen:
#    - Laender-Ebene: Mittelwert je Land (aus Tabelle A, n = Laender)
#    - Land-Jahr-Ebene: alle beobachteten Programmjahre 1992-2023
#    (Der dokumentierte Median-Split bei 11,8 % bezieht sich auf die
#    Land-Jahr-Ebene der H2-Stichprobe.)
# ---------------------------------------------------------------------------
probs <- c(0, 0.05, 0.10, 0.25, 0.50, 0.75, 0.90, 0.95, 0.99, 1)

# Land-Jahr-Ebene (reine Verteilung, keine Laender-Zuordnung moeglich)
perzentile_jahre <- tibble(
  Ebene = "Land-Jahre (Paneljahre)",
  n     = sum(!is.na(panel$resource_dep)),
  Perzentil = probs,
  Wert  = round(quantile(panel$resource_dep, probs = probs,
                         na.rm = TRUE, names = FALSE), 2),
  Land_beim_Perzentil = NA_character_
)

# Laender-Ebene: aufsteigend sortiert, Land an der jeweiligen Position
laender_aufsteigend <- tabelle_a %>%
  arrange(mean_resource_dep) %>%
  mutate(rang_aufsteigend = row_number())

n_laender <- nrow(laender_aufsteigend)

perzentile_laender <- bind_rows(lapply(probs, function(p) {
  ziel_pos <- round(p * (n_laender - 1)) + 1
  zeile <- slice(laender_aufsteigend, ziel_pos)
  tibble(
    Ebene = "Laender (Mittel je Land)",
    n     = n_laender,
    Perzentil = p,
    Wert  = round(quantile(tabelle_a$mean_resource_dep, probs = p,
                           na.rm = TRUE, names = FALSE), 2),
    Land_beim_Perzentil = paste0(zeile$country, " (", zeile$ISO3, ")")
  )
}))

perzentile <- bind_rows(perzentile_laender, perzentile_jahre)

write.csv(perzentile,
          file.path(output_dir, "ressourcen_perzentile.csv"),
          row.names = FALSE, na = "")

cat("\n=== D) Perzentile der Rohstoffabhaengigkeit ===\n")
print(perzentile, row.names = FALSE)

# Laender mit ihrer Perzentil-Position (0 = rohstoffaermstes,
# 100 = rohstoffreichstes Land der Verteilung)
laender_perzentilposition <- tabelle_a %>%
  transmute(
    Rang = row_number(),
    ISO3,
    Land = country,
    Rohstoffanteil_Prozent = round(mean_resource_dep, 1),
    Perzentilposition = round(percent_rank(mean_resource_dep) * 100, 1),
    Beobachtungsjahre = n_years
  )

write.csv(laender_perzentilposition,
          file.path(output_dir, "ressourcen_perzentile_laender.csv"),
          row.names = FALSE, na = "")

cat("\n=== D2) Laender mit Perzentil-Position (rohstoffreichste 10) ===\n")
print(head(laender_perzentilposition, 10), row.names = FALSE)

cat("\n=== D2) Laender mit Perzentil-Position (rohstoffaermste 10) ===\n")
print(tail(laender_perzentilposition, 10), row.names = FALSE)

# ---------------------------------------------------------------------------
# E) Perzentile der Konditionalitaet (0/25/50/75/100 %) fuer beide Maasse:
#    - Bedingungen pro Quartal (avgcondtype_count) und Gesamtbedingungen
#      (nrcondtype_all)
#    - Ebenen: Land-Jahre (Panel) und Laender (Mittel je Land)
# ---------------------------------------------------------------------------
probs_e <- c(0, 0.25, 0.50, 0.75, 1)

perzentil_zeile <- function(werte, p) {
  round(quantile(werte, probs = p, na.rm = TRUE, names = FALSE), 1)
}

konditionalitaet_perzentile <- bind_rows(
  bind_rows(lapply(probs_e, function(p) {
    tibble(
      Mass  = "Bedingungen pro Quartal",
      Ebene = "Land-Jahre (Panel)",
      n     = sum(!is.na(panel$avgcondtype_count)),
      Perzentil = p,
      Wert  = perzentil_zeile(panel$avgcondtype_count, p),
      Land_beim_Perzentil = NA_character_
    )
  })),
  bind_rows(lapply(probs_e, function(p) {
    tibble(
      Mass  = "Bedingungen pro Quartal",
      Ebene = "Laender (Mittel je Land)",
      n     = sum(!is.na(tabelle_a$mean_count_quarter)),
      Perzentil = p,
      Wert  = perzentil_zeile(tabelle_a$mean_count_quarter, p),
      Land_beim_Perzentil = NA_character_
    )
  })),
  bind_rows(lapply(probs_e, function(p) {
    tibble(
      Mass  = "Gesamtbedingungen je Programm",
      Ebene = "Land-Jahre (Panel)",
      n     = sum(!is.na(panel$nrcondtype_all)),
      Perzentil = p,
      Wert  = perzentil_zeile(panel$nrcondtype_all, p),
      Land_beim_Perzentil = NA_character_
    )
  })),
  bind_rows(lapply(probs_e, function(p) {
    tibble(
      Mass  = "Gesamtbedingungen je Programm",
      Ebene = "Laender (Mittel je Land)",
      n     = sum(!is.na(tabelle_a$mean_nrcondtype_all)),
      Perzentil = p,
      Wert  = perzentil_zeile(tabelle_a$mean_nrcondtype_all, p),
      Land_beim_Perzentil = NA_character_
    )
  }))
)

# Laender an den Perzentilpositionen: je Perzentil genau EIN Land,
# passend zur jeweiligen Zeile zugewiesen
aufst_quarter <- tabelle_a %>%
  filter(!is.na(mean_count_quarter)) %>%
  arrange(mean_count_quarter)
aufst_total <- tabelle_a %>%
  filter(!is.na(mean_nrcondtype_all)) %>%
  arrange(mean_nrcondtype_all)

land_beim_perzentil <- function(aufst, p) {
  ziel <- round(p * (nrow(aufst) - 1)) + 1
  zeile <- slice(aufst, ziel)
  paste0(zeile$country, " (", zeile$ISO3, ")")
}

konditionalitaet_perzentile <- konditionalitaet_perzentile %>%
  mutate(Land_beim_Perzentil = if_else(
    Ebene == "Laender (Mittel je Land)" &
      Mass == "Bedingungen pro Quartal",
    sapply(Perzentil, function(p)
      land_beim_perzentil(aufst_quarter, p)),
    if_else(
      Ebene == "Laender (Mittel je Land)" &
        Mass == "Gesamtbedingungen je Programm",
      sapply(Perzentil, function(p)
        land_beim_perzentil(aufst_total, p)),
      Land_beim_Perzentil
    )
  ))

write.csv(konditionalitaet_perzentile,
          file.path(output_dir, "konditionalitaet_perzentile.csv"),
          row.names = FALSE, na = "")

cat("\n=== E) Perzentile der Konditionalitaet (0/25/50/75/100 %) ===\n")
print(konditionalitaet_perzentile, row.names = FALSE)

# ---------------------------------------------------------------------------
# F) Konditionalitaet nach Kalenderjahr (Jahresreihe 1992-2023):
#    zeigt, ab welchen Jahren die Konditionalitaet gestiegen ist.
#    Vorsicht bei der Deutung: Jahresmittel haengen von der Laender-
#    zusammensetzung der Programme je Jahr ab (Kompositionseffekt);
#    in den Regressionsmodellen absorbsieren Jahr-FE dieses Niveau.
# ---------------------------------------------------------------------------
jahresreihe <- panel %>%
  group_by(Year) %>%
  summarise(
    n_programmjahre       = n(),
    n_messwerte           = sum(!is.na(avgcondtype_count)),
    mean_count_quarter    = mean_or_na(avgcondtype_count),
    mean_nrcondtype_all   = mean_or_na(nrcondtype_all),
    .groups = "drop"
  ) %>%
  arrange(Year)

write.csv(jahresreihe,
          file.path(output_dir, "konditionalitaet_jahresreihe.csv"),
          row.names = FALSE, na = "")

cat("\n=== F) Konditionalitaet nach Jahr (1992-2023) ===\n")
print(jahresreihe, digits = 3, row.names = FALSE)

# ---------------------------------------------------------------------------
# G) Streudiagramm: Konditionalitaet nach Jahr mit linearem Trend
#    (fuer die Hausarbeit; deskriptiv, kein Kausalschaetzer)
# ---------------------------------------------------------------------------
suppressMessages(library(ggplot2))

p_jahresreihe <- ggplot(jahresreihe,
                        aes(x = Year, y = mean_count_quarter)) +
  geom_point(size = 2.2, alpha = 0.85) +
  geom_smooth(method = "lm", se = TRUE,
              color = "steelblue", fill = "lightblue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(1992, 2023, 4)) +
  labs(
    title = "Konditionalitaet nach Programmjahr (1992-2023)",
    subtitle = "Punkte: Jahresmittel der Bedingungen pro Quartal; Linie: linearer Trend mit 95%-Band",
    x = NULL, y = "Bedingungen pro Quartal (Jahresmittel)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 11),
        axis.text.x = element_text(size = 8.5))

dir.create("results/phase_b/figures", recursive = TRUE, showWarnings = FALSE)
ggsave("results/phase_b/figures/konditionalitaet_jahresreihe.png",
       p_jahresreihe, width = 8, height = 5, dpi = 300)

# Kopie fuer den LaTeX-Appendix-Ordner
file.copy("results/phase_b/figures/konditionalitaet_jahresreihe.png",
          "latex/figures/phase_b/konditionalitaet_jahresreihe.png",
          overwrite = TRUE)

cat("\n=== G) Streudiagramm: konditionalitaet_jahresreihe.png ===\n")
cat("  results/phase_b/figures/konditionalitaet_jahresreihe.png\n")
cat("  latex/figures/phase_b/konditionalitaet_jahresreihe.png (Kopie)\n")

cat("\nAusgabe:\n",
    "  ", file.path(output_dir, "ressourcen_konditionalitaet_laender.csv"), "\n",
    "  ", file.path(output_dir, "h3_ansicht_nach_ressourcen.csv"), "\n",
    "  ", file.path(output_dir, "ressourcen_rangliste.csv"), "\n",
    "  ", file.path(output_dir, "ressourcen_perzentile.csv"), "\n",
    sep = "")
