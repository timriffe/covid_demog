### Monitoring trends and differences in COVID-19 case fatality  ##############
### rates using decomposition methods: A demographic perspective ##############
  
  ### Last updated: 2020-07-15 16:26:50 CEST
  
  ### Contact:
  ### riffe@demogr.mpg.de
  ### acosta@demogr.mpg.de
  ### dudel@demogr.mpg.de
  
  
### Load functions & packages #################################################
  
  source(("R/00_functions.R"))
  

### Load case data ############################################################

  # Load data
  cases <- read_csv("Data/inputdata.csv")
  
  # Edit date
  cases$Date <- as.Date(cases$Date,"%d.%m.%y")
  
  # Lists of countries and regions
  countrylist <- c("China","Germany","Italy","South Korea","Spain","USA")
  regionlist <- c("All")
  
  # Restrict
  cases <- cases %>% filter(Country %in% countrylist & Region %in% regionlist)
  
  # Drop tests
  cases <- cases %>% mutate(Tests=NULL)
  
  
### Load and edit excess mortality data #######################################
  
  # Load CSV file
  dat <- read_csv("Data/baseline_excess_pclm_5.csv")
  
  # Set Date as date
  dat$Date <- as.Date(dat$date,"%d.%m.%y")

  # Restrict
  dat <- dat %>% filter(Country %in% countrylist)
  
  # Merge with cases
  dat <- inner_join(dat,cases[,c("Country","Date","Age","Sex","Cases")])
  
  # Find max dates
  maxdates <- dat %>% 
    group_by(Country) %>% 
    summarize(maxdate=max(Date))
  
  # Get least common denominator
  maxdate <- maxdates %>% 
    filter(Country!="China") %>% 
    ungroup() %>% 
    summarize(min(maxdate))
  
  maxdate <- as.data.frame(maxdate)[1,1]
  

### Analysis similar to Table 2 ###############################################
  
  # # Generate cumulative deaths/predictions
  # dat <- dat %>% group_by(Country,Date,t) %>% 
  #   mutate(cumdeath = cumsum(Deaths),
  #          cumpred = cumsum(pred))
  # 
  # # Calculate excess deaths
  # dat$Exc <- dat$cumdeath - dat$cumpred
  # 
  # # Set to 0 if below 0
  # dat$Exc[dat$Exc<0] <- 0
  
  #### constraining excess to be >0 (Enrique's version)
  
  dat <- dat %>% 
    mutate(exc_p = ifelse(excess < 0, 0, excess)) %>%
    group_by(Country,Age,Sex) %>% 
    mutate(Exc = cumsum(exc_p))
  
  # Calculate ASFRs
  dat <- dat %>% mutate(ascfr = Exc / Cases,
                        ascfr = replace_na(ascfr, 0))
  
  # Decide some reference patterns (here Germany)
  DE <- dat %>% 
    filter(Country == "Germany",
           Sex == "b",
           #Date == maxdate)
           Week == 21)

  
  # Decompose
  DecDE <- as.data.table(dat)[,
                              kitagawa_cfr(DE$Cases, DE$ascfr,Cases,ascfr),
                              #by=list(Country,Date, Sex)]#
                              by=list(Country,Week, Sex)]
  
  # Select only most recent date, both genders combined
  #DecDE <- DecDE %>% filter(Sex=="b") %>% group_by(Country) %>% slice(which.max(Date))
  DecDE <- DecDE %>% filter(Sex=="b") %>% group_by(Country) %>% filter(Week %in% 19:21)

  # Drop unnecessary variables
  DecDE <- DecDE %>% select(Country,Week,CFR2,Diff,AgeComp,RateComp)

  # Calculate relative contributions
  DecDE <- DecDE %>% mutate(relAgeDE = abs(AgeComp)/(abs(AgeComp)+abs(RateComp)))
  DecDE <- DecDE %>% mutate(relRateDE = abs(RateComp)/(abs(AgeComp)+abs(RateComp)))

  # Rename
  DecDE <- DecDE %>% rename(DiffDE=Diff,AgeCompDE=AgeComp,RateCompDE=RateComp)

  # Sort data
  DecDE <- DecDE %>% arrange(CFR2) # Appendix


### Save extra table ##########################################################
  
  # Appendix table 1
  write_xlsx(x=DecDE,
            path="Output/AppendixTab6.xlsx")
  
