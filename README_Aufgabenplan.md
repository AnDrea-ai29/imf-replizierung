# README: Aufgabenplan für IMF-Replizierung mit Afrika-Fokus

**Projekt:** Replizierung der Studie *"Politics and IMF Conditionality"* (Dreher et al. 2015) mit neuen MONA-Daten (2002–2026) und Afrika-Fokus
**Ziel:** 15–20-seitige Hausarbeit in 2 Wochen mit **Note 1,3–1,7**
**Erstellt:** 2026-09-12

---

## 📚 Projektübersicht

Dieses Dokument ist ein **Master-Dokument**, das alle wichtigen Sessions und Dateien für Ihre Hausarbeit verlinkt. Es dient als **zentrale Anlaufstelle**, um schnell auf alle Informationen zugreifen zu können.

---

## 🗂️ Verzeichnis der Sessions (Ihre Wissensdatenbank)

### **📌 Grundlagen der Originalstudie**
- **📄 [`session_Gen_Original.md`](session_Gen_Original.md)**
  *Inhalt:* Detaillierte Analyse der Original-Stata-Do-Dateien (1992–2008), inkl. aller Schritte von den Rohdaten bis zum finalen Datensatz.
  *Wichtig für:* Verständnis der Originalmethodik, Datenaufbereitung, Variablendefinitionen.

---

### **📌 Anleitung für neue MONA-Daten (2002–2026)**
- **📄 [`session_MONA_neu_Anleitung.md`](session_MONA_neu_Anleitung.md)**
  *Inhalt:* Schritt-für-Schritt-Anleitung zur Nutzung der aktuellen IMF MONA-Daten, inkl. R-Code für Datenaufbereitung, Klassifizierung und Regressionen.
  *Wichtig für:* Datenaufbereitung mit neuen MONA-Daten, UNSC-Variable `unsc3`, Regressionsmodelle.

---

### **📌 Replizierungsanleitung (R & Python)**
- **📄 [`session_RPC_Anleitung.md`](session_RPC_Anleitung.md)**
  *Inhalt:* Schritt-für-Schritt-Anleitung zur Replizierung der Originalstudie, inkl. R/Python-Code, erwartete Ergebnisse und Herausforderungen.
  *Wichtig für:* Ökonometrische Methode, Robustheitschecks, Ergebnisinterpretation.

---

### **📌 Strategie für Afrika-Fokus (2002–2008 + 2009–2026)**
- **📄 [`session_MONA_neu_Afrika.md`](session_MONA_neu_Afrika.md)**
  *Inhalt:* Bewertung der Machbarkeit einer Teilreplizierung (2002–2008, alle Länder) + Erweiterung (2009–2026, Afrika-Fokus). Enthält Aufwandschätzung, erwartete Ergebnisse, Zeitplan und Umsetzungsanleitung.
  *Wichtig für:* **Ihre Hauptstrategie!** Hier finden Sie den detaillierten Zeitplan und die Begründung, warum der Afrika-Fokus sinnvoll ist.

---

### **📌 Postkoloniale Analyse (Dependenz-Theorie)**
- **📄 [`session_MONA_kolonial.md`](session_MONA_kolonial.md)**
  *Inhalt:* Theoretische und empirische Integration der Dependenz-Theorie und postkolonialer Kritik in Ihre Analyse. Enthält Hypothesen, empirische Operationalisierung, R-Code für erweiterte Modelle und Interpretationsrahmen.
  *Wichtig für:* Theoretische Einbindung Ihrer Ergebnisse, Diskussion der UNSC-Effekte im Kontext neokolonialer Machtstrukturen.

---

### **📌 Einfacher Zeitplan mit Puffer (2 Wochen)**
- **📄 [`session_MONA_einfach.md`](session_MONA_einfach.md)**
  *Inhalt:* Vereinfachte, realistische Anleitung für eine stressfreie Replizierung mit Afrika-Fokus in 2 Wochen. Enthält Priorisierung, Zeitplan mit **25–30 Stunden Puffer** und Notfallplan.
  *Wichtig für:* **Ihr Arbeitsplan!** Hier finden Sie den detaillierten Zeitplan Tag für Tag.

---

---

## 🎯 Schnellzugriff: Wofür Sie welche Session brauchen

| **Ihre Frage/Aufgabe** | **Relevante Session** | **Abschnitt** |
|------------------------|------------------------|--------------|
| *Wie waren die Originaldaten aufbereitet?* | [`session_Gen_Original.md`](session_Gen_Original.md) | Schritt 1–13 (txt2dta7.do) |
| *Wie bereite ich die neuen MONA-Daten auf?* | [`session_MONA_neu_Anleitung.md`](session_MONA_neu_Anleitung.md) | Schritt 1–4 (Datenvorbereitung) |
| *Wie führe ich die Regressionen durch?* | [`session_RPC_Anleitung.md`](session_RPC_Anleitung.md) | Kapitel 4 (Implementierung in R) |
| *Ist der Afrika-Fokus machbar?* | [`session_MONA_neu_Afrika.md`](session_MONA_neu_Afrika.md) | Abschnitt 🎯 (Warum dieser Ansatz optimal ist) |
| *Wie integriere ich die Dependenz-Theorie?* | [`session_MONA_kolonial.md`](session_MONA_kolonial.md) | Abschnitt 📚 (Theorieteil) |
| *Welcher Zeitplan ist realistisch?* | [`session_MONA_einfach.md`](session_MONA_einfach.md) | Abschnitt 📅 (Zeitplan für 2 Wochen) |

---

---

## 📂 Wichtigste Dateipfade in Ihrem Projekt

| **Kategorie** | **Pfad** | **Beschreibung** |
|---------------|----------|-----------------|
| **📁 MONA-Daten** | `/c/Users/HP/io/MONA/` | Enthält `Combined.xlsx`, `Program.xlsx`, `Description.xlsx`, etc. |
| **📁 UNSC-Daten** | `/c/Users/HP/io/` (manuell) | Zu erstellen: UNSC-Mitgliedschaft für 2002–2026 |
| **📁 WDI-Daten** | `/c/Users/HP/io/` (manuell) | Zu erstellen: World Bank WDI-Daten für Rohstoffabhängigkeit |
| **📄 Session-Dokumente** | `/c/Users/HP/io/` | Alle `session_*.md`-Dateien ( Ihre Wissensdatenbank) |

---

---

## 🚀 Empfohlener Arbeitsablauf

### **1. Lesen Sie zuerst diese Sessions (für das Verständnis):**
1. [`session_MONA_einfach.md`](session_MONA_einfach.md) → **Ihr Zeitplan!**
2. [`session_MONA_neu_Afrika.md`](session_MONA_neu_Afrika.md) → **Ihre Strategie!**

### **2. Beginnen Sie mit der Datenbeschaffung:**
- **UNSC-Daten:** [UN Security Council Membership](https://www.un.org/securitycouncil/en/content/member-states)
- **WDI-Daten:** [World Bank WDI](https://data.worldbank.org/indicator) (nur `TM.VAL.FUEL.ZS.WT` + `TM.VAL.MNER.ZS.WT`)

### **3. Nutzen Sie die R-Code-Snippets:**
- Alle wichtigen R-Befehle finden Sie in:
  - [`session_MONA_neu_Anleitung.md`](session_MONA_neu_Anleitung.md) (Datenaufbereitung)
  - [`session_RPC_Anleitung.md`](session_RPC_Anleitung.md) (Regressionen)
  - [`session_MONA_einfach.md`](session_MONA_einfach.md) (Zeitplan mit Code)

### **4. Bei Problemen:**
- **R-Fehler?** → Schicken Sie mir **Fehlermeldung + Code** → Ich helfe innerhalb von **1 Stunde**!
- **Daten fehlen?** → Ich sage Ihnen, wo Sie sie finden.
- **Theorie unklar?** → Ich gebe Ihnen **fertige Formulierungen**.

---

---

## 💡 Tipps für effizientes Arbeiten

1. **📌 Erstellen Sie eine lokale Kopie aller Sessions** in `/c/Users/HP/io/` (falls noch nicht geschehen).
2. **📌 Nutzen Sie die Suchfunktion** (Strg+F) in den Sessions, um schnell Antworten zu finden.
3. **📌 Speichern Sie Ihre Fortschritte täglich** (z. B. in einer Datei `fortschritt.md`).
4. **📌 Halten Sie sich an den Zeitplan** aus [`session_MONA_einfach.md`](session_MONA_einfach.md).

---

---

## 📌 Zusammenfassung: Was Sie als Nächstes tun

1. **Lesen Sie [`session_MONA_einfach.md`](session_MONA_einfach.md)** – dort finden Sie Ihren **detaillierten Zeitplan mit Puffer**.
2. **Beginnen Sie mit Tag 1** (Datenbeschaffung: UNSC + WDI).
3. **Nutzen Sie die anderen Sessions als Nachschlagewerk**, falls Sie Details nachschlagen müssen.
4. **Fragen Sie nach Hilfe**, wenn Sie nicht weiterkommen!

---

**Viel Erfolg! Mit diesem Master-Dokument haben Sie alle wichtigen Informationen an einem Ort.** 🎉

**Letzte Aktualisierung:** 2026-09-12
