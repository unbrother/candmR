#' Get data from the main station names
#'
#' Get yearly volumes or dates for volume only or classification data for non
#' permanent stations. For permanent stations, use **ms2_all_dates**
#'
#' @param attributes Attributes list obtained by the `ms2_attributes` function
#' @param district Vector of districts
#' @param county Vector of counties
#' @param community Vector of communities
#' @param stations_list The dataframe containing the stations to be consulted,
#' can also be a vector containing the stations' location IDs
#' @returns A dataframe containing all stations in a given district, county or
#' community
# Export this function
#' @export
#' @importFrom rlang .data

ms2_fastdates <- function(attributes, district = NULL, county = NULL, community = NULL,
                          stations_list) {

  if (!missing(attributes)) {

    main_url = attributes[["main_url"]]
    search_url = paste0(main_url, "search.asp?home=1")
    analysis_type = attributes[["analysis_type"]]
    dl_path = attributes[["dl_path"]]


    if (is.vector(stations_list)) {

      stations_list <- data.frame(Loc_ID = stations_list)

    } else {

      stations_list <- stations_list %>%
        dplyr::filter(type == analysis_type) %>%
        dplyr::group_by(Loc_ID) %>% dplyr::distinct(Loc_ID)

    }

    if (nrow(stations_list) == 0) {

      stop("Stations list does not have matching analysis type stations")

    }

  } else {

    stop("No attributes table provided")

  }

  district_string <- paste(district, collapse = ",")
  county_string <- paste(county, collapse = ",")
  community_string <- paste(community, collapse = ",")

  # Creates Selenium driver object
  rd <- RSelenium::rsDriver(browser = "firefox",
                            chromever = NULL,
                            verbose = FALSE)
  # Access the client object
  remDr <- rd$client

  remDr$open(silent = TRUE)

  # Navigate to the main MS2 site, which allows to keep a session open within
  # their system, preventing timeouts
  remDr$navigate(main_url)

  Sys.sleep(5)

  remDr$navigate(search_url)

  Sys.sleep(5)

  district_element <- remDr$findElement(using = "css selector",
                                        value = "#ddlDistrict")
  county_element <- remDr$findElement(using = "css selector",
                                      value = "#ddlCounty")
  community_element <- remDr$findElement(using = "css selector",
                                         value = "#ddlCommunity")

  district_element$sendKeysToElement(list(district_string))
  county_element$sendKeysToElement(list(county_string))
  community_element$sendKeysToElement(list(community_string))

  search_button <- remDr$findElement(using = "css selector",
                                     value = "#btnSubmit")
  search_button$clickElement()

  Sys.sleep(15)

  list_view <- remDr$findElement(using = "css selector",
                                 value = ".button_sml:nth-child(1)")
  list_view$clickElement()

  Sys.sleep(15)

  export <- remDr$findElement(using = "css selector",
                              value = "#ContentPlaceHolder1_btnEXPORT")
  export$clickElement()

  Sys.sleep(15)

  file <- file.info(list.files(dl_path, full.names = T))

  path <- rownames(file)[which.max(file$mtime)]

  tcds <- rvest::read_html(path) %>% rvest::html_table() %>% .[[2]]

  tcds_offsets <- tcds %>%
    dplyr::mutate(offset = seq(0, nrow(tcds)-1, 1))

  tcds_select <- tcds_offsets %>%
    dplyr::filter(`Loc ID` %in% stations_list$Loc_ID) %>%
    dplyr::select(`Loc ID`, offset) %>%
    dplyr::mutate(url = paste0(main_url, "/tdetail.asp?offset=", offset))

  colnames(tcds_select) <- c("Loc_ID", "offset", "url")

  results <- list()

  if (analysis_type == "aadt") {

    dir.create("outputs", showWarnings = FALSE)
    dir.create("outputs/yearly_volumes", showWarnings = FALSE)

  }

  for (i in 1:nrow(tcds_select)) {

    url <- tcds_select$url[i]
    station <- tcds_select$Loc_ID[i]

    remDr$navigate(url)

    Sys.sleep(20)

    tables <- remDr$getPageSource()[[1]] %>%
      rvest::read_html() %>%
      rvest::html_table()

    names_list <- lapply(tables, function(x) paste(x$X1[1], x$X1[2]))
    names_list <- lapply(names_list, function(x) substr(x, 1, 15))

    names(tables) <- unlist(names_list) %>%
      gsub("\n", "", .) %>% gsub(" ", "", .)

    if (analysis_type == "aadt") {

      table <- tables[["AADT"]]

      year <- table$X2[6:10] %>% as.numeric()

      volumes <- c()

      for (position in 6:10) {

        if (nchar(table$X3[position]) > 3) {

          first <- table$X3[position] %>%
            gsub("\\,[^\\,]*$", "", .) %>% gsub(",","",.)

          second <- stringr::str_extract(table$X3[position], "\\,[^\\,]*$") %>%
            gsub(",","",.) %>%
            sub("^(\\d{3}).*$", "\\1", .)

          volume <- paste0(first, second) %>% as.numeric()

          volumes <- append(volumes, volume)


        } else {

          first <- table$X3[position] %>%
            gsub("\\,[^\\,]*$", "", .) %>% gsub(",","",.)

          volume <- first %>% as.numeric()

          volumes <- append(volumes, volume)

        }

      }

      DHIV30 <- table$X4[6:10] %>% gsub(",", "",.) %>% as.numeric()
      K_perc <- table$X5[6:10] %>% as.numeric()
      D_perc <- table$X6[6:10] %>% as.numeric()
      PA <- table$X7[6:10]
      BC <- table$X8[6:10]
      SRC <- table$X9[6:10]

      data <- data.frame(year, volumes, DHIV30, K_perc, D_perc, PA, BC, SRC) %>%
        dplyr::mutate(station = station) %>%
        dplyr::filter(!is.na(year))


      for (i in 1:5) {

        next_record <- tryCatch({remDr$findElement(using = "css selector",
                                                   value = "#tblTable4 > tbody > tr:nth-child(8) > td > input:nth-child(3)")
        }, error = function(e){NA_character_})

        if (!is.na(next_record)) {

          next_record$clickElement()

          Sys.sleep(15)

          tables <- remDr$getPageSource()[[1]] %>%
            rvest::read_html() %>%
            rvest::html_table()

          names_list <- lapply(tables, function(x) paste(x$X1[1], x$X1[2]))
          names_list <- lapply(names_list, function(x) substr(x, 1, 15))
          names(tables) <- unlist(names_list) %>% gsub("\n", "", .) %>%
            gsub(" ", "", .)

          table <- tables[["AADT"]]

          year <- table$X2[6:10] %>% as.numeric()

          volumes <- c()

          for (position in 6:10) {

            if (nchar(table$X3[position]) > 3) {

              first <- table$X3[position] %>%
                gsub("\\,[^\\,]*$", "", .) %>% gsub(",","",.)

              second <- stringr::str_extract(table$X3[position], "\\,[^\\,]*$") %>%
                gsub(",","",.) %>%
                sub("^(\\d{3}).*$", "\\1", .)

              volume <- paste0(first, second) %>% as.numeric()

              volumes <- append(volumes, volume)


            } else {

              first <- table$X3[position] %>%
                gsub("\\,[^\\,]*$", "", .) %>% gsub(",","",.)

              volume <- first %>% as.numeric()

              volumes <- append(volumes, volume)

            }

          }

          DHIV30 <- table$X4[6:10] %>% gsub(",", "",.) %>% as.numeric()
          K_perc <- table$X5[6:10] %>% as.numeric()
          D_perc <- table$X6[6:10] %>% as.numeric()
          PA <- table$X7[6:10]
          BC <- table$X8[6:10]
          SRC <- table$X9[6:10]

          data_bind <- data.frame(year, volumes, DHIV30, K_perc, D_perc, PA, BC, SRC) %>%
            dplyr::mutate(station = station) %>%
            dplyr::filter(!is.na(year))

        }

        data <- rbind(data, data_bind)

      }

      results[[station]] <- data

      write.csv(data, paste0("outputs/yearly_volumes/yearly_volume_", station, ".csv"))

    } else if (analysis_type == "dates volume") {

      data <- tables[["VOLUMECOUNT"]]$X2 %>% as.Date(format = "%a %m/%d/%Y") %>%
        format(format = "%m/%d/%Y") %>%
        .[!is.na(.)]

      results[[station]] <- data

    } else if (analysis_type == "dates class") {

      data <- tables[["CLASSIFICATION"]]$X2 %>% as.Date(format = "%a %m/%d/%Y") %>%
        format(format = "%m/%d/%Y") %>%
        .[!is.na(.)]

      results[[station]] <- data

    }

    Sys.sleep(5)

  }

  rd$server$stop()

  if (analysis_type == "aadt") {

    results <- results %>%
      purrr::reduce(rbind)

    write.csv(results, "outputs/aadt.csv")

  }

  return(results)

}
