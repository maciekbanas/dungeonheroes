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
      htmltools::tags$img(
        class = "world-map-art",
        src = "dungeonheroes-assets/general/world_map.png",
        alt = "Map of the Shattered Realms"
      ),
      htmltools::tags$div(class = "map-title", "The Shattered Realms"),
      realm_destination("mushroom-swamps", "Mushroom Swamps", "Enter", 31, 61),
      realm_destination("magma-hills", "Magma Hills", "Travel", 72, 31),
      htmltools::tags$img(
        id = "world-hero",
        src = "dungeonheroes-assets/sprites/hero_idle.png",
        alt = "Hero at Mushroom Swamps"
      ),
      htmltools::tags$p(class = "map-help", "Click a realm to travel. Press Enter to enter Mushroom Swamps.")
    ),
    htmltools::tags$button(id = "leave-realm", type = "button", `aria-label` = "Return to world map"),
    htmltools::tags$script(src = "dungeonheroes-assets/js/realm-navigation.js")
  )
}

realm_destination <- function(id, label, action, left, top) {
  htmltools::tags$button(
    id = id,
    class = "realm-destination",
    type = "button",
    style = sprintf("left:%s%%;top:%s%%", left, top),
    htmltools::tags$strong(label),
    htmltools::tags$span(action)
  )
}

initialize_realm_navigation <- function(input, session) {
  shiny::observeEvent(input$realm, {
    if (identical(input$realm, "mushroom_swamps")) {
      shinyalert::shinyalert(
        title = "Use Space to attack and interact",
        type = "info"
      )
    }
    shiny::showNotification(
      sprintf("Entering %s", if (identical(input$realm, "magma_hills")) "Magma Hills" else "Mushroom Swamps"),
      type = "message", duration = 2
    )
  }, ignoreInit = TRUE)
}
