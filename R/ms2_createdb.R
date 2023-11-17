#' Create a database from files downloaded
#'
#' Imports data stored in the stations folder and arranges it into a dataframe
#' @param analysis_type The type of analysis to be performed, between
#' class, perm and short
#' @param attributes Attributes list obtained by the `ms2_attributes()` function
#' @param class_number Column number for the reclassification table to name
#' columns
#' @returns A dataframe containing all traffic data stored in the  `stations/`
#' folder
#' @export
#'

ms2_createdb <-
  function(analysis_type = c("class", "perm", "short", "speed"),
           attributes = attributes,
           class_number) {

    if (!missing(attributes)) {

      analysis_type = attributes[["analysis_type"]]

    }

    if (analysis_type == "class") {

      years <- list.files(paste0(getwd(), "/stations/class"))
      class_name <- paste0("Class", class_number)
      names <- c("time", class_table[, class_name] %>% dplyr::pull())
      a <- character(0)
      database <- data.frame()

      for (year in years) {
        stations <- paste0("stations/class/", year, "/",
                           list.files(paste0("stations/class/",
                                             year)))

        for (station in stations) {

          if (!identical(a, list.files(station))) {
            paths <- paste0(station, "/",
                            list.files(station))

            for (path in paths) {

              file_name <- basename(path)
              clean0 <- stringr::str_remove(file_name, ".xls")
              date <- stringr::str_sub(clean0, stringr::str_length(clean0)-9) %>%
                as.Date(format = "%m-%d-%Y")

              st <- stringr::str_extract(clean0, "(?<=_)(.+)(?=_)") %>%
                stringr::str_extract("(.+)(?=_)")

              dir <- stringr::str_extract(clean0, "(?<=_)(.+)(?=_)") %>%
                stringr::str_extract("(?<=_)(.+)")

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

    } else if (analysis_type == "short") {

      years <- list.files(paste0(getwd(), "/stations/short"))
      a <- character(0)
      database <- data.frame()

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
              data <- rvest::read_html(path) %>% rvest::html_table() %>% .data[[1]]
              st <- data[2, 2] %>% dplyr::pull() %>%
                stringr::str_extract(.data, "(.+)(?=_)")

              dir <- data[2, 2] %>% dplyr::pull() %>%
                stringr::str_extract(.data, "(?<=_)(.+)")

              date <- data[2, 9] %>% dplyr::pull() %>%
                as.Date(format = "%m/%d/%Y")

              interval <- data[14, 1] %>% stringr::str_extract(.data, "(?<= )(.+)") %>%
                stringr::str_extract(.data, "(.+)(?= )") %>% as.numeric()

              if (interval == 60) {

                table <- c(data[16, 8] %>% dplyr::pull(), data[17:39, 6] %>% dplyr::pull()) %>%
                  data.frame(volume = .data)

              } else if (interval == 15) {

                table <- data[17:40, 6] %>% dplyr::pull() %>%
                  data.frame(volume = .data)

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

    return(database)

  }
