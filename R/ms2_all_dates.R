#' Get a list of available dates for a set of MS2Soft Stations
#'
#' Download a list of dates in which data is available for the analysis type
#' selected
#' @param main_url The URL of the state MS2Soft platform
#' @param analysis_type The type of analysis to be performed, between
#' class, perm and short
#' @param offset The offset value within the MS2Soft platform URL
#' @param a The "a" value within the MS2Soft platform URL
#' @param quiet Defaults to TRUE, wether to show the downloading progress
#' @param day_type Defines wether only weekdays or weekends are selected. Defaults to all
#' @param sampling Generates a sample of the downloaded data, useful when
#' having too many dates
#' @param sample_weeks Number of weeks to sample from each year
#' @param stations_list The dataframe containing the stations to be consulted,
#' avoids entering the `start_date` and `end_date` and allows for different
#' values across stations. Useful when running multiple stations.
#' @param attributes Attributes list obtained by the `ms2_attributes` function
#' @returns A list of dates when data is available
# Export this function
#' @export
#' @importFrom rlang .data

ms2_all_dates <- function(main_url,
                          analysis_type = c("class", "perm", "short", "speed"),
                          offset, a,
                          quiet = FALSE,
                          day_type = "all",
                          sampling = FALSE,
                          sample_weeks = 1,
                          stations_list,
                          attributes) {

  if (!missing(attributes)) {

    analysis_type = attributes[["analysis_type"]]
    main_url = attributes[["main_url"]]
    dl_path = attributes[["dl_path"]]
    dot = attributes[["dot"]]
    offset = attributes[["offset"]]
    a = attributes[["a"]]

  }

  stations_vector <- stations_list[stations_list$type == analysis_type,] %>% .$Loc_ID

  dates_list <- list()

  for (station in stations_vector) {

    dates_vector <- ms2_dates(main_url = main_url,
                              analysis_type = analysis_type,
                              offset = offset, a = a,
                              station = station, quiet = quiet,
                              day_type = day_type, sampling = sampling,
                              stations_list = stations_list)

    dates_list[[station]] <- dates_vector

  }

  return(dates_list)

}
