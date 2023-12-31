% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ms2_readStations.R
\name{ms2_readStations}
\alias{ms2_readStations}
\title{Import MS2Soft stations list}
\usage{
ms2_readStations(path = "inputs/stations_list.xlsx")
}
\arguments{
\item{path}{path to the stations list file, usually left as default if using
recomended folder structure}
}
\value{
A dataframe containing the stations
}
\description{
Imports the stations list from an input file containing the metadata required
to download data
}
