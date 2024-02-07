#' Get traffic data for a given station
#'
#' Downloads data of the types for analysis types permanent, short term or classification
#' and stores files in a `stations/` folder within the working directory.
#' @param station The station ID for which the data will be requested
#' @param date The date in DD/MM/YYY format as read by the URL
#' @param main_url The main URL, can be omitted if declaring the attribute table
#' @param analysis_type The type of analysis to be performed, between
#' class, perm and short
#' @param stations_list The dataframe containing the stations to be consulted.
#' @param attributes Attributes list obtained by the `ms2_attributes()` function
#' @returns Downloaded files within the created stations folder
#' @export
ms2_data <-
  function(station, date,
           main_url,
           analysis_type = c("class", "perm", "short", "speed"),
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

    if (analysis_type == "class") {
      stations <- stations_list[stations_list$type == analysis_type, ]
      direction_id <- stations_list[stations_list$Loc_ID == station, "dir_id"]

      if (direction_id == "aggr") {

        direction_vector <- "aggr"

      } else {

        direction_vector <- c(substr(direction_id, 1, 2), substr(direction_id, 3, 4))

      }

      dir.create("stations", showWarnings = FALSE)
      dir.create("stations/class", showWarnings = FALSE)
      dir.create(paste0("stations/class/",
                        format(as.Date(date,
                                       "%m/%d/%Y"),
                               "%Y")) %>% unique(), showWarnings = FALSE)
      dir.create(paste0(getwd(), "/stations/class/",
                        format(as.Date(date,
                                       "%m/%d/%Y"),
                               "%Y"),
                        "/",
                        station) %>% unique(), showWarnings = FALSE)

      # Creates Selenium driver object
      rd <- RSelenium::rsDriver(browser = "firefox",
                                chromever = NULL)


      # Access the client object
      remDr <- rd$client
      remDr$open()

      # Navigate to the main MS2 site, which allows to keep a session open within
      # their system, preventing timeouts

      remDr$navigate(main_url)

      for (direction in direction_vector) {

        if (length(direction_vector) != 2) {

          url <- paste0("https://", dot,
                        ".public.ms2soft.com/tcds/tcount_gcs.asp?offset=",
                        offset,
                        "&local_id=",
                        station,
                        "&a=",
                        a,
                        "&sdate=",
                        date,
                        "&jump_date=",
                        date,
                        "&classDate=&speedDate=&gapDate=&int=&type=class&count_type=class")

        } else {

          url <- paste0("https://", dot,
                        ".public.ms2soft.com/tcds/tcount_gcs.asp?offset=",
                        offset,
                        "&local_id=",
                        station, "_", direction,
                        "&a=",
                        a,
                        "&sdate=",
                        date,
                        "&jump_date=",
                        date,
                        "&classDate=&speedDate=&gapDate=&int=&type=class&count_type=class")

        }


        # Navigate to the site containing the station by id, direction and date

        remDr$navigate(url)

        Sys.sleep(15)
        tryCatch({
          # Find the element containing the monthly data and click on it to download
          remDr$findElement(using = "css selector",
                            "li:nth-child(4) img")$clickElement()
        }, error = function(e){NA_character_})

        Sys.sleep(15)

        file <- file.info(list.files(dl_path, full.names = T))

        file.copy(rownames(file)[which.max(file$mtime)],
                  paste0("stations/class/",
                         format(as.Date(date,
                                        "%m/%d/%Y"),
                                "%Y"),
                         "/",
                         station))
        file.remove(rownames(file)[which.max(file$mtime)])
      }

    } else if (analysis_type == "perm") {

      stations <- stations_list[stations_list$type == analysis_type, ]
      direction_id <- stations_list[stations_list$Loc_ID == station, "dir_id"]

      if (direction_id == "aggr") {

        direction_vector <- "aggr"

      } else {

        direction_vector <- c(substr(direction_id, 1, 2), substr(direction_id, 3, 4))

      }

      dir.create("stations", showWarnings = FALSE)
      dir.create("stations/perm", showWarnings = FALSE)
      dir.create(paste0("stations/perm/",
                        format(as.Date(date,
                                       "%m/%d/%Y"),
                               "%Y")) %>% unique(), showWarnings = FALSE)
      dir.create(paste0(getwd(), "/stations/perm/",
                        format(as.Date(date,
                                       "%m/%d/%Y"),
                               "%Y"),
                        "/",
                        station) %>% unique(), showWarnings = FALSE)

      # Creates Selenium driver object
      rd <- RSelenium::rsDriver(browser = "firefox",
                                chromever = NULL)

      # Access the client object
      remDr <- rd$client

      remDr$open()

      # Navigate to the main MS2 site, which allows to keep a session open within
      # their system, preventing timeouts

      remDr$navigate(main_url)

      for (direction in direction_vector) {

        if (length(direction_vector) != 2) {

          url <-
            paste0(main_url,
                   "tcount.asp?offset=",
                   offset,
                   "&local_id=",
                   station
                   ,"&a=",
                   a,
                   "&sdate=",
                   date)

        } else {

          url <-
            paste0(main_url,
                   "tcount.asp?offset=",
                   offset,
                   "&local_id=",
                   station,
                   "_",
                   direction,"&a=",
                   a,
                   "&sdate=",
                   date)

        }

        # Navigate to the site containing the station by id, direction and date

        remDr$navigate(url)

        Sys.sleep(15)

        tryCatch({
          # Find the element containing the monthly data and click on it to download
          remDr$findElement(using = "xpath",
                            "//li[(((count(preceding-sibling::*) + 1) = 6) and parent::*)]//a")$clickElement()
        }, error = function(e){NA_character_})

        Sys.sleep(15)

        file <- file.info(list.files(dl_path, full.names = T))

        file.copy(rownames(file)[which.max(file$mtime)],
                  paste0("stations/perm/",
                         format(as.Date(date,
                                        "%m/%d/%Y"),
                                "%Y"),
                         "/",
                         station))

        file.remove(rownames(file)[which.max(file$mtime)])

      }

    } else if (analysis_type == "short") {

      stations <- stations_list[stations_list$type == analysis_type, ]
      direction_id <- stations_list[stations_list$Loc_ID == station, "dir_id"]

      if (direction_id == "aggr") {

        direction_vector <- "aggr"

      } else {

        direction_vector <- c(substr(direction_id, 1, 2), substr(direction_id, 3, 4))

      }

      dir.create("stations", showWarnings = FALSE)
      dir.create("stations/short", showWarnings = FALSE)
      dir.create(paste0("stations/short/",
                        format(as.Date(date,
                                       "%m/%d/%Y"),
                               "%Y")) %>% unique(), showWarnings = FALSE)
      dir.create(paste0(getwd(), "/stations/short/",
                        format(as.Date(date,
                                       "%m/%d/%Y"),
                               "%Y"),
                        "/",
                        station) %>% unique(), showWarnings = FALSE)

      # Creates Selenium driver object

      rd <- RSelenium::rsDriver(browser = "firefox",
                                chromever = NULL)

      # Access the client object

      remDr <- rd$client

      remDr$open()

      # Navigate to the main MS2 site, which allows to keep a session open within
      # their system, preventing timeouts

      remDr$navigate(main_url)

      for (direction in direction_vector) {

        if (length(direction_vector) != 2) {

          url <-
            paste0(main_url,
                   "tcount.asp?offset=",
                   offset,
                   "&local_id=",
                   station,
                   "&a=",
                   a,
                   "&sdate=",
                   date)

        } else {

          url <-
            paste0(main_url,
                   "tcount.asp?offset=",
                   offset,
                   "&local_id=",
                   station,
                   "_",
                   direction,"&a=",
                   a,
                   "&sdate=",
                   date)

        }

        # Navigate to the site containing the station by id, direction and date

        remDr$navigate(url)

        Sys.sleep(15)

        tryCatch({
          # Find the element containing the monthly data and click on it to download
          remDr$findElement(using = "xpath",
                            "//li[(((count(preceding-sibling::*) + 1) = 2) and parent::*)]//a")$clickElement()
        }, error = function(e){NA_character_})

        Sys.sleep(15)

        file <- file.info(list.files(dl_path, full.names = T))

        file.copy(rownames(file)[which.max(file$mtime)],
                  paste0("stations/short/",
                         format(as.Date(date,
                                        "%m/%d/%Y"),
                                "%Y"),
                         "/",
                         station))
        file.remove(rownames(file)[which.max(file$mtime)])

      }

    }

    # Close the connection

    rd$server$stop()

  }
