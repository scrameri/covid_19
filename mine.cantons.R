
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
