# Run the complete Dungeon Heroes application locally from R with:
#
#   shiny::runApp(source("dungeonheroes.R")$value)
#
# The file is also a Shiny application entry point, so it can be supplied as
# `appPrimaryDoc` when the project root is deployed with rsconnect. Find this
# file from source()'s evaluation frame first: a hosted Shiny process can have
# its own --file argument which must not be mistaken for this application.
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

# The Shiny app lives in a subdirectory, while its asset library is kept at the
# project root. Register the URL prefix used throughout the game before Shiny
# evaluates app.R.
shiny::addResourcePath("dungeonheroes-assets", assets_dir)

# Return the application object rather than starting another Shiny process.
# This is the contract expected by shinyapps.io (and by runApp() for a single
# R-file app). `app_dir` remains available to app.R so its delayed server
# callbacks can resolve module paths without relying on the process working
# directory.
sys.source(file.path(app_dir, "app.R"), envir = environment())
