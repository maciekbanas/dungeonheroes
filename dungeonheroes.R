library(shinyphaser)
library(shinyalert)

game <- PhaserGame$new(width = 1600, height = 800)

ui <- shiny::tagList(
  game$ui(),
  shinyalert::useShinyalert()
)

server <- function(input, output, session) {

  shiny::addResourcePath("assets", "assets")
  
  life_points <- 100
  wizard_is_talking <- FALSE

  game$set_shiny_session()

  game$add_image(
    name = "ground",
    url = "assets/terrain/ground.png",
    x = 800,
    y = 300
  )
  hero <- game$add_sprite(
    name = "hero",
    url = "assets/sprites/hero_idle.png",
    x = 100,
    y = 100,
    frame_width = 100,
    frame_height = 100,
    frame_count = 7,
    frame_rate = 4
  )
  hero$add_player_controls()
  Sys.sleep(0.1)
  hero$add_animation(
    suffix = "move_down",
    url = "assets/sprites/hero_move_down.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "move_up",
    url = "assets/sprites/hero_move_up.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "move_left",
    url = "assets/sprites/hero_move_left.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "move_right",
    url = "assets/sprites/hero_move_right.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "attack",
    url = "assets/sprites/hero_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )

  game$add_control(
    "Space",
    action = function() {
      hero$play_animation("hero_attack", duration = 1e3)
      are_overlap_skeleton <- game$are_overlap(
        object_one_name = "hero",
        object_two_name = "skeleton",
        input = input
      )
      are_overlap_wizard <- game$are_overlap(
        object_one_name = "hero",
        object_two_name = "wizard",
        input = input
      )
      if (are_overlap_skeleton()) {
        skeleton$destroy()
      }
      if (are_overlap_wizard()) {
        show_wizard_window(game, input)
      }
    },
    input
  )

  life_points_text <- game$add_text(
    text = "life: 100/100",
    id = "life_points",
    x = 1200,
    y = 50
  )

  wizard <- game$add_sprite(
    name = "wizard",
    url = "assets/sprites/wizard_idle.png",
    x = 500,
    y = 300,
    frame_width = 100,
    frame_height = 100,
    frame_count = 17,
    frame_rate = 4
  )
  wizard$add_animation(
    suffix = "talk",
    url = "assets/sprites/wizard_talk.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )

  skeleton <- game$add_sprite(
    name = "skeleton",
    url = "assets/sprites/skeleton_idle.png",
    x = 700,
    y = 500,
    frame_width = 100,
    frame_height = 100,
    frame_count = 8,
    frame_rate = 4
  )

  skeleton$add_animation(
    suffix = "attack",
    url = "assets/sprites/skeleton_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )

  talk_btn <- game$add_rectangle(
    name = "talk_btn",
    y = 600,
    x = 600,
    width = 100,
    height = 40,
    color = '0xffffff',
    visible = FALSE,
    clickable = TRUE
  )
  game$add_overlap(
    object_name = "hero",
    object_two = "wizard",
    callback_fun = function(evt) {
      talk_btn$show()
      if (!wizard_is_talking) {
        wizard_is_talking <<- TRUE
        wizard$play_animation("wizard_talk", 2e3)
      }
    },
    input = input
  )
  game$add_overlap_end(
    object_one_name = "hero",
    object_two_name = "wizard",
    callback_fun = function(evt) {
      talk_btn$hide()
      wizard_is_talking <<- FALSE
      wizard$play_animation("wizard_idle")
    },
    input = input
  )

  game$add_overlap(
    object_name = "hero",
    object_two = "skeleton",
    callback_fun = function(evt) {
      print("Skeleton attacks you!")
      skeleton$play_animation("skeleton_attack")
    },
    input = input
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "skeleton",
    callback_fun = function(evt) {
      print("Skeleton stops.")
      skeleton$play_animation("skeleton_idle")
    },
    input = input
  )

  talk_btn$click(
    event_fun = function(evt) {
      show_wizard_window(game, input)
    },
    input = input
  )
}

show_wizard_window <- function(game, input) {
  shinyalert::shinyalert(
    title = "Greetings from the Wizard",
    text = "Welcome, brave hero! The wizard sends you wise greetings and wishes you strength for your quest.",
    type = "info"
  )
}

shiny::shinyApp(ui, server)
