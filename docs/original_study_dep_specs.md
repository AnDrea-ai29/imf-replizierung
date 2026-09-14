# Spezifikationen: Originalstudie + Dependenz-Theorie

> **Issue #0a** — Diese Vorlage ausfüllen, als `original_study_dep_specs.md` im Repo speichern und committen.
> Alles in `[eckigen Klammern]` ist Platzhalter — durch eigene Werte ersetzen oder löschen.

---

## 1. Originalstudie: Dreher et al. (2015), Tabelle 2

> Quelle: Dreher, A., Sturm, J.-E., & Vreeland, J. R. (2015). *The IMF and the Political Economy of Aid*. Journal of Conflict Resolution.

### 1.1 Zentrale Regressionsergebnisse (zum Replizieren)
   Variable | Koeffizient (GLS)    | t-Wert (GLS) | Koeffizient (OLS)  | t-Wert (OLS) | Signifikanz |
 |----------|----------------------|--------------|--------------------|--------------|-------------|
 | `unsc3`  | −2.096***            | −4.023       | −3.329*            | −1.950       | GLS: p<0.01 / OLS: p<0.10 |
 | `count`  | -0.133***            | -3.728       | -0.0851            | -0.855       | GLS: p<0.01 / OLS: kein Wert
 | `election year`, t-I | 1.184*** | 4.517        | 1.507*             | 1.897        | GLS: p<0.01 / OLS: p<0.10
 | `XDebtGNI` | -0.0198***         | -4.825       | -0.0149            | -1.407       | GLS: p<0.01 / OLS: kein Wert |
 | `DebtServGNI` | 0.120**         | 2.547        | 0.120              | 0.926        | GLS: p<0.05 / OLS: kein Wert |
 | `ResXDebt` | -0.0138            | -1.138       | 0.00223            | 0.0868       | GLS: kein Wert / OLS: kein Wert |
 | `XBal`   |  -0.0478*            | -1.661       | -0.0809            | -1.386       | GLS: p<0.10 / OLS: kein Wert
 | `Invest` | 0.00502              | 0.131        | -0.000591          | -0.00634     | GLS: kein Wert / OLS: kein Wert
 | `USAid`  | -0.283               | -1.251       | -0.0889            | -0.225       | GLS: kein Wert / OLS: kein Wert
 | `ConcIMFLoan`|    -0.109        | -0.966       | -0.0813            | -0.257       | GLS: kein Wert / OLS: kein Wert
 | `NonConcIMFLoan`| 0.480***      | 11.44        | 0.486*             | 1.726        | GLS: p<0.01 / OLS: p<0.10
 

### 1.2 Modellspezifikation
 | Parameter | Wert |
 |-----------|------|
 | **Methode Hauptmodell** | GLS (Spalte 6) — `unsc3 = −2.096***` |
 | **Methode Vergleich** | OLS (Spalte 5) — `unsc3 = −3.329*` |
 | **Vergleichsmaßstab Replizierung** | Mein UNSC-Koeffizient (2002–2008) sollte nahe −2.1 (im Breich -1.8 bis -2.4) liegen und p < 0.01 |
 | **t-Werte (keine SE)** | Originalstudie gibt t-Werte, keine Standardfehler |
 | **Anzahl Beobachtungen (N)** | GLS und OLS: 217 |
 | **Anzahl der Länder** | GLS und OLS: 75 |
 | **R^2** | OLS: 0.124 |
 | **F-Test** | OLS: 0.002 | Fixed country effects |
 | **Breusch-Pagan-Test** | 0.000 | Heteroskasdizität |
 
> Anmerkung: Die Werte in Klammern (-1.950 und -4.023) sind keine Standardfehler, sondern t-Statistiken (t-Werte). Das erkennt man daran, dass sie negativ
> sind - Standardfehler sind immer positiv. Der t-Wert = Koeffizient / Standardfehler


### 1.3 Mein Vergleichsmaßstab für die Replizierung

> ✅ Replizierung gelungen, wenn mein UNSC-Koeffizient (2002–2008) im Bereich **−2.1 bis −2.5** liegt und **p < 0.01**.

---

## 2. Dependenz-Theorie: Kernthesen

### 2.1 Samir Amin (1974) — *Accumulation on a World Scale*

- **These 1:** [Zentrum-Peripherie-Dynamik: Die Entwicklung des Zentrums (Globaler Norden) beruht auf der Ausbeutung der Peripherie (Globaler Süden).]
- **These 2:** [Afrikanische Länder sind politisch instrumentalisierbar, weil sie wirtschaftlich abhängig sind.]
- **Relevanz für H2:** [Der stärkere UNSC-Effekt in Afrika zeigt, dass afrikanische Länder als strategische Ressource für den Globalen Norden gelten.]

### 2.2 Andre Gunder Frank (1967) — *Capitalism and Underdevelopment*

- **These 1:** [Unterentwicklung ist kein Rückstand, sondern ein Produkt der kapitalistischen Entwicklung des Zentrums.]
- **These 2:** [Extraktivismus: Rohstoffexport wird gefördert statt Diversifizierung.]
- **Relevanz für H4:** [Rohstoffreiche Länder werden durch IMF-Bedingungen in der Abhängigkeit gehalten — der ungleiche Austausch verstärkt den UNSC-Effekt.]

### 2.3 Immanuel Wallerstein (1974) — *The Modern World-System*

- **These 1:** [Weltsystem aus Kern, Semiperipherie und Peripherie reproduziert sich selbst.]
- **These 2:** [Politische Reformen (z. B. UNSC-Mitgliedschaft) schaffen nur kurzfristige Spielräume, ändern aber keine strukturellen Machtverhältnisse.]
- **Relevanz für H3 (optional):** [UNSC-Effekt reduziert nur kurzfristig Konditionalität, verändert aber keine strukturellen Abhängigkeiten.]

### 2.4 Weitere Autoren (optional)

**Walter Rodney (1972)** — *How Europe Underdeveloped Africa*
- [Formale Unabhängigkeit, aber informelle Kontrolle durch wirtschaftliche/finanzielle Mechanismen (Neokolonialismus).]

**Arghiri Emmanuel (1972)** — *Unequal Exchange*
- [Ungleicher Austausch: Rohstoffreiche Länder sind für den Globalen Norden wirtschaftlich zu wertvoll, um destabilisiert zu werden.]

**Dos Santos (1970)** - *The structure of dependence*


### Ruy Mauro Marini (2022) - *The Dialectics of Dependency*
- [Dependenz unterscheidet sich von früheren Ausbeutungsstrukturen darin, dass sie nicht hauptsächlich auf politischer Unterordnung oder der Androhung militärischer Unterdrückung beruht, sondern auf der Reproduktion ökonomischer Strukturen, 
	die Rückständigkeit und Schwäche anderer Nationen ausnutzt und verfestigt]

### Antunes de Oliveira (2024) - *Dependency Theory*
- [Dependenz ist das Equivalent der Internationalen Beziehungen zum Übergang der Gewinnextrahierung durch Zwang/Unterdrückung hin zur Extrahierung durch ökonomische Mittel; was ein Hauptmerkmal des Kapitalismus darstellt.(siehe dazu auch ***Wood (2022): The Origin of Capitalism***]
- [Dependenz ist "a self-reproducing hierarchical relationship between politically independent capitalist societies (happening) through deeply embedded social, economic, and cultural structures based on gendered and racialized forms of oppression, which largely constrain the development possibilities of dependent societies while sustaining the wealth and the power of central societies.]
- [Dependenz ist ein kapitalistisches Phänomen, das nach direkter kolonialer Herrschaft entsteht]


>Die Dependenz-Theorie (Frank 1967, Amin 1974, Emmanuel 1972) argumentiert:
>Die Peripherie exportiert Rohstoffe (Brennstoffe, Erze) an das Zentrum, um Devisen zu verdienen und Schuldendienst zu leisten.

Die Mechanik ist:
1. Afrikanisches Land exportiert Kobalt/Kupfer/Öl → TM.VAL.FUEL.ZS.WT + TM.VAL.MNER.ZS.WT (Exporte)
2. Deviseneinnahmen fließen → Schuldendienst an IWF/Weltbank
3. IWF-Konditionalität zwingt zu weiterem Rohstoffexport statt Diversifizierung → Extraktivismus






---

## 3. Verbindung: Theorie → Hypothesen → Modelle

| Hypothese | Theoretische Grundlage | Empirischer Test | Modell |
|-----------|------------------------|------------------|--------|
| **H2** — UNSC-Effekt in Afrika stärker als global | Amin (1974): Politische Instrumentalisierbarkeit | Vergleich UNSC-Koeffizient Teil 1 vs. Teil 2 | `model_1_fe` vs. `model_2_fe` |
| **H4** — Rohstoffabhängigkeit verstärkt UNSC-Effekt | Emmanuel (1972): Ungleicher Austausch | Interaktionsterm `unsc3 × Rohstoffabhängigkeit` | `model_2_interaction` |
| **H1** (optional) — Mehr Rohstoff-Bedingungen in Afrika | Frank (1967): Extraktivismus | Policy-Bereiche-Analyse | [optional] |
| **H3** (optional) — Nur kurzfristig, keine Strukturveränderung | Wallerstein (1974): Weltsystem-Reproduktion | Langfristige Panel-Analyse | [optional] |

---

## 4. Zitate für die Hausarbeit (vorbereitet)

> *"Der signifikant stärkere UNSC-Effekt in Afrika bestätigt, dass afrikanische Länder als strategische Ressource für den Globalen Norden gelten (Amin 1974)."*

> *"Die Interaktionsanalyse zeigt, dass der UNSC-Effekt in rohstoffreichen Ländern besonders stark ist. Dies stützt Emmanuel (1972), der den ungleichen Austausch als Kern der Ausbeutung identifiziert."*

> *"IMF-Konditionalität erzwingt Liberalisierung und Rohstofffokus und reproduziert damit Abhängigkeit (Frank 1967)."*

---

## ✅ Checkliste vor dem Commit

- [X] Tabelle 2 aus Originalstudie ausgefüllt (Koeffizienten, p-Werte, N)
- [ ] Dependenz-Thesen für Amin, Frank, Wallerstein notiert
- [ ] Verbindung H2/H4 zu Theorien hergestellt
- [X] Datei als `original_study_dep_specs.md` gespeichert
- [ ] `git add original_study_dep_specs.md && git commit -m "Issue #0a: Originalstudie + Dependenz-Theorie exzerpiert" && git push`