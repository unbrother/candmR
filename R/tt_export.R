#' Export Google Travel Results
#'
#' Export results obtained from travel time requests as dataframe or
#' shapefile obtained with `tt_travel_time()`. Or travel time, speed or distance
#' matrices obtained with `tt_matric()`.
#' @param x Dataframe obtained from `tt_travel_time()` or list of matrices obtained
#' with `tt_matrix`
#' @param file_name Full file name including path and extension
#' @param type Type of data for the exported file, either "matrix", "dataframe"
#' or "shp"
#' @export
#'
tt_export <- function(x, file_name, type) {

  if (type == "matrix") {

    wb <- openxlsx::createWorkbook("n")

    for (elem in 1:length(x)) {

      exp_table <- x[[elem]]

      openxlsx::addWorksheet(wb, paste0("R", elem))
      openxlsx::writeData(wb, sheet = paste0("R", elem), exp_table)

    }

    openxlsx::saveWorkbook(wb, file = file_name, overwrite = TRUE)

  } else if (type == "dataframe") {

    df <- x %>% sf::st_drop_geometry()

    wb <- openxlsx::createWorkbook("n")

    openxlsx::addWorksheet(wb, "Data")
    openxlsx::writeData(wb, sheet = "Data", df)

    openxlsx::saveWorkbook(wb, file = file_name, overwrite = TRUE)

  } else if (type == "shp") {

    x <- x %>%
      dplyr::mutate(departure_time = lubridate::ymd_hms(departure_time) %>%
                      as.character(),
                    dep_hour = lubridate::hour(departure_time)) %>%
      dplyr::select(alternative_id, leg_id, summary, distance_m, distance_text,
                    duration_s, duration_text, duration_in_traffic_s,
                    duration_in_traffic_text, departure_time, dep_hour,
                    arrival_time, TOD,
                    route, Code, travel_time, distance, speed)

    colnames(x) <- c("alt_id", "leg_id", "summary",
                     "dist_m", "dist_txt", "dur_s", "dur_txt",
                     "d_tr_s", "d_tr_txt", "dep_time", "dep_hour",
                     "arr_time", "TOD", "route", "Code", "traveltime", "dist",
                     "speed", "geometry")

    sf::st_write(x, file_name, append = FALSE)

  }

}
