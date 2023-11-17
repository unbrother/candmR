#' Get travel time data from Google Maps Directions API
#'
#' Use Google Maps Directions API and the mapsapi package to directly get
#' segment travel times
#' @param points Points special features object with a Name column identifying
#' each point and a Route column to identify each route, leg or direction
#' @param tod_list TOD list containing a TOD column describing each TOD or the
#' equivalencies of TODs by hour.
#' @param key Google API key
#' @param name_col How the ID column is called, if used the `tt_gather_points()`
#' function, defaults to "Name"
#' @param route_col How the Route column is called, if used the `tt_gather_points()`
#' function, defaults to "Route"
#' @returns A special features object with the travel time results as geographic
#' lines. Travel times are returned in minutes, distance in miles and speed in
#' miles per hour.
#' @export

tt_get_traveltime <- function(points, tod_list, key,
                              name_col = "Name", route_col = "Route") {

  routes_num <- points[route_col] %>% sf::st_drop_geometry() %>%
    unique() %>%
    dplyr::pull() %>%
    as.character()

  old <-  c(route_col, name_col, "Point")
  new <-  c("Route", "Name", "Point")

  points <- points %>%
    dplyr::select(dplyr::all_of(old)) %>%
    dplyr::rename_with(~new, dplyr::all_of(old))

  travel_times_all_routes <- data.frame()

  for (route in routes_num) {

    current_route <- points[points$Route == route,]
    route_code <- paste0("R", route)

    travel_times <- data.frame()

    for (point in 1:(nrow(current_route)-1)) {

      origin <- current_route[point,]
      destination <- current_route[point+1, ]

      r_aux <- data.frame()

      for (tod in 1:nrow(tod_list)) {

        departure_time = tod_list[tod, 2]
        doc = mapsapi::mp_directions(
          origin = origin,
          destination = destination,
          alternatives = FALSE,
          key = key,
          quiet = TRUE,
          departure_time =  departure_time
        )
        r = mapsapi::mp_get_routes(doc)
        r$departure_time = departure_time
        r$TOD = tod_list[tod, 1]
        r$route = route_code
        r_aux <- rbind(r_aux, r)

      }

      r_aux <- r_aux %>% dplyr::mutate(Code = current_route[point, "Name"] %>%
                                  sf::st_drop_geometry() %>% dplyr::pull())
      travel_times <- rbind(travel_times, r_aux)

    }

    travel_times_all_routes <- rbind(travel_times_all_routes, travel_times)

  }

  travel_times_all_routes <- travel_times_all_routes %>%
    dplyr::mutate(travel_time = round(duration_in_traffic_s/60,2),
           distance = round(distance_m/1600,2),
           speed = round(distance / travel_time * 60,2))

  return(travel_times_all_routes)

}
