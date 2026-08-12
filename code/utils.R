check_shinyphaser_version <- function(config_file) {
  required_version <- yaml::read_yaml(config_file)$required_version

  if (!is.character(required_version) || length(required_version) != 1L) {
    stop(
      "shinyphaser.yml must define a single required_version string.",
      call. = FALSE
    )
  }

  installed_version <- as.character(utils::packageVersion("shinyphaser"))

  if (!identical(installed_version, required_version)) {
    warning(
      sprintf(
        paste0(
          "Dungeon Heroes expects shinyphaser version %s, but version %s is ",
          "installed. The application may not work correctly."
        ),
        required_version,
        installed_version
      ),
      call. = FALSE
    )
  }

  installed_version
}
