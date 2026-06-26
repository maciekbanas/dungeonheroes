library(shinyphaser)
library(shinyalert)

game <- PhaserGame$new(width = 1600, height = 800)
shinyphaser_version <- as.character(utils::packageVersion("shinyphaser"))

ui <- shiny::tagList(
  game$use_phaser()
)

server <- function(input, output, session) {

  shiny::addResourcePath("assets", "assets")

  skeleton_specs <- list(
    list(name = "skeleton", x = 750, y = 480),
    list(name = "skeleton_2", x = 870, y = 580)
  )
  skeleton_names <- vapply(skeleton_specs, `[[`, character(1), "name")

  life_points <- 100
  skeleton_hit_points <- stats::setNames(rep(2, length(skeleton_names)), skeleton_names)
  skeleton_is_alive <- stats::setNames(rep(TRUE, length(skeleton_names)), skeleton_names)
  skeleton_last_attack_time <- stats::setNames(
    rep(as.numeric(Sys.time()) - 2, length(skeleton_names)),
    skeleton_names
  )
  skeleton_attack_cooldown <- 2
  skeleton_in_range <- NULL
  wizard_in_range <- FALSE
  sword_in_range <- FALSE
  has_sword <- FALSE
  game_over_shown <- FALSE
  wizard_is_talking <- FALSE

  show_intro_alerts <- function() {
    shinyalert::shinyalert(
      title = "Welcome to the game, dungeon hero!",
      type = "success",
      callbackR = function(value) {
        shinyalert::shinyalert(
          title = "Use arrows to move and space to attack or interact",
          type = "info"
        )
      }
    )
  }

  session$onFlushed(show_intro_alerts, once = TRUE)

  skeleton_animation_key <- function(skeleton_name, suffix) {
    paste(skeleton_name, suffix, sep = "_")
  }

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

  hero$add_animation(
    suffix = "sword_idle",
    url = "assets/sprites/hero_sword_idle.png",
    frame_width = 100, frame_height = 100,
    frame_count = 7, frame_rate = 4
  )
  hero$add_animation(
    suffix = "sword_move_down",
    url = "assets/sprites/hero_sword_move_down.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_move_up",
    url = "assets/sprites/hero_sword_move_up.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_move_left",
    url = "assets/sprites/hero_sword_move_left.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_move_right",
    url = "assets/sprites/hero_sword_move_right.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_attack",
    url = "assets/sprites/hero_sword_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )

  skeletons <- stats::setNames(lapply(skeleton_specs, function(spec) {
    skel <- game$add_sprite(
      name = spec$name,
      url = "assets/sprites/skeleton_idle.png",
      x = spec$x,
      y = spec$y,
      frame_width = 100,
      frame_height = 100,
      frame_count = 8,
      frame_rate = 4
    )

    skel$add_animation(
      suffix = "attack",
      url = "assets/sprites/skeleton_attack.png",
      frame_width = 100, frame_height = 100,
      frame_count = 2, frame_rate = 4
    )

    skel
  }), skeleton_names)

  game$add_control(
    "Space",
    action = function() {
      if (sword_in_range && !has_sword) {
        has_sword <<- TRUE
        sword_in_range <<- FALSE
        sword$destroy()
        inventory_text$set("weapon: sword")
        hero$play_animation("hero_sword")
      } else {
        if (has_sword) {
          hero$play_animation("hero_sword_attack", duration = 500)
        } else {
          hero$play_animation("hero_attack", duration = 500)
        }
        if (!is.null(skeleton_in_range) && isTRUE(skeleton_is_alive[[skeleton_in_range]])) {
          target_name <- skeleton_in_range
          skeleton_hit_points[target_name] <<- skeleton_hit_points[[target_name]] - 1
          if (skeleton_hit_points[[target_name]] <= 0) {
            skeleton_is_alive[target_name] <<- FALSE
            skeletons[[target_name]]$destroy()
            skeleton_in_range <<- NULL
          }
        }
      }
      if (wizard_in_range) {
        show_wizard_window(game, input, has_sword)
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
  inventory_text <- game$add_text(
    text = "weapon: none",
    id = "inventory_weapon",
    x = 1200,
    y = 85
  )
  game$add_text(
    text = sprintf("shinyphaser v%s", shinyphaser_version),
    id = "shinyphaser_version",
    x = 50,
    y = 660
  )

  sword <- game$add_static_sprite(
    name = "sword",
    url = "assets/weapons/sword.png",
    x = 300,
    y = 300
  )
  game$add_overlap(
    object_one = "hero",
    object_two = "sword",
    callback_fun = function(evt) {
      if (!has_sword) {
        sword_in_range <<- TRUE
      }
    },
    input = input
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "sword",
    callback_fun = function(evt) {
      sword_in_range <<- FALSE
    },
    input = input
  )

  wizard <- game$add_sprite(
    name = "wizard",
    url = "assets/sprites/wizard_idle.png",
    x = 1200,
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

  talk_bubble_text <- game$add_text(
    text = "...",
    id = "talk_bubble_text",
    x = 1200,
    y = 193,
    visible = FALSE
  )
  game$add_overlap(
    object_one = "hero",
    object_two = "wizard",
    callback_fun = function(evt) {
      talk_bubble_text$show()
      wizard_in_range <<- TRUE
      if (!wizard_is_talking) {
        wizard_is_talking <<- TRUE
        wizard$play_animation("wizard_talk", 2e3)
      }
    },
    input = input
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "wizard",
    callback_fun = function(evt) {
      talk_bubble_text$hide()
      wizard_in_range <<- FALSE
      wizard_is_talking <<- FALSE
      wizard$play_animation("wizard_idle")
    },
    input = input
  )

  add_skeleton_handlers <- function(skeleton_name) {
    force(skeleton_name)

    game$add_overlap(
      object_one = "hero",
      object_two = skeleton_name,
      callback_fun = function(evt) {
        skeleton_in_range <<- skeleton_name
        if (!isTRUE(skeleton_is_alive[[skeleton_name]])) {
          return()
        }

        current_time <- as.numeric(Sys.time())
        if ((current_time - skeleton_last_attack_time[[skeleton_name]]) >= skeleton_attack_cooldown) {
          skeleton_last_attack_time[skeleton_name] <<- current_time
          skeletons[[skeleton_name]]$play_animation(
            skeleton_animation_key(skeleton_name, "attack"),
            duration = 350
          )
          life_points <<- max(life_points - 10, 0)
          life_points_text$set(sprintf("life: %d/100", life_points))
          if (life_points <= 0 && !game_over_shown) {
            game_over_shown <<- TRUE
            shinyalert::shinyalert(
              title = "Game Over",
              text = "You have been defeated.",
              type = "error"
            )
          }
        }
      },
      input = input
    )

    game$add_overlap_end(
      object_one = "hero",
      object_two = skeleton_name,
      callback_fun = function(evt) {
        if (identical(skeleton_in_range, skeleton_name)) {
          skeleton_in_range <<- NULL
        }
        if (isTRUE(skeleton_is_alive[[skeleton_name]])) {
          skeletons[[skeleton_name]]$play_animation(skeleton_animation_key(skeleton_name, "idle"))
        }
      },
      input = input
    )
  }

  lapply(skeleton_names, add_skeleton_handlers)
}

show_wizard_window <- function(game, input, has_sword = FALSE) {
  greeting <- if (has_sword) {
    "You found the sword. The wizard believes you are ready for the next challenge."
  } else {
    "Welcome, brave hero! Find the sword before facing the deepest dungeon challenge."
  }

  shinyalert::shinyalert(
    title = "Greetings from the Wizard",
    text = greeting,
    type = "info"
  )
}

shiny::shinyApp(ui, server)
