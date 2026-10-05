# Export Phase-B result tables as LaTeX fragments and Word documents.

setwd("C:/Users/HP/io/imf-replizierung")

input_dir <- "results/phase_b/tables"
output_dir <- "results/phase_b/publication"
inputs <- c(
  results = file.path(input_dir, "phase_b_hypothesen_robustheit.csv"),
  comparison = file.path(input_dir, "phase_b_modellvergleich.csv")
)
missing_inputs <- inputs[!file.exists(inputs)]
if (length(missing_inputs)) {
  stop("Ergebnistabelle(n) fehlen. Bitte zuerst ",
       "phase_b_hypothesen_robustheit.R ausfuehren: ",
       paste(missing_inputs, collapse = ", "))
}
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

required_columns <- c(
  "Spezifikation", "Fokus_Term", "Koeffizient", "Standardfehler",
  "p_Wert", "n_obs", "Jahr_von", "Jahr_bis"
)

format_estimate <- function(x) {
  if (is.na(x)) return("--")
  if (x != 0 && abs(x) < 0.001) return(sprintf("%.2e", x))
  sprintf("%.3f", x)
}

format_p <- function(x) {
  if (is.na(x)) return("--")
  if (x < 0.001) return("<0.001")
  sprintf("%.3f", x)
}

latex_escape <- function(x) {
  replacements <- c(
    "\\" = "\\textbackslash{}",
    "&" = "\\&",
    "%" = "\\%",
    "$" = "\\$",
    "#" = "\\#",
    "_" = "\\_",
    "{" = "\\{",
    "}" = "\\}",
    "~" = "\\textasciitilde{}",
    "^" = "\\textasciicircum{}"
  )
  vapply(x, function(value) {
    characters <- strsplit(value, "", fixed = TRUE)[[1]]
    escaped <- unname(replacements[characters])
    escaped[is.na(escaped)] <- characters[is.na(escaped)]
    paste(escaped, collapse = "")
  }, character(1), USE.NAMES = FALSE)
}

write_latex <- function(data, caption, label, note, path) {
  headings <- names(data)
  rows <- vapply(seq_len(nrow(data)), function(i) {
    paste(latex_escape(as.character(unlist(data[i, ], use.names = FALSE))),
          collapse = " & ")
  }, character(1))
  body <- paste0(rows, " \\\\")
  if (ncol(data) > 6L) {
    first_width <- 3.5
    other_width <- (14.3 - first_width) / (ncol(data) - 1L)
    column_spec <- paste0(
      ">{\\raggedright\\arraybackslash}p{", first_width, "cm}",
      paste(
        rep(
          paste0(">{\\raggedleft\\arraybackslash}p{",
                 sprintf("%.2f", other_width), "cm}"),
          ncol(data) - 1L
        ),
        collapse = ""
      )
    )
  } else {
    column_spec <- paste0(
      ">{\\raggedright\\arraybackslash}p{4.8cm}",
      paste(rep(" r", ncol(data) - 1L), collapse = "")
    )
  }
  output <- c(
    "% LaTeX table fragment. Requires \\usepackage[utf8]{inputenc}, \\usepackage{booktabs,longtable,array}, and \\usepackage{pdflscape}.",
    "\\begingroup",
    "\\scriptsize",
    "\\setlength{\\tabcolsep}{3pt}",
    "\\begin{landscape}",
    paste0("\\begin{longtable}{", column_spec, "}"),
    paste0("\\caption{", latex_escape(caption), "}\\label{", label, "}\\\\"),
    "\\toprule",
    paste(latex_escape(headings), collapse = " & "), " \\\\",
    "\\midrule",
    "\\endfirsthead",
    "\\toprule",
    paste(latex_escape(headings), collapse = " & "), " \\\\",
    "\\midrule",
    "\\endhead",
    "\\midrule",
    paste0(
      "\\multicolumn{", ncol(data),
      "}{r}{Fortsetzung auf der naechsten Seite}\\\\"
    ),
    "\\endfoot",
    "\\bottomrule",
    "\\endlastfoot",
    body,
    "\\end{longtable}",
    paste0("\\noindent\\footnotesize ", latex_escape(note), "\\par"),
    "\\end{landscape}",
    "\\endgroup",
    ""
  )
  writeLines(output, path, useBytes = TRUE)
}

xml_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  x <- gsub("'", "&apos;", x, fixed = TRUE)
  x
}

word_run <- function(text, bold = FALSE, size = 18L) {
  properties <- paste0(
    if (bold) "<w:b/>" else "",
    "<w:sz w:val=\"", size, "\"/>"
  )
  paste0(
    "<w:r><w:rPr>", properties, "</w:rPr><w:t xml:space=\"preserve\">",
    xml_escape(text), "</w:t></w:r>"
  )
}

word_paragraph <- function(text, bold = FALSE, size = 18L,
                           style = NULL, after = 80L) {
  ppr <- paste0(
    if (!is.null(style)) paste0("<w:pStyle w:val=\"", style, "\"/>") else "",
    "<w:spacing w:after=\"", after, "\"/>"
  )
  paste0("<w:p><w:pPr>", ppr, "</w:pPr>",
         word_run(text, bold = bold, size = size), "</w:p>")
}

word_cell <- function(text, width, header = FALSE, alignment = "left") {
  align <- if (identical(alignment, "right")) "right" else "left"
  fill <- if (header) "<w:shd w:fill=\"D9E2F3\"/>" else ""
  paste0(
    "<w:tc><w:tcPr><w:tcW w:w=\"", width,
    "\" w:type=\"dxa\"/>", fill,
    "<w:tcMar><w:top w:w=\"60\" w:type=\"dxa\"/>",
    "<w:left w:w=\"80\" w:type=\"dxa\"/>",
    "<w:bottom w:w=\"60\" w:type=\"dxa\"/>",
    "<w:right w:w=\"80\" w:type=\"dxa\"/></w:tcMar></w:tcPr>",
    "<w:p><w:pPr><w:jc w:val=\"", align,
    "\"/><w:spacing w:after=\"0\"/></w:pPr>",
    word_run(text, bold = header, size = 16L), "</w:p></w:tc>"
  )
}

word_row <- function(values, widths, header = FALSE) {
  cells <- vapply(seq_along(values), function(i) {
    alignment <- if (i >= 2L) "right" else "left"
    word_cell(values[[i]], widths[[i]], header, alignment)
  }, character(1))
  paste0("<w:tr>",
         if (header) "<w:trPr><w:tblHeader/></w:trPr>" else "",
         paste(cells, collapse = ""), "</w:tr>")
}

write_docx <- function(data, caption, note, path) {
  headers <- names(data)
  column_count <- ncol(data)
  table_width <- 12240L
  first_width <- 3200L
  remaining_width <- floor((table_width - first_width) / (column_count - 1L))
  widths <- c(
    first_width,
    rep(remaining_width, column_count - 1L)
  )
  widths[[column_count]] <- widths[[column_count]] +
    table_width - sum(widths)
  rows <- vapply(seq_len(nrow(data)), function(i) {
    word_row(as.character(unlist(data[i, ], use.names = FALSE)), widths)
  }, character(1))
  borders <- paste0(
    "<w:tblBorders>",
    "<w:top w:val=\"single\" w:sz=\"8\" w:color=\"808080\"/>",
    "<w:left w:val=\"nil\"/><w:bottom w:val=\"single\" w:sz=\"8\" w:color=\"808080\"/>",
    "<w:right w:val=\"nil\"/>",
    "<w:insideH w:val=\"single\" w:sz=\"4\" w:color=\"D9D9D9\"/>",
    "<w:insideV w:val=\"single\" w:sz=\"4\" w:color=\"D9D9D9\"/>",
    "</w:tblBorders>"
  )
  grid <- paste0("<w:gridCol w:w=\"", widths, "\"/>", collapse = "")
  table <- paste0(
    "<w:tbl><w:tblPr><w:tblW w:w=\"", table_width, "\" w:type=\"dxa\"/>",
    "<w:tblLayout w:type=\"fixed\"/>", borders, "</w:tblPr>",
    "<w:tblGrid>", grid, "</w:tblGrid>",
    word_row(headers, widths, header = TRUE),
    paste(rows, collapse = ""), "</w:tbl>"
  )
  document <- paste0(
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>",
    "<w:document xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\">",
    "<w:body>",
    word_paragraph(caption, bold = TRUE, size = 24L, after = 160L),
    table,
    word_paragraph(note, size = 16L, after = 0L),
    "<w:sectPr><w:pgSz w:w=\"15840\" w:h=\"12240\" w:orient=\"landscape\"/>",
    "<w:pgMar w:top=\"900\" w:right=\"1440\" w:bottom=\"900\" w:left=\"1440\"",
    " w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/></w:sectPr>",
    "</w:body></w:document>"
  )

  package_dir <- tempfile("phase_b_docx_")
  if (!dir.create(package_dir)) {
    stop("Temporäres DOCX-Verzeichnis konnte nicht erstellt werden.")
  }
  staged_docx <- tempfile(
    pattern = paste0(".", basename(path), "-"),
    tmpdir = normalizePath(dirname(path), winslash = "/", mustWork = TRUE),
    fileext = ".docx"
  )
  on.exit(unlink(c(package_dir, staged_docx), recursive = TRUE), add = TRUE)
  dir.create(file.path(package_dir, "_rels"))
  dir.create(file.path(package_dir, "word"))
  dir.create(file.path(package_dir, "word", "_rels"))
  writeLines(c(
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>",
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">",
    "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>",
    "<Default Extension=\"xml\" ContentType=\"application/xml\"/>",
    "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>",
    "</Types>"
  ), file.path(package_dir, "[Content_Types].xml"), useBytes = TRUE)
  writeLines(c(
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>",
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">",
    "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>",
    "</Relationships>"
  ), file.path(package_dir, "_rels", ".rels"), useBytes = TRUE)
  writeLines(document, file.path(package_dir, "word", "document.xml"),
             useBytes = TRUE)
  writeLines(c(
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>",
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"/>"
  ), file.path(package_dir, "word", "_rels", "document.xml.rels"),
  useBytes = TRUE)

  working_dir <- getwd()
  on.exit(setwd(working_dir), add = TRUE)
  setwd(package_dir)
  zip_status <- utils::zip(
    zipfile = normalizePath(staged_docx, winslash = "/", mustWork = FALSE),
    files = c("[Content_Types].xml", "_rels/.rels", "word/document.xml",
              "word/_rels/document.xml.rels"),
    flags = "-q"
  )
  if (!identical(zip_status, 0L) || !file.exists(staged_docx) ||
      file.info(staged_docx)$size == 0) {
    stop("DOCX-Archiv konnte nicht erstellt werden: ", path)
  }
  destination <- normalizePath(
    file.path(working_dir, path), winslash = "/", mustWork = FALSE
  )
  if (!file.copy(staged_docx, destination, overwrite = TRUE)) {
    stop(
      "DOCX konnte nicht aktualisiert werden (ist die Datei in Word geöffnet?): ",
      destination
    )
  }
}

results_data <- read.csv(inputs[["results"]], stringsAsFactors = FALSE)
comparison_data <- read.csv(inputs[["comparison"]], stringsAsFactors = FALSE)
for (input_data in list(results_data, comparison_data)) {
  if (!all(required_columns %in% names(input_data))) {
    stop("Unerwartetes Schema in Phase-B-Ergebnis- oder Vergleichsdatei: ",
         paste(setdiff(required_columns, names(input_data)), collapse = ", "))
  }
}

display_table <- function(data) {
  data.frame(
    Spezifikation = data$Spezifikation,
    Effekt = ifelse(is.na(data$Fokus_Term), "--", data$Fokus_Term),
    Schaetzer = vapply(data$Koeffizient, format_estimate, character(1)),
    Robuster_SE = vapply(data$Standardfehler, format_estimate, character(1)),
    p_Wert = vapply(data$p_Wert, format_p, character(1)),
    N = as.character(data$n_obs),
    Jahre = ifelse(
      is.na(data$Jahr_von) | is.na(data$Jahr_bis),
      "--",
      paste(data$Jahr_von, data$Jahr_bis, sep = "--")
    ),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

summary_tables <- list(
  results = list(
    data = display_table(results_data),
    caption = "Phase B: Hypothesen- und Robustheitsergebnisse (1992–2023)",
    label = "tab:phase-b-results",
    note = paste(
      "Robuste heteroskedastizitaetskonsistente Standardfehler.",
      "Die Tabelle fasst H1 und H2 einschließlich Robustheiten zusammen."
    ),
    file_stem = "phase_b_hypothesen_robustheit"
  ),
  comparison = list(
    data = display_table(comparison_data),
    caption = "Phase B: Gesamtvergleich der Modellspezifikationen (1992–2023)",
    label = "tab:phase-b-model-comparison",
    note = paste(
      "Basismodelle, DSV-Vollmodelle, Zwei-Wege-FE-Modelle und",
      "DSV-nahe GLS-Spezifikationen für H1/H2."
    ),
    file_stem = "phase_b_modellvergleich"
  )
)
for (table in summary_tables) {
  write_latex(
    table$data, table$caption, table$label, table$note,
    file.path(output_dir, paste0(table$file_stem, ".tex"))
  )
  write_docx(
    table$data, table$caption, table$note,
    file.path(output_dir, paste0(table$file_stem, ".docx"))
  )
}

hypotheses <- list(
  H1 = list(
    title = "H1: UNSC-Mitgliedschaft und Konditionalität",
    comparison_labels = c(
      "H1 Basismodell: Länder-FE, nur nrquarterssmpl",
      "H1 Vollmodell: Länder-FE, DSV-Kontrollen",
      "H1 Vollmodell: Länder- und Jahres-FE",
      "H1 Vollmodell: DSV-nahes GLS"
    )
  ),
  H2 = list(
    title = "H2: UNSC-Mitgliedschaft und Rohstoffabhängigkeit",
    comparison_labels = c(
      "H2 Basismodell: Länder-FE, nur nrquarterssmpl",
      "H2 Vollmodell: Länder-FE, DSV-Kontrollen",
      "H2 Vollmodell: Länder- und Jahres-FE",
      "H2 Vollmodell: DSV-nahes GLS"
    )
  )
)

significance_stars <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.1) return("*")
  ""
}

for (hypothesis_name in names(hypotheses)) {
  hypothesis <- hypotheses[[hypothesis_name]]
  prefix <- paste0(hypothesis_name, " ")
  hypothesis_results <- results_data[
    startsWith(results_data$Spezifikation, prefix) &
      !grepl("Basismodell:|Vollmodell:|DSV-nahes GLS", results_data$Spezifikation),
    ,
    drop = FALSE
  ]
  if (nrow(hypothesis_results) == 0L) {
    stop("Keine Ergebniszeilen fuer ", hypothesis_name, " gefunden.")
  }

  result_table <- data.frame(
    Ergebnis = hypothesis_results$Spezifikation,
    Effekt = ifelse(
      is.na(hypothesis_results$Fokus_Term),
      "--",
      hypothesis_results$Fokus_Term
    ),
    Schaetzer = paste0(
      vapply(hypothesis_results$Koeffizient, format_estimate, character(1)),
      vapply(hypothesis_results$p_Wert, significance_stars, character(1))
    ),
    Robuster_SE = vapply(
      hypothesis_results$Standardfehler, format_estimate, character(1)
    ),
    p_Wert = vapply(hypothesis_results$p_Wert, format_p, character(1)),
    N = as.character(hypothesis_results$n_obs),
    Jahre = paste(hypothesis_results$Jahr_von,
                  hypothesis_results$Jahr_bis, sep = "--"),
    Laender = as.character(hypothesis_results$n_laender),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  comparison_rows <- match(
    hypothesis$comparison_labels,
    comparison_data$Spezifikation
  )
  if (anyNA(comparison_rows)) {
    stop("Modellvergleich fehlt fuer ", hypothesis_name, ": ",
         paste(hypothesis$comparison_labels[is.na(comparison_rows)],
               collapse = "; "))
  }
  models <- comparison_data[comparison_rows, , drop = FALSE]
  model_columns <- c(
    "Basis-FE", "Vollmodell-FE", "Länder- und Jahres-FE", "DSV-GLS"
  )[seq_len(nrow(models))]
  stats <- data.frame(
    Kennzahl = c(
      "Fokuseffekt",
      "Koeffizient",
      "Robuster Standardfehler",
      "p-Wert",
      "Beobachtungen",
      "Länder",
      "Länder mit unsc3 = 1",
      "Jahre",
      "Länder-FE",
      "Jahres-FE",
      "Kontrollen"
    ),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  for (i in seq_len(nrow(models))) {
    stats[[model_columns[[i]]]] <- c(
      models$Fokus_Term[[i]],
      paste0(
        format_estimate(models$Koeffizient[[i]]),
        significance_stars(models$p_Wert[[i]])
      ),
      format_estimate(models$Standardfehler[[i]]),
      format_p(models$p_Wert[[i]]),
      as.character(models$n_obs[[i]]),
      as.character(models$n_laender[[i]]),
      as.character(models$n_unsc3_laender[[i]]),
      paste(models$Jahr_von[[i]], models$Jahr_bis[[i]], sep = "--"),
      "Ja",
      if (grepl("Jahres-FE", models$Modelltyp[[i]])) "Ja" else "Nein",
      if (grepl("Basismodell", models$Spezifikation[[i]])) {
        "Laufzeit"
      } else {
        "DSV-Vollsatz"
      }
    )
  }

  note <- paste(
    "Koeffizienten der Hypothese, nicht die Koeffizienten aller Kontrollen.",
    "Heteroskedastizitaetskonsistente robuste Standardfehler.",
    "Signifikanz: * p<0.10, ** p<0.05, *** p<0.01."
  )
  for (table_kind in c("ergebnisse", "modellvergleich")) {
    data <- if (table_kind == "ergebnisse") result_table else stats
    caption <- paste0(
      "Phase B: ", hypothesis$title, " — ",
      if (table_kind == "ergebnisse") "Ergebnisse" else "Modellvergleich",
      " (1992–2023)"
    )
    stem <- paste0(
      "phase_b_", tolower(hypothesis_name), "_", table_kind
    )
    write_latex(
      data, caption, paste0("tab:", stem), note,
      file.path(output_dir, paste0(stem, ".tex"))
    )
    write_docx(
      data, caption, note,
      file.path(output_dir, paste0(stem, ".docx"))
    )
  }
}

h3_path <- "results/phase_b/exploration/h3_country_profiles.csv"
if (!file.exists(h3_path)) {
  stop("H3-Laenderprofile fehlen. Bitte zuerst ",
       "phase_b_h3_exploration.R ausfuehren: ", h3_path)
}
h3_data <- read.csv(h3_path, stringsAsFactors = FALSE)
h3_required <- c(
  "ISO3", "country", "n_country_years", "n_unsc3_years",
  "mean_count_unsc3", "mean_count_non_unsc3",
  "descriptive_unsc3_gap", "mean_resource_dep"
)
if (!all(h3_required %in% names(h3_data))) {
  stop("Unerwartetes Schema in H3-Laenderprofilen: ",
       paste(setdiff(h3_required, names(h3_data)), collapse = ", "))
}
h3_table <- data.frame(
  Land = paste0(h3_data$country, " (", h3_data$ISO3, ")"),
  `Land-Jahre` = as.character(h3_data$n_country_years),
  `UNSC-Jahre` = as.character(h3_data$n_unsc3_years),
  `Konditionalitaet bei UNSC` = vapply(
    h3_data$mean_count_unsc3, format_estimate, character(1)
  ),
  `Konditionalitaet ohne UNSC` = vapply(
    h3_data$mean_count_non_unsc3, format_estimate, character(1)
  ),
  `Deskriptive Differenz` = vapply(
    h3_data$descriptive_unsc3_gap, format_estimate, character(1)
  ),
  `Rohstoffabhaengigkeit` = vapply(
    h3_data$mean_resource_dep, format_estimate, character(1)
  ),
  stringsAsFactors = FALSE,
  check.names = FALSE
)
h3_note <- paste(
  "Explorative deskriptive Profile fuer 1992-2023; keine kausalen Effekte",
  "oder inferenziellen Tests. Fuer H3 wird daher keine Modellvergleichstabelle",
  "ausgegeben."
)
write_latex(
  h3_table, "H3: Explorative Länderprofile (1992–2023)",
  "tab:phase-b-h3-country-profiles", h3_note,
  file.path(output_dir, "phase_b_h3_laenderprofile.tex")
)
write_docx(
  h3_table, "H3: Explorative Länderprofile (1992–2023)", h3_note,
  file.path(output_dir, "phase_b_h3_laenderprofile.docx")
)

cat("Hypothesenspezifische LaTeX- und Word-Tabellen erstellt unter ",
    output_dir, ":\n", sep = "")
for (hypothesis_name in names(hypotheses)) {
  cat("- ", tolower(hypothesis_name),
      ": Ergebnistabelle + Modellvergleich\n", sep = "")
}
cat("- H3: explorative Laenderprofile; kein Modellvergleich\n")
