#' Create a database from files downloaded
#'
#' Imports data stored in the stations folder and arranges it into a dataframe
#' @param analysis_type The type of analysis to be performed, between
#' class, perm and short
#' @param attributes Attributes list obtained by the `ms2_attributes()` function
#' @param class_number Column number for the reclassification table to name
#' columns
#' @param get_interval Defaults to FALSE, extracts total data. If TRUE, extracts
#' data by interval
#' @returns A dataframe containing all traffic data stored in the  `stations/`
#' folder
#' @export
#'

ms2_createdb <-
  function(analysis_type = NULL,
           attributes = attributes,
           class_number,
           get_interval = FALSE) {

    # Check for attributes table, if available, gets analysis type from there,
    # if missing, analysis type has to be set as an argument
    if (!missing(attributes)) {

      analysis_type <-  attributes[["analysis_type"]]

    }

    #### Class Type ####

    if (analysis_type == "class") {

      # Set parameters for class type analysis
      years <- list.files(paste0(getwd(), "/stations/class"))
      class_name <- paste0("Class", class_number)
      names <- c("time", class_table[, class_name] %>% dplyr::pull())
      a <- character(0)
      database <- data.frame()

      # Gather all years in the analysis folder
      for (year in years) {
        stations <- paste0("stations/class/", year, "/",
                           list.files(paste0("stations/class/",
                                             year)))

        # Gather all stations by year
        for (station in stations) {

          if (!identical(a, list.files(station))) {
            paths <- paste0(station, "/",
                            list.files(station))

            # Get paths from all files by station by year
            for (path in paths) {

              file_name <- basename(path)
              clean0 <- stringr::str_remove(file_name, ".xls")
              date <- stringr::str_sub(clean0, stringr::str_length(clean0)-9) %>%
                as.Date(format = "%m-%d-%Y")

              # Metadata columns for ID

              # Station ID
              st <- stringr::str_extract(clean0, "(?<=_)(.+)(?=_)") %>%
                stringr::str_extract("(.+)(?=_)")

              # Direction ID
              dir <- stringr::str_extract(clean0, "(?<=_)(.+)(?=_)") %>%
                stringr::str_extract("(?<=_)(.+)")

              # Volume data
              data <- rvest::read_html(path) %>% rvest::html_table() %>% .data[[2]]
              colnames(data) <- names

              metadata <- data.frame(station = c(rep(st, 24)),
                                     date = c(rep(date, 24)),
                                     year = c(rep(year, 24)),
                                     dir = c(rep(dir, 24)))

              data <- cbind(metadata, data[1:24,])

              database <- rbind(database, data)

            }

          }

        }

      }

      #### Short Type ####

    } else if (analysis_type == "short") {

      # Set parameters for class type analysis
      years <- list.files(paste0(getwd(), "/stations/short"))
      a <- character(0)
      database <- data.frame()

      # For total volumes, no interval
      if (get_interval == FALSE) {

        # Gather all years in the analysis folder
        for (year in years) {

          stations <- paste0("stations/short/", year, "/",
                             list.files(paste0("stations/short/",
                                               year)))

          # Gather all stations by year
          for (station in stations) {

            if (!identical(a, list.files(station))) {

              paths <- paste0(station, "/",
                              list.files(station))

              # Get paths from all files by station by year
              for (path in paths) {

                # Metadata columns for ID

                # File name (necesarry because files are html)
                file_name <- basename(path)

                # Use rvest to extract html data
                data <- rvest::read_html(path) %>% rvest::html_table() %>% .[[1]]

                # Station ID
                st <- data[2, 2] %>% dplyr::pull() %>%
                  stringr::str_extract(., "(.+)(?=_)")

                # Direction ID
                dir <- data[2, 2] %>% dplyr::pull() %>%
                  stringr::str_extract(., "(?<=_)(.+)")

                # Date
                date <- data[2, 9] %>% dplyr::pull() %>%
                  as.Date(format = "%m/%d/%Y")

                # Interval
                interval <- data[14, 1] %>% stringr::str_extract(., "(?<= )(.+)") %>%
                  stringr::str_extract(., "(.+)(?= )") %>% as.numeric()

                # Check for full hours or partial intervals
                if (interval == 60) {

                  table <- c(data[16, 8] %>% dplyr::pull(), data[17:39, 6] %>% dplyr::pull()) %>%
                    data.frame(volume = .)

                } else if (interval == 15) {

                  table <- data[17:40, 6] %>% dplyr::pull() %>%
                    data.frame(volume = .)

                }

                # Metadata
                metadata <- data.frame(station = c(rep(st, 24)),
                                       date = c(rep(date, 24)),
                                       year = c(rep(year, 24)),
                                       dir = c(rep(dir, 24)),
                                       interval = c(rep(interval, 24)),
                                       time = seq(0, 23, 1))

                # Bind table columns
                data <- cbind(metadata, table)

                # Bind extracted rows
                database <- rbind(database, data)

              }

            }

          }

        }

      } else if (get_interval == TRUE) {

        for (year in years) {

          stations <- paste0("stations/short/", year, "/",
                             list.files(paste0("stations/short/",
                                               year)))

          for (station in stations) {

            if (!identical(a, list.files(station))) {

              paths <- paste0(station, "/",
                              list.files(station))

              for (path in paths) {

                file_name <- basename(path)
                data <- rvest::read_html(path) %>% rvest::html_table() %>% .[[1]]
                st <- data[2, 2] %>% dplyr::pull() %>%
                  stringr::str_extract(., "(.+)(?=_)")

                dir <- data[2, 2] %>% dplyr::pull() %>%
                  stringr::str_extract(., "(?<=_)(.+)")

                date <- data[2, 9] %>% dplyr::pull() %>%
                  as.Date(format = "%m/%d/%Y")

                interval <- data[14, 1] %>% stringr::str_extract(., "(?<= )(.+)") %>%
                  stringr::str_extract(., "(.+)(?= )") %>% as.numeric()

                if (interval == 60) {

                  table <- c(data[16, 8] %>% dplyr::pull(), data[17:39, 6] %>% dplyr::pull()) %>%
                    data.frame(volume = .)

                } else if (interval == 15) {

                  int1 <- data[17:40, 2] %>% dplyr::pull() %>% as.numeric() %>%
                    data.frame(Int_1 = .)

                  int2 <- data[17:40, 3] %>% dplyr::pull() %>% as.numeric() %>%
                    data.frame(Int_2 = .)

                  int3 <- data[17:40, 4] %>% dplyr::pull() %>% as.numeric() %>%
                    data.frame(Int_3 = .)

                  int4 <- data[17:40, 5] %>% dplyr::pull() %>% as.numeric() %>%
                    data.frame(Int_4 = .)

                  table <- cbind(int1,
                                 int2,
                                 int3,
                                 int4) %>%
                    dplyr::mutate(Volume = Int_1 + Int_2 + Int_3 + Int_4)

                }

                metadata <- data.frame(station = c(rep(st, 24)),
                                       date = c(rep(date, 24)),
                                       year = c(rep(year, 24)),
                                       dir = c(rep(dir, 24)),
                                       interval = c(rep(interval, 24)),
                                       time = seq(0, 23, 1))

                data <- cbind(metadata, table)

                database <- rbind(database, data)

              }

            }

          }

        }

      }

    }

    return(database)

  }
