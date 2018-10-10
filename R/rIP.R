#' Passes an array of IP addresses to iphub.info and returns a dataframe with details of IP
#'
#' Makes a call to an IP address verification service (iphub.info) that returns the information on the IP address, including the internet service provider (ISP) and whether it is likely a server farm being used to disguise a respondent's location.
#'@usage getIPinfo(d, "i", "key")
#'@param d Data frame where IP addresses are stored
#'@param i Name of the vector in data frame, d, corresponding to IP addresses in quotation marks
#'@param key User's X-key in quotation marks
#'@details Takes an array of IPs and the user's X-Key, and passes these to iphub.info. Returns a dataframe with the IP address (used for merging), country code, country name, asn, isp, block, and hostname.
#'@return ipDF A dataframe with the IP address, country code, country name, asn, isp, block, and hostname.
#'@note Users must have an active iphub.info account with a valid X-key.
#'@examples
#'id <- c(1,2,3,4) # fake respondent id's
#'ips <- c(123.232, 213.435, 234.764, 543.765) # fake ips
#'data <- data.frame(id,ips)
#'getIPinfo(data, "ips", "MzI3NDpJcVJKSTdIdXpQSUJLQVhZY1RvRxaXFsFW3jS3xcQ")
#'@export
getIPinfo <- function(d, i, key){
  if (!requireNamespace("httr", quietly = TRUE)) {
    stop("Package \"httr\" needed for this function to work. Please install it.",
         call. = FALSE)
  }
  if (!requireNamespace("utils", quietly = TRUE)) {
    stop("Package \"utils\" needed for this function to work. Please install it.",
         call. = FALSE)
  }
  message("* Consider storing the ipDF as an object to write as an external df, e.g., write.csv(ipDF, 'ipDF.csv')")
  ips <- unique(d[ ,i])
  options(stringsAsFactors = FALSE)
  url <- "http://v2.api.iphub.info/ip/"
  pb <- utils::txtProgressBar(min = 0, max = length(ips), style = 3)
  ipDF <- c()
  for (i in 1:length(ips)) {
    ipInfo <- httr::GET(paste0(url, ips[i]), httr::add_headers(`X-Key` = key))
    infoVector <- unlist(httr::content(ipInfo))
    ipDF <- rbind(ipDF, infoVector)
    utils::setTxtProgressBar(pb, i)
  }
  close(pb)
  rownames(ipDF) <- NULL
  ipDF <- data.frame(ipDF)

  return(ipDF)
}
