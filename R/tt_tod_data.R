#' Creates a dataframe with TOD data and hours
#'
#' Creates a dataframe with TOD data and hours by either declaring the TOD and
#' Time variables or by importing a table with the required structure
#' @param tods Vector containing all TODs
#' @param hours Vector of hours created by the `tt_hours_vector` function
#' @param table_path Excel sheet containing both TOD and Time columns
#' @param sheet Name of sheet containing the TOD table
#' @returns A dataframe with columns `TOD` and `Time`
#' @examples
#' tods <- c("AM1", "AM2", "AM3", "MD1" ,"PM1")
#' hours <- tt_hours_vector(Sys.Date()+1, c(2, 4, 8, 12, 14))
#' tod_list <- tt_tod_data(tods, hours)
#' @export
#'

tt_tod_data <- function(tods, hours, table_path, sheet = "TOD") {

  if (missing(table_path)) {

    df <- data.frame(TOD = tods, Time = hours)

    return(df)

  } else if (missing(tods) && missing(hours)) {


    df <- readxl::read_excel(table_path, sheet = sheet) %>%
      dplyr::mutate(Time = lubridate::ymd_hms(Time, tz = "")) %>% as.data.frame()

    if (names(df)[1] != "TOD") {

      stop("Column 1 should be named 'TOD'")

    } else if (names(df)[2] != "Time") {

      stop("Column 2 should be named 'Time'")

    } else if (!is(df$Time, "POSIXct")) {

      stop("Time column should be of class POSIXct")

    }

    return(df)

  } else {

    stop("Use only one set of arguments: either declare TOD and Time vectors
         or import TOD table")

  }

}
