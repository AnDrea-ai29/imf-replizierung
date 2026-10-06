# Deskriptive Evidenz vor den konfirmatorischen Phase-B-Modellen, analog zu
# Tabelle 1 der Originalstudie (Dreher/Sturm/Vreeland 2015): Vergleich von
# Mittelwerten zwischen temporären UNSC-Mitgliedern und Nicht-Mitgliedern.
# Explizit deskriptiv gekennzeichnet: Die p-Werte charakterisieren
# Groessenunterschiede, sie sind KEINE Hypothesentests und ersetzen die
# FE-/GLS-Modelle nicht.
#
# Balkendiagramme nach der Darstellungsweise des Originals: Der Balken bildet
# nur den Mittelwert ab (halbtransparente Farben: hellgrau = Nicht-UNSC,
# hellblau = UNSC); Standardabweichung und Fallzahl (n) stehen schriftlich
# unterhalb des Balkens, der p-Wert des Welch-t-Tests im Paneltitel
# (Abbildung 1) bzw. unter der Achse (Abbildung 2).
#
# H1-Analogon: avgcondtype_count (Bedingungen pro Quartal) nach unsc3.
# H2-Analogon: derselbe Vergleich getrennt fuer niedrige vs. hohe
# Rohstoffexportabhaengigkeit (Median-Split), da H2 eine Interaktion
# unsc3 x resource_dep prueft.
#
# Output:
#   results/phase_b/tables/phase_b_deskriptive_evidenz.csv
#   results/phase_b/tables/phase_b_deskriptive_evidenz_h2_split.csv
#   results/phase_b/figures/deskriptive_evidenz_gruppe.png
#   results/phase_b/figures/deskriptive_evidenz_h2_split.png

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages(library(dplyr))

panel_path <- "data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
if (!file.exists(panel_path)) stop("Phase-B-Panel fehlt: ", panel_path)

d <- read.csv(panel_path, stringsAsFactors = FALSE) %>%
  filter(Year >= 1992, Year <= 2023)

if (nrow(d) == 0) stop("Keine Beobachtungen im Analysezeitraum 1992-2023.")

# ---------------------------------------------------------------------------
# 1) Deskriptiver Vergleich UNSC vs. Nicht-UNSC (analog Original-Tabelle 1)
# ---------------------------------------------------------------------------

vars_desc <- c("nrcondtype_all", "nrquarterssmpl", "avgcondtype_count",
               "resource_dep", "FuelExportPct", "MineralExportPct")

describe_group <- function(x) {
  x <- x[!is.na(x)]
  c(n = length(x), mean = if (length(x)) mean(x) else NA_real_,
    sd = if (length(x) > 1) sd(x) else NA_real_)
}

table1 <- do.call(rbind, lapply(vars_desc, function(v) {
  g0 <- d[[v]][d$unsc3 == 0]
  g1 <- d[[v]][d$unsc3 == 1]
  s0 <- describe_group(g0)
  s1 <- describe_group(g1)
  tt <- tryCatch(t.test(g1, g0), error = function(e) NULL)
  data.frame(
    Variable = v,
    n_nicht_unsc = s0["n"], mean_nicht_unsc = s0["mean"], sd_nicht_unsc = s0["sd"],
    n_unsc = s1["n"], mean_unsc = s1["mean"], sd_unsc = s1["sd"],
    differenz = s1["mean"] - s0["mean"],
    p_welch = if (!is.null(tt)) tt$p.value else NA_real_,
    stringsAsFactors = FALSE
  )
}))

# ---------------------------------------------------------------------------
# 2) H2-Analogon: Vergleich getrennt nach Median-Split der Rohstoffabhaengigkeit
# ---------------------------------------------------------------------------

d_h2 <- d %>% filter(!is.na(avgcondtype_count), !is.na(resource_dep))
median_rd <- median(d_h2$resource_dep)
d_h2$rd_gruppe <- ifelse(d_h2$resource_dep <= median_rd,
                         "niedrige Rohstoffabhaengigkeit (<= Median)",
                         "hohe Rohstoffabhaengigkeit (> Median)")

table_h2 <- do.call(rbind, lapply(split(d_h2, d_h2$rd_gruppe), function(stratum) {
  g0 <- stratum$avgcondtype_count[stratum$unsc3 == 0]
  g1 <- stratum$avgcondtype_count[stratum$unsc3 == 1]
  s0 <- describe_group(g0)
  s1 <- describe_group(g1)
  tt <- tryCatch(t.test(g1, g0), error = function(e) NULL)
  data.frame(
    Rohstoffgruppe = unique(stratum$rd_gruppe),
    resource_dep_grenze = round(median_rd, 2),
    n_nicht_unsc = s0["n"], mean_nicht_unsc = s0["mean"], sd_nicht_unsc = s0["sd"],
    n_unsc = s1["n"], mean_unsc = s1["mean"], sd_unsc = s1["sd"],
    differenz = s1["mean"] - s0["mean"],
    p_welch = if (!is.null(tt)) tt$p.value else NA_real_,
    stringsAsFactors = FALSE
  )
}))
table_h2 <- table_h2[order(table_h2$Rohstoffgruppe), ]

dir.create("results/phase_b/tables", recursive = TRUE, showWarnings = FALSE)
write.csv(table1, "results/phase_b/tables/phase_b_deskriptive_evidenz.csv",
          row.names = FALSE)
write.csv(table_h2,
          "results/phase_b/tables/phase_b_deskriptive_evidenz_h2_split.csv",
          row.names = FALSE)

cat("=== Deskriptive Evidenz (analog Original-Tabelle 1), 1992-2023 ===\n")
cat("Stichprobe: alle Programm-Land-Jahre; je Variable verfuegbare Faelle.\n")
print(table1, row.names = FALSE, digits = 3)
cat("\n=== H2-Analogon: Median-Split resource_dep, avgcondtype_count nach unsc3 ===\n")
cat("Median resource_dep:", round(median_rd, 2), "% der Warenexporte\n")
print(table_h2, row.names = FALSE, digits = 3)
cat("\nKennzeichnung: deskriptiv. p-Werte (Welch-t-Test) beschreiben\n")
cat("Groessenunterschiede, sie testen keine Hypothese.\n")

# ---------------------------------------------------------------------------
# 3) Balkendiagramme im Stil des Originals: Balken = Mittelwert
#    (halbtransparent: hellgrau = Nicht-UNSC, hellblau = UNSC),
#    SD und n unterhalb des Balkens, p-Wert im Paneltitel bzw. unter der Achse
# ---------------------------------------------------------------------------

suppressMessages(library(ggplot2))

labels_desc <- c(
  nrcondtype_all = "Bedingungen gesamt",
  nrquarterssmpl = "Programmquartale",
  avgcondtype_count = "Bedingungen pro Quartal",
  resource_dep = "Rohstoffabhängigkeit (% Warenexporte)"
)

farben <- c("Nicht-UNSC" = "grey75", "UNSC" = "lightskyblue")

df_plot1 <- do.call(rbind, lapply(names(labels_desc), function(v) {
  r <- table1[table1$Variable == v, ]
  data.frame(
    Variable = paste0(labels_desc[[v]], "\n(p = ",
                      sprintf("%.2f", r$p_welch), ")"),
    Gruppe = c("Nicht-UNSC", "UNSC"),
    n = c(r$n_nicht_unsc, r$n_unsc),
    mean = c(r$mean_nicht_unsc, r$mean_unsc),
    sd = c(r$sd_nicht_unsc, r$sd_unsc)
  )
}))

p1 <- ggplot(df_plot1, aes(x = Gruppe, y = mean, fill = Gruppe)) +
  geom_col(width = 0.6, alpha = 0.6) +
  geom_text(aes(label = sprintf("%.1f", mean)), vjust = -0.9, size = 3.2) +
  geom_text(aes(label = paste0("SD ", sprintf("%.1f", sd), "\nn ", n)),
            y = 0, vjust = -0.4, size = 2.5, lineheight = 0.9,
            color = "grey25") +
  facet_wrap(~Variable, scales = "free_y", nrow = 2) +
  scale_fill_manual(values = farben) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(title = "Deskriptiver Vergleich: IMF-Programme 1992–2023",
       subtitle = paste0("Balken = Mittelwert (hellgrau = Nicht-UNSC, hellblau = UNSC); ",
                         "darunter Standardabweichung und Fallzahl je Gruppe; ",
                         "p-Wert des Welch-t-Tests im Paneltitel"),
       x = NULL, y = "Mittelwert", fill = NULL) +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold", size = 11),
        strip.text = element_text(face = "bold", size = 8.5))

df_plot2 <- do.call(rbind, lapply(seq_len(nrow(table_h2)), function(i) {
  r <- table_h2[i, ]
  data.frame(
    Rohstoffgruppe = rep(
      paste0(gsub("Rohstoffabhaengigkeit", "Rohstoffabhängigkeit",
                  r$Rohstoffgruppe),
             "\n(p = ", sprintf("%.2f", r$p_welch), ")"), 2),
    Gruppe = c("Nicht-UNSC", "UNSC"),
    n = c(r$n_nicht_unsc, r$n_unsc),
    mean = c(r$mean_nicht_unsc, r$mean_unsc),
    sd = c(r$sd_nicht_unsc, r$sd_unsc)
  )
}))

p2 <- ggplot(df_plot2, aes(x = Rohstoffgruppe, y = mean, fill = Gruppe)) +
  geom_col(position = position_dodge(0.7), width = 0.6, alpha = 0.6) +
  geom_text(aes(label = sprintf("%.1f", mean)),
            position = position_dodge(0.7), vjust = -0.9, size = 3.2) +
  geom_text(aes(y = 0, label = paste0("SD ", sprintf("%.1f", sd), "\nn ", n)),
            vjust = -0.4, size = 2.5, lineheight = 0.9,
            color = "grey25", position = position_dodge(0.7)) +
  scale_fill_manual(values = farben, name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Bedingungen pro Quartal nach UNSC-Mitgliedschaft und Rohstoffabhängigkeit",
       subtitle = paste0("Median-Split der Rohstoffexportabhängigkeit (Median 11,8 % der Warenexporte); ",
                        "Balken = Mittelwert (hellgrau = Nicht-UNSC, hellblau = UNSC); ",
                        "darunter Standardabweichung und Fallzahl; ",
                        "p-Werte der Welch-t-Tests unter der Achse"),
       x = NULL, y = "Bedingungen pro Quartal") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 11),
        axis.text.x = element_text(size = 8.5))

dir.create("results/phase_b/figures", recursive = TRUE, showWarnings = FALSE)
ggsave("results/phase_b/figures/deskriptive_evidenz_gruppe.png", p1,
       width = 8, height = 5.5, dpi = 300)
ggsave("results/phase_b/figures/deskriptive_evidenz_h2_split.png", p2,
       width = 8, height = 4.5, dpi = 300)

cat("\nBalkendiagramme (Balken = Mittelwert, SD/n darunter, p schriftlich):\n")
cat("- results/phase_b/figures/deskriptive_evidenz_gruppe.png\n")
cat("- results/phase_b/figures/deskriptive_evidenz_h2_split.png\n")
cat("\nOutput: results/phase_b/tables/phase_b_deskriptive_evidenz.csv\n")
cat("        results/phase_b/tables/phase_b_deskriptive_evidenz_h2_split.csv\n")
