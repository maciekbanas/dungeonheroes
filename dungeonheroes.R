# Run the complete Dungeon Heroes application from R with:
#
#   source("dungeonheroes.R")
#
# `Rscript dungeonheroes.R` is also supported. Find this file from either
# Rscript's arguments or source()'s evaluation frame. The working-directory
# fallback also supports selecting and running the whole file in an R editor.
launcher_path <- function() {
  script_argument <- grep(
    "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
  )
  if (length(script_argument) > 0L) {
    return(normalizePath(
      sub("^--file=", "", script_argument[[1L]]), mustWork = TRUE
    ))
  }

  frames <- sys.frames()
  for (frame in rev(frames)) {
    if (!is.null(frame$ofile)) {
      path <- tryCatch(
        normalizePath(frame$ofile, mustWork = TRUE),
        error = function(...) NULL
      )
      if (!is.null(path) && basename(path) == "dungeonheroes.R") {
        return(path)
      }
    }
  }

  path <- file.path(getwd(), "dungeonheroes.R")
  if (file.exists(path)) {
    return(normalizePath(path, mustWork = TRUE))
  }

  stop(
    paste(
      "Could not locate dungeonheroes.R.",
      "Use source() with its path or run the file from the project directory."
    ),
    call. = FALSE
  )
}

project_dir <- dirname(launcher_path())
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

# Run the root app entry point used by deployments. It registers assets before
# loading the game implementation from app_dir.
shiny::runApp(project_dir, launch.browser = interactive())
