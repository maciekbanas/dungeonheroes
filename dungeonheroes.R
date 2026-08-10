# Run the complete Dungeon Heroes application with:
#
#   Rscript dungeonheroes.R
#
# Resolve paths from this file rather than from the caller's working directory,
# so the same command also works when it is invoked from somewhere else.
script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_argument) == 0L) {
  stop("Run this launcher with `Rscript dungeonheroes.R`.", call. = FALSE)
}

script_path <- sub("^--file=", "", script_argument[[1L]])
project_dir <- dirname(normalizePath(script_path, mustWork = TRUE))
app_dir <- file.path(project_dir, "dungeonheroes")
assets_dir <- file.path(project_dir, "www", "assets")

required_packages <- c("later", "shiny", "shinyalert", "shinyphaser")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1L), quietly = TRUE)
]

if (length(missing_packages) > 0L) {
  stop(
    sprintf(
      "Install the required package%s before starting Dungeon Heroes: %s",
      if (length(missing_packages) == 1L) "" else "s",
      paste(missing_packages, collapse = ", ")
    ),
    call. = FALSE
  )
}

if (!dir.exists(app_dir) || !dir.exists(assets_dir)) {
  stop("The application or its assets are missing from the project.", call. = FALSE)
}

# The Shiny app lives in a subdirectory, while its large asset library is kept
# at the project root. Register the URL prefix used throughout the game before
# Shiny evaluates app.R.
shiny::addResourcePath("dungeonheroes-assets", assets_dir)
shiny::runApp(app_dir, launch.browser = interactive())
