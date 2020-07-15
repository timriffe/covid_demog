### Monitoring trends and differences in COVID-19 case fatality  ##############
### rates using decomposition methods: A demographic perspective ##############

  ### File 2 of 4
  
  ### Last updated: 2020-07-15 09:20:04 CEST
  
  ### Contact:
  ### riffe@demogr.mpg.de
  ### acosta@demogr.mpg.de
  ### dudel@demogr.mpg.de


### Get data ##################################################################

  # Required packages
  source(("R/00_functions.R"))

  # URL + filename
  url <- 'https://osf.io/wu5ve//?action=download'
  filename <- 'Data/Output_10.csv'
  
  # Load data
  GET(url, write_disk(filename, overwrite = TRUE))
  dat <- read_csv(filename,skip=3)

  
### Select countries ##########################################################
  
  # Lists of countries and regions
  countrylist <- c("China","Germany","Italy","South Korea","Spain","USA")
  region <- c("All","NYC")
  
  # Restrict
  dat <- dat %>% filter(Country %in% countrylist & Region %in% region)
  
  
### Save ######################################################################
  
  write_csv(dat,path="Data/inputdata.csv")
