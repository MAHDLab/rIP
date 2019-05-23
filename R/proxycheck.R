#' Retrieve IP address metadata from ProxyCheck
#'
#' Pass in an IP address along with API key and any extra API query flags
#' and retrieve metadata about the IP from ProxyCheck.
#'
#' You can specify values for any additional query flags via `...`.
#' The package will be updated as the [supported flags](https://proxycheck.io/api/#query_flags)
#' change. Current supported query flags are:
#'
#' - `vpn`: (logical) VPN check on the IP Address and present the result to you.
#' - `asn`: (logical) ASN check on the IP Address and present you with the provider name,
#'          ASN, country, country isocode, city (if it's in a city) and lang/long for the IP Address.
#' - `node`: (logical) Will return node within our cluster answered your API call.
#'           This is only really needed for diagnosing problems with our support staff.
#' - `time`: (logical) Will return how long this query took to be answered by our API
#'           excluding network overhead.
#' - `inf`: (logical) When `FALSE` the query will _not_ use the real-time inference engine.
#'          In the absence of this flag or if it's set to `TRUE` we will run the query through
#'          our real-time inference engine.
#' - `risk`: (logical) When `TRUE`, will return the risk score for this IP Address ranging from 0 to 100.
#'           Scores below 33 can be considered low risk while scores between 34 and 66 can
#'           be considered high risk. Addresses with scores above 66 are considered very dangerous.
#' - `port`: (logical) Will return the port number we saw this IP Address operating a proxy server on.
#' - `seen`: (logical) Will return the most recent time we saw this IP Address operating as a proxy server.
#' - `days`: (integer) Will restrict proxy results to between now and the amount of days specified.
#'           For example if you supplied `days=2` we would only check our database for
#'           Proxies that we saw within the past 48 hours. By default without this flag supplied we
#'           search within the past 7 days.
#' - `tag`: (string) The query result will be tagged with the message you supply.
#'
#' @md
#' @param ip an IP address (length 1 character vector)
#' @param ... ProxyCheck API query flage (see Details)
#' @param api_key a ProxyCheck API key (see [proxycheck_api_key()])
#' @author Bob Rudis (bob@@rud.is)
#' @references <https://proxycheck.io/api/#introduction>
#' @export
#' @examples \dontrun{
#' proxycheck("24.63.157.68", asn = TRUE, risk = TRUE)
#' }
proxycheck <- function(ip, ..., api_key = proxycheck_api_key()) {

  ip <- ip[1]

  if (is.na(iptools::ip_classify(ip))) {
    stop("`ip` is not a valid IP address", call.=FALSE)
  }

  params <- list(...)
  param_names <- names(params)

  cts <- table(param_names)
  cts <- names(cts[cts > 1])

  if (length(cts)) {
    stop(
      "Encountered duplicate API parameters: ",
      paste0(sprintf('"%s"', cts), collapse = ", "),
      call.=FALSE
    )
  }

  if (!all(names(params) %in% .valid_proxycheck_params)) {
    params <- params[param_names %in% .valid_proxycheck_params]
    bad_params <- unique(param_names[!(param_names %in% .valid_proxycheck_params)])
    warning(
      "Ignoring invalid API parameters: ",
      paste0(sprintf('"%s"', bad_params), collapse = ", "),
      call. = FALSE
    )
  }

  if (length(params[["tag"]])) {
    if (!is.character(params[["tag"]])) {
      stop("`tag` API parameter must be a text string.", call.=FALSE)
    }
  }

  if (length(params[["days"]])) {
    if (!is.integer(params[["days"]])) {
      stop("`days` API parameter must be an integer.", call.=FALSE)
    }
  }

  bool_params <- params[c("vpn", "asn", "node", "time", "inf", "risk", "port", "seen")]
  bool_params <- Filter(Negate(is.null), bool_params)

  if (length(bool_params)) {
    notlog <- vapply(bool_params, FUN = is.logical, logical(1), USE.NAMES = TRUE)
    notlog <- names(notlog[!notlog])
    if (length(notlog)) {
      stop(
        "Invalid values (must be logical) for: ",
        paste0(sprintf('"%s"', notlog), collapse = ", "),
        call.=FALSE
      )
    }
  }

  for (bp in c("vpn", "asn", "node", "time", "inf", "risk", "port", "seen")) {
    if (length(params[[bp]])) params[[bp]] <- as.integer(params[[bp]])
  }

  params[["key"]] <- api_key

  httr::GET(
    url = sprintf("https://proxycheck.io/v2/%s", ip),
    query = params,
    .RIP_UA
  ) -> res

  httr::stop_for_status(res)

  out <- httr::content(res, as = "text", encoding = "UTF-8")
  out <- jsonlite::fromJSON(out)

  out

}
