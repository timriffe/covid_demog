
library(here)
source("R/02_data_prep.R")

# decide some standard patterns

SK <- dat %>% 
  filter(Code == "SK25.03.2020",
         Sex == "b")
DE <- dat %>% 
  filter(Code == "DE25.03.2020",
         Sex == "b")
IT <- dat %>% 
  filter(Code == "ITinfo26.03.2020",
         Sex == "b")

DecSK <- as.data.table(dat)[,
                   kitagawa_cfr4(SK$Cases, SK$ascfr,Cases,ascfr),
                   by=list(Country, Code, Date, Sex)]

DecDE <- as.data.table(dat)[,
                   kitagawa_cfr4(DE$Cases, DE$ascfr,Cases,ascfr),
                   by=list(Country, Code, Date, Sex)]
  
DecIT <- as.data.table(dat)[,
                   kitagawa_cfr4(IT$Cases, IT$ascfr,Cases,ascfr),
                   by=list(Country, Code, Date, Sex)]
