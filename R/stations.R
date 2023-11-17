#' Stations input data table
#'
#' Stations list containing several statiions with different analysis types to
#' select from

#' @format Data frame with 7 observations and 14 columns

#' \describe{
#' \item{Loc_ID}{Location ID}
#' \item{County}{Station's county}
#' \item{Community}{Station's community}
#' \item{Functional_Class}{Functional class of the road where the station is located}
#' \item{Rural_Urban}{Urban or Rural environment for the station}
#' \item{On}{Road name where the station is located}
#' \item{Latitude}{Station's Latitude}
#' \item{Longitude}{Station's Longitude}
#' \item{Latest_Date}{Most recent date with traffic data}
#' \item{start_year}{First year for data request}
#' \item{end_year}{Last year for data request}
#' \item{type}{Analysis type to be performed on the station}
#' \item{Bridge_vicinity}{Closest international bridge to the station}
#' \item{dir_id}{Directions string containing both directions}
#' }

#' @examples
#' stations
"stations"
