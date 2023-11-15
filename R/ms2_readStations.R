#' Import MS2Soft stations list
#'
#' Imports the stations list from an input file containing the metadata required
#' to download data
#' @param path path to the stations list file, usually left as default if using
#' recomended folder structure
#' @returns A dataframe containing the stations
# Export this function
#' @export
#'
ms2_readStations <-
  function(path = "inputs/stations_list.xlsx"){
    readxl::read_excel(path,
                       col_types = c("text", "text", "text",
                                     "text", "text", "text",
                                     "numeric", "numeric", "date",
                                     "numeric", "numeric",
                                     "text", "text", "text"))
  }
