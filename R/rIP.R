#'Detects Fraud in Online Surveys by Tracing, Scoring, and Visualizing IP Addresses
#'
#'Cleans and processes an array of IP address data and, using keys for several IP check services, passes these data to the needed APIs. Returns visual and numerical information on the IP address, including the internet service provider (ISP) and whether it is likely a server farm being used to disguise a respondent's location.
#'@usage getIPinfo(d, "i", "iphub_key", "ipintel_key", "proxycheck_key", plots = TRUE)
#'@param d Data frame where IP addresses are stored
#'@param i Name of the vector in data frame, d, corresponding to IP addresses in quotation marks
#'@param iphub_key User's IP Hub X-key in quotation marks
#'@param ipintel_key User's email address (used as key for getipintel.net) in quotation marks
#'@param proxycheck_key User's API key for proxycheck.io in quotation marks
#'@param plots Logical argument. If TRUE, produces a barplot of potentially suspicious IP addresses. Default is TRUE.
#'@details Takes an array of IPs and the keys for the services the user wishes to use (IP Hub, IP Intel, and Proxycheck), and passes these to all respective APIs. Returns a dataframe with the IP addresses (used for merging), country, ISP, labels for non-US IP Addresses, VPS use, and recommendations for blocking. The function also provides optional visualization tools for checking the distributions.
#'@return ipDF A dataframe with the IP address, country code, country name, asn, isp, block, and hostname.
#'@note Users must have active accounts and/or valid keys at iphub, ipintel, and/or proxycheck.
#'@examples
#'\dontrun{
#'ip_hub_key <- "MzI2MTpkOVpld3pZTVg1VmdTV3ZPenpzMmhopIMkRMZQ=="
#'ipintel_key <- "useremailaddress"
#'proxycheck_key <- "MzI2MTpkOVpld3pZTVg1VmdTV3ZPenpzMmhod"
#'ipsample <- data.frame(rbind(c(1, "189.8.105.146"), c(2, "148.233.134.248")))
#'names(ipsample) <- c("number", "IPAddress")
#'getIPinfo(ipsample, "IPAddress", ip_hub_key, ipintel_key, proxycheck_key)
#'}
#'@export
getIPinfo <- function(d, i, iphub_key, ipintel_key, proxycheck_key, plots = TRUE){
  if(!requireNamespace("httr", quietly = TRUE)) {
    stop("Package \"httr\" needed for this function to work. Please install it.",
         call. = FALSE)
  }
  if(!requireNamespace("utils", quietly = TRUE)) {
    stop("Package \"utils\" needed for this function to work. Please install it.",
         call. = FALSE)
  }
  if(!requireNamespace("iptools", quietly = TRUE)) {
    stop("Package \"iptools\" needed for this function to work. Please install it.",
         call. = FALSE)
  }
  if(!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Package \"dplyr\" needed for this function to work. Please install it.",
         call. = FALSE)
  }
  #message("* Consider storing the ipDF as an object to write as an external df, e.g., write.csv(ipDF, 'ipDF.csv')")
  if (!is.data.frame(d)) warning("d must be a 'data.frame' object: Try 'as.data.frame(d)'")
  ips <- unique(d[ , i])
  options(stringsAsFactors = FALSE)
  iphub_url <- "http://v2.api.iphub.info/ip/"
  ipintel_url <- "http://check.getipintel.net/check.php?ip="
  proxycheck_url <- "http://proxycheck.io/v2/"
  pb <- utils::txtProgressBar(min = 0, max = length(ips), style = 3)
  # Check iphub.info
  iphubDF <- c()
  if (!is.na(iphub_key)) {
    cat(paste("Getting IP Hub information."))
    pb <- utils::txtProgressBar(min = 0, max = length(ips), style = 3)
    for (i in 1:length(ips)) {
      if (is.na(iptools::ip_classify(ips[i])) | iptools::ip_classify(ips[i]) == "invalid") {
        warning(paste0("Warning: An invalid or missing IP address was detected on line ", i, ". Please check this."))
        next
      }
      ipInfo <- httr::GET(paste0(iphub_url, ips[i]), httr::add_headers(`X-Key` = iphub_key))
      infoVector <- unlist(httr::content(ipInfo))
      iphubDF <- rbind(iphubDF, infoVector)
      utils::setTxtProgressBar(pb, i)
    }
    close(pb)
    rownames(iphubDF) <- NULL
    iphubDF <- data.frame(iphubDF)
    iphubDF <- subset(iphubDF, select = c("ip", "countryCode", "isp", "block"))
    iphubDF$IP_Hub_nonUSIP <- ifelse(iphubDF$countryCode != "US", 1, 0)
    iphubDF$IP_Hub_VPS <- ifelse(iphubDF$block == "1", 1, 0)
    iphubDF$IP_Hub_recommend_block <- ifelse(iphubDF$IP_Hub_nonUSIP == 1 |
                                               iphubDF$IP_Hub_VPS == 1, 1, 0)
    if (plots == TRUE) {
      iphubDF$plot_var <- ifelse(iphubDF$IP_Hub_nonUSIP == 1, "Not US",
                                 ifelse(iphubDF$IP_Hub_VPS == 1, "VPS",
                                        "Clean"))
      tablePlot <- table(iphubDF$plot_var)
      graphics::barplot(tablePlot, main = "IP Hub", xlab = "Abberation detection",
              ylab = "Frequency")
      iphubDF$plot_var <- NULL
    }
    iphubDF$block <- NULL
    names(iphubDF)[1:3] <- c("IPAddress", "IP_Hub_Country_Code", "IP_Hub_ISP")
  }else {
    iphubDF <- data.frame(ips)
    names(iphubDF) <- "IPAddress"}
  # Check getipinfo.net
  ipintelDF <- c()
  if (!is.na(ipintel_key)) {
    cat(paste("Getting GetIPIntel.net information."))
    pb <- utils::txtProgressBar(min = 0, max = length(ips), style = 3)
    for (i in 1:length(ips)) {
      if (is.na(iptools::ip_classify(ips[i])) | iptools::ip_classify(ips[i]) == "invalid") {
        warning(paste0("Warning: An invalid or missing IP address was detected on line ", i, ". Please check this."))
        next
      }
      ipInfo <- httr::GET(paste0(ipintel_url, ips[i], "&contact=", ipintel_key,
                                 "&flags=f&oflags=c&format=json"))
      infoVector <- unlist(httr::content(ipInfo))
      ipintelDF <- rbind(ipintelDF, infoVector)
      utils::setTxtProgressBar(pb, i)
    }
    close(pb)
    rownames(ipintelDF) <- NULL
    ipintelDF <- data.frame(ipintelDF)
    ipintelDF <- subset(ipintelDF, select = c("queryIP", "Country", "result"))
    ipintelDF$IP_Intel_nonUSIP <- ifelse(ipintelDF$Country != "US", 1, 0)
    ipintelDF$IP_Intel_VPS <- ifelse(ipintelDF$result == "1", 1, 0)
    ipintelDF$IP_Intel_recommend_block <- ifelse(ipintelDF$IP_Intel_nonUSIP == 1 |
                                                   ipintelDF$IP_Intel_VPS == 1, 1, 0)
    if (plots == TRUE) {
      ipintelDF$plot_var <- ifelse(ipintelDF$IP_Intel_nonUSIP == 1, "Not US",
                                   ifelse(ipintelDF$IP_Intel_VPS == 1, "VPS",
                                          "Clean"))
      tablePlot <- table(ipintelDF$plot_var)
      graphics::barplot(tablePlot, main = "IP Intel", xlab = "Abberation detection",
              ylab = "Frequency")
      ipintelDF$plot_var <- NULL
    }
    names(ipintelDF)[1:3] <- c("IPAddress", "IP_Info_Country_Code", "IP_Info_ISP")
  }else {
    ipintelDF <- data.frame(ips)
    names(ipintelDF) <- "IPAddress"}
  # Check proxycheck.io
  proxycheckDF <- c()
  if (!is.na(proxycheck_key)) {
    cat(paste("Getting proxycheck.io information."))
    pb <- utils::txtProgressBar(min = 0, max = length(ips), style = 3)
    for (i in 1:length(ips)) {
      if (is.na(iptools::ip_classify(ips[i])) | iptools::ip_classify(ips[i]) == "invalid") {
        warning(paste0("Warning: An invalid or missing IP address was detected on line ", i, ". Please check this."))
        next
      }
      ipInfo <- httr::GET(paste0(proxycheck_url, ips[i], "&key=", proxycheck_key,
                                 "&vpn=1&asn=1&days=365"))
      infoVector <- unlist(httr::content(ipInfo))
      infoVector <- as.array(infoVector)
      names(infoVector) <- sub("[^[:alpha:]]+", "", names(infoVector))
      infoVector <- c(ips[i], infoVector)
      names(infoVector)[1] <- "IPAddress"
      proxycheckDF <- dplyr::bind_rows(proxycheckDF, infoVector)
      utils::setTxtProgressBar(pb, i)
    }
    close(pb)
    rownames(proxycheckDF) <- NULL
    proxycheckDF <- data.frame(proxycheckDF)
    proxycheckDF <- subset(proxycheckDF, select = c("IPAddress", "isocode", "provider", "proxy"))
    proxycheckDF$Proxycheck_nonUSIP <- ifelse(proxycheckDF$isocode != "US", 1, 0)
    proxycheckDF$Proxycheck_VPS <- ifelse(proxycheckDF$proxy == "yes", 1, 0)
    proxycheckDF$Proxycheck_recommend_block <- ifelse(proxycheckDF$Proxycheck_nonUSIP == 1 |
                                                        proxycheckDF$Proxycheck_VPS == 1, 1, 0)
    if (plots == TRUE) {
      proxycheckDF$plot_var <- ifelse(proxycheckDF$Proxycheck_nonUSIP == 1, "Not US",
                                      ifelse(proxycheckDF$Proxycheck_VPS == 1, "VPS",
                                             "Clean"))
      tablePlot <- table(proxycheckDF$plot_var)
      graphics::barplot(tablePlot, main = "Proxycheck", xlab = "Abberation detection",
              ylab = "Frequency")
      proxycheckDF$plot_var <- NULL
    }
    proxycheckDF$proxy <- NULL
    names(proxycheckDF)[2:3] <- c("Proxycheck_Country_Code", "Proxycheck_ISP")
  } else {
    proxycheckDF <- data.frame(ips)
    names(proxycheckDF) <- "IPAddress"}
  fullDF <- merge(iphubDF, ipintelDF, by = "IPAddress")
  fullDF <- merge(fullDF, proxycheckDF, by = "IPAddress")
  return(fullDF)
}
