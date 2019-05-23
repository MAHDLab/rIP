#' Get or set IPHUB_API_KEY value
#'
#' The API wrapper functions in this package all rely on a PacketTotal API
#' key residing in the environment variable `IPHUB_API_KEY`.
#' The easiest way to accomplish this is to set it
#' in the `.Renviron` file in your home directory.
#'
#' @md
#' @param force Force setting a new IPHub key for the current environment?
#' @return atomic character vector containing the IPHub api key
#' @author Bob Rudis (bob@@rud.is)
#' @references <https://iphub.info/api>
#' @export
iphub_api_key <- function(force = FALSE) {

  env <- Sys.getenv('IPHUB_API_KEY')
  if (!identical(env, "") && !force) return(env)

  if (!interactive()) {
    stop("Please set env var IPHUB_API_KEY to your IPHub key",
         call. = FALSE)
  }

  message("Couldn't find env var IPHUB_API_KEY See ?iphub_api_key for more details.")
  message("Please enter your API key:")
  pat <- readline(": ")

  if (identical(pat, "")) {
    stop("IPHub key entry failed", call. = FALSE)
  }

  message("Updating IPHUB_API_KEY env var")
  Sys.setenv(IPHUB_API_KEY = pat)

  pat

}