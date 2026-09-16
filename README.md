# IMF-Studie Replizierung mit Afrika-Fokus + Dependenz-Theorie

Vollständige Replizierung der Originalstudie Dreher et al. (2015) für 2002-2008 (alle Länder) 
+ Erweiterung für Afrika 2008-2025 mit Dependenz-Theorie (H2 + H4)

## Struktur
-`data/raw/`- Rohdaten (UNSC, WDI, MONA)
-`data/processed/`- aufbereitete Datensätze
-`results/`- Regressionsergebnisse, Tabellen, Grafiken
-`code/`- R-Skripte (Datenaufbereitung, Analyse, Replizierung)

# IMF-Replizierung: Datenaufbereitung (Phase 2)

## 📌 Projektstatus
- ✅ **Phase 1**: Datenbeschaffung abgeschlossen
- ✅ **Phase 2**: Datenaufbereitung abgeschlossen (2026-09-15)
- ⏳ **Phase 3**: Analyse (Modellierung) – *in Arbeit*

---

## 🔧 Wichtige Änderungen in Phase 2

### Datenquellen
| Datensatz | Datei | Beschreibung |
|-----------|-------|--------------|
| **MONA** | `data/raw/mona/Combined_ISO.xlsx` | Enthält jetzt **ISO3** und **iso_numeric** (manuell ergänzt) |
| **UNSC** | `data/raw/unsc/unsc_membership_2002_2025.csv` | Panel mit `unsc3` (Mitglied in t oder t-1) |
| **WDI** | `data/raw/wdi/wdi_2002_2025_dep.csv` | Rohstoffabhängigkeit: `FuelExportPct` + `MineralExportPct` |
| **Final** | `data/processed/final_data_2002_2025.csv` | Vollständiger Datensatz für Modelle |

### Anpassungen
- **ISO-Codes**: `Combined.xlsx` → **`Combined_ISO.xlsx`** (manuelles Mapping nötig, da MONA eigene Codes verwendet).
- **WDI-Variablen**:
  - `FuelExportPct = TX.VAL.FUEL.ZS.UN` (Exporte)
  - `MineralExportPct = TX.VAL.MMTL.ZS.UN` (Exporte)
- **Verknüpfungen**: Alle Joins laufen jetzt über **`ISO3`** (nicht mehr `Country Code`).

### Ergebnisse
- `data/processed/` enthält alle aufbereiteten Datensätze für Phase 3.
- `session_neu_final_2Wochen.md` wurde aktualisiert (Code + Anleitung).
