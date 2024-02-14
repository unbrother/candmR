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
           class_number = 1,
           get_interval = FALSE) {

    # Check for attributes table, if available, gets analysis type from there,
    # if missing, analysis type has to be set as an argument
    if (!missing(attributes)) {

      analysis_type <-  attributes[["analysis_type"]]
      class_table <- attributes[["class_table"]]

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
              data <- rvest::read_html(path) %>% rvest::html_table() %>% .[[2]]
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

        print(paste0("Added data from station: ", station))

      }

      #### Short Type ####

    } else if (analysis_type == "short") {

      # Set parameters for short type analysis
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

                tryCatch({

                  suppressMessages({
                    data <- rvest::read_html(path) %>% rvest::html_table() %>% .[[1]]
                  })}, error = function(e){data <<- NA_character_})

                if (is.na(data[1,1])) {

                  print(paste0("No data found for station: ", file_name, " in ", year))

                } else {

                  # Station ID
                  st <- data[2, 2] %>% dplyr::pull() %>%
                    stringr::str_extract(., "(.+)(?=_)")

                  if (is.na(st)) {

                    st <- with(data, X2[match("Location ID", X1)])

                  }

                  # Direction ID
                  dir <- data[2, 2] %>% dplyr::pull() %>%
                    stringr::str_extract(., "(?<=_)(.+)")

                  if (is.na(dir)) {

                    dir <- with(data, X2[match("Direction", X1)])

                  }

                  # Date
                  date <- data[2, 9] %>% dplyr::pull() %>%
                    as.Date(format = "%m/%d/%Y")

                  if (is.na(date)) {

                    date <- with(data, X9[match("Start Date", X8)]) %>%
                      as.Date(format = "%m/%d/%Y")

                  }

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

          print(paste0("Added data from station: ", station))

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

                tryCatch({

                  suppressMessages({
                    data <- rvest::read_html(path) %>% rvest::html_table() %>% .[[1]]
                  })}, error = function(e){data <<- NA_character_})

                if (is.na(data[1,1])) {

                  print(paste0("No data found for station: ", file_name, " in ", year))

                } else {

                  # Station ID
                  st <- data[2, 2] %>% dplyr::pull() %>%
                    stringr::str_extract(., "(.+)(?=_)")

                  if (is.na(st)) {

                    st <- with(data, X2[match("Location ID", X1)])

                  }

                  # Direction ID
                  dir <- data[2, 2] %>% dplyr::pull() %>%
                    stringr::str_extract(., "(?<=_)(.+)")

                  if (is.na(dir)) {

                    dir <- with(data, X2[match("Direction", X1)])

                  }

                  # Date
                  date <- data[2, 9] %>% dplyr::pull() %>%
                    as.Date(format = "%m/%d/%Y")

                  if (is.na(date)) {

                    date <- with(data, X9[match("Start Date", X8)]) %>%
                      as.Date(format = "%m/%d/%Y")

                  }

                interval <- data[14, 1] %>% stringr::str_extract(., "(?<= )(.+)") %>%
                  stringr::str_extract(., "(.+)(?= )") %>% as.numeric()

                if (interval == 60) {

                  int1 <- rep(NA, 24) %>% data.frame()

                  int2 <- rep(NA, 24) %>% data.frame()

                  int3 <- rep(NA, 24) %>% data.frame()

                  int4 <- rep(NA, 24) %>% data.frame()

                  Volume <- c(data[16, 8] %>% dplyr::pull(), data[17:39, 6] %>% dplyr::pull()) %>%
                    data.frame(volume = .)

                  table <- cbind(int1,
                                 int2,
                                 int3,
                                 int4,
                                 Volume)

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

        print(paste0("Added data from station: ", station))

      }

      #### Perm Type ####

    } else if (analysis_type == "perm") {

      # Set parameters for class type analysis
      years <- list.files(paste0(getwd(), "/stations/perm"))
      names <- c("day", sprintf("H[%d]", seq(1:24)), "Total", "Status")
      a <- character(0)
      database <- data.frame()

      for (station in stations) {

        if(!identical(a, list.files(station))) {

          paths <- paste0(station, "/", list.files(station))

          for (path in paths) {

            file_name <- basename(path)
            clean0 <- stringr::str_remove(file_name, ".xlsx")
            clean1 <- stringr::str_remove(clean0, paste0("_", year))

            month <- stringr::str_sub(clean1, -2) %>%
              stringr::str_replace("_", "0") %>%
              as.numeric()

            clean2 <- ifelse(nchar(month) == 1,
                             stringr::str_sub(clean1, end = -3),
                             stringr::str_sub(clean1, end = -4))

            clean3 <- stringr::str_extract(clean2, "(?<=_)(.+)")
            st <- clean3 %>%
              stringr::str_extract(., "(.+)(?=_)")
            # Direction ID
            dir <- clean3 %>%
              stringr::str_extract(., "(?<=_)(.+)")

            data <- readxl::read_excel(path,
                                       range = "A11:AA41",
                                       col_types = c("numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "numeric", "numeric",
                                                     "text"),
                                       col_names = FALSE)

            colnames(data) <- names

            metadata <- data.frame(station = c(rep(st, 31)),
                                   year = c(rep(year, 31)),
                                   month = c(rep(month, 31)),
                                   dir = c(rep(dir, 31)))

            data <- cbind(metadata, data) %>% dplyr::filter(!is.na(day))

            database <- rbind(database, data)

          }

        }

      }

      print(paste0("Added data from station: ", station))

    }

    return(database)

  }
