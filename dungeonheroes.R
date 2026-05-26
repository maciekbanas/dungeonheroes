library(shinyphaser)
library(shinyalert)

game <- PhaserGame$new(width = 1600, height = 800)

ui <- shiny::tagList(
  game$ui()
)

server <- function(input, output, session) {

  shiny::addResourcePath("assets", "assets")
  
  life_points <- 100
  skeleton_hit_points <- 2
  skeleton_is_alive <- TRUE
  skeleton_last_attack_time <- as.numeric(Sys.time()) - 2
  skeleton_attack_cooldown <- 2
  skeleton_in_range <- FALSE
  wizard_in_range <- FALSE
  game_over_shown <- FALSE
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
      hero$play_animation("hero_attack", duration = 500)
      if (skeleton_in_range && skeleton_is_alive) {
        skeleton_hit_points <<- skeleton_hit_points - 1
        if (skeleton_hit_points <= 0) {
          skeleton_is_alive <<- FALSE
          skeleton$destroy()
          skeleton_in_range <<- FALSE
        }
      }
      if (wizard_in_range) {
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
      wizard_in_range <<- TRUE
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
      wizard_in_range <<- FALSE
      wizard_is_talking <<- FALSE
      wizard$play_animation("wizard_idle")
    },
    input = input
  )

  game$add_overlap(
    object_name = "hero",
    object_two = "skeleton",
    callback_fun = function(evt) {
      skeleton_in_range <<- TRUE
      if (!skeleton_is_alive) {
        return()
      }

      current_time <- as.numeric(Sys.time())
      if ((current_time - skeleton_last_attack_time) >= skeleton_attack_cooldown) {
        skeleton_last_attack_time <<- current_time
        skeleton$play_animation("skeleton_attack", duration = 350)
        life_points <<- max(life_points - 10, 0)
        life_points_text$set(sprintf("life: %d/100", life_points))
        if (life_points <= 0 && !game_over_shown) {
          game_over_shown <<- TRUE
          shinyalert::shinyalert(
            title = "Game Over",
            text = "The skeleton has defeated you.",
            type = "error"
          )
        }
      }
    },
    input = input
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "skeleton",
    callback_fun = function(evt) {
      skeleton_in_range <<- FALSE
      if (skeleton_is_alive) {
        skeleton$play_animation("skeleton_idle")
      }
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
