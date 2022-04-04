#' Create HTML Barplots (Tooltip) pour first round of voting
#'
#' @param year The election year in the form of YYYY.
#'
#' @return No return values. Barplots (HTML code) are exported in 
#'   `figures/barplots/`.
#'   
#' @export
#'
#' @examples
#' \dontrun{
#' make_tooltip_barplot(2017)
#' }

make_tooltip_barplot <- function(year) {
  
  check_year(year)
  
  ## Get candidates list ----
  
  infos <- read_candidates_info(year)
  
  candidates <- infos$"name"
  candidates <- candidates[!(candidates %in% c("blancs", "nuls", "abstention"))]
  
  
  ## Import spatial results ----
  
  shp <- readRDS(here::here("outputs", paste0("election_results_", year, 
                                              "_round_1.rds")))
  

  ttips <- list()
  
  for (j in 1:length(shp)) {
    
    ## Prepare data for barplot ----
    
    vals <- t(shp@data[j, candidates])[ , 1]
    
    dat <- data.frame("name"  = names(vals), 
                      "value" = round(100 * vals / sum(vals), 2))
    
    dat <- merge(dat, infos, by = 'name', all.x = TRUE, all.y = FALSE)
    dat <- dat[order(dat[ , 'value'], decreasing = TRUE), ]
    
    dat$group <- seq(1, nrow(dat))
    
    
    ## Make Highcharter barplot ----
    
    ttips[[j]] <- highcharter::highchart() %>%
      
      highcharter::hc_add_series(data = dat$"value", type = "bar", 
                                 name = "Votes cast (%)", 
                                 showInLegend = FALSE, colorByPoint = TRUE) %>%
      
      highcharter::hc_yAxis(title = list(text = "Votes cast (%)"), 
                            allowDecimals = FALSE) %>%
      
      highcharter::hc_xAxis(categories = dat$"label", tickmarkPlacement = "on",
                            opposite = FALSE) %>%
      
      highcharter::hc_title(text = shp@data[j, 'departement'], 
                            style = list(fontWeight = "bold")) %>%
      
      highcharter::hc_subtitle(text = paste("French presidential election", 
                                            year, "- Results of 1st round of", 
                                            "voting")) %>%
      
      highcharter::hc_tooltip(valueDecimals = 2, 
                              pointFormat = "Votes: {point.y}%") %>%
      
      highcharter::hc_credits(enabled = TRUE, text = "Source: data.gouv.fr", 
                              href = paste0("http://www.data.gouv.fr/fr/", 
                                            "posts/les-donnees-des-elections/"),
                              style = list(fontSize = "10px")) %>%
      
      highcharter::hc_add_theme(theme_alone())
    
    ttips[[j]]$"x"$"theme"$"colors" <- dat$"color"
    
    ttips[[j]]$"x"$"conf_opts"$"lang"$"decimalPoint" <- "."
    
    
    ## Export tooltip ----
    
    filename <- tolower(shp@data[j, "code"])
    filename <- gsub("fr-", "", filename)
    filename <- paste0("barplot_", filename, ".html")
    
    htmlwidgets::saveWidget(widget = ttips[[j]], 
                            file = here::here("figures", "barplots", filename), 
                            selfcontained = FALSE)
    
    
    ## Move JS libs (only one for all barplots) ----
    
    dirname <- gsub("\\.html", "_files", filename)
    
    if (j == 1) {
      
      invisible(file.copy(here::here("figures", "barplots", dirname, "/"), 
                          here::here("figures", "barplots", "libs"), 
                          recursive = TRUE))
    }
    
    
    ## Delete JS libs ----
    
    unlink(here::here("figures", "barplots", dirname), recursive = TRUE)
    
    
    ## Correct path to JS libs ----
    
    html <- readLines(here::here("figures", "barplots", filename))
    html <- gsub(dirname, "libs", html)
    html <- gsub('"padding":15|"padding":40', '"padding":5', html)
    
    cat(paste0(html, collapse = '\n'), 
        file = here::here("figures", "barplots", filename))
  }
  
  
  ## Export list of barplots ----
  
  pop_up_graph <- leafpop::popupGraph(ttips, type = "html", 
                                      width = 750, height = 425)
  saveRDS(pop_up_graph, here::here("outputs", "popup_barplots.rds"))
  
  invisible(NULL)
}
