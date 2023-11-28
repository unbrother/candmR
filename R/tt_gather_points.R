#' Imports points from spatial data
#'
#' Used to import points in a geographic format. Requires an excel file containing
#' a sheet with point details, including a joining code between the spatial file
#' and the details.
#' @param points_path System path containing the points spatial data
#' @param details_path System path directing to the file containing the points
#' details or descriptions
#' @param sheet Sheet within the details file containing the point details,
#' defaults to "PointDetails"
#' @returns A special features object with the points for all routes that will
#' be queried
#' @export
#'
tt_gather_points <- function(points_path, details_path, sheet = "PointDetails") {

  points <- sf::st_read(points_path)

  point_details <- readxl::read_excel(details_path, sheet = sheet)

  all_points <- dplyr::left_join(points, point_details, by = c("Name" = "Code"))

  return(all_points)

}
