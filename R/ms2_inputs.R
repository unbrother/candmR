#' Create  MS2Soft attributes and class input file
#'
#' Creates an input file with attributes and class equivalencies table.
#' Attributes and class table can be defined as arguments or the file can be
#' made empty to fill out later
#' @param path path to the stations list file, usually left as default if using
#' recomended folder structure
#' @param fill Defaults to FALSE, to produce an empty input file
#' @param state The US State from where to download data
#' @param analysis_type The analysis type between `perm`, `class` and
#' `short`
#' @param start_year The starting year for the analysis
#' @param end_year The endind year for the analysis
#' @param downloads_folder The path to the downloads folder
#' @param dot The department of transportation acronym corresponding to the
#' platform being consulted
#' @param main_url The core URL used to host the main page of the platform
#' @param offset The offset parameter from the URL when consulted as frames
#' @param a The a parameter from the URL when consulted as frames
#' @param class_ids The classifications IDs given to classified traffic data
#' @param reclass Reclassification names, use `class_ids` if no reclassification
#' is needed
#' @returns An excel file containing the columns required for the analysis
# Export this function
#' @export
#'
ms2_inputs <- function(path = "inputs/input_file.xlsx",
                       fill = FALSE,
                       state = NULL,
                       analysis_type = NULL,
                       start_year = NULL,
                       end_year = NULL,
                       downloads_folder = NULL,
                       dot = NULL,
                       main_url = NULL,
                       offset = NULL,
                       a = NULL,
                       class_ids, reclass) {

  if (fill == TRUE) {

    attr_table <- data.frame(attribute = c("state",
                             "analysis_type",
                             "start_year",
                             "end_year",
                             "downloads_folder",
                             "dot",
                             "main_url",
                             "offset",
                             "a"),
               value = c(state,
                         analysis_type,
                         start_year,
                         end_year,
                         downloads_folder,
                         dot,
                         main_url,
                         offset,
                         a))

    class_table <- data.frame(ID = class_ids,
                              class1 = reclass)

  }

  attr_table <- data.frame(attribute = c("state",
                           "analysis_type",
                           "start_year",
                           "end_year",
                           "downloads_folder",
                           "dot",
                           "main_url",
                           "offset",
                           "a"),
             value = c(NA,
                       NA,
                       NA,
                       NA,
                       NA,
                       NA,
                       NA,
                       NA,
                       NA))

  class_table <- data.frame(ID = NA,
                            class1 = NA)

  wb <- openxlsx::createWorkbook("n")

  openxlsx::addWorksheet(wb, "attributes")
  openxlsx::addWorksheet(wb, "class_table")

  openxlsx::writeData(wb, sheet = 1, attr_table)
  openxlsx::writeData(wb, sheet = 2, class_table)

  openxlsx::saveWorkbook(wb, file = path, overwrite = TRUE)

}
