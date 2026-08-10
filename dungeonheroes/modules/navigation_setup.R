  # Pass the server session explicitly. When this module is sourced, relying on
  # the default reactive domain can capture a non-session evaluation context,
  # which makes send_js() fail when it calls sendCustomMessage().
  game$set_shiny_session(session)

  game$set_world_bounds(world_width, world_height)

  map_navigation_background <- game$add_rectangle(
    name = "map_navigation_background",
    x = 800, y = 400, width = 1600, height = 800,
    color = "0x000000", visible = FALSE
  )
  castle_map_image <- game$add_image(
    name = "choose_castle",
    url = "dungeonheroes-assets/terrain/castle/castle_map.png",
    x = 300, y = 200, visible = FALSE, clickable = TRUE
  )
  mushroom_swamps_map_image <- game$add_image(
    name = "choose_mushroom_swamps",
    url = "dungeonheroes-assets/terrain/mushroom_swamps/mushroom_swamps_map.png",
    x = 500, y = 200, visible = FALSE, clickable = TRUE
  )
  wild_forests_map_image <- game$add_image(
    name = "choose_wild_forests",
    url = "dungeonheroes-assets/terrain/wild_forests/wild_forests_map.png",
    x = 400, y = 200, visible = FALSE, clickable = TRUE
  )
  grey_mountains_map_image <- game$add_image(
    name = "choose_grey_mountains",
    url = "dungeonheroes-assets/terrain/grey_mountains/grey_mountains_map.png",
    x = 300, y = 300, visible = FALSE, clickable = TRUE
  )
  magma_hills_map_image <- game$add_image(
    name = "choose_magma_hills",
    url = "dungeonheroes-assets/terrain/magma_hills/magma_hills_map.png",
    x = 400, y = 300, visible = FALSE, clickable = TRUE
  )
  navigation_images <- list(
    castle_map_image, wild_forests_map_image, mushroom_swamps_map_image,
    grey_mountains_map_image, magma_hills_map_image
  )
  map_navigation_background$set_scroll_factor(0)
  map_navigation_background$set_depth(99)
  lapply(navigation_images, function(image) image$set_scroll_factor(0))
  lapply(navigation_images, function(image) image$set_depth(100))

  game$add_map(
    map_key = "castle",
    map_url = "dungeonheroes-assets/maps/castle.json",
    tileset_urls = "dungeonheroes-assets/terrain/castle/castle_map.png",
    tileset_names = "castle_map",
    layer_name = "terrain"
  )
  game$add_map(
    map_key = "mushroom_swamps",
    map_url = "dungeonheroes-assets/maps/mushroom_swamps.json",
    tileset_urls = c(
      "dungeonheroes-assets/terrain/mushroom_swamps/mushroom_swamps_grass_1.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/mushroom_swamps_swamp_1.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_bottom.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_bottom_right.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_left.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_left_bottom.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_left_bottom_right.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_right.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_top_bottom_left_right.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_top_left.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_top_left_right.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_top_right.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_top.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_top_bottom.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_top_bottom_left.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_top_bottom_right.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/ms_bank_left_right.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/mushroom_swamps_grass_2.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/mushroom_swamps_grass_3.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/mushroom_swamps_grass_4.png",
      "dungeonheroes-assets/terrain/mushroom_swamps/mushroom_swamps_grass_5.png"
    ),
    tileset_names = c(
      "mushroom_swamps_grass_1",
      "mushroom_swamps_swamp_1",
      "mushroom_swamps_swamp_bank_bottom",
      "mushroom_swamps_swamp_bank_bottom_right",
      "mushroom_swamps_swamp_bank_left",
      "mushroom_swamps_swamp_bank_left_bottom",
      "mushroom_swamps_swamp_bank_left_bottom_right",
      "mushroom_swamps_swamp_bank_right",
      "mushroom_swamps_swamp_bank_top_bottom_left_right",
      "mushroom_swamps_swamp_bank_top_left",
      "mushroom_swamps_swamp_bank_top_left_right",
      "mushroom_swamps_swamp_bank_top_right",
      "mushroom_swamps_swamp_bank_top",
      "mushroom_swamps_swamp_bank_top_bottom",
      "mushroom_swamps_swamp_bank_top_bottom_left",
      "mushroom_swamps_swamp_bank_top_bottom_right",
      "mushroom_swamps_swamp_bank_left_right",
      "mushroom_swamps_grass_2",
      "mushroom_swamps_grass_3",
      "mushroom_swamps_grass_4",
      "mushroom_swamps_grass_5"
    ),
    layer_name = "terrain"
  )
  game$add_map(
    map_key = "magma_hills",
    map_url = "dungeonheroes-assets/maps/magma_hills.json",
    tileset_urls = c(
      "dungeonheroes-assets/terrain/magma_hills/hill_1.png",
      "dungeonheroes-assets/terrain/magma_hills/lava_1.png"
    ),
    tileset_names = c("hill_1", "lava_1"),
    layer_name = "terrain"
  )
  game$add_map(
    map_key = "wild_forests",
    map_url = "dungeonheroes-assets/maps/wild_forests.json",
    tileset_urls = c(
      sprintf("dungeonheroes-assets/terrain/wild_forests/grass_%d.png", 1:5),
      "dungeonheroes-assets/terrain/wild_forests/forest_path_1.png"
    ),
    tileset_names = c(sprintf("grass_%d", 1:5), "forest_path_1"),
    layer_name = "terrain"
  )
  game$add_map(
    map_key = "grey_mountains",
    map_url = "dungeonheroes-assets/maps/grey_mountains.json",
    tileset_urls = c(
      "dungeonheroes-assets/terrain/grey_mountains/hill_1.png",
      "dungeonheroes-assets/terrain/grey_mountains/rock_1.png"
    ),
    tileset_names = c("hill_1", "rock_1"),
    layer_name = "terrain"
  )
