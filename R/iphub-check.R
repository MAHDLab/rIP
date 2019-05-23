#' Retrieve IP address metadata from IPHub
#'
#' @md
#' @param ip an IP address (length 1 character vector)
#' @param api_key an IPHub API key (see [iphub_api_key()])
#' @author Bob Rudis (bob@@rud.is)
#' @references <https://iphub.info/api>
#' @export
#' @examples \dontrun{
#' iphub_check("24.63.157.68")
#' }
iphub_check <- function(ip, api_key = iphub_api_key()) {

  ip <- ip[1]

  if (is.na(iptools::ip_classify(ip))) {
    stop("`ip` is not a valid IP address", call.=FALSE)
  }

  httr::GET(
    url = sprintf("https://v2.api.iphub.info/ip/%s", ip),
    httr::add_headers(
      `X-Key` = api_key
    ),
    .RIP_UA
  ) -> res

  httr::stop_for_status(res)

  out <- httr::content(res, as = "text")
  out <- jsonlite::fromJSON(out)

  out

}

