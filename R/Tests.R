### Monitoring trends and differences in COVID-19 case fatality  ##############
### rates using decomposition methods: A demographic perspective ##############

  ### Last updated: 2020-07-16 11:03:37 CEST
  
  ### Contact:
  ### riffe@demogr.mpg.de
  ### acosta@demogr.mpg.de
  ### dudel@demogr.mpg.de


### Get test data #############################################################

  # Tidy
  library(tidyverse)

  # Load data
  tests <- read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/testing/covid-testing-all-observations.csv")
  
  # Generate country and type variable
  tests$Country <- sapply(strsplit(tests$Entity,"-"),
                          function(x) trimws(x[[1]]))
  tests$Type <- sapply(strsplit(tests$Entity,"-"),
                       function(x) trimws(x[[2]]))
  
  # Countries
  countrylist <- c("China","Germany","Italy","South Korea","Spain","United States")
  tests <- tests %>% filter(Country%in%countrylist)
  
  # Restrict type
  #tests <- tests %>% filter(Type=="tests performed")
  
  # Get test variable
  tests <- tests %>% rename(Total=`Cumulative total`)
  tests <- tests %>% select(Country,Date,Total,Type)
  
  
### Select correct dates ######################################################
  
  tab <- tests %>% filter(Country=="Germany" & Date == "2020-06-28"|
                            Country=="Italy"   & Date == "2020-06-30"|
                            Country=="Spain"   & Date == "2020-05-21"|
                            Country=="South Korea" & Date == "2020-06-30"|
                            Country=="United States"&Date == "2020-06-27"|
                            Country=="China"  & Date == "2020-02-11")
  
