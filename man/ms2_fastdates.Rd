% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ms2_fastdates.R
\name{ms2_fastdates}
\alias{ms2_fastdates}
\title{Get data from the main station names}
\usage{
ms2_fastdates(
  attributes,
  district = NULL,
  county = NULL,
  community = NULL,
  stations_list
)
}
\arguments{
\item{attributes}{Attributes list obtained by the \code{ms2_attributes} function}

\item{district}{Vector of districts}

\item{county}{Vector of counties}

\item{community}{Vector of communities}

\item{stations_list}{The dataframe containing the stations to be consulted,
can also be a vector containing the stations' location IDs}
}
\value{
A dataframe containing all stations in a given district, county or
community
}
\description{
Get yearly volumes or dates for volume only or classification data for non
permanent stations. For permanent stations, use \strong{ms2_all_dates}
}
