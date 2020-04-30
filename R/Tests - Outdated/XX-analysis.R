### Monitoring trends and differences in COVID-19 case fatality  ##############
### rates using decomposition methods: A demographic perspective ##############
 

  ### Last updated: 2020-04-21 13:55:58 CEST

  ### Contact:
  ### riffe@demogr.mpg.de
  ### acosta@demogr.mpg.de
  ### dudel@demogr.mpg.de


### Load functions & packages #################################################

  source(("R/00_functions.R"))


### Load and edit data ########################################################

  # Load CSV file
  source <- "https://raw.githubusercontent.com/timriffe/covid_age/master/Data/"
  dat <- read.csv(paste0(source,"Output_10.csv")
                  ,sep=",",header=T,stringsAsFactors=F)
  
  # Set Date as date
  dat$Date <- as.Date(dat$Date,format="%d.%m.%Y")

  # Restrict to countries of interest
  countrylist <- c("Germany","Italy","China","SouthKorea","Spain","USA")
  regionlist  <- c("All","NYC")
  dat <- dat %>% filter(Country %in% countrylist) %>%
                 filter(Region %in% regionlist)
  
  # Remove Tests variable
  dat <- dat %>% mutate(Tests=NULL)
  
  # Drop if no cases/Deaths
  dat <- na.omit(dat)
  
  # Latest date: April 22
  dat <- dat %>% filter(Date<="2020-04-22")

  
### Numbers for Table 1 #######################################################
  
  # Aggregate case and death counts
  cases <- aggregate(Cases~Code+Date+Country+Region,data=dat[dat$Sex=="b",],sum) 
  deaths <- aggregate(Deaths~Code+Date+Country+Region,data=dat[dat$Sex=="b",],sum)
  
  # Most recent counts
  cases %>% group_by(Country,Region) %>% slice(which.max(Date))
  deaths %>% group_by(Country,Region) %>% slice(which.max(Date))
  
  
### Analysis for Table 2 (and appendix) #######################################
  
  # Calculate ASFRs
  dat <- dat %>% mutate(ascfr = Deaths / Cases,
                        ascfr = replace_na(ascfr, 0))
  
  # Decide some reference patterns (For main text: SK)
  DE <- dat %>% 
    filter(Code == "DE22.04.2020",
           Sex == "b")
  IT <- dat %>% 
    filter(Code == "ITinfo22.04.2020",
           Sex == "b")
  SK <- dat %>% 
    filter(Code == "KR22.04.2020",
           Sex == "b")
  
  # Decompose
  DecDE <- as.data.table(dat)[,
                              kitagawa_cfr4(DE$Cases, DE$ascfr,Cases,ascfr),
                              by=list(Country, Code, Date, Sex, Region)]
  
  DecIT <- as.data.table(dat)[,
                              kitagawa_cfr4(IT$Cases, IT$ascfr,Cases,ascfr),
                              by=list(Country, Code, Date, Sex,Region)]
  
  DecSK <- as.data.table(dat)[,
                              kitagawa_cfr4(SK$Cases, SK$ascfr,Cases,ascfr),
                              by=list(Country, Code, Date, Sex,Region)]
  
  # Select only most recent date, both genders combined
  
  DecDE <- DecDE %>% filter(Sex=="b") %>% group_by(Country,Region) %>% slice(which.max(Date))
  DecIT <- DecIT %>% filter(Sex=="b") %>% group_by(Country,Region) %>% slice(which.max(Date))
  DecSK <- DecSK %>% filter(Sex=="b") %>% group_by(Country,Region) %>% slice(which.max(Date))
  
  # Drop unnecessary variables
  DecDE <- DecDE %>% select(Country,Region,Date,CFR2,Diff,AgeComp,RateComp)
  DecIT <- DecIT %>% select(Country,Region,Date,CFR2,Diff,AgeComp,RateComp)
  DecSK <- DecSK %>% select(Country,Region,Date,CFR2,Diff,AgeComp,RateComp)
  
  # Calculate relative contributions
  DecDE <- DecDE %>% mutate(relAgeDE = abs(AgeComp)/(abs(AgeComp)+abs(RateComp)))
  DecDE <- DecDE %>% mutate(relRateDE = abs(RateComp)/(abs(AgeComp)+abs(RateComp)))
  
  DecIT <- DecIT %>% mutate(relAgeIT = abs(AgeComp)/(abs(AgeComp)+abs(RateComp)))
  DecIT <- DecIT %>% mutate(relRateIT = abs(RateComp)/(abs(AgeComp)+abs(RateComp)))
  
  DecSK <- DecSK %>% mutate(relAgeSK = abs(AgeComp)/(abs(AgeComp)+abs(RateComp)))
  DecSK <- DecSK %>% mutate(relRateSK = abs(RateComp)/(abs(AgeComp)+abs(RateComp)))
  
  # Rename
  DecDE <- DecDE %>% rename(DiffDE=Diff,AgeCompDE=AgeComp,RateCompDE=RateComp)
  DecIT <- DecIT %>% rename(DiffIT=Diff,AgeCompIT=AgeComp,RateCompIT=RateComp)
  DecSK <- DecSK %>% rename(DiffSK=Diff,AgeCompSK=AgeComp,RateCompSK=RateComp)
  
  # Sort data
  DecDE <- DecDE %>% arrange(CFR2) # Appendix
  DecIT <- DecIT %>% arrange(CFR2) # Appendix
  DecSK <- DecSK %>% arrange(CFR2) # Table 2
  
  
### Table 3 ###################################################################
  
  # Italy trend
  ITtrend <- dat %>% 
    filter(Code == "ITbol09.03.2020",
           Sex == "b")
  
  # Calculate decomposition
  DecITtrend <- as.data.table(dat)[,
                                   kitagawa_cfr4(Cases,ascfr,ITtrend$Cases, ITtrend$ascfr),
                                   by=list(Country, Code, Date, Sex)]
  
  # Select only Italy
  DecITtrend <- DecITtrend %>% filter(Country=="Italy" & Sex=="b") 
  
  # Only keep interesting variables
  DecITtrend <- DecITtrend %>% select(Country,Date,CFR1,Diff,AgeComp,RateComp)
  
  # Relative contributions
  DecITtrend <- DecITtrend %>% mutate(relAgeDE = abs(AgeComp)/(abs(AgeComp)+abs(RateComp)))
  DecITtrend <- DecITtrend %>% mutate(relRateDE = abs(RateComp)/(abs(AgeComp)+abs(RateComp)))
  
  # Rename
  DecITtrend <- DecITtrend %>% rename(DiffITt=Diff,AgeCompITt=AgeComp,RateCompITt=RateComp)
  
  # Sort data
  DecITtrend <- DecITtrend %>% arrange(Date)
  
  
### Save results ##############################################################
  
  # Output
  library(writexl)
  
  write_xlsx(x=DecSK,
             path="Output/Table2.xlsx")
  
  write_xlsx(x=DecITtrend,
             path="Output/Table3.xlsx")
  
  write_xlsx(x=DecDE,
             path="Output/AppendixTab1.xlsx")
  
  write_xlsx(x=DecIT,
             path="Output/AppendixTab2.xlsx")
  