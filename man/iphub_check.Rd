% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/iphub-check.R
\name{iphub_check}
\alias{iphub_check}
\title{Retrieve IP address metadata from IPHub}
\usage{
iphub_check(ip, api_key = iphub_api_key())
}
\arguments{
\item{ip}{an IP address (length 1 character vector)}

\item{api_key}{an IPHub API key (see \code{\link[=iphub_api_key]{iphub_api_key()}})}
}
\description{
Retrieve IP address metadata from IPHub
}
\examples{
\dontrun{
iphub_check("24.63.157.68")
}
}
\references{
\url{https://iphub.info/api}
}
\author{
Bob Rudis (bob@rud.is)
}
