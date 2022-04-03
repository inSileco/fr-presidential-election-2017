#' Read candidates information
#'
#' Imports a CSV file stored in `data/YYYY/` and named 
#' `candidates_info_YYYY.csv` where `YYYY` is the year of the election. 
#'
#' @param year The election year in the form of YYYY.
#'
#' @return A `data.frame` with three columns:
#'   - `name`: the name of the candidate (for joins);
#'   - `label`: the name of the candidate (for display);
#'   - `color`: the color associated to the candidate.
#'   
#' @export
#'
#' @examples
#' \dontrun{
#' info <- read_candidates_info(2017)
#' }

read_candidates_info <- function(year) {
  
  if (length(year) != 1) {
    stop("Argument 'year' must of length 1")
  }
  
  year <- as.character(year)
  
  if (nchar(year) != 4) {
    stop("Argument 'year' must be of the form YYYY")
  }
  
  path <- here::here("data", year, paste0("candidates_info_", year, ".csv"))
  
  if (!file.exists(path)) {
    stop("Unable to find 'candidates_info' for year ", year)
  }
                     
  utils::read.csv(path)
}
