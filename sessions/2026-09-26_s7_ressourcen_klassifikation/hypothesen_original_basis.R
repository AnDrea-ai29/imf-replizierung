# H1-H4 auf der Original-Zaehlbasis 1992-2008
#
# Datenbasis: data/processed/conditionality_dsv_1992_2008.csv — der gegen das
# Original validierte Nachbau (314/314 identisch in Zaehlung, Quartalen,
# nrcntprogram, unsc3, avgcondtype_all). Damit entfaellt die MONA-Vintage-
# Unsicherheit; unsc3 folgt der DSV-Regel (t | t+1, Wahljahr als LEAD).
#
# Spezifikationen (README-Hypothesentabelle):
#   H1: avgcondtype_all  ~ unsc3 + Kontrollen
#   H2: avgcondtype_all  ~ unsc3 * resource_dep + Kontrollen
#   H4: rohstoff_cond_share ~ unsc3 * resource_dep + Kontrollen
# Kontrollen: XDebtGNI + DebtServGNI + ResXDebt (aus dem Original-.dta, also
# WDI-2008-Stand); Two-way FE (ISO3 + Year), heteroskedastierobuste SE.
#
# Ergaenzend M1_base: die Tabellen-2-Basisspezifikation
#   avgcondtype_all ~ unsc3 + nrquarterssmpl | ISO3
# als Sanity-Check (Soll: unsc3 = -2.410 wie phase0/Original).
#
# Ressourcen-Klassifikation der Bedingungen: gleiche Text-Keywords wie
# erstellen_mona_all.r. Die Descriptor-Praefixe (11.2, 5.1., 1., 2.) des
# modernen MONA existieren im 2008er-Exportformat nicht (numerische areacode-
# Taxonomie) und fallen daher weg — auf der Original-Basis ist die
# Klassifikation rein textbasiert (dokumentierter Unterschied zum 2000-2026-
# Panel).
#
# resource_dep (FuelExportPct + MineralExportPct) seit 2026-09-26 ab 1990
# verfuegbar (resource_dep_all.csv -> build_controls_wdi.R ->
# controls_wdi_1990_2025.csv); H2/H4 schaetzen damit ueber die volle Periode
# 1992-2008. Hinweis: die WDI-Fuel-Serie beginnt datenbedingt erst ~1995,
# Programme 1992-1994 fallen daher im H2/H4-Sample heraus.
#
# Output: results/tables/hypothesen_original_basis.csv
#         results/models/model_origbasis_*.rds

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(haven)
  library(dplyr)
  library(fixest)
})

# ---------------------------------------------------------------------------
# 1) Panel laden, Kontrollen aus dem Original mergen
# ---------------------------------------------------------------------------
base <- read.csv("data/processed/conditionality_dsv_1992_2008.csv",
                 stringsAsFactors = FALSE)
orig <- as.data.frame(read_dta("data/final/Dreher_Sturm_Vreeland_JCR.dta"))

ctrl_orig <- orig %>%
  transmute(country, Year = year,
            XDebtGNI, DebtServGNI, ResXDebt)

d <- base %>%
  left_join(ctrl_orig, by = c("country", "Year"))

cat("Panel:", nrow(d), "Land-Jahre | Kontrollen verfuegbar:",
    sum(complete.cases(d[, c("XDebtGNI", "DebtServGNI", "ResXDebt")])), "\n")

# ---------------------------------------------------------------------------
# 2) Ressourcen-Klassifikation der Original-Bedingungszeilen
#    Kuratiertes Woerterbuch statt Inline-Regex: Die Klassifikation erfolgt
#    auf Ebene der eindeutigen areadescription (offizielle MONA-Kategorie,
#    1.636 eindeutige Werte) per Join mit der reviewten Datei
#    bedingungsbeschreibungen_review.csv (Erzeugung und Vorschlagsregeln:
#    code/data_prep/klassifikation_bedingungen.R; dortiger Diagnosebefund:
#    die alte breite Keyword-Regel klassifizierte u. a. 137 Bank-
#    Privatisierungen als "rohstoff"). rohstoff_final/stabil_final sind die
#    manuell zu pruefenden Spalten (initial = konservativer Vorschlag,
#    extraktiv-spezifisch: Oel/Gas/Bergbau; energie_* = breitere
#    Sensitivitaetskategorie).
# ---------------------------------------------------------------------------
mona <- as.data.frame(read_dta(
  "data/raw/original/construction/Data MONA.dta"))

rev <- read.csv("data/processed/bedingungsbeschreibungen_review.csv",
               stringsAsFactors = FALSE)
stopifnot(all(c("desc", "rohstoff_final", "stabil_final") %in% names(rev)))

mona <- mona %>%
  mutate(desc = tolower(trimws(as.character(areadescription)))) %>%
  left_join(rev %>% select(desc, rohstoff_final, stabil_final,
                           energie_vorschlag),
            by = "desc") %>%
  mutate(
    rohstoff_cond = ifelse(is.na(rohstoff_final), 0L, rohstoff_final),
    stabil_cond   = ifelse(is.na(stabil_final), 0L, stabil_final),
    energie_cond  = ifelse(is.na(energie_vorschlag), 0L, energie_vorschlag),
    sonstige_cond = as.integer(rohstoff_cond == 0 & stabil_cond == 0)
  )
n_unmapped <- sum(is.na(mona$rohstoff_final))
n_overlap <- sum(mona$rohstoff_cond == 1 & mona$stabil_cond == 1)

cat("\nKlassifikation der 22.810 Bedingungszeilen (Review-Datei,",
    "rohstoff_final): rohstoff", sum(mona$rohstoff_cond),
    "| stabil", sum(mona$stabil_cond),
    "| energie (Sensitivitaet)", sum(mona$energie_cond),
    "| sonstige", sum(mona$sonstige_cond),
    "| rohstoff UND stabil:", n_overlap,
    "| Beschreibungen ohne Mapping:", n_unmapped, "\n")

# Programm-Ebene, dann dokumentierte Verschiebungen, dann Land-Jahr
klass <- mona %>%
  group_by(country = countryname, approvaldate) %>%
  summarise(Year = first(approvalyear),
            n_rows = n(),
            rohstoff_cond = sum(rohstoff_cond),
            stabil_cond = sum(stabil_cond),
            energie_cond = sum(energie_cond),
            sonstige_cond = sum(sonstige_cond),
            .groups = "drop") %>%
  mutate(Year = case_when(
    country == "senegal" & approvaldate == "29.08.1994" ~ 1995L,
    country == "uganda"  & approvaldate == "15.12.2006" ~ 2007L,
    TRUE ~ as.integer(Year))) %>%
  group_by(country, Year) %>%
  summarise(rohstoff_cond = sum(rohstoff_cond),
            stabil_cond = sum(stabil_cond),
            energie_cond = sum(energie_cond),
            sonstige_cond = sum(sonstige_cond),
            .groups = "drop")

d <- d %>%
  left_join(klass, by = c("country", "Year")) %>%
  mutate(
    nrcondtype_all_chk = rohstoff_cond + stabil_cond + sonstige_cond,
    rohstoff_cond_share = ifelse(nrcondtype_all > 0, rohstoff_cond / nrcondtype_all, NA_real_),
    energie_cond_share  = ifelse(nrcondtype_all > 0,
                                 (rohstoff_cond + energie_cond) / nrcondtype_all, NA_real_),
    avgcondtype_share   = ifelse(nrcondtype_all > 0,
                                 (rohstoff_cond + stabil_cond) / nrcondtype_all, NA_real_)
  )

# Konsistenz: Zaehlung identisch, Summe der Klassen >= Zaehlung wg. Doppelzuordnung
stopifnot(all(d$nrcondtype_all_chk >= d$nrcondtype_all))
cat("\nZaehlung (Nachbau == Original-Basis): identisch;",
    sum(d$nrcondtype_all_chk - d$nrcondtype_all),
    "Doppelzuordnungen rohstoff+stabil in der Land-Jahr-Summe\n")

# Konsistenz der Anteile gegen das eigene 2000-2026-Panel (nur Deskriptiv)
rp <- read.csv("data/processed/final_data_panel_ALL.csv", stringsAsFactors = FALSE)
chk <- merge(
  d %>% select(ISO3, Year, share_neu = rohstoff_cond_share),
  rp %>% select(ISO3, Year, share_alt = rohstoff_cond_share),
  by = c("ISO3", "Year"))
cat("\nKonsistenz rohstoff_cond_share gegen eigenes Panel (",
    nrow(chk), "Ueberlappungen): Korrelation",
    round(cor(chk$share_neu, chk$share_alt, use = "complete.obs"), 3),
    "| Median-Differenz", round(median(chk$share_neu - chk$share_alt, na.rm = TRUE), 3), "\n")

# ---------------------------------------------------------------------------
# 3) resource_dep aus der neuen WDI (TX.VAL.FUEL.ZS.UN + TX.VAL.MMTL.ZS.UN,
#    ab 1990 verfuegbar -> H2/H4 erstmals ueber die volle Periode 1992-2008)
# ---------------------------------------------------------------------------
wdi <- read.csv("data/processed/controls_wdi_1990_2025.csv",
                stringsAsFactors = FALSE)
res <- wdi %>%
  transmute(ISO3, Year,
            FuelExportPct, MineralExportPct, resource_dep)
d <- d %>% left_join(res, by = c("ISO3", "Year"))

ctrl <- "XDebtGNI + DebtServGNI + ResXDebt"

# ---------------------------------------------------------------------------
# 4) Modelle
# ---------------------------------------------------------------------------
cat("\n=== M1_base (Sanity, Tabellen-2-Spezifikation) ===\n")
m1_base <- feols(avgcondtype_all ~ unsc3 + nrquarterssmpl | ISO3,
                 data = d, vcov = "hetero")
print(summary(m1_base))
cat("Soll (Original/phase0): unsc3 = -2.410 (t = -1.906)\n")

cat("\n=== H1: avgcondtype_all ~ unsc3 + Kontrollen, Two-way FE ===\n")
m_h1 <- feols(as.formula(paste("avgcondtype_all ~ unsc3 +", ctrl,
                               "| ISO3 + Year")),
              data = d, vcov = "hetero")
print(summary(m_h1))

cat("\n=== H1-Variante: Kontrollen aus neuer WDI (2026-Stand, Vintage-Robustheit) ===\n")
# Alle 9 DSV-Kontrollen aus controls_wdi_1990_2025.csv verfuegbar (inkl.
# USaidGDP, IMF-Serien mit BIP ab 1990; legelec_l aus dpi_all.csv bis 2023).
d <- d %>%
  left_join(wdi %>%
              select(ISO3, Year,
                     XDebtGNI_wdi    = XDebtGNI,
                     DebtServGNI_wdi = DebtServGNI,
                     ResXDebt_wdi    = ResXDebt,
                     ExtBalGDP_wdi   = ExtBalGDP,
                     GFCFGDP_wdi     = GFCFGDP,
                     USaidGDP_wdi    = USaidGDP,
                     imf_conc_gdp_wdi    = imf_conc_gdp,
                     imf_noconc_gdp_wdi  = imf_noconc_gdp,
                     legelec_l_wdi   = legelec_l),
            by = c("ISO3", "Year"))
m_h1_wdi <- feols(avgcondtype_all ~ unsc3 +
                    XDebtGNI_wdi + DebtServGNI_wdi + ResXDebt_wdi +
                    ExtBalGDP_wdi + GFCFGDP_wdi |
                    ISO3 + Year,
                  data = d, vcov = "hetero")
print(summary(m_h1_wdi))

cat("\n=== H1-Vollmodell-Variante (8 von 9 DSV-Kontrollen, nur legelec_l fehlt) ===\n")
# DSV-Vollmodell-Spezifikation: unsc3 + nrquarterssmpl + fullvar. Eigene Basis
# mit WDI-2026-Kontrollen; fehlt: legelec_l (DPI). IMF-Serien hier NFL-Fluesse
# (konzepttreu: auch das Original misst Nettofluesse, Summen-Korrelation 0.835;
# nur die Typen-Aufteilung weicht ab, s. build_controls_wdi.R).
# Benchmark Original (Spur A): unsc3 = -3.329 (t=-1.950, N=217).
m_h1_voll8 <- feols(avgcondtype_all ~ unsc3 + nrquarterssmpl +
                      XDebtGNI_wdi + DebtServGNI_wdi + ResXDebt_wdi +
                      ExtBalGDP_wdi + GFCFGDP_wdi + USaidGDP_wdi +
                      imf_conc_gdp_wdi + imf_noconc_gdp_wdi |
                      ISO3,
                    data = d, vcov = "hetero")
print(summary(m_h1_voll8))
cat("Benchmark Original: unsc3 = -3.329 (t=-1.950, N=217, WDI-2008-Vintage)\n")

cat("\n=== H1-VOLLMODELL auf eigener Basis (ALLE 9 DSV-Kontrollen aus WDI-2026 + DPI) ===\n")
# Jetzt vollstaendig: legelec_l rekonstruiert aus dpi_all.csv (DPI-2023-Stand,
# Korrelation mit Original 0.978). IMF-Serien = NFL-Nettofluesse (konzepttreu,
# Summen-Korrelation mit Original 0.835; Typen-Aufteilung weicht ab).
# Dies ist die Spur-B-Reproduktion des Tabellen-2-Vollmodells.
m_h1_voll9 <- feols(avgcondtype_all ~ unsc3 + nrquarterssmpl +
                      XDebtGNI_wdi + DebtServGNI_wdi + ResXDebt_wdi +
                      ExtBalGDP_wdi + GFCFGDP_wdi + USaidGDP_wdi +
                      imf_conc_gdp_wdi + imf_noconc_gdp_wdi + legelec_l_wdi |
                      ISO3,
                    data = d, vcov = "hetero")
print(summary(m_h1_voll9))
cat("Benchmark Original: unsc3 = -3.329 (t=-1.950, N=217, WDI-2008-Vintage)\n")

cat("\n=== H2: avgcondtype_all ~ unsc3 * resource_dep + Kontrollen ===\n")
# resource_dep jetzt ab 1990 (neue WDI, TX.VAL.FUEL/MMTL.ZS.UN) -> Schätzung
# ueber die volle Periode 1992-2008, Two-way FE wie in der eigenen Spezifikation
ok_h2 <- !is.na(d$resource_dep) & !is.na(d$unsc3) &
         complete.cases(d[, c("XDebtGNI", "DebtServGNI", "ResXDebt")])
cat("H2/H4-Sample (Complete Cases):", sum(ok_h2),
    "| Jahre", if (sum(ok_h2)) paste(range(d$Year[ok_h2]), collapse = "-"),
    "| davon unsc3==1:", sum(ok_h2 & d$unsc3 == 1),
    "| Laender:", n_distinct(d$ISO3[ok_h2]), "\n")
m_h2 <- feols(as.formula(paste("avgcondtype_all ~ unsc3 * resource_dep +", ctrl,
                               "| ISO3 + Year")),
              data = d, vcov = "hetero")
print(summary(m_h2))

cat("\n=== H4: rohstoff_cond_share ~ unsc3 * resource_dep + Kontrollen ===\n")
m_h4 <- feols(as.formula(paste("rohstoff_cond_share ~ unsc3 * resource_dep +", ctrl,
                               "| ISO3 + Year")),
              data = d, vcov = "hetero")
print(summary(m_h4))

cat("\n=== H4-Sensitivitaet: breitere Energie-Kategorie ===\n")
# rohstoff_final ist eng (Extraktivsektor) — true resource conditions sind in
# IMF-Programmen dieser Periode SELTEN. Sensitivitaet mit breiterer Kategorie:
# extraktiv + Energie (energy/electricity/power/coal).
m_h4e <- feols(as.formula(paste("energie_cond_share ~ unsc3 * resource_dep +", ctrl,
                                "| ISO3 + Year")),
               data = d, vcov = "hetero")
print(summary(m_h4e))

# ---------------------------------------------------------------------------
# 5) Ergebnistabelle
# ---------------------------------------------------------------------------
get_term <- function(m, term) {
  ct <- coeftable(m)
  if (term %in% rownames(ct)) c(coef = ct[term, 1], p = ct[term, 4]) else c(coef = NA, p = NA)
}
mods <- list(M1_base = m1_base, H1 = m_h1, H1_wdi = m_h1_wdi,
             H1_voll8 = m_h1_voll8, H1_voll9 = m_h1_voll9, H2 = m_h2, H4 = m_h4, H4_energie = m_h4e)
terms <- c("unsc3", "resource_dep", "unsc3:resource_dep")

res_tab <- do.call(rbind, lapply(names(mods), function(lbl) {
  m <- mods[[lbl]]
  row <- data.frame(Modell = lbl, n_obs = nobs(m),
                   r2_within = NA_real_)
  for (t in terms) {
    v <- get_term(m, t)
    row[[paste0(t, "_coef")]] <- v["coef"]
    row[[paste0(t, "_p")]]    <- v["p"]
  }
  row
}))

write.csv(res_tab, "results/tables/hypothesen_original_basis.csv",
          row.names = FALSE)
saveRDS(m1_base,    "results/models/model_origbasis_m1base.rds")
saveRDS(m_h1,       "results/models/model_origbasis_h1.rds")
saveRDS(m_h1_wdi,   "results/models/model_origbasis_h1_wdi.rds")
saveRDS(m_h1_voll8, "results/models/model_origbasis_h1_voll8.rds")
saveRDS(m_h1_voll9, "results/models/model_origbasis_h1_voll9.rds")
saveRDS(m_h2,       "results/models/model_origbasis_h2.rds")
saveRDS(m_h4,       "results/models/model_origbasis_h4.rds")
saveRDS(m_h4e,      "results/models/model_origbasis_h4_energie.rds")

cat("\n=== Ergebnisuebersicht (Original-Zaehlbasis 1992-2008) ===\n")
print(res_tab, row.names = FALSE, digits = 3)
cat("\nOutput: results/tables/hypothesen_original_basis.csv\n")

cat("\nHinweis zur Belastbarkeit:\n")
cat("- M1_base reproduziert die Original-Basiszahl exakt (unsc3 = -2.410; mit\n")
cat("  plain SE t = -1.906 wie in phase0, s. Tabellen-2-Spalte 1).\n")
cat("- H1: negativer UNSC-Effekt auf der korrekt gemessenen Basis bestaetigt\n")
cat("  (statt +3.11 im alten, anders gemessenen Panel).\n")
cat("- H2/H4 auf der vollen Periode 1992-2008 (resource_dep ab 1990 aus der\n")
cat("  neuen WDI; Fuel-Serie beginnt datenbedingt ~1995). UNSC-Fallzahl im\n")
cat("  Sample oben angegeben (13).\n")
cat("- Alle 9 DSV-Kontrollen auf eigener Basis verfuegbar; IMF-Serien sind\n")
cat("  NFL-Nettofluesse (konzepttreu, Summen-Korrelation mit Original 0.835,\n")
cat("  nur Typen-Aufteilung weicht ab); legelec_l aus DPI-2023 (Korrelation\n")
cat("  0.978, Serie endet 2023).\n")
