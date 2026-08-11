# Run the complete Dungeon Heroes application locally from R with:
#
#   shiny::runApp(source("dungeonheroes.R")$value)
#
# Deploy the project root to shinyapps.io; app.R is its standard Shiny entry
# point. This file remains as a backwards-compatible local launcher.
launcher_path <- function() {
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

  script_argument <- sub(
    "^--file=", "",
    grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  )
  script_argument <- script_argument[
    basename(script_argument) == "dungeonheroes.R"
  ]
  if (length(script_argument) > 0L) {
    return(normalizePath(script_argument[[1L]], mustWork = TRUE))
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
sys.source(file.path(project_dir, "app.R"), envir = environment())
