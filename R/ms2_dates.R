#' Get a vector of available dates for an MS2Soft Station
#'
#' Creates a vector containing all available dates within the time range given
#' between `start_date` and `end_date` in years
#' @param station The station ID for which the data will be requested
#' @param main_url The URL of the state MS2Soft platform
#' @param analysis_type The type of analysis to be performed, between
#' class, perm and short
#' @param offset The offset value within the MS2Soft platform URL
#' @param a The "a" value within the MS2Soft platform URL
#' @param start_date The starting year for the request
#' @param end_date The final year to be requested
#' @param quiet Defaults to TRUE, wether to show the downloading progress
#' @param day_type Defines wether only weekdays or weekends are selected
#' @param sampling Generates a sample of the downloaded data, useful when
#' having too many dates
#' @param sample_weeks Number of weeks to sample from each year
#' @param stations_list The dataframe containing the stations to be consulted,
#' avoids entering the `start_date` and `end_date` and allows for different
#' values across stations. Useful when running multiple stations.
#' @param attributes Attributes list obtained by the `ms2_attributes()` function
#' @returns A vector of dates when data is available
# Export this function
#' @export
#'
ms2_dates <-
  function(station = NULL, main_url = NULL, analysis_type = NULL,
           offset = NULL, a, start_date = NULL, end_date = NULL, quiet = TRUE,
           day_type = "all", sampling = TRUE,
           sample_weeks = 1, stations_list, attributes) {

    if (!missing(stations_list)) {
      start_date <- paste0(stations_list[stations_list$type == analysis_type & stations_list$Loc_ID == station,
                                         "start_year"] %>%
                             dplyr::pull(),
                           "-01-01") %>%
        as.Date()
      end_date <- paste0(stations_list[stations_list$type == analysis_type & stations_list$Loc_ID == station,
                                       "end_year"] %>%
                           dplyr::pull(), "-12-31") %>%
        as.Date()
    }

    if (!missing(attributes)) {

      analysis_type = attributes[["analysis_type"]]
      main_url = attributes[["main_url"]]
      dl_path = attributes[["dl_path"]]
      dot = attributes[["dot"]]
      offset = attributes[["offset"]]
      a = attributes[["a"]]

    }

    # Create vector of all days between starting and ending dates
    dates_check <- seq(start_date, end_date, by = "1 day")

    # Format dates to url style
    days_of_year <- format(dates_check, format = "%m/%d/%Y")

    # Creates Selenium driver object
    rd <- RSelenium::rsDriver(browser = "firefox",
                              chromever = NULL)
    # Access the client object
    remDr <- rd$client

    remDr$open()

    # Navigate to the main MS2 site, which allows to keep a session open within
    # their system, preventing timeouts
    remDr$navigate(main_url)

    # Empty dataframe of available dates
    available_dates <- data.frame()

    # Loop
    for (day in days_of_year) {

      if (quiet == FALSE) {

        print(paste0("Working on station: ", station, " at ", day))

      }

      if (analysis_type == "class") {

        url <- paste0(main_url,
                      "tcount_gcs.asp?offset=",
                      offset,
                      "&local_id=",
                      station,
                      "&a=",
                      a,
                      "&sdate=",
                      day,
                      "&jump_date=",
                      day,
                      "&classDate=&speedDate=&gapDate=&int=&type=class&count_type=class")

        remDr$navigate(url)

        available <- tryCatch({

          remDr$findElement(using = "css selector",
                            ".frmDtl tr:nth-child(3) td:nth-child(2)")$getElementText()[[1]]
        }, error = function(e){NA_character_})

        available_dates <- rbind(available_dates, cbind(available, day))

      } else if (analysis_type == "perm") {

        url <-
          paste0(main_url,
                 "tcount.asp?offset=",
                 offset,
                 "&local_id=",
                 station,
                 "&a=",
                 a,
                 "&sdate=",
                 day)

        # Navigate to the site containing the station by id, direction and date

        remDr$navigate(url)

        available <- tryCatch({

          suppressMessages({
            remDr$findElement(using = "css selector",
                              ".frmDtl+ .frmDtl tr:nth-child(4) td")$getElementText()[[1]]
          })}, error = function(e){NA_character_})

        available_dates <- rbind(available_dates, cbind(available, day))

      } else if (analysis_type == "short") {

        url <-
          paste0(main_url,
                 "tcount.asp?offset=",
                 offset,
                 "&local_id=",
                 station,
                 "&a=",
                 a,
                 "&sdate=",
                 day)

        # Navigate to the site containing the station by id, direction and date

        remDr$navigate(url)

        available <- tryCatch({

          suppressMessages({
            remDr$findElement(using = "css selector",
                              ".frmDtl+ .frmDtl tr:nth-child(4) td")$getElementText()[[1]]
          })}, error = function(e){NA_character_})

        available_dates <- rbind(available_dates, cbind(available, day))

      }

    }

    rd$server$stop()

    available_dates <- available_dates %>% dplyr::filter(available != " ")

    if (analysis_type %in% c("short", "class")) {

      if (day_type == "weekday") {

        available_dates <- available_dates %>%
          dplyr::mutate(weekday = weekdays(as.Date(day, "%m/%d/%Y"))) %>%
          dplyr::filter(weekday %in% c("Tuesday", "Wednesday", "Thursday"))

      } else if (day_type == "weekend") {

        available_dates <- available_dates %>%
          dplyr::mutate(weekday = weekdays(as.Date(day, "%m/%d/%Y"))) %>%
          dplyr::filter(weekday %in% c("Saturday", "Sunday"))

      } else if (day_type == "all") {

        available_dates <- available_dates %>%
          dplyr::mutate(weekday = weekdays(as.Date(day, "%m/%d/%Y")))

      }

    } else if (analysis_type == "perm") {

      available_dates <- available_dates %>%
        dplyr::filter(!is.na(available)) %>%
        dplyr::mutate(ym = paste(lubridate::year(lubridate::mdy(day)), lubridate::month(lubridate::mdy(day))),
                      year = paste(lubridate::year(lubridate::mdy(day))),
                      month = lubridate::month(lubridate::mdy(day)) %>% as.numeric()) %>%
        dplyr::group_by(ym) %>%
        dplyr::slice_head(n = 1) %>%
        dplyr::arrange(year, month)

    }

    if (sampling == TRUE) {

      mean <- available_dates %>%

        dplyr:: mutate(month = lubridate::month(as.Date(day, "%m/%d/%Y")),
                       year = lubridate::year(as.Date(day, "%m/%d/%Y"))) %>%
        dplyr::group_by(year) %>% dplyr::summarise(sum = dplyr::n()) %>%
        dplyr::ungroup() %>%
        dplyr::summarise(mean = mean(sum)) %>% dplyr::pull()

      if (mean > 48) {

        available_dates <- available_dates %>%
          dplyr::mutate(month = lubridate::month(as.Date(day, "%m/%d/%Y")),
                        year = lubridate::year(as.Date(day, "%m/%d/%Y"))) %>%
          dplyr::group_by(year, month, weekday) %>% dplyr::slice_sample(n = sample_weeks)

      }

    }

    return(dates_vector <- available_dates$day)

  }
