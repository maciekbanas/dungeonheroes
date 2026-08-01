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
    ),
    htmltools::tags$button(id = "leave-realm", type = "button", `aria-label` = "Return to world map"),
    htmltools::tags$script(src = "dungeonheroes-assets/js/realm-navigation.js")
  )
}

realm_destination <- function(id, label, left, top) {
  htmltools::tags$button(
    id = id,
    class = "realm-destination",
    type = "button",
    style = sprintf("left:%s%%;top:%s%%", left, top),
    `aria-label` = sprintf("Enter %s", label)
  )
}

initialize_realm_navigation <- function(input, session, game, hero, navigation_objects) {
  loaded_realm_count <- 0L

  shiny::observeEvent(input$realm, {
    if (identical(input$realm, "world_map")) {
      hero$hide()
      lapply(navigation_objects, function(object) object$show())
      return(invisible(NULL))
    }

    loaded_realm_count <<- loaded_realm_count + 1L
    add_realm_map(
      game,
      input$realm,
      map_key = sprintf("%s_%d", input$realm, loaded_realm_count)
    )
    Sys.sleep(0.1)
    game$enable_terrain_collision("hero")
    lapply(navigation_objects, function(object) object$hide())
    hero$show()

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
