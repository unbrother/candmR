#' \code{candmR} package
#'
#' candmR Tools
#'
#'
#' @docType package
#' @name candmR
#' @importFrom dplyr %>%
#' @importFrom methods is
#' @importFrom utils write.csv
#' @importFrom utils write.table
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(c("class_table",
                                                        "weekday",
                                                        "year",
                                                        "month",
                                                        "key",
                                                        "duration_in_traffic_s",
                                                        "distance_m",
                                                        "distance",
                                                        "travel_time",
                                                        "Time",
                                                        "TOD",
                                                        "Code",
                                                        "value",
                                                        "departure_time",
                                                        "alternative_id",
                                                        "leg_id",
                                                        "distance_text",
                                                        "duration_s",
                                                        "duration_text",
                                                        "duration_in_traffic_text",
                                                        "dep_hour",
                                                        "arrival_time",
                                                        "route",
                                                        "speed",
                                                        "Date",
                                                        "Int_1",
                                                        "Int_2",
                                                        "Int_3",
                                                        "Int_4",
                                                        "Loc ID",
                                                        "Loc_ID",
                                                        "day",
                                                        "offset",
                                                        "type",
                                                        "ym",
                                                        "."))
