% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/platforms.R
\docType{data}
\name{platforms}
\alias{platforms}
\title{Registered platforms}
\format{
Dataframe with 3 observations of 5 variables
\describe{
\item{state}{US State}
\item{dot}{Department of Transportation acronym for the given US State}
\item{main_url}{The Home URL for the platform, usually composed by the \code{dot} + "public.ms2soft.com/tcds/"}
\item{offset_value}{The offset value for that platform}
\item{a_value}{The a value for that platform}
}
}
\usage{
platforms
}
\description{
Database containing platforms that have been registered and checked to work
with this package.
A platform is the name given to each of the MS2Soft portal available by US
State
}
\examples{
platforms
}
\keyword{datasets}
