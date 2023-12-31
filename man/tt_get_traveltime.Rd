% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tt_get_traveltime.R
\name{tt_get_traveltime}
\alias{tt_get_traveltime}
\title{Get travel time data from Google Maps Directions API}
\usage{
tt_get_traveltime(
  points,
  tod_list,
  key,
  name_col = "Name",
  route_col = "Route"
)
}
\arguments{
\item{points}{Points special features object with a Name column identifying
each point and a Route column to identify each route, leg or direction}

\item{tod_list}{TOD list containing a TOD column describing each TOD or the
equivalencies of TODs by hour.}

\item{key}{Google API key}

\item{name_col}{How the ID column is called, if used the \code{tt_gather_points()}
function, defaults to "Name"}

\item{route_col}{How the Route column is called, if used the \code{tt_gather_points()}
function, defaults to "Route"}
}
\value{
A special features object with the travel time results as geographic
lines. Travel times are returned in minutes, distance in miles and speed in
miles per hour.
}
\description{
Use Google Maps Directions API and the mapsapi package to directly get
segment travel times
}
