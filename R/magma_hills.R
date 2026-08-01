# Magma Hills currently consists only of terrain. Lava collision is declared in
# the Tiled JSON; enemies, NPCs, and perks can be added here later.

initialize_magma_hills <- function(game) {
  game$set_shiny_session()
  game$set_world_bounds(world_width, world_height)
  add_realm_map(game, "magma_hills")
  Sys.sleep(0.1)
  add_realm_hero(game)
  game$enable_terrain_collision("hero")
}
