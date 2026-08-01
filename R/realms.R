# Shared realm plumbing. Realm-specific code only needs to describe its Tiled map;
# movement and terrain collision stay identical in every realm.

realm_specs <- function() {
  list(
    mushroom_swamps = list(
      map_url = "dungeonheroes-assets/maps/mushroom_swamps.json",
      tileset_urls = paste0(
        "dungeonheroes-assets/terrain/ms/",
        c(
          "mushroom_swamps_grass_1.png", "mushroom_swamps_swamp_1.png",
          "ms_bank_bottom.png", "ms_bank_bottom_right.png", "ms_bank_left.png",
          "ms_bank_left_bottom.png", "ms_bank_left_bottom_right.png", "ms_bank_right.png",
          "ms_bank_top_bottom_left_right.png", "ms_bank_top_left.png",
          "ms_bank_top_left_right.png", "ms_bank_top_right.png", "ms_bank_top.png",
          "ms_bank_top_bottom.png", "ms_bank_top_bottom_left.png",
          "ms_bank_top_bottom_right.png", "ms_bank_left_right.png",
          "mushroom_swamps_grass_2.png", "mushroom_swamps_grass_3.png",
          "mushroom_swamps_grass_4.png", "mushroom_swamps_grass_5.png"
        )
      ),
      tileset_names = c(
        "mushroom_swamps_grass_1", "mushroom_swamps_swamp_1",
        paste0("mushroom_swamps_swamp_bank_", c(
          "bottom", "bottom_right", "left", "left_bottom", "left_bottom_right", "right",
          "top_bottom_left_right", "top_left", "top_left_right", "top_right", "top",
          "top_bottom", "top_bottom_left", "top_bottom_right", "left_right"
        )),
        paste0("mushroom_swamps_grass_", 2:5)
      )
    ),
    magma_hills = list(
      map_url = "dungeonheroes-assets/maps/magma_hills.json",
      tileset_urls = paste0(
        "dungeonheroes-assets/terrain/magma_hills/",
        c("hill_1.png", "lava_1.png")
      ),
      tileset_names = c("magma_hills_hill_1", "magma_hills_lava_1")
    )
  )
}

add_realm_map <- function(game, realm_name, map_key = realm_name) {
  realm <- realm_specs()[[realm_name]]
  game$add_map(
    map_key = map_key,
    map_url = realm$map_url,
    tileset_urls = realm$tileset_urls,
    tileset_names = realm$tileset_names,
    layer_name = "terrain"
  )
}

enable_player_movement <- function(game, player) {
  player$add_player_controls()
  player$follow_camera()
  player$set_depth(10)
}

add_navigation_button <- function(game, name, label, x, y, width) {
  background <- game$add_rectangle(
    name = paste0(name, "_background"), x = x, y = y,
    width = width, height = 48, color = "0x33251d"
  )
  label_object <- game$add_text(
    text = label, id = paste0(name, "_label"),
    x = x - width / 2 + 16, y = y - 12
  )
  lapply(list(background, label_object), function(object) {
    object$set_scroll_factor(0)
    object$set_depth(1002)
  })
  list(background, label_object)
}

add_realm_navigation <- function(game) {
  world_map <- game$add_image(
    name = "realm_world_map",
    url = "dungeonheroes-assets/general/world_map.png",
    x = 800,
    y = 400
  )
  world_map$set_scroll_factor(0)
  world_map$set_depth(1000)

  title <- game$add_text(
    text = "The Shattered Realms", id = "realm_map_title", x = 610, y = 65
  )
  help <- game$add_text(
    text = "Choose a realm to begin your journey", id = "realm_map_help", x = 610, y = 720
  )
  lapply(list(title, help), function(object) {
    object$set_scroll_factor(0)
    object$set_depth(1002)
  })

  c(
    list(world_map, title, help),
    add_navigation_button(game, "mushroom_swamps", "Mushroom Swamps", 500, 500, 230),
    add_navigation_button(game, "magma_hills", "Magma Hills", 1150, 260, 190)
  )
}
