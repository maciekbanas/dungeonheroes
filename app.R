# shinyapps.io bundles files below the directory containing the deployed app.R.
# Keep this entry point at the project root so the sibling www asset tree and
# the implementation in dungeonheroes/ are both part of the deployment.
project_dir <- normalizePath(getwd(), mustWork = TRUE)
game_dir <- file.path(project_dir, "dungeonheroes")
assets_dir <- file.path(project_dir, "www", "assets")

if (!dir.exists(game_dir) || !dir.exists(assets_dir)) {
  stop("The application or its assets are missing from the project.", call. = FALSE)
}

shiny::addResourcePath("dungeonheroes-assets", assets_dir)

# The game modules use paths relative to dungeonheroes/. source(chdir = TRUE)
# preserves those paths while returning the shiny.appobj created by its app.R.
source(file.path(game_dir, "app.R"), chdir = TRUE)$value
