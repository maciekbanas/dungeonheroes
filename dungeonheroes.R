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
    list(name = "skeleton", x = 750, y = 480, hit_points = 3, damage = 8),
    list(name = "skeleton_2", x = 870, y = 580, hit_points = 4, damage = 12)
  )
  skeleton_names <- vapply(skeleton_specs, `[[`, character(1), "name")

  max_life_points <- 100
  life_points <- max_life_points
  skeleton_max_hit_points <- stats::setNames(
    vapply(skeleton_specs, `[[`, numeric(1), "hit_points"),
    skeleton_names
  )
  skeleton_hit_points <- skeleton_max_hit_points
  skeleton_is_alive <- stats::setNames(rep(TRUE, length(skeleton_names)), skeleton_names)
  skeleton_last_attack_time <- stats::setNames(
    rep(as.numeric(Sys.time()) - 2, length(skeleton_names)),
    skeleton_names
  )
  skeleton_damage <- stats::setNames(
    vapply(skeleton_specs, `[[`, numeric(1), "damage"),
    skeleton_names
  )
  skeleton_attack_cooldown <- 2
  skeleton_in_range <- NULL
  wizard_in_range <- FALSE
  sword_in_range <- FALSE
  has_sword <- FALSE
  hero_last_attack_time <- as.numeric(Sys.time()) - 1
  hero_attack_cooldown <- 0.75
  hero_fist_damage <- 1
  hero_sword_damage <- 2
  health_bar_segment_count <- 10
  health_bar_segment_width <- 18
  health_bar_segment_height <- 14
  health_bar_segment_gap <- 3
  game_over_shown <- FALSE
  wizard_is_talking <- FALSE
  defeated_skeleton_count <- 0

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

  format_skeleton_label <- function(skeleton_name) {
    gsub("_", " ", skeleton_name)
  }

  set_combat_status <- function(message) {
    combat_status_text$set(message)
  }

  update_life_points <- function() {
    visible_segments <- ceiling(life_points / max_life_points * health_bar_segment_count)

    lapply(seq_len(health_bar_segment_count), function(segment_index) {
      if (segment_index <= visible_segments) {
        health_bar_segments[[segment_index]]$show()
      } else {
        health_bar_segments[[segment_index]]$hide()
      }
    })
  }

  update_enemy_status <- function() {
    living_skeleton_names <- skeleton_names[skeleton_is_alive]
    if (length(living_skeleton_names) == 0) {
      enemy_status_text$set("enemies: defeated")
      return()
    }

    enemy_summaries <- vapply(living_skeleton_names, function(skeleton_name) {
      sprintf(
        "%s %d/%d",
        format_skeleton_label(skeleton_name),
        skeleton_hit_points[[skeleton_name]],
        skeleton_max_hit_points[[skeleton_name]]
      )
    }, character(1))

    enemy_status_text$set(paste("enemies:", paste(enemy_summaries, collapse = " | ")))
  }

  nearest_living_skeleton <- function() {
    if (!is.null(skeleton_in_range) && isTRUE(skeleton_is_alive[[skeleton_in_range]])) {
      return(skeleton_in_range)
    }

    NULL
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
      if (life_points <= 0) {
        set_combat_status("You are defeated and cannot fight.")
        return()
      }

      if (sword_in_range && !has_sword) {
        has_sword <<- TRUE
        sword_in_range <<- FALSE
        sword$destroy()
        inventory_text$set("weapon: sword")
        set_combat_status("You equipped the sword. Your attacks are stronger.")
        hero$play_animation("hero_sword")
      } else {
        current_time <- as.numeric(Sys.time())
        if ((current_time - hero_last_attack_time) < hero_attack_cooldown) {
          set_combat_status("You need a moment before attacking again.")
          return()
        }

        hero_last_attack_time <<- current_time

        if (has_sword) {
          hero$play_animation("hero_sword_attack", duration = 500)
        } else {
          hero$play_animation("hero_attack", duration = 500)
        }

        target_name <- nearest_living_skeleton()
        if (!is.null(target_name)) {
          attack_damage <- if (has_sword) hero_sword_damage else hero_fist_damage
          skeleton_hit_points[target_name] <<- max(
            skeleton_hit_points[[target_name]] - attack_damage,
            0
          )

          if (skeleton_hit_points[[target_name]] <= 0) {
            skeleton_is_alive[target_name] <<- FALSE
            skeletons[[target_name]]$destroy()
            skeleton_in_range <<- NULL
            defeated_skeleton_count <<- defeated_skeleton_count + 1
            set_combat_status(sprintf(
              "You defeated %s (%d/%d defeated).",
              format_skeleton_label(target_name),
              defeated_skeleton_count,
              length(skeleton_names)
            ))
          } else {
            set_combat_status(sprintf(
              "You hit %s for %d damage.",
              format_skeleton_label(target_name),
              attack_damage
            ))
          }
          update_enemy_status()
        } else {
          set_combat_status("Your attack hits only air.")
        }
      }
      if (wizard_in_range) {
        show_wizard_window(game, input, has_sword)
      }
    },
    input
  )

  inventory_text <- game$add_text(
    text = "weapon: none",
    id = "inventory_weapon",
    x = 1200,
    y = 85
  )
  lapply(seq_len(health_bar_segment_count), function(segment_index) {
    segment_x <- 1340 + ((segment_index - 1) * (health_bar_segment_width + health_bar_segment_gap))
    game$add_rectangle(
      name = sprintf("life_bar_red_%02d", segment_index),
      x = segment_x,
      y = 60,
      width = health_bar_segment_width,
      height = health_bar_segment_height,
      color = "0xc0392b"
    )
  })
  health_bar_segments <- lapply(seq_len(health_bar_segment_count), function(segment_index) {
    segment_x <- 1340 + ((segment_index - 1) * (health_bar_segment_width + health_bar_segment_gap))
    game$add_rectangle(
      name = sprintf("life_bar_green_%02d", segment_index),
      x = segment_x,
      y = 60,
      width = health_bar_segment_width,
      height = health_bar_segment_height,
      color = "0x2ecc71"
    )
  })
  update_life_points()
  enemy_status_text <- game$add_text(
    text = "enemies: loading",
    id = "enemy_status",
    x = 1200,
    y = 120
  )
  combat_status_text <- game$add_text(
    text = "combat: find a weapon, then face the skeletons",
    id = "combat_status",
    x = 800,
    y = 660
  )
  update_enemy_status()
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
          damage <- skeleton_damage[[skeleton_name]]
          life_points <<- max(life_points - damage, 0)
          update_life_points()
          set_combat_status(sprintf(
            "%s strikes you for %d damage.",
            format_skeleton_label(skeleton_name),
            damage
          ))
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
