#' @export

# rIP function

getIPinfo <- function(ips, key) {
  options(stringsAsFactors = FALSE)
  url <- "http://v2.api.iphub.info/ip/"
  pb <- txtProgressBar(min = 0, max = length(ips), style = 3)
  ipDF <- c()
  for (i in 1:length(ips)) {
    ipInfo <- httr::GET(paste0(url, ips[i]), httr::add_headers(`X-Key` = key))
    infoVector <- unlist(httr::content(ipInfo))
    ipDF <- rbind(ipDF, infoVector)
    setTxtProgressBar(pb, i)
  }
  close(pb)
  rownames(ipDF) <- NULL
  ipDF <- data.frame(ipDF)
  return(ipDF)
}
