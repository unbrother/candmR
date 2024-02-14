#' Get traffic data for all stations in the stations list file
#'
#' Get traffic data for all stations in the stations list file, downloads data and stores files in a
#' `stations/` folder within the working directory.
#' Downloads traffic data of the types  permanent, short term or classification
#' @param dates_list The dates list obtained with the `ms2_all_data` function
#' @param main_url The main URL, can be omitted if declaring the attribute table
#' @param analysis_type The type of analysis to be performed, between
#' class, perm and short
#' @param stations_list The dataframe containing the stations to be consulted.
#' @param attributes Attributes list obtained by the `ms2_attributes` function
#' @returns Downloaded files within the created stations folder
#' @export
#' @importFrom rlang .data

ms2_all_data <- function(dates_list,
                         main_url,
                         analysis_type = c("class", "perm", "short", "speed"),
                         stations_list, attributes) {

  if (!missing(attributes)) {

    analysis_type = attributes[["analysis_type"]]
    main_url = attributes[["main_url"]]

  }

  stations_type <- stations_list[stations_list$type == analysis_type,]
  stations_vector <- names(dates_list)

  for (station in stations_vector) {

    dates <- dates_list[[station]]

    for (date in dates) {

      ms2_data(station = station,
               date = date,
               main_url = main_url,
               stations_list = stations_list,
               attributes = attributes)

      paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " Finished data download for station: ", station, " for year: ", year)

    }

    log_message <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " Finished data download for station: ", station)

    print(log_message)

    write.table(log_message,
                file = "TEMP/log_data.csv", col.names = FALSE, row.names = FALSE, append = TRUE)


  }

}
