# Navigation between the realm overview and playable realm scenes is kept here
# so realm selection remains independent from Mushroom Swamps combat logic.

realm_navigation_ui <- function() {
  htmltools::tagList(
    htmltools::tags$link(
      rel = "stylesheet",
      href = "dungeonheroes-assets/css/realm-navigation.css"
    ),
    htmltools::tags$div(
      id = "realm-map",
      tabindex = "0",
      `aria-label` = "World map. The hero is at Mushroom Swamps.",
      realm_destination("mushroom-swamps", "Mushroom Swamps", 31, 61),
      realm_destination("magma-hills", "Magma Hills", 72, 31)
    )
  )
}

realm_destination <- function(id, label, left, top) {
  realm_name <- gsub("-", "_", id, fixed = TRUE)
  htmltools::tags$a(
    id = id,
    class = "realm-destination",
    href = sprintf("?realm=%s", realm_name),
    style = sprintf("left:%s%%;top:%s%%", left, top),
    `aria-label` = sprintf("Enter %s", label),
    htmltools::tags$strong(label),
    htmltools::tags$span("Enter realm")
  )
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

  title <- game$add_text(
    text = "The Shattered Realms", id = "realm_map_title", x = 610, y = 65
  )
  help <- game$add_text(
    text = "Choose a realm to begin your journey", id = "realm_map_help", x = 610, y = 720
  )
  lapply(list(title, help), function(object) {
    object$set_scroll_factor(0)
  })

  c(
    list(world_map, title, help),
    add_navigation_button(game, "mushroom_swamps", "Mushroom Swamps", 500, 500, 230),
    add_navigation_button(game, "magma_hills", "Magma Hills", 1150, 260, 190)
  )
}


initialize_world_map <- function(game) {
  game$set_shiny_session()
  add_realm_navigation(game)
}
