### Monitoring trends and differences in COVID-19 case fatality  ##############
### rates using decomposition methods: A demographic perspective ##############

  ### Last updated: 2020-07-16 09:27:20 CEST
  
  ### Contact:
  ### riffe@demogr.mpg.de
  ### acosta@demogr.mpg.de
  ### dudel@demogr.mpg.de


### Get data ##################################################################

  # Required packages & functions
  source(("R/00_functions.R"))

  # URL + file name
  url <- 'https://osf.io/43ucn//?action=download'
  
  # Where to save
  filename <- 'Data/Output_10.zip'
  
  # Download data
  GET(url, write_disk(filename, overwrite = TRUE))
  
  # Unzip 
  unzip(filename)
  
  # Load data 
  filename <- 'Data/Output_10.csv'
  dat <- read_csv(filename,skip=3)

  
### Edit data (select countries, etc.) ########################################
  
  # Lists of countries and regions
  countrylist <- c("China","Germany","Italy","South Korea","Spain","USA")
  region <- c("All","NYC")
  
  # Restrict
  dat <- dat %>% filter(Country %in% countrylist & Region %in% region)
  
  # Remove Tests variable
  dat <- dat %>% mutate(Tests=NULL)
  
  # Drop if no cases/Deaths
  dat <- na.omit(dat)
  
  
### Save ######################################################################
  
  write_csv(dat,path="Data/inputdata.csv")
