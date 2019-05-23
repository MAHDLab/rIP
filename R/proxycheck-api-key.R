#' Get or set PROXYCHECK_API_KEY value
#'
#' The API wrapper functions in this package all rely on a PacketTotal API
#' key residing in the environment variable `PROXYCHECK_API_KEY`.
#' The easiest way to accomplish this is to set it
#' in the `.Renviron` file in your home directory.
#'
#' @md
#' @param force Force setting a new ProxyCheck key for the current environment?
#' @return atomic character vector containing the ProxyCheck api key
#' @author Bob Rudis (bob@@rud.is)
#' @references <https://proxycheck.io/api/#introduction>
#' @export
proxycheck_api_key <- function(force = FALSE) {

  env <- Sys.getenv('PROXYCHECK_API_KEY')
  if (!identical(env, "") && !force) return(env)

  if (!interactive()) {
    stop("Please set env var PROXYCHECK_API_KEY to your ProxyCheck key",
         call. = FALSE)
  }

  message("Couldn't find env var PROXYCHECK_API_KEY See ?proxycheck_api_key for more details.")
  message("Please enter your API key:")
  pat <- readline(": ")

  if (identical(pat, "")) {
    stop("ProxyCheck key entry failed", call. = FALSE)
  }

  message("Updating PROXYCHECK_API_KEY env var")
  Sys.setenv(PROXYCHECK_API_KEY = pat)

  pat

}