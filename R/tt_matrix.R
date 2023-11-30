#' Creates a list of results from the `tt_get_traveltime()` function
#'
#' Creates a list of dataframes, each containing the values for all TODs and
#' segments queried by route. The summarized parameter can be changed
#' @param travel_times A special features object obtained from the `tt_get_traveltime()``
#' function
#' @param summ_by Variable to summarize data with, defaults to "travel_time", can
#' also be "speed" and "distance"
#' @param group_tod Defaults to FALSE, which returns the matrices by hour. If TRUE,
#' groups by same TOD based on the input from the TOD and hours vector
#' @param is_sf Set to TRUE to accept direct results from `tt_get_traveltime()`, change
#' to FALSE to input a dataframe
#' @returns A list of dataframes by route
#' @export
#'

tt_matrix <- function(travel_times, summ_by = "travel_time",
                      group_tod = FALSE, is_sf = TRUE) {

  if (is_sf == TRUE) {
    travel_times_df <- travel_times %>% sf::st_drop_geometry()
  } else {
    travel_times_df <- travel_times
  }

  routes_vector <- travel_times_df[, "route"] %>% unique() %>%
    gtools::mixedsort()

  list <- list()

  for (r in routes_vector) {

    if (group_tod == FALSE) {

      matrix <- travel_times_df[travel_times_df$route == r, c("departure_time", "Code", summ_by)] %>%
        tidyr::pivot_wider(names_from = "Code", values_from = summ_by)

      list[[r]] <- matrix

    } else {

      matrix <- travel_times_df[travel_times_df$route == r, c("TOD", "Code", summ_by)] %>%
        dplyr::group_by(TOD, Code = factor(Code, levels = unique(Code))) %>%
        dplyr::summarise(value = round(mean(get(summ_by)), 2)) %>%
        tidyr::pivot_wider(names_from = "Code", values_from = value)


      list[[r]] <- matrix

    }

  }

  return(list)

}
