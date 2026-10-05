# Harmonisiertes WDI-Kontrollpanel 1990-2025 (alle Laender)
#
# Quellen (data/raw/wdi/):
#   - Data_all/<Var>_all.csv: je Serie, DURCHGEHEND 1990-2025:
#     ExtBalGDP (NE.RSB.GNFS.ZS), XDebtGNI (DT.DOD.DECT.GN.ZS),
#     GFCFGDP (NE.GDI.FTOT.ZS), DebtServGNI (DT.TDS.DECT.GN.ZS),
#     ResXDebt (FI.RES.TOTL.DT.ZS), NetUSAid (DC.DAC.USAL.CD, US$),
#     imf_conc (DT.NFL.IMFC.CD) / imf_noconc (DT.NFL.IMFN.CD), Nettofluesse US$,
#     sowie resource_dep_all.csv mit DREI Serien je Land, 1990-2025:
#     NE.EXP.GNFS.ZS (Exporte % BIP -> ExportGDP), TX.VAL.FUEL.ZS.UN und
#     TX.VAL.MMTL.ZS.UN (-> FuelExportPct/MineralExportPct -> resource_dep).
#   - Data_all/NY.GDP.MKTP.CD_all.csv: BIP laufende US$, durchgehend 1990-2025
#
# WICHTIGE CAVEATS:
#   1) resource_dep_all.csv enthaelt NEBEN den Treibstoff-/Mineralien-Serien
#      auch NE.EXP.GNFS.ZS = Gesamtexporte (% BIP) — das ist AUSSENHANDELS-
#      OFFNUNG, NICHT Rohstoffabhaengigkeit und wird separat als `ExportGDP`
#      gefuehrt. resource_dep = FuelExportPct + MineralExportPct.
#   2) USaidGDP: 100 * NetUSAid / BIP — Abweichung zum Original (dort
#      Faktorkosten-BIP und Aid in Mio. US$); Median-Abweichung -14 %.
#   3) Die IMF-Serien sind Nettofluesse (DT.NFL.IMFC/IMFN.CD), kein
#      Kreditbestand wie im Original — Konzeptabweichung, kein Ersatz
#      (Korrelation 0.65/0.35). DSV-Regel NA->0 vor Division uebernommen.
#   4) legelec_l (DPI-Wahljahr, Lag Kalenderjahr t-1) aus dpi_all.csv
#      (DPI-2023-Stand, laeuft nur bis 2023; Original-Vintage: DPI 2006 rev4).
#
# Output:
#   data/processed/controls_wdi_1990_2025.csv  (ISO3, Year, <Variablen>)
#   results/shared/tables/wdi_kontrollen_vintage_check.csv (Vintage-Vergleich)

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(haven)
  library(dplyr)
  library(tidyr)
})

wdi_long <- function(file) {
  raw <- read.csv(file, check.names = FALSE, stringsAsFactors = FALSE,
                 na.strings = c("..", "", "NA"))
  raw %>%
    select(ISO3 = `Country Code`, Serie = `Series Name`, matches("^[0-9]{4}")) %>%
    pivot_longer(-c(ISO3, Serie), names_to = "Year", values_to = "value") %>%
    mutate(Year = as.integer(sub(" .*", "", Year)),
           value = suppressWarnings(as.numeric(value)))
}

# ---------------------------------------------------------------------------
# 1) Einzel-Serien-Dateien (durchgehend 1990-2025)
# ---------------------------------------------------------------------------
files_einzeln <- c(
  ExtBalGDP   = "ExtBalGDP_all.csv",
  XDebtGNI    = "XDebtGNI_all.csv",
  GFCFGDP     = "GFCFGDP_all.csv",
  DebtServGNI = "DebtServGNI_all.csv",
  ResXDebt    = "ResXDebt_all.csv",
  NetUSAid    = "NetUSAid_all.csv",
  imf_conc    = "imf_conc_gdp_all.csv",
  imf_noconc  = "imf_noconc_gdp_all.csv",
  UseIMFCredit = "UseofIMFCredit_all.csv"   # DT.DOD.DIMF.CD: Kreditbestand je Land
)
einzeln <- bind_rows(lapply(names(files_einzeln), function(nm) {
  d <- wdi_long(file.path("data/raw/wdi/Data_all", files_einzeln[[nm]]))
  d %>% mutate(var = nm) %>% select(ISO3, Year, var, value)
}))

# Serien-Codes zur Kontrolle ausgeben
for (nm in names(files_einzeln)) {
  f <- files_einzeln[[nm]]
  code <- unique(read.csv(file.path("data/raw/wdi/Data_all", f),
               check.names = FALSE, na.strings = "..")[["Series Code"]])
  cat(sprintf("%-12s <- %s (%s)\n", nm, code, f))
}

# resource_dep_all.csv enthaelt DREI Serien je Land (1990-2025):
#   NE.EXP.GNFS.ZS   -> ExportGDP      (Exporte % BIP: Handelsorientierung)
#   TX.VAL.FUEL.ZS.UN-> FuelExportPct  (Treibstoff-Exportanteil)
#   TX.VAL.MMTL.ZS.UN-> MineralExportPct (Erze/Metalle-Exportanteil)
res_raw <- read.csv("data/raw/wdi/Data_all/resource_dep_all.csv",
                    check.names = FALSE, stringsAsFactors = FALSE,
                    na.strings = c("..", "", "NA"))
map_res <- c(
  "NE.EXP.GNFS.ZS"    = "ExportGDP",
  "TX.VAL.FUEL.ZS.UN" = "FuelExportPct",
  "TX.VAL.MMTL.ZS.UN" = "MineralExportPct"
)
res_long <- res_raw %>%
  select(ISO3 = `Country Code`, Serie = `Series Code`, matches("^[0-9]{4}")) %>%
  filter(Serie %in% names(map_res)) %>%
  pivot_longer(-c(ISO3, Serie), names_to = "Year", values_to = "value") %>%
  mutate(Year = as.integer(sub(" .*", "", Year)),
         var = unname(map_res[Serie]),
         value = suppressWarnings(as.numeric(value))) %>%
  select(ISO3, Year, var, value)
cat("resource_dep_all.csv-Serien:",
    paste(unique(res_long$var), collapse = ", "), "\n")

# ---------------------------------------------------------------------------
# 2) GDP (NY.GDP.MKTP.CD, 1990-2025, fuer %-BIP-Umrechnungen)
# ---------------------------------------------------------------------------
nomgdp <- wdi_long("data/raw/wdi/Data_all/NY.GDP.MKTP.CD_all.csv") %>%
  mutate(var = "nomGDP") %>% select(ISO3, Year, var, value)

# ---------------------------------------------------------------------------
# 2b) DPI: legelec und legelec_l (Lag auf Kalenderjahr t-1 im Volljahres-Panel)
#     Konstruktion exakt nach txt2dta7.do (verifiziert): DPI-Serien legelec,
#     -999 -> NA, Code-Fix YSR->SRB (Original: YSR->YUG), Merge ISO3 x Jahr,
#     legelec_l = legelec im KALENDERJAHR t-1; dpi_all.csv laeuft nur bis 2023.
# ---------------------------------------------------------------------------
dpi <- read.csv("data/raw/wdi/Data_all/dpi_all.csv",
                check.names = FALSE, stringsAsFactors = FALSE,
                na.strings = c("", "NA"))
dpi_raw <- dpi
dpi <- dpi[!is.na(suppressWarnings(as.integer(substr(as.character(dpi$year), 1, 4)))), ]
if (nrow(dpi) < nrow(dpi_raw)) {
  cat("HINWEIS: ", nrow(dpi_raw) - nrow(dpi),
      " DPI-Zeilen nicht parsbar (unbalancierte Anfuehrungszeichen,",
      "betrifft Chile 2014-2017; ausserhalb des Original-Zeitraums) und wurden verworfen.\n")
}
dpi_leg <- dpi %>%
  transmute(ISO3 = as.character(ifs),
            Year = as.integer(substr(as.character(year), 1, 4)),
            legelec = suppressWarnings(as.numeric(legelec)),
            exelec  = suppressWarnings(as.numeric(exelec)),
            execrlc = as.character(execrlc)) %>%
  mutate(ISO3 = case_when(ISO3 == "YSR" ~ "SRB",   # Original: YSR -> YUG
                          ISO3 == "ROM" ~ "ROU",
                          ISO3 == "ZAR" ~ "COD",
                          TRUE ~ ISO3),
         across(c(legelec, exelec), ~ ifelse(.x == -999, NA_real_, .x))) %>%
  group_by(ISO3, Year) %>%
  summarise(legelec = first(legelec[!is.na(legelec)]),
            exelec  = first(exelec[!is.na(exelec)]),
            execrlc = first(execrlc[!is.na(execrlc) & execrlc != ""]),
            .groups = "drop")
cat("DPI:", nrow(dpi_leg), "Land-Jahre |",
    length(unique(dpi_leg$ISO3)), "Laender, Jahre",
    paste(range(dpi_leg$Year), collapse = "-"),
    "| legelec==1:", sum(dpi_leg$legelec == 1, na.rm = TRUE), "\n")

long_all <- bind_rows(einzeln, res_long, nomgdp)

wide <- long_all %>%
  group_by(ISO3, Year, var) %>%
  summarise(value = first(value[!is.na(value)]), .groups = "drop") %>%
  pivot_wider(names_from = var, values_from = value) %>%
  arrange(ISO3, Year) %>%
  mutate(
    USaidGDP = ifelse(!is.na(NetUSAid) & !is.na(nomGDP),
                     100 * NetUSAid / nomGDP, NA_real_),
    # DSV-Regel NA->0 vor Division (hier auf Nettofluesse uebertragen,
    # Konzeptabweichung zum Original-Kreditbestand dokumentiert)
    imf_conc0   = ifelse(is.na(imf_conc), 0, imf_conc),
    imf_noconc0 = ifelse(is.na(imf_noconc), 0, imf_noconc),
    imf_conc_gdp   = ifelse(!is.na(nomGDP), 100 * imf_conc0 / nomGDP, NA_real_),
    imf_noconc_gdp = ifelse(!is.na(nomGDP), 100 * imf_noconc0 / nomGDP, NA_real_),
    # Konzepttreuer IMF-Kreditbestand (DOD) je Land, DSV-Regel NA->0:
    # SUPPLEMENTAER — Diagnose 2026-09-26: Die Original-Variable imf_conc_gdp/
    # imf_noconc_gdp kann NEGATIV sein und ihre Summe korreliert mit der
    # NFL-Flusssumme (DT.NFL.IMFC+IMFN) mit 0.835, mit dem DOD-Bestand nur
    # schwach. Das Original misst also NETTOFLUESSE (nicht Bestand); die
    # NFL-Serien im Kontrollpanel sind konzepttreu, nur die Aufteilung
    # konzessionaer/nicht-konzessionaer weicht zwischen den Quellen ab.
    # UseIMFCredGDP bleibt als alternative, sauber definierte Bestandsgröße.
    UseIMFCredGDP = ifelse(!is.na(nomGDP),
                           100 * ifelse(is.na(UseIMFCredit), 0, UseIMFCredit) / nomGDP,
                           NA_real_),
    imf_sum_gdp = imf_conc_gdp + imf_noconc_gdp,
    resource_dep = ifelse(!is.na(FuelExportPct) | !is.na(MineralExportPct),
                          FuelExportPct + MineralExportPct, NA_real_)
  ) %>%
  # DPI: legelec (Jahr t) und legelec_l (Kalenderjahr t-1, wie im Original)
  left_join(dpi_leg, by = c("ISO3", "Year")) %>%
  left_join(dpi_leg %>%
              select(ISO3, Year, legelec_l = legelec) %>%
              mutate(Year = Year + 1),
            by = c("ISO3", "Year")) %>%
  select(ISO3, Year, ExtBalGDP, XDebtGNI, GFCFGDP, DebtServGNI, ResXDebt,
         NetUSAid, nomGDP, USaidGDP, imf_conc_gdp, imf_noconc_gdp,
         UseIMFCredit, UseIMFCredGDP, imf_sum_gdp,
         ExportGDP, FuelExportPct, MineralExportPct, resource_dep,
         legelec, legelec_l)

write.csv(wide, "data/processed/controls_wdi_1990_2025.csv", row.names = FALSE)
cat("\nKontrollpanel:", nrow(wide), "Land-Jahre |",
    length(unique(wide$ISO3)), "Laender ->",
    "data/processed/controls_wdi_1990_2025.csv\n")

cat("\n=== Deckung je Variable (Land-Jahre mit Wert) ===\n")
for (v in c("ExtBalGDP", "XDebtGNI", "GFCFGDP", "DebtServGNI", "ResXDebt",
            "ExportGDP", "USaidGDP", "imf_conc_gdp", "imf_noconc_gdp",
            "resource_dep", "legelec_l", "imf_sum_gdp")) {
  w9299 <- sum(!is.na(wide[[v]]) & wide$Year >= 1992 & wide$Year <= 1999)
  w0008 <- sum(!is.na(wide[[v]]) & wide$Year >= 2000 & wide$Year <= 2008)
  w0925 <- sum(!is.na(wide[[v]]) & wide$Year >= 2009)
  cat(sprintf("%-14s 1992-99: %4d | 2000-08: %4d | 2009-25: %4d\n",
              v, w9299, w0008, w0925))
}

# ---------------------------------------------------------------------------
# 3) Vintage-Validierung gegen Original-.dta (1992-2008)
# ---------------------------------------------------------------------------
orig <- as.data.frame(read_dta("data/final/Dreher_Sturm_Vreeland_JCR.dta"))
cw <- read.csv("data/processed/crosswalk_dsv_iso3.csv", stringsAsFactors = FALSE)
orig_c <- orig %>%
  transmute(country, Year = year, ExtBalGDP, XDebtGNI, GFCFGDP, DebtServGNI,
            ResXDebt, USaidGDP, imf_conc_gdp, imf_noconc_gdp, legelec_l,
            imf_sum_gdp = imf_conc_gdp + imf_noconc_gdp) %>%
  left_join(cw %>% select(country, ISO3), by = "country")

cmp <- orig_c %>%
  inner_join(wide, by = c("ISO3", "Year"), suffix = c(".orig", ".wdi"))

cat("\n=== Vintage-Vergleich Original (WDI-2008) vs. neue WDI (2026-Stand) ===\n")
vint <- do.call(rbind, lapply(
  c("ExtBalGDP", "XDebtGNI", "GFCFGDP", "DebtServGNI", "ResXDebt",
    "USaidGDP", "imf_conc_gdp", "imf_noconc_gdp", "legelec_l", "imf_sum_gdp"),
  function(v) {
    a <- cmp[[paste0(v, ".orig")]]; b <- cmp[[paste0(v, ".wdi")]]
    ok <- !is.na(a) & !is.na(b)
    data.frame(Variable = v,
               n_gemeinsam = sum(ok),
               Korrelation = if (sum(ok) > 2) round(cor(a[ok], b[ok]), 3) else NA,
               Median_RelDiff = if (sum(ok) > 0)
                 round(median((b[ok] - a[ok]) / pmax(abs(a[ok]), 1e-9)), 3) else NA)
  }))
print(vint, row.names = FALSE)

dir.create("results/shared/tables", recursive = TRUE, showWarnings = FALSE)
write.csv(vint, "results/shared/tables/wdi_kontrollen_vintage_check.csv",
          row.names = FALSE)
cat("\nOutput: results/shared/tables/wdi_kontrollen_vintage_check.csv\n")
