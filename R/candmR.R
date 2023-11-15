#' \code{candmR} package
#'
#' candmR Tools
#'
#'
#' @docType package
#' @name candmR
#' @importFrom dplyr %>%
#' @importFrom methods is
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
                                                        "Time"))
