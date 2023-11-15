#' Create a vector of hours composing the Time of Day periods
#'
#' @param date Date to be queried. Must be a future day, at least one day after
#' the current date
#' @param hours_numbers Vector of numeric values of hours
#' @returns A vector of hours of type POSIXct
#' @examples
#' hours <- tt_hours_vector(Sys.Date()+1, c(2, 4, 8, 12, 14))
#' @export
#'
tt_hours_vector <- function(date, hours_numbers) {

  date <- as.Date(date)

  if (Sys.Date() >= date) {

    stop("Date must be a future value")

  } else {


    hours <- paste0(hours_numbers,":00:00")
    dates <- as.POSIXct(paste(date, hours), tz = '')

    return(dates)

  }

}
