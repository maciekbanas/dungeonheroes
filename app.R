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

library(shinyphaser)

# Shiny starts app.R with the application directory as its working directory.
project_dir <- getwd()
code_dir <- file.path(project_dir, "code")
assets_dir <- file.path(project_dir, "www", "assets")

if (!dir.exists(code_dir) || !dir.exists(assets_dir)) {
  stop("The application or its assets are missing from the project.", call. = FALSE)
}

shiny::addResourcePath("dungeonheroes-assets", assets_dir)

game <- PhaserGame$new(width = 1600, height = 800)
map_tile_size <- 100
map_tile_width <- 32
map_tile_height <- 64
world_width <- map_tile_width * map_tile_size
world_height <- map_tile_height * map_tile_size
shinyphaser_version <- as.character(utils::packageVersion("shinyphaser"))

# Each module is evaluated in the app or server environment so the example stays
# easy to read while retaining the shared state expected by its Shiny callbacks.
sys.source(file.path(code_dir, "ui.R"), envir = environment())

server <- function(input, output, session) {
  server_env <- environment()
  modules <- c(
    "game_state.R",
    "navigation_setup.R",
    "hero.R",
    file.path("realms", "mushroom_swamps_world.R"),
    file.path("realms", "wild_forests_world.R"),
    "navigation.R",
    "saving.R",
    "navigation_events.R",
    file.path("realms", "mushroom_swamps.R"),
    file.path("realms", "magma_hills.R"),
    file.path("realms", "wild_forests.R"),
    file.path("realms", "grey_mountains.R"),
    file.path("realms", "castle.R"),
    "realm_routes.R"
  )

  for (module in file.path(code_dir, "modules", modules)) {
    sys.source(module, envir = server_env)
  }
}

shiny::shinyApp(ui, server)
