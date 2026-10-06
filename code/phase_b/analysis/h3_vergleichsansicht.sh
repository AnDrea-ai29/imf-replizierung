#!/usr/bin/env bash
# H3-Vergleichsansicht: Bedingungen pro Quartal in UNSC- vs. Nicht-UNSC-
# Jahren je Land, sortiert nach UNSC-Intensitaet (absteigend).
# Rein deskriptiv/explorativ, keine Inferenz.
#
# Konventionen identisch zu phase_b_h3_exploration.R:
#   Analysefenster 1992-2023, nur Land-Jahre mit beobachteter Zaehl-AV
#   (avgcondtype_count). Kanonische Quelle bleibt das R-Skript
#   (results/phase_b/exploration/h3_vergleichsansicht.csv); dieses Skript
#   ist die schnelle Terminal-Sicht ohne R-Start.
#
# Parsing: gawk FPAT (quoted-CSV-sicher, benoetigt GNU awk; Git Bash
# liefert gawk als awk mit).
#
# Aufruf:  bash code/phase_b/analysis/h3_vergleichsansicht.sh [TOP_N]
#          TOP_N = anzuzeigende Laender (Default 15; 0 = alle)

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
panel="$repo_root/data/processed/phase_b_panel_identical_measurement_1992_2025.csv"
top_n="${1:-15}"
[[ "$top_n" == "0" ]] && top_n=1000000

if [[ ! -f "$panel" ]]; then
  echo "Panel fehlt: $panel" >&2
  echo "Zuerst code/phase_b/data_prep/build_phase_b_identical_measurement.R ausfuehren." >&2
  exit 1
fi

awk '
BEGIN { FPAT = "([^,]*)|(\"[^\"]*\")" }
NR == 1 {
  for (i = 1; i <= NF; i++) { h = $i; gsub(/"/, "", h); col[h] = i }
  c_iso = col["ISO3"];  c_yr = col["Year"];  c_nm = col["country"]
  c_av  = col["avgcondtype_count"];           c_u  = col["unsc3"]
  next
}
{
  iso = $c_iso; yr = $c_yr; nm = $c_nm; av = $c_av; u = $c_u
  gsub(/"/, "", iso); gsub(/"/, "", nm); gsub(/"/, "", av); gsub(/"/, "", u)
  if (yr + 0 < 1992 || yr + 0 > 2023) next
  if (av == "" || av == "NA") next
  if (u + 0 == 1)      { sU[iso] += av; cU[iso]++ }
  else if (u + 0 == 0) { sN[iso] += av; cN[iso]++ }
  name[iso] = nm
}
END {
  for (k in sU)
    if (cU[k] > 0) {
      mU  = sU[k] / cU[k]
      mN  = (cN[k] > 0) ? sN[k] / cN[k] : -1
      gap = (cN[k] > 0) ? mU - mN : -999
      printf "%.4f\t%s\t%s\t%d\t%.4f\t%d\t%.4f\n", mU, k, name[k], cU[k], mN, cN[k], gap
    }
}
' "$panel" | sort -t$'\t' -k1,1 -rn | head -n "$top_n" | awk -F'\t' '
BEGIN {
  printf "%-4s %-26s %7s %10s | %7s %10s | %9s\n", \
         "ISO", "Land", "UNSC-n", "UNSC-Mw", "o.UNSC-n", "o.UNSC-Mw", "Luecke"
  print "----------------------------------------------------------------------------------------"
}
{
  if ($5 + 0 < 0) { nN = "-"; mN = "-"; gap = "-" }
  else { nN = $6; mN = sprintf("%.1f", $5); gap = sprintf("%+.1f", $7) }
  printf "%-4s %-26s %7d %10.1f | %7s %10s | %9s\n", $2, $3, $4, $1, nN, mN, gap
}'
