### Check PCLM for COVID-19 mortality #########################################

  ### Rough draft!

### Get functions, libraries ##################################################

  # Functions
  source(("R/00_functions.R"))

  # Libraries
  library(googlesheets4)
  library(reshape2)


### Data ######################################################################

  # Load data from web
  ss  <- "https://docs.google.com/spreadsheets/d/1LdMsCq7JAgeWpJ-veobTDTzeZ9A3WIAx-ghjF49JDGE"
  dat <- sheets_read(ss, skip =1)
  
  # Edit variable types
  dat$Age    <- unlist(dat$Age)
  dat$AgeInt <- unlist(dat$AgeInt)
  
  # Change date variable
  dat <- dat %>% mutate(Date = dmy(Date))

  # Subset to Italy, last date available
  dat_10 <- dat %>% filter(Code=="IT30.03.2020" & Sex=="b") 

  # Recode age variable to new age groups
  dat_tmp <- dat_10 %>% mutate(Age = recode(Age, "0" ="0",
                                                "10"="0",
                                                "20"="20",
                                                "30"="20",
                                                "40"="40",
                                                "50"="40",
                                                "60"="60",
                                                "70"="60",
                                                "80"="80",
                                                "90"="80"))
  
  # Aggregate to new age groups
  dat_20 <- aggregate(Cases~Country + Code + Date + Sex + Age,data = dat_tmp, sum)
  
  # Add deaths
  dat_20$Deaths <- aggregate(Deaths~Country + Code + Date + Sex + Age,data = dat_tmp, sum)$Deaths
  
  # Add interval width
  dat_20$AgeInt <- "20"
  dat_20$AgeInt[dat_20$Age=="80"] <- "25"
  dat_20$AgeInt[dat_20$Age=="UNK"] <- "NA"
  
  
### Fit PCLM, redistribute unknown age ########################################
  
  # Fit PCLM
  dat_10_fit <- dat_20 %>% 
    # figure out which subsets have both cases and deaths
    group_by(Country, Date, Code, Sex) %>% 
    mutate(keep = all(!is.na(Cases)) & all(!is.na(Deaths))) %>% 
    filter(keep) %>% 
    # distribute, then standardize
    do(redistribute_NAs(.chunk = .data)) %>% 
    do(standardize_chunk(.chunk = .data, N = 10, OA = 90)) %>% 
    unnest(cols = c())
  
  # Redistribute unknowns
  dat_10_re <- dat_10 %>% 
    # figure out which subsets have both cases and deaths
    group_by(Country, Date, Code, Sex) %>% 
    mutate(keep = all(!is.na(Cases)) & all(!is.na(Deaths))) %>% 
    filter(keep) %>% 
    # distribute, then standardize
    do(redistribute_NAs(.chunk = .data)) %>%
    unnest(cols = c())
  
  
### Basic plots ###############################################################
  
  # Deaths
  plot(dat_10_re$Age,dat_10_re$Deaths/1000,type="b",
       xlab="Age group",ylab="Deaths (in 1000s)",
       ylim=c(0,max(dat_10_re$Deaths/1000)*1.2),
       panel.first=grid(),
       col=rgb(0,0,1,alpha=0.75),pch=16)
  lines(dat_10_fit$Age,dat_10_fit$Deaths/1000,
         col=rgb(1,0,0,alpha=0.75),pch=15,type="b") 
  legend(x=0,y=3,lty=1,pch=c(16,15),col=c("blue","red"),
         bg="white",legend=c("Observed","Predicted"))
  
  # Cases
  plot(dat_10_re$Age,dat_10_re$Cases/1000,type="b",
       xlab="Age group",ylab="Cases (in 1000s)",
       ylim=c(0,max(dat_10_re$Cases/1000)*1.2),
       panel.first=grid(),
       col=rgb(0,0,1,alpha=0.75),pch=16)
  lines(dat_10_fit$Age,dat_10_fit$Cases/1000,type="b",
         col=rgb(1,0,0,alpha=0.75),pch=15) 
  legend(x=0,y=17,lty=1,pch=c(16,15),col=c("blue","red"),
         bg="white",legend=c("Observed","Predicted"))
  
  # Age-specific CFRs
  plot(dat_10_re$Age,dat_10_re$Deaths/dat_10_re$Cases,type="b",
       xlab="Age group",ylab="CFR",
       ylim=c(0,max(dat_10_re$Deaths/dat_10_re$Cases)*1.5),
       panel.first=grid(),
       col=rgb(0,0,1,alpha=0.75),pch=16)
  lines(dat_10_fit$Age,dat_10_fit$Deaths/dat_10_fit$Cases,type="b",
         col=rgb(1,0,0,alpha=0.75),pch=15) 
  legend(x=0,y=0.35,lty=1,pch=c(16,15),col=c("blue","red"),
         bg="white",legend=c("Observed","Predicted"))
  
  