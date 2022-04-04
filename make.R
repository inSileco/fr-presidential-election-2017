#' Results of French Presidential Election
#' 
#' @description 
#' __ADD DESCRIPTION__
#' 
#' @author Nicolas Casajus \email{nicolas.casajus@gmail.com}
#' 
#' @date 2022/04/03



## Install dependencies (listed in DESCRIPTION) ----

renv::restore()


## Load project addins (R functions and packages) ----

devtools::load_all(here::here())


## Global variables ----

year <- 2017


## Add results to French departments geometry ----

add_data_to_shp(year, round = 1)
add_data_to_shp(year, round = 2)


## Create tooltips - Barplots for 1st round ----

make_tooltip_barplot(year)


## Create tooltips - Piecharts for 2nd round ----

make_tooltip_piechart(year)
