# Shared game construction used by every playable realm.

create_realm_game <- function() {
  PhaserGame$new(width = 1600, height = 800)
}

add_realm_hero <- function(game, x = 100, y = 100) {
  hero <- game$add_sprite(
    name = "hero",
    url = "dungeonheroes-assets/sprites/hero_idle.png",
    x = x, y = y,
    frame_width = 100, frame_height = 100,
    frame_count = 7, frame_rate = 4
  )
  enable_player_movement(game, hero)

  lapply(c("down", "up", "left", "right"), function(direction) {
    hero$add_animation(
      suffix = paste0("move_", direction),
      url = sprintf("dungeonheroes-assets/sprites/hero_move_%s.png", direction),
      frame_width = 100, frame_height = 100,
      frame_count = 4, frame_rate = 8
    )
  })
  hero
}

add_player_health_bar <- function(game, segment_count = 10, x = 1200, y = 60,
                                  segment_width = 18, segment_height = 14,
                                  segment_gap = 3) {
  add_segments <- function(prefix, color) {
    lapply(seq_len(segment_count), function(segment_index) {
      segment <- game$add_rectangle(
        name = sprintf("life_bar_%s_%02d", prefix, segment_index),
        x = x + ((segment_index - 1) * (segment_width + segment_gap)),
        y = y, width = segment_width, height = segment_height, color = color
      )
      segment$set_scroll_factor(0)
      segment
    })
  }
  add_segments("red", "0xc0392b")
  add_segments("green", "0x2ecc71")
}

show_game_over <- function() {
  shinyalert::shinyalert(
    title = "Game over",
    text = "Your life points reached 0.",
    type = "error",
    closeOnClickOutside = FALSE,
    showCancelButton = FALSE
  )
}

realm_page_ui <- function(game, show_leave = TRUE) {
  shiny::tagList(
    if (show_leave) htmltools::tags$a(
      id = "leave-realm", href = "?realm=world_map", "World map"
    ),
    game$use_phaser(),
    dungeonheroes_loader_ui()
  )
}

dungeonheroes_loader_ui <- function() {
  htmltools::tagList(
    htmltools::tags$style(htmltools::HTML("
      @keyframes dungeonheroes-skeleton-loader {
        from { background-position: 0 0; }
        to { background-position: -800px 0; }
      }
      #dungeonheroes_loader { position:fixed; inset:0; z-index:9999; display:flex;
        flex-direction:column; gap:18px; align-items:center; justify-content:center;
        background:#111827; color:#f9fafb; font:24px sans-serif; }
      #dungeonheroes_loader .skeleton_loader_sprite { width:100px; height:100px;
        background-image:url('dungeonheroes-assets/sprites/skeleton_idle.png');
        background-repeat:no-repeat; animation:dungeonheroes-skeleton-loader 1s steps(8) infinite;
        image-rendering:pixelated; }
      #leave-realm { position:fixed; z-index:9500; right:25px; top:25px; padding:12px 20px;
        border:2px solid #e7cb87; border-radius:5px; color:white; background:#33251d;
        font-weight:bold; font-family:sans-serif; text-decoration:none; }
    ")),
    htmltools::tags$div(
      id = "dungeonheroes_loader",
      htmltools::tags$div(class = "skeleton_loader_sprite"),
      htmltools::tags$div("Loading dungeon heroes...")
    ),
    htmltools::tags$script(htmltools::HTML("
      window.addEventListener('load', function() {
        setTimeout(function() {
          var loader = document.getElementById('dungeonheroes_loader');
          if (loader) loader.style.display = 'none';
        }, 1200);
      });
    "))
  )
}
