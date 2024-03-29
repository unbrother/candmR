% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ms2_getlist.R
\name{ms2_getlist}
\alias{ms2_getlist}
\title{Get a list of stations based on search criteria}
\usage{
ms2_getlist(attributes, district = NULL, county = NULL, community = NULL)
}
\arguments{
\item{attributes}{Attributes list obtained by the \code{ms2_attributes} function}

\item{district}{Vector of districts}

\item{county}{Vector of counties}

\item{community}{Vector of communities}
}
\value{
A dataframe containing all stations in a given district, county or
community
}
\description{
Get a list of stations based on search criteria
}
