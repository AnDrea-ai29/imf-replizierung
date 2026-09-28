# Nachbau des Konditionalitaets- und UNSC-Blocks des Originaldatensatzes
# (Dreher/Sturm/Vreeland, JCR 2015) fuer 1992-2008 aus den Original-Konstruktionsdaten.
#
# Basis: data/raw/original/construction/Data MONA.dta (22.810 Bedingungs-Zeilen)
# Regeln exakt nach construction/txt2dta7.do (verifiziert 2026-09-25):
#   - Programm  = countryname x approvaldate (= programnr in Data MONA.dta)
#   - Zaehlung  = Zeilenzahl je Bedingungstyp; Joint-Typ "SB+PA" zaehlt doppelt
#                 (condtype_2/3 enthalten den Joint-Typ bereits, condtype_0 = Summe)
#   - Quartale  : fstartdate = max(approvaldate, 31.03.1992 = Stata-Tag 11778)
#                 fenddate   = min(finalenddate, 28.09.2008 = Stata-Tag 17803)
#                 nrquarterssmpl = round((fenddate - fstartdate)/90)
#   - Land-Jahr : eine Zeile pro Land-Jahr; zwei dokumentierte Verschiebungen:
#                 Senegal 29.08.1994 -> Jahr 1995; Uganda 15.12.2006 -> Jahr 2007
#   - unsc3     = UNSC-Mitgliedschaft im Programmjahr t ODER im Kalenderjahr
#                 t+1 ("election year included", s. JCR_DSV_Table1.doh);
#                 4 Handwerte auf 0: AETH 1992, RUS 1995/1996/1999
#   - nrcntprogram = Rang des Programmjahres je Land (1..7)
#
# UNSC-Quelle: data/raw/unsc/unsc_membership_ISO3_correct.csv (DPPA, Vollpanel)
#
# Output:
#   data/processed/crosswalk_dsv_iso3.csv
#   data/processed/conditionality_dsv_1992_2008.csv
# Validierung gegen data/final/Dreher_Sturm_Vreeland_JCR.dta (Soll: 314/314 exakt)

setwd("C:/Users/HP/io/imf-replizierung")

suppressMessages({
  library(haven)
  library(dplyr)
})

STATA_ORIGIN <- as.Date("1960-01-01")
FLOOR_START  <- 11778L   # 31.03.1992: erstes Approval-Datum im Sample
CAP_END      <- 17803L   # 30.06.2008 + 90 Tage (letztes Testdatum im Sample)

mona <- as.data.frame(read_dta(
  "data/raw/original/construction/Data MONA.dta"))
orig <- as.data.frame(read_dta("data/final/Dreher_Sturm_Vreeland_JCR.dta"))

# ---------------------------------------------------------------------------
# 1) Crosswalk: countryname -> wdicode -> ISO3 (moderne Codes)
# ---------------------------------------------------------------------------
cw <- mona %>%
  distinct(countryname, wdicode) %>%
  rename(country = countryname) %>%
  mutate(
    ISO3 = case_when(
      wdicode == "ROM" ~ "ROU",   # Rumänien: alter WDI-Code
      wdicode == "ZAR" ~ "COD",   # Kongo, DR: alter WDI-Code
      wdicode == "YUG" ~ "SRB",   # Jugoslawien / Serbien-Montenegro
      TRUE ~ wdicode
    ),
    ISO3_note = case_when(
      wdicode %in% c("ROM", "ZAR") ~ "Vintage-Korrektur",
      wdicode == "YUG" ~ "Gilt fuer yugoslavia UND serbia and montenegro (idcnt 237)",
      TRUE ~ ""
    )
  )
id_map <- orig %>% distinct(country, idcnt)
cw <- cw %>%
  left_join(id_map, by = "country") %>%
  arrange(country)

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
write.csv(cw, "data/processed/crosswalk_dsv_iso3.csv", row.names = FALSE)
cat("Crosswalk:", nrow(cw), "Laender ->", "data/processed/crosswalk_dsv_iso3.csv\n")

# ---------------------------------------------------------------------------
# 2) Programmerebene: Zaehlung, Laufzeit, Typen
# ---------------------------------------------------------------------------
prog <- mona %>%
  group_by(programnr) %>%
  summarise(
    country   = first(countryname),
    wdicode   = first(wdicode),
    approvaldate     = first(approvaldate),
    approvaldatestata = first(approvaldatestata),
    Year      = first(approvalyear),
    finalenddate = max(enddatestata, na.rm = TRUE),
    nrcondtype_0 = sum(condtype_0, na.rm = TRUE),
    nrcondtype_1 = sum(condtype_1, na.rm = TRUE),
    nrcondtype_2 = sum(condtype_2, na.rm = TRUE),
    nrcondtype_3 = sum(condtype_3, na.rm = TRUE),
    nrarrtype_0  = sum(arrtype_0,  na.rm = TRUE),
    nrarrtype_1  = sum(arrtype_1,  na.rm = TRUE),
    nrarrtype_2  = sum(arrtype_2,  na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    fstartdate = pmax(as.integer(approvaldatestata), FLOOR_START),
    fenddate   = pmin(as.integer(finalenddate), CAP_END),
    nrdayssmpl = ifelse(fenddate > fstartdate, fenddate - fstartdate, NA_real_),
    nrquarterssmpl = ifelse(!is.na(nrdayssmpl),
                            floor(nrdayssmpl / 90 + 0.5), NA_real_),
    # Dokumentierte Jahresverschiebungen (txt2dta7.do)
    Year = case_when(
      country == "senegal" & approvaldate == "29.08.1994" ~ 1995L,
      country == "uganda"  & approvaldate == "15.12.2006" ~ 2007L,
      TRUE ~ as.integer(Year)
    )
  )

cat("Programme:", nrow(prog), "\n")

# ---------------------------------------------------------------------------
# 3) Land-Jahr-Ebene: Aggregation, nrcntprogram, AV
# ---------------------------------------------------------------------------
panel <- prog %>%
  group_by(country, Year) %>%
  summarise(
    wdicode       = first(wdicode),
    approvaldate  = paste(approvaldate, collapse = ";"),
    nrquarterssmpl = max(nrquarterssmpl, na.rm = TRUE),
    nrcondtype_0  = sum(nrcondtype_0),
    nrcondtype_1  = sum(nrcondtype_1),
    nrcondtype_2  = sum(nrcondtype_2),
    nrcondtype_3  = sum(nrcondtype_3),
    nrarrtype_0   = sum(nrarrtype_0),
    nrarrtype_1   = sum(nrarrtype_1),
    nrarrtype_2   = sum(nrarrtype_2),
    .groups = "drop"
  ) %>%
  # nrcntprogramm = Rang des Programmjahres je idcnt-Gruppe (yugoslavia und
  # serbia and montenegro teilen idcnt 237 / ISO3 SRB und werden gemeinsam
  # gereiht, wie im Original "rank of approvalyear by idcnt")
  group_by(wdicode) %>%
  arrange(wdicode, Year, .by_group = TRUE) %>%
  mutate(nrcntprogram = row_number()) %>%
  ungroup()

# ---------------------------------------------------------------------------
# 4) unsc3 nach DSV-Regel (Vollpanel-Datenquelle, tsset-Luecken-Semantik)
# ---------------------------------------------------------------------------
unsc_panel <- read.csv("data/raw/unsc/unsc_membership_ISO3_correct.csv",
                       stringsAsFactors = FALSE)
unsc_lookup <- unsc_panel %>% distinct(ISO3, year, unsc)

iso_of <- setNames(cw$ISO3, cw$country)
panel$ISO3 <- unname(iso_of[panel$country])

unsc_next_lookup <- unsc_panel %>%
  distinct(ISO3, year, unsc) %>%
  mutate(Year = year - 1) %>%
  select(ISO3, Year, unsc_tplus1 = unsc)

panel <- panel %>%
  left_join(unsc_lookup, by = c("ISO3", "Year" = "year")) %>%
  left_join(unsc_next_lookup, by = c("ISO3", "Year")) %>%
  mutate(
    # Kalenderjahr t+1 aus dem Vollpanel (unabhaengig von Programmzeilen)
    unsc_tplus1 = ifelse(is.na(unsc_tplus1), 0, unsc_tplus1),
    unsc3 = as.integer((unsc == 1) | (unsc_tplus1 == 1)),
    # Handkorrekturen aus txt2dta7.do
    unsc3 = ifelse(ISO3 == "ETH" & Year == 1992, 0L, unsc3),
    unsc3 = ifelse(ISO3 == "RUS" & Year %in% c(1995, 1996, 1999), 0L, unsc3)
  ) %>%
  select(-unsc_tplus1)

# ---------------------------------------------------------------------------
# 5) Abhaengige Variablen (avg* = nr* / nrquarterssmpl, wie txt2dta7.do)
# ---------------------------------------------------------------------------
for (t in 0:3) {
  panel[[paste0("avgcondtype_", t)]] <-
    ifelse(panel$nrquarterssmpl > 0, panel[[paste0("nrcondtype_", t)]] / panel$nrquarterssmpl, NA_real_)
  panel[[paste0("avgarrtype_", t)]] <-
    ifelse(panel$nrquarterssmpl > 0, panel[[paste0("nrarrtype_", t)]] / panel$nrquarterssmpl, NA_real_)
}
panel <- panel %>%
  mutate(
    nrcondtype_all = nrcondtype_0, nrcondtype_pc = nrcondtype_1,
    nrcondtype_pa = nrcondtype_2,  nrcondtype_sb = nrcondtype_3,
    avgcondtype_all = avgcondtype_0, avgcondtype_pc = avgcondtype_1,
    avgcondtype_pa = avgcondtype_2, avgcondtype_sb = avgcondtype_3
  )

panel <- panel %>%
  select(country, wdicode, ISO3, Year, approvaldate, nrcntprogram,
         unsc, unsc3, nrquarterssmpl,
         nrcondtype_all, nrcondtype_pc, nrcondtype_pa, nrcondtype_sb,
         nrarrtype_0, nrarrtype_1, nrarrtype_2,
         avgcondtype_all, avgcondtype_pc, avgcondtype_pa, avgcondtype_sb,
         avgcondtype_0, avgarrtype_0) %>%
  arrange(ISO3, Year)

write.csv(panel, "data/processed/conditionality_dsv_1992_2008.csv",
          row.names = FALSE)
cat("Nachbau:", nrow(panel), "Land-Jahre ->",
    "data/processed/conditionality_dsv_1992_2008.csv\n\n")

# ---------------------------------------------------------------------------
# 6) Validierung gegen den Original-Datensatz
# ---------------------------------------------------------------------------
cmp_vars <- c("nrcondtype_all", "nrcondtype_pc", "nrcondtype_pa", "nrcondtype_sb",
              "nrquarterssmpl", "nrcntprogram", "unsc3", "avgcondtype_all")
cmp <- merge(
  orig[, c("country", "year", cmp_vars)],
  panel[, c("country", "Year", cmp_vars)],
  by.x = c("country", "year"), by.y = c("country", "Year"),
  suffixes = c(".orig", ".rebuild"), all = TRUE)

cat("=== Validierung Nachbau vs. Original ===\n")
cat("Zeilen: Original", sum(!is.na(cmp$nrcondtype_all.orig)),
    "| Nachbau", sum(!is.na(cmp$nrcondtype_all.rebuild)),
    "| nur Original:", sum(is.na(cmp$nrcondtype_all.rebuild)),
    "| nur Nachbau:", sum(is.na(cmp$nrcondtype_all.orig)), "\n\n")
for (v in cmp_vars) {
  a <- cmp[[paste0(v, ".orig")]]; b <- cmp[[paste0(v, ".rebuild")]]
  ok <- !is.na(a) & !is.na(b)
  # rel. Toleranz: Original speichert floats (7 Stellen), Nachbau doubles
  eq <- ok & (abs(a - b) <= 1e-6 * pmax(abs(a), abs(b), 1))
  cat(sprintf("%-16s %3d / %3d identisch\n", v, sum(eq), sum(ok)))
  bad <- ok & !eq
  if (any(bad)) print(cmp[bad, c("country", "year",
                                 paste0(v, ".orig"), paste0(v, ".rebuild"))],
                      row.names = FALSE)
}
mism <- cmp[!is.na(cmp$nrcondtype_all.orig) & !is.na(cmp$nrcondtype_all.rebuild) &
            ((abs(cmp$nrcondtype_all.orig - cmp$nrcondtype_all.rebuild) >
              1e-6 * pmax(abs(cmp$nrcondtype_all.orig), 1)) |
             cmp$unsc3.orig != cmp$unsc3.rebuild |
             cmp$nrquarterssmpl.orig != cmp$nrquarterssmpl.rebuild |
             cmp$nrcntprogram.orig != cmp$nrcntprogram.rebuild),
            c("country", "year", "nrcondtype_all.orig", "nrcondtype_all.rebuild",
              "nrquarterssmpl.orig", "nrquarterssmpl.rebuild",
              "unsc3.orig", "unsc3.rebuild", "nrcntprogram.orig", "nrcntprogram.rebuild")]
if (nrow(mism) > 0) {
  cat("\nAbweichende Zeilen:\n"); print(mism, row.names = FALSE)
} else {
  cat("\nNachbau vollstaendig identisch mit dem Original-Konditionalitaets- und UNSC-Block.\n")
}
