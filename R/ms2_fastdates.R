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
#' @param table_type Type of data to gather between "aadt", "dates volume" or
#' "dates class", defaults to "aadt"
#' @returns A dataframe containing all stations in a given district, county or
#' community
# Export this function
#' @export
#' @importFrom rlang .data


ms2_fastdates <- function(attributes, district = NULL, county = NULL, community = NULL,
                          stations_list, table_type = "aadt") {

  if (!missing(attributes)) {

    main_url = attributes[["main_url"]]
    search_url = paste0(main_url, "search.asp?home=1")
    dl_path = attributes[["dl_path"]]

  } else {

    stop("No attributes table provided")

  }

  district_string <- paste(district, collapse = ",")
  county_string <- paste(county, collapse = ",")
  community_string <- paste(community, collapse = ",")

  # Creates Selenium driver object
  rd <- RSelenium::rsDriver(browser = "firefox",
                            chromever = NULL)
  # Access the client object
  remDr <- rd$client

  remDr$open()

  # Navigate to the main MS2 site, which allows to keep a session open within
  # their system, preventing timeouts
  remDr$navigate(main_url)
  remDr$navigate(search_url)

  Sys.sleep(5)

  district_element <- remDr$findElement(using = "css selector", value = "#ddlDistrict")
  county_element <- remDr$findElement(using = "css selector", value = "#ddlCounty")
  community_element <- remDr$findElement(using = "css selector", value = "#ddlCommunity")

  district_element$sendKeysToElement(list(district_string))
  county_element$sendKeysToElement(list(county_string))
  community_element$sendKeysToElement(list(community_string))

  search_button <- remDr$findElement(using = "css selector", value = "#btnSubmit")
  search_button$clickElement()

  Sys.sleep(10)

  list_view <- remDr$findElement(using = "css selector", value = ".button_sml:nth-child(1)")
  list_view$clickElement()

  Sys.sleep(10)

  export <- remDr$findElement(using = "css selector", value = "#ContentPlaceHolder1_btnEXPORT")
  export$clickElement()

  Sys.sleep(15)

  file <- file.info(list.files(dl_path, full.names = T))

  path <- rownames(file)[which.max(file$mtime)]

  tcds <- rvest::read_html(path) %>% rvest::html_table() %>% .[[2]]

  tcds_offsets <- tcds %>%
    dplyr::mutate(offset = seq(0, nrow(tcds)-1, 1))

  tcds_select <- tcds_offsets %>% dplyr::filter(`Loc ID` %in% stations_list$Loc_ID) %>%
    dplyr::select(`Loc ID`, offset) %>%
    dplyr::mutate(url = paste0(main_url, "/tdetail.asp?offset=", offset))

  colnames(tcds_select) <- c("Loc_ID", "offset", "url")

  results <- list()

  for (i in 1:nrow(tcds_select)) {

    url <- tcds_select$url[i]
    station <- tcds_select$Loc_ID[i]

    remDr$navigate(url)

    Sys.sleep(10)

    tables <- remDr$getPageSource()[[1]] %>%
      rvest::read_html() %>%
      rvest::html_table()

    if (table_type == "aadt") {

      years <- tables[[19]]$X2 %>% as.numeric() %>%
        .[!is.na(.)]

      volumes <- tables[[19]]$X3 %>% gsub(",", "", .) %>% as.numeric() %>%
        .[!is.na(.)]

      data <- data.frame(years = years, aadt = volumes)

      results[[station]] <- data

    } else if (table_type == "dates volume") {

      data <- tables[[22]]$X2 %>% as.Date(format = "%a %m/%d/%Y") %>%
        .[!is.na(.)]

      results[[station]] <- data

    } else if (table_type == "dates class") {

      data <- tables[[25]]$X2 %>% as.Date(format = "%a %m/%d/%Y") %>%
        .[!is.na(.)]

      results[[station]] <- data

    }

    Sys.sleep(5)

  }

  rd$server$stop()

  return(results)

}
