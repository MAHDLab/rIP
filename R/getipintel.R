#' Retrieve IP address metadata from GetIPIntel
#'
#' @md
#' @param ip an IP address (length 1 character vector)
#' @param flags,oflags a valid GetIPIntel flag specification (See: <https://getipintel.net/free-proxy-vpn-tor-detection-api/#optional_settings>)
#' @param contact_info GetIPIntel requires supplying contact info with each API call. Presently,
#'        this takes the form of an email address. See [getipintel_contact_info()] for more information.
#' @author Bob Rudis (bob@@rud.is)
#' @references <https://getipintel.net/>
#' @export
#' @examples \dontrun{
#' getipintel("24.63.157.68")
#' }
getipintel <- function(ip,
                       flags = NULL,
                       oflags = NULL,
                       contact_info = getipintel_contact_info()) {

  ip <- ip[1]

  if (is.na(iptools::ip_classify(ip))) {
    stop("`ip` is not a valid IP address", call.=FALSE)
  }

  httr::GET(
    url = "https://check.getipintel.net/check.php",
    query = list(
      ip = ip,
      contact = contact_info,
      flags = flags,
      oflags = oflags,
      format = "json"
    ),
    .RIP_UA
  ) -> res

  httr::stop_for_status(res)

  out <- httr::content(res, as = "text")
  out <- jsonlite::fromJSON(out)

  out

}
