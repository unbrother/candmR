#' Creates a list of results from the `tt_get_traveltime` function
#'
#' Creates a list of dataframes, each containing the values for all TODs and
#' segments queried by route. The summarized parameter can be changed
#' @param travel_times A special features object obtained from the `tt_get_traveltime``
#' function
#' @param summ_by Variable to summarize data with, defaults to "travel_time", can
#' also be "speed" and "distance"
#' @returns A list of dataframes by route
#' @export
#'

tt_matrix <- function(travel_times, summ_by = "travel_time") {

  travel_times_df <- travel_times %>% sf::st_drop_geometry()

  routes_vector <- travel_times_df[, "route"] %>% unique()

  list <- list()

  for (r in routes_vector) {

    matrix <- travel_times_df[travel_times_df$route == r, c("TOD", "Code", summ_by)] %>%
      tidyr::pivot_wider(names_from = "Code", values_from = summ_by)

    list[[r]] <- matrix

  }

  return(list)

}
