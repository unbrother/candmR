#' Get a list of stations based on search criteria
#'
#' Get a list of stations based on search criteria
#'
#' @param attributes Attributes list obtained by the `ms2_attributes` function
#' @param district Vector of districts
#' @param county Vector of counties
#' @param community Vector of communities
#' @returns A dataframe containing all stations in a given district, county or
#' community
# Export this function
#' @export
#' @importFrom rlang .data

ms2_getlist <- function(attributes, district = NULL, county = NULL, community = NULL) {

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

  district_element <- remDr$findElement(using = "css selector", value = "#ddlDistrict")
  county_element <- remDr$findElement(using = "css selector", value = "#ddlCounty")
  community_element <- remDr$findElement(using = "css selector", value = "#ddlCommunity")

  district_element$sendKeysToElement(list(district_string))
  county_element$sendKeysToElement(list(county_string))
  community_element$sendKeysToElement(list(community_string))

  search_button <- remDr$findElement(using = "css selector", value = "#btnSubmit")
  search_button$clickElement()

  Sys.sleep(3)

  list_view <- remDr$findElement(using = "css selector", value = ".button_sml:nth-child(1)")
  list_view$clickElement()

  Sys.sleep(3)

  export <- remDr$findElement(using = "css selector", value = "#ContentPlaceHolder1_btnEXPORT")
  export$clickElement()

  Sys.sleep(15)

  file <- file.info(list.files(dl_path, full.names = T))

  path <- rownames(file)[which.max(file$mtime)]

  tcds <- rvest::read_html(path) %>% rvest::html_table() %>% .[[2]]

  rd$server$stop()

  write.csv(tcds, "outputs/stations_search.csv")

  return(tcds)

}



