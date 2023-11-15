#' Create  MS2Soft stations list basefile
#'
#' Creates a stations list that can be used to fill with stations metadata
#' @param path path to the stations list file, usually left as default if using
#' recomended folder structure
#' @returns An excel file containing the columns required for the analysis
# Export this function
#' @export
#'
ms2_stationsCols <- function(path = "inputs/stations_list.xlsx") {

  names <- c("Loc_ID", "County", "Community", "Functional_Class", "Rural_Urban",
             "On", "Latitude", "Longitude",
             "Latest_Date", "start_year", "end_year", "type",
             "Bridge_vicinity", "dir_id")

  stations_list <- data.frame(matrix(ncol = 14, nrow = 0))

  colnames(stations_list) <- names

  openxlsx::write.xlsx(stations_list, path)

}
