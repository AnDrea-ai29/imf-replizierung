# 1. MONA-Daten laden und Länder-Codes extrahieren
mona_raw <- read_excel("C:/Users/HP/io/imf-replizierung/data/raw/mona/Combined.xlsx")

# 2. Eindeutige MONA-Codes + Ländernamen extrahieren
mona_codes <- mona_raw %>%
  select(MONA_Code = `Country Code`, Country_Name = `Country Name`) %>%
  distinct()

# 3. ISO-3-Codes laden
iso_codes <- read.csv("C:/Users/HP/io/imf-replizierung/data/raw/country_codes_wdi-iso-itu.csv") %>%
  select(iso_3ltr, Country_Name = wdi_short_name) %>%
  rename(ISO3 = iso_3ltr)        # ISO-3 + Ländername

# 4. Mapping über Ländername erstellen
mapping <- mona_codes %>%
  left_join(iso_codes, by = "Country_Name") %>%
  select(MONA_Code, ISO3, Country_Name) %>%
  filter(!is.na(ISO3))  # Nur Zeilen mit ISO3 behalten


# 5. Fehlende Länder manuell ergänzen (aus deiner Nicht-Übereinstimmung.txt)
# Beispiel für fehlende Länder (ergänze die Liste aus deiner Datei):
mapping <- mapping %>%
  add_row(
    MONA_Code = 512, Country_Name = "AFGHANISTAN,ISLAMIC REPUBLIC OF", ISO3 = "AFG", iso_numeric = 4
  ) %>%
  add_row(
    MONA_Code = 914, Country_Name = "ALBANIA", ISO3 = "ALB"
  ) %>%
  add_row(
    MONA_Code = 614, Country_Name = "ANGOLA", ISO3 = "AGO"
  ) %>%
  add_row(
    MONA_Code = 311, Country_Name = "ANTIGUA AND BARBUDA", ISO3 = "."
  ) %>%
  add_row(
    MONA_Code = 213, Country_Name = "ARGENTINA", ISO3 = "ARG"
  ) %>%
  add_row(
    MONA_Code = 911, Country_Name = "ARMENIA", ISO3 = "ARM"
  ) %>%
  add_row(
    MONA_Code = 513, Country_Name = "BANGLADESH", ISO3 = "BGD"
  ) %>%
  add_row(
    MONA_Code = 316, Country_Name = "BARBADOS", ISO3 = "BRB"
  ) %>%
  add_row(
    MONA_Code = 913, Country_Name = "BELARUS", ISO3 = "BLR"
  ) %>%
  add_row(
    MONA_Code = 638, Country_Name = "BENIN", ISO3 = "BEN"
  ) %>%
  add_row(
    MONA_Code = 218, Country_Name = "BOLIVIA", ISO3 = "BOL"
  ) %>%
  add_row(
    MONA_Code = 963, Country_Name = "BOSNIA AND HERZEGOVINA", ISO3 = "BIH"
  ) %>%
  add_row(
    MONA_Code = 223, Country_Name = "BRAZIL", ISO3 = "BRA"
  ) %>%
  add_row(
    MONA_Code = 918, Country_Name = "BULGARIA", ISO3 = "BGR"
  ) %>%
  add_row(
    MONA_Code = 748, Country_Name = "BURKINA FASO", ISO3 = "BFA"
  ) %>%
  add_row(
    MONA_Code = 618, Country_Name = "BURUNDI", ISO3 = "BDI"
  ) %>%
  add_row(
    MONA_Code = 622, Country_Name = "CAMEROON", ISO3 = "CMR"
  ) %>%
  add_row(
    MONA_Code = 624, Country_Name = "CAPE VERDE", ISO3 = "CPV"
  ) %>%
  add_row(
    MONA_Code = 626, Country_Name = "CENTRAL AFRICAN REPUBLIC", ISO3 = "CAF"
  ) %>%
  add_row(
    MONA_Code = 628, Country_Name = "CHAD", ISO3 = "TCD"
  ) %>%
  add_row(
    MONA_Code = 233, Country_Name = "COLOMBIA", ISO3 = "COL"
  ) %>%
  add_row(
    MONA_Code = 632, Country_Name = "COMOROS", ISO3 = "COM"
  ) %>%
  add_row(
    MONA_Code = 634, Country_Name = "CONGO,REPUBLIC OF", ISO3 = "COG"
  ) %>%
  add_row(
    MONA_Code = 636, Country_Name = "CONGO,DEMOCRATIC REPUBLIC OF", ISO3 = "COD"
  ) %>%
  add_row(
    MONA_Code = 238, Country_Name = "COSTA RICA", ISO3 = "CRI"
  ) %>%
  add_row(
    MONA_Code = 662, Country_Name = "COTE D'IVOIRE", ISO3 = "CIV"
  ) %>%
  add_row(
    MONA_Code = 960, Country_Name = "CROATIA", ISO3 = "HRV"
  ) %>%
  add_row(
    MONA_Code = 423, Country_Name = "CYPRUS", ISO3 = "CYP"
  ) %>%
  add_row(
    MONA_Code = 611, Country_Name = "DJIBOUTI", ISO3 = "DJI"
  ) %>%
  add_row(
    MONA_Code = 321, Country_Name = "DOMINICA", ISO3 = "DMA"
  ) %>%
  add_row(
    MONA_Code = 243, Country_Name = "DOMINICAN REPUBLIC", ISO3 = "DOM"
  ) %>%
  add_row(
    MONA_Code = 248, Country_Name = "ECUADOR", ISO3 = "ECU"
  ) %>%
  add_row(
    MONA_Code = 469, Country_Name = "EGYPT", ISO3 = "EGY"
  ) %>%
  add_row(
    MONA_Code = 253, Country_Name = "EL SALVADOR", ISO3 = "SLV"
  ) %>%
  add_row(
    MONA_Code = 642, Country_Name = "EQUATORIAL GUINEA", ISO3 = "GNQ"
  ) %>%
  add_row(
    MONA_Code = 644, Country_Name = "ETHIOPIA", ISO3 = "ETH"
  ) %>%
  add_row(
    MONA_Code = 646, Country_Name = "GABON", ISO3 = "GAB"
  ) %>%
  add_row(
    MONA_Code = 648, Country_Name = "GAMBIA, THE", ISO3 = "GMB"
  ) %>%
  add_row(
    MONA_Code = 915, Country_Name = "GEORGIA", ISO3 = "GEO"
  ) %>%
  add_row(
    MONA_Code = 652, Country_Name = "GHANA", ISO3 = "GHA"
  ) %>%
  add_row(
    MONA_Code = 174, Country_Name = "GREECE", ISO3 = "GRC"
  ) %>%
  add_row(
    MONA_Code = 328, Country_Name = "GRENADA", ISO3 = "GRD"
  ) %>%
  add_row(
    MONA_Code = 258, Country_Name = "GUATEMALA", ISO3 = "GTM"
  ) %>%
  add_row(
    MONA_Code = 656, Country_Name = "GUINEA", ISO3 = "GIN"
  ) %>%
  add_row(
    MONA_Code = 654, Country_Name = "GUINEA-BISSAU", ISO3 = "GNB"
  ) %>%
  add_row(
    MONA_Code = 263, Country_Name = "HAITI", ISO3 = "HTI"
  ) %>%
  add_row(
    MONA_Code = 268, Country_Name = "HONDURAS", ISO3 = "HND"
  ) %>%
  add_row(
    MONA_Code = 944, Country_Name = "HUNGARY", ISO3 = "HUN"
  ) %>%
  add_row(
    MONA_Code = 176, Country_Name = "ICELAND", ISO3 = "ISL"
  ) %>%
  add_row(
    MONA_Code = 433, Country_Name = "IRAQ", ISO3 = "IRQ"
  ) %>%
  add_row(
    MONA_Code = 178, Country_Name = "IRELAND", ISO3 = "IRL"
  ) %>%
  add_row(
    MONA_Code = 343, Country_Name = "JAMAICA", ISO3 = "JAM"
  ) %>%
  add_row(
    MONA_Code = 439, Country_Name = "JORDAN", ISO3 = "JOR"
  ) %>%
  add_row(
    MONA_Code = 664, Country_Name = "KENYA", ISO3 = "KEN"
  ) %>%
  add_row(
    MONA_Code = 967, Country_Name = "KOSOVO, REPUBLIC OF", ISO3 = "."
  ) %>%
  add_row(
    MONA_Code = 917, Country_Name = "KYRGYZ REPUBLIC", ISO3 = "KGZ"
  ) %>%
  add_row(
    MONA_Code = 941, Country_Name = "LATVIA", ISO3 = "LVA"
  ) %>%
  add_row(
    MONA_Code = 666, Country_Name = "LESOTHO", ISO3 = "LSO"
  ) %>%
  add_row(
    MONA_Code = 668, Country_Name = "LIBERIA", ISO3 = "LBR"
  ) %>%
  add_row(
    MONA_Code = 674, Country_Name = "MADAGASCAR", ISO3 = "MDG"
  ) %>%
  add_row(
    MONA_Code = 676, Country_Name = "MALAWI", ISO3 = "MWI"
  ) %>%
  add_row(
    MONA_Code = 556, Country_Name = "MALDIVES", ISO3 = "MDV"
  ) %>%
  add_row(
    MONA_Code = 678, Country_Name = "MALI", ISO3 = "MLI"
  ) %>%
  add_row(
    MONA_Code = 682, Country_Name = "MAURITANIA", ISO3 = "MRT"
  ) %>%
  add_row(
    MONA_Code = 921, Country_Name = "MOLDOVA", ISO3 = "MDA"
  ) %>%
  add_row(
    MONA_Code = 948, Country_Name = "MONGOLIA", ISO3 = "MNG"
  ) %>%
  add_row(
    MONA_Code = 688, Country_Name = "MOZAMBIQUE", ISO3 = "MOZ"
  ) %>%
  add_row(
    MONA_Code = 558, Country_Name = "NEPAL", ISO3 = "NPL"
  ) %>%
  add_row(
    MONA_Code = 278, Country_Name = "NICARAGUA", ISO3 = "NIC"
  ) %>%
  add_row(
    MONA_Code = 692, Country_Name = "NIGER", ISO3 = "NER"
  ) %>%
  add_row(
    MONA_Code = 694, Country_Name = "NIGERIA", ISO3 = "NGA"
  ) %>%
  add_row(
    MONA_Code = 962, Country_Name = "NORTH MACEDONIA, REPUBLIC OF", ISO3 = "MKD"
  ) %>%
  add_row(
    MONA_Code = 564, Country_Name = "PAKISTAN", ISO3 = "PAK"
  ) %>%
  add_row(
    MONA_Code = 283, Country_Name = "PANAMA", ISO3 = "PAN"
  ) %>%
  add_row(
    MONA_Code = 853, Country_Name = "PAPUA NEW GUINEA", ISO3 = "PNG"
  ) %>%
  add_row(
    MONA_Code = 288, Country_Name = "PARAGUAY", ISO3 = "PRY"
  ) %>%
  add_row(
    MONA_Code = 293, Country_Name = "PERU", ISO3 = "PER"
  ) %>%
  add_row(
    MONA_Code = 182, Country_Name = "PORTUGAL", ISO3 = "PRT"
  ) %>%
  add_row(
    MONA_Code = 968, Country_Name = "ROMANIA", ISO3 = "ROU"
  ) %>%
  add_row(
    MONA_Code = 714, Country_Name = "RWANDA", ISO3 = "RWA"
  ) %>%
  add_row(
    MONA_Code = 716, Country_Name = "SAO TOME AND PRINCIPE", ISO3 = "STP"
  ) %>%
  add_row(
    MONA_Code = 722, Country_Name = "SENEGAL", ISO3 = "SEN"
  ) %>%
  add_row(
    MONA_Code = 965, Country_Name = "SERBIA AND MONTENEGRO", ISO3 = "."
  ) %>%
  add_row(
    MONA_Code = 942, Country_Name = "SERBIA, REPUBLIC OF", ISO3 = "SRB"
  ) %>%
  add_row(
    MONA_Code = 718, Country_Name = "SEYCHELLES", ISO3 = "SYC"
  ) %>%
  add_row(
    MONA_Code = 724, Country_Name = "SIERRA LEONE", ISO3 = "SLE"
  ) %>%
  add_row(
    MONA_Code = 813, Country_Name = "SOLOMON ISLANDS", ISO3 = "SLB"
  ) %>%
  add_row(
    MONA_Code = 726, Country_Name = "SOMALIA", ISO3 = "SOM"
  ) %>%
  add_row(
    MONA_Code = 524, Country_Name = "SRI LANKA", ISO3 = "LKA"
  ) %>%
  add_row(
    MONA_Code = 361, Country_Name = "ST. KITTS AND NEVIS", ISO3 = "KNA"
  ) %>%
  add_row(
    MONA_Code = 732, Country_Name = "SUDAN", ISO3 = "SDN"
  ) %>%
  add_row(
    MONA_Code = 366, Country_Name = "SURINAME", ISO3 = "SUR"
  ) %>%
  add_row(
    MONA_Code = 923, Country_Name = "TAJIKISTAN", ISO3 = "TJK"
  ) %>%
  add_row(
    MONA_Code = 738, Country_Name = "TANZANIA", ISO3 = "TZA"
  ) %>%
  add_row(
    MONA_Code = 742, Country_Name = "TOGO", ISO3 = "TGO"
  ) %>%
  add_row(
    MONA_Code = 744, Country_Name = "TUNISIA", ISO3 = "TUN"
  ) %>%
  add_row(
    MONA_Code = 186, Country_Name = "TURKEY", ISO3 = "TUR"
  ) %>%
  add_row(
    MONA_Code = 746, Country_Name = "UGANDA", ISO3 = "UGA"
  ) %>%
  add_row(
    MONA_Code = 926, Country_Name = "UKRAINE", ISO3 = "UKR"
  ) %>%
  add_row(
    MONA_Code = 298, Country_Name = "URUGUAY", ISO3 = "URY"
  ) %>%
  add_row(
    MONA_Code = 474, Country_Name = "YEMEN, REPUBLIC OF", ISO3 = "YEM"
  ) %>%
  add_row(
    MONA_Code = 754, Country_Name = "ZAMBIA", ISO3 = "ZMB"
  ) %>%
  stringsAsFactors = FALSE


















