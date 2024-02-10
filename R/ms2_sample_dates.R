#' Sample a dates list
#'
#' Get a reduced dates list by sampling by month and year, only selects weekdays
#'
#' @param dates_list a dates list obtained with the **ms2_all_dates** function
#' @param sample_weeks the amount of weeks to sample each month
#' @returns A reduced dates list with x amounts of weeks sampled by month
# Export this function
#' @export
#' @importFrom rlang .data
#'

ms2_sample_dates <- function(dates_list, sample_weeks = 1){

  dates_list <- lapply(dates_list, function(x) data.frame(Date = x) %>%
           dplyr::mutate(month = lubridate::month(as.Date(Date, "%m/%d/%Y")),
                         year = lubridate::year(as.Date(Date, "%m/%d/%Y")),
                         weekday = weekdays(as.Date(Date, "%m/%d/%Y"))) %>%
           dplyr::filter(weekday %in% c("Tuesday", "Wednesday", "Thursday")) %>%
           dplyr::group_by(year, month) %>%
           dplyr::slice_sample(n = sample_weeks) %>%
           .$Date)

  return(dates_list)

}
