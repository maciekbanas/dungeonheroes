library(shiny)
library(shinyphaser)

invisible(lapply(sort(list.files("R", pattern = "[.]R$", full.names = TRUE)), source))

shiny::addResourcePath(
  prefix = "dungeonheroes-assets",
  directoryPath = normalizePath("www/assets", mustWork = TRUE)
)

map_tile_size <- 100
map_tile_width <- 32
map_tile_height <- 64
world_width <- map_tile_width * map_tile_size
world_height <- map_tile_height * map_tile_size
shinyphaser_version <- as.character(utils::packageVersion("shinyphaser"))
dungeonheroes_version <- read.dcf("DESCRIPTION", fields = "Version")[[1]]

scene_games <- list(
  world_map = create_realm_game(),
  mushroom_swamps = create_realm_game(),
  magma_hills = create_realm_game()
)

requested_scene <- function(query_string) {
  query_string <- if (is.null(query_string)) "" else query_string
  if (nzchar(query_string) && !startsWith(query_string, "?")) {
    query_string <- paste0("?", query_string)
  }
  query <- shiny::parseQueryString(query_string)
  scene <- if (is.null(query$realm)) "world_map" else query$realm
  if (!scene %in% names(scene_games)) "world_map" else scene
}

ui <- function(request) {
  scene <- requested_scene(request$QUERY_STRING)
  if (identical(scene, "world_map")) {
    return(shiny::tagList(
      realm_navigation_ui(),
      realm_page_ui(scene_games[[scene]], show_leave = FALSE)
    ))
  }
  realm_page_ui(scene_games[[scene]])
}

server <- function(input, output, session) {
  scene <- requested_scene(session$request$QUERY_STRING)
  game <- scene_games[[scene]]

  switch(
    scene,
    world_map = initialize_world_map(game),
    mushroom_swamps = initialize_mushroom_swamps(game, input, session),
    magma_hills = initialize_magma_hills(game)
  )
}

shiny::shinyApp(ui, server)
