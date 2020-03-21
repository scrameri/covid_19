source("scrape.cantons.R")

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
