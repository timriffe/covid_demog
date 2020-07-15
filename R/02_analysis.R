### Monitoring trends and differences in COVID-19 case fatality  ##############
### rates using decomposition methods: A demographic perspective ##############
 
  ### File 3 of 4

  ### Last updated: 2020-07-14 11:19:20 CEST

  ### Contact:
  ### riffe@demogr.mpg.de
  ### acosta@demogr.mpg.de
  ### dudel@demogr.mpg.de


### Load functions & packages #################################################

  source(("R/00_functions.R"))


### Load and edit data ########################################################

  # Load CSV file
  dat <- read_csv("Data/inputdata.csv")
  
  # Set Date as date
  dat$Date <- as.Date(dat$Date,"%d.%m.%y")
  
  # Remove Tests variable
  dat <- dat %>% mutate(Tests=NULL)
  
  # Drop if no cases/Deaths
  dat <- na.omit(dat)
  
  # Find max dates
  maxdates <- dat %>% 
    group_by(Country,Region) %>% 
    summarize(maxdate=max(Date))
  
  # Get least common denominator
  maxdate <- maxdates %>% 
    filter(Country!="China") %>% 
    ungroup() %>% 
    summarize(min(maxdate))
  
  maxdate <- as.data.frame(maxdate)[1,1]


### Numbers for Table 1 #######################################################
  
  # Latest date: maxdate
  dat2 <- dat %>% filter(Date<=maxdate)
  
  # Aggregate case and death counts
  cases <- aggregate(Cases~Code+Date+Country+Region,data=dat2[dat2$Sex=="b",],sum) 
  deaths <- aggregate(Deaths~Code+Date+Country+Region,data=dat2[dat2$Sex=="b",],sum)
  
  # Most recent counts
  cases %>% group_by(Country,Region) %>% slice(which.max(Date))
  deaths %>% group_by(Country,Region) %>% slice(which.max(Date))
  
  
### Analysis for Table 2 (and appendix) #######################################
  
  # Calculate ASFRs
  dat <- dat %>% mutate(ascfr = Deaths / Cases,
                        ascfr = replace_na(ascfr, 0))
  
  # Get codes for reference countries
  maxdate <- format.Date(maxdate,"%d.%m.%Y")
  refdate <- as.Date("30.06.2020","%d.%m.%Y")
  refdate2 <- format.Date(refdate,"%d.%m.%Y")#maxdate
  
  DE_code <- paste0("DE_",refdate2)#paste0("DE_",maxdate)
  IT_code <- paste0("ITbol",refdate2)#paste0("ITinfo",maxdate)
  SK_code <- paste0("KR",refdate2)#paste0("SK",maxdate)
  
  # Decide some reference patterns (For main text: SK)
  DE <- dat %>% 
    filter(Code == DE_code,
           Sex == "b")
  IT <- dat %>% 
    filter(Code == IT_code,
           Sex == "b")
  SK <- dat %>% 
    filter(Code == SK_code,
           Sex == "b")
  
  # Decompose
  DecDE <- as.data.table(dat)[,
                              kitagawa_cfr(DE$Cases, DE$ascfr,Cases,ascfr),
                              by=list(Country, Code, Date, Sex, Region)]
  
  DecIT <- as.data.table(dat)[,
                              kitagawa_cfr(IT$Cases, IT$ascfr,Cases,ascfr),
                              by=list(Country, Code, Date, Sex,Region)]
  
  DecSK <- as.data.table(dat)[,
                              kitagawa_cfr(SK$Cases, SK$ascfr,Cases,ascfr),
                              by=list(Country, Code, Date, Sex,Region)]
  
  # Select only most recent date, both genders combined
  
  DecDE <- DecDE %>% filter(Sex=="b") %>% group_by(Country,Region) %>% filter(Date<=refdate) %>% slice(which.max(Date))
  DecIT <- DecIT %>% filter(Sex=="b") %>% group_by(Country,Region) %>% filter(Date<=refdate) %>% slice(which.max(Date))
  DecSK <- DecSK %>% filter(Sex=="b") %>% group_by(Country,Region) %>% filter(Date<=refdate) %>% slice(which.max(Date))
  
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
  
  
### Table 3: Italy trend ######################################################
  
  # Italy trend
  ITtrend <- dat %>% 
    filter(Code == "ITbol09.03.2020",
           Sex == "b")
  
  # Calculate decomposition
  DecITtrend <- as.data.table(dat)[,
                                   kitagawa_cfr(Cases,ascfr,ITtrend$Cases, ITtrend$ascfr),
                                   by=list(Country, Code, Date, Sex)]
  
  # Select only Italy
  DecITtrend <- DecITtrend %>% filter(Country=="Italy" & Sex=="b") 
  
  # Only keep interesting variables
  DecITtrend <- DecITtrend %>% select(Country,Code,Date,CFR1,Diff,AgeComp,RateComp)
  
  # Relative contributions
  DecITtrend <- DecITtrend %>% mutate(relAgeDE = abs(AgeComp)/(abs(AgeComp)+abs(RateComp)))
  DecITtrend <- DecITtrend %>% mutate(relRateDE = abs(RateComp)/(abs(AgeComp)+abs(RateComp)))
  
  # Rename
  DecITtrend <- DecITtrend %>% rename(DiffITt=Diff,AgeCompITt=AgeComp,RateCompITt=RateComp)
  
  # Sort data
  DecITtrend <- DecITtrend %>% arrange(Date)
  
  
### Appendix: Trends USA/Spain ################################################
  
  ### NYC trend
  NYtrend <- dat %>% 
    filter(Code == "US_NYC22.03.2020",
           Sex == "b")
  
  # Calculate decomposition
  DecNYtrend <- as.data.table(dat)[,
                                   kitagawa_cfr(Cases,ascfr,NYtrend$Cases, NYtrend$ascfr),
                                   by=list(Country, Region,Code, Date, Sex)]
  
  # Select only NYC
  DecNYtrend <- DecNYtrend %>% filter(Country=="USA" & Region=="NYC" & Sex=="b") 
  
  # Only keep interesting variables
  DecNYtrend <- DecNYtrend %>% select(Country,Code,Date,CFR1,Diff,AgeComp,RateComp)
  
  # Relative contributions
  DecNYtrend <- DecNYtrend %>% mutate(relAgeDE = abs(AgeComp)/(abs(AgeComp)+abs(RateComp)))
  DecNYtrend <- DecNYtrend %>% mutate(relRateDE = abs(RateComp)/(abs(AgeComp)+abs(RateComp)))
  
  # Rename
  DecNYtrend <- DecNYtrend %>% rename(DiffITt=Diff,AgeCompITt=AgeComp,RateCompITt=RateComp)
  
  # Sort data
  DecNYtrend <- DecNYtrend %>% arrange(Date)
  
  ### Spain trend
  EStrend <- dat %>% 
    filter(Code == "ES21.03.2020",
           Sex == "b")
  
  # Calculate decomposition
  DecEStrend <- as.data.table(dat)[,
                                   kitagawa_cfr(Cases,ascfr,EStrend$Cases, EStrend$ascfr),
                                   by=list(Country, Code, Date, Sex)]
  
  # Select only Spain
  DecEStrend <- DecEStrend %>% filter(Country=="Spain" & Sex=="b") 
  
  # Only keep interesting variables
  DecEStrend <- DecEStrend %>% select(Country,Code,Date,CFR1,Diff,AgeComp,RateComp)
  
  # Relative contributions
  DecEStrend <- DecEStrend %>% mutate(relAgeDE = abs(AgeComp)/(abs(AgeComp)+abs(RateComp)))
  DecEStrend <- DecEStrend %>% mutate(relRateDE = abs(RateComp)/(abs(AgeComp)+abs(RateComp)))
  
  # Rename
  DecEStrend <- DecEStrend %>% rename(DiffITt=Diff,AgeCompITt=AgeComp,RateCompITt=RateComp)
  
  # Sort data
  DecEStrend <- DecEStrend %>% arrange(Date)
  
  ### Germany trend
  DEtrend <- dat %>% 
    filter(Code == "DE_21.03.2020",
           Sex == "b")
  
  # Calculate decomposition
  DecDEtrend <- as.data.table(dat)[,
                                   kitagawa_cfr(Cases,ascfr,DEtrend$Cases, DEtrend$ascfr),
                                   by=list(Country, Code, Date, Sex)]
  
  # Select only Germany
  DecDEtrend <- DecDEtrend %>% filter(Country=="Germany" & Sex=="b" & Date>="2020-03-21") 
  
  # Only keep interesting variables
  DecDEtrend <- DecDEtrend %>% select(Country,Code,Date,CFR1,Diff,AgeComp,RateComp)
  
  # Relative contributions
  DecDEtrend <- DecDEtrend %>% mutate(relAgeDE = abs(AgeComp)/(abs(AgeComp)+abs(RateComp)))
  DecDEtrend <- DecDEtrend %>% mutate(relRateDE = abs(RateComp)/(abs(AgeComp)+abs(RateComp)))
  
  # Rename
  DecDEtrend <- DecDEtrend %>% rename(DiffITt=Diff,AgeCompITt=AgeComp,RateCompITt=RateComp)
  
  # Sort data
  DecDEtrend <- DecDEtrend %>% arrange(Date)
  
  
### Save results ##############################################################
  
  # Table 2
  write_xlsx(x=DecSK,
             path="Output/Table2.xlsx")
  
  # Table 3
  write_xlsx(x=DecITtrend,
             path="Output/Table3.xlsx")
  
  # Appendix table 1
  write_xlsx(x=DecDE,
             path="Output/AppendixTab1.xlsx")
  
  # Appendix table 2
  write_xlsx(x=DecIT,
             path="Output/AppendixTab2.xlsx")
  
  # Appendix table 3
  write_xlsx(x=DecNYtrend,
             path="Output/AppendixTab3.xlsx")
  
  # Appendix table 4
  write_xlsx(x=DecEStrend,
             path="Output/AppendixTab4.xlsx")
  
  # Appendix table 5
  write_xlsx(x=DecEStrend,
             path="Output/AppendixTab5.xlsx")
  