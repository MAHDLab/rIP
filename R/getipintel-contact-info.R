#' Get or set GETIPINTEL_CONTACT_INFO value
#'
#' The API wrapper functions in this package all rely on a GetIPInfo API
#' contact info string residing in the environment variable `GETIPINTEL_CONTACT_INFO`.
#' The easiest way to accomplish this is to set it
#' in the `.Renviron` file in your home directory.
#'
#' @md
#' @param force Force setting a new GetIPIntel contact info string for the current environment?
#' @return atomic character vector containing the PGetIPIntel contact info string
#' @author Bob Rudis (bob@@rud.is)
#' @references <https://getipintel.net/>
#' @export
getipintel_contact_info <- function(force = FALSE) {

  env <- Sys.getenv('GETIPINTEL_CONTACT_INFO')
  if (!identical(env, "") && !force) return(env)

  if (!interactive()) {
    stop("Please set env var GETIPINTEL_CONTACT_INFO to your GetIPIntel contact info",
         call. = FALSE)
  }

  message("Couldn't find env var GETIPINTEL_CONTACT_INFO See ?getipintel_contact_info for more details.")
  message("Please enter your API key:")
  pat <- readline(": ")

  if (identical(pat, "")) {
    stop("GetIPIntel contact info entry failed", call. = FALSE)
  }

  message("Updating GETIPINTEL_CONTACT_INFO env var")
  Sys.setenv(GETIPINTEL_CONTACT_INFO = pat)

  pat

}