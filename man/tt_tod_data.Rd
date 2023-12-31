% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tt_tod_data.R
\name{tt_tod_data}
\alias{tt_tod_data}
\title{Creates a dataframe with TOD data and hours}
\usage{
tt_tod_data(tods, hours, table_path, sheet = "TOD")
}
\arguments{
\item{tods}{Vector containing all TODs}

\item{hours}{Vector of hours created by the \code{tt_hours_vector()} function}

\item{table_path}{Excel sheet containing both TOD and Time columns}

\item{sheet}{Name of sheet containing the TOD table}
}
\value{
A dataframe with columns \code{TOD} and \code{Time}
}
\description{
Creates a dataframe with TOD data and hours by either declaring the TOD and
Time variables or by importing a table with the required structure
}
\examples{
tods <- c("AM1", "AM2", "AM3", "MD1" ,"PM1")
hours <- tt_hours_vector(Sys.Date()+1, c(2, 4, 8, 12, 14))
tod_list <- tt_tod_data(tods, hours)
}
