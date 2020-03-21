
## Covid 19 monitoring

## simon.crameri@env.ethz.ch, 21.03.2020

## Define scraper funciton
scrape.canton <- function(abbreviation_canton, url, queries, vars, template, encoding = "utf-8") {
  
  ### Load libraries
  library("XML") # htmlTreeParse(), xpathApply(), xmlValue()
  library("httr") # GET()
  library("RCurl") # getURL
  
  ## define helperfunctions
  # main mining function
  mine.between <- function(string, before, after) {
    ls <- sapply(strsplit(string, split = paste0(before, " "), fixed = T), "[", 2)
    for (i in after) ls <- sapply(strsplit(ls, split = paste0(" ", i), fixed = T), "[", 1)
    if (ls %in% after) ls <- NA
    for (i in 1:length(after)) if (!is.na(ls) & !is.na(pmatch(after, ls)[i])) ls <- NA
    if (!is.na(ls) & ls == "") ls <- NA
    if (!is.na(ls)) {
      repeat{
        if (substring(ls, nchar(ls), nchar(ls)) == " ") ls <- substring(ls, 1, nchar(ls)-1) 
        else break
      }
    }
    ls
  }
  
  # sapply wrapper around mining function
  mine <- function(string, queries) {
    ls <- sapply(queries[-length(queries)], 
                 FUN = function(x) {
                   mine.between(string = string, 
                                before = x, 
                                after = queries[(which(queries == x)+1):length(queries)])
                 }
    )
    ls
  }
  
  # extract 
  get.classes <- function(string) {
    
    # remove Tausender, leading and trailing spaces
    s <- trimws(gsub("'", "", string), whitespace = "\\s")
    
    # return numerics or characters
    isnum <- nchar(gsub("[0-9]+", "", s)) == 0
    
    if (isnum) s <- as.numeric(s)
    s
  }
  
  ## get data base template with data structure proposed by zdavatz
  dd <- read.csv(template, stringsAsFactors = FALSE)
 
  ## get .html content
  d.html <- suppressWarnings(htmlParse(getURL(url, .encoding = encoding), encoding = encoding))
  raw <- xpathApply(doc = d.html, path = "//div", fun = xmlValue)
  
  ## get rid of all consecutive whitespaces (\\s, should replace all of \t, \n, \r and some others)
  cleaned <- gsub("\\s", " ", paste(unlist(raw), collapse = " "))
  repeat {
    cleaned <- gsub("  ", " ", cleaned)
    if (is.na(pmatch("  ", cleaned))) break()
  }
  
  ## mine string
  d.info <- mine(string = cleaned, queries = queries)
  
  ## create case-empty output in template structure
  d <- dd[dd[,"abbreviation_canton"] == abbreviation_canton,]
  d$date <- NA ; d[,names(d)[(which(names(d)=="long")+1):ncol(d)]] <- NA
  d$mined <- Sys.time()

  ## write numerics (numbers of cases) and characters (dates etc.) to data base
  for (string in d.info) {
    if (!is.na(string)) {
      var <- vars[match(names(d.info)[match(string, d.info)], queries)]
      if (var != "junk") {
        d[1,var] <- unname(get.classes(string))
      }
    }
  }
  
  # return
  return(d)
}


#### Demo for different cantons ####
template <- "https://raw.githubusercontent.com/zdavatz/covid19_ch/master/data-cantons-csv/dd-covid19-ch-cantons-20200319-example.csv"


## Graubünden (explanations apply also for other cantons)
url = "https://www.gr.ch/DE/institutionen/verwaltung/djsg/ga/coronavirus/info/Seiten/Start.aspx"

# need unique strings before and after each mined string
# mined strings will be named according to the upstream query string <queries>
queries = c("Fallzahlen", "Bestätigte Fälle:", "Personen in Spitalpflege:", "Verstorbene Personen:", "Update")

# mined strings will be matched to the corresponding variable name in <vars>
vars = c("date", "total_positive_cases", "total_hospitalized", "deaths")

scrape.canton(abbreviation_canton = "GR", url = url, queries = queries, vars = vars, template = template)


## Luzern
url = "https://gesundheit.lu.ch/themen/Humanmedizin/Infektionskrankheiten/Coronavirus"
queries = c("Im Kanton Luzern gibt es", "bestätige Fälle (Stand:", "Uhr")
vars = c("total_positive_cases","date")
scrape.canton(abbreviation_canton = "LU", url = url, queries = queries, vars = vars, template = template)


## St. Gallen
url = "https://www.sg.ch/tools/informationen-coronavirus.html"
queries = c("Update Kanton St.Gallen","Bestätigte Fälle:","Verhaltenshinweise")
vars = c("date","total_positive_cases")
scrape.canton(abbreviation_canton = "SG", url = url, queries = queries, vars = vars, template = template)


## Thurgau
url = "https://www.tg.ch/news/fachdossier-coronavirus.html/10552"
queries = c("Anzahl bestätigter Fälle:", "Stand", "Social Media")
vars = c("total_positive_cases", "date")
scrape.canton(abbreviation_canton = "TG", url = url, queries = queries, vars = vars, template = template)


## Vallis
url = "https://www.vs.ch/de/web/coronavirus"
queries = c("Der Bundesrat und die Schweiz zählen auf Sie! Aktuelle Situation im Kanton Wallis", "Derzeit gibt es", ": Derzeit gibt es", "bestätigte Fälle von Coronavirus-Infektionen im Kanton. Insgesamt hat das Virus bisher den Tod von", "Personen im Wallis verursacht.")
vars = c("date", "junk", "total_positive_cases", "deaths")
scrape.canton(abbreviation_canton = "VS", url = url, queries = queries, vars = vars, template = template)


## Zürich
url = "https://gd.zh.ch/internet/gesundheitsdirektion/de/themen/coronavirus.html"
queries = c("Im Kanton Zürich sind zurzeit", "Personen positiv auf das Coronavirus getestet worden. Total", "Todesfälle", "Stand", "Uhr")
vars = c("total_positive_cases", "deaths", "junk", "date")
scrape.canton(abbreviation_canton = "ZH", url = url, queries = queries, vars = vars, template = template)

