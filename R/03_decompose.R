
library(here)
source("R/02_data_prep.R")

# Case and death counts

aggregate(Cases~Code,data=dat[dat$Sex=="b",],sum)
aggregate(Deaths~Code,data=dat[dat$Sex=="b",],sum)

# decide some standard patterns

DE <- dat %>% 
  filter(Code == "DE29.03.2020",
         Sex == "b")
IT <- dat %>% 
  filter(Code == "ITinfo29.03.2020",
         Sex == "b")
SK <- dat %>% 
  filter(Code == "SK30.03.2020",
         Sex == "b")

# Decompose

DecDE <- as.data.table(dat)[,
                   kitagawa_cfr4(DE$Cases, DE$ascfr,Cases,ascfr),
                   by=list(Country, Code, Date, Sex)]
  
DecIT <- as.data.table(dat)[,
                   kitagawa_cfr4(IT$Cases, IT$ascfr,Cases,ascfr),
                   by=list(Country, Code, Date, Sex)]

DecSK <- as.data.table(dat)[,
                            kitagawa_cfr4(SK$Cases, SK$ascfr,Cases,ascfr),
                            by=list(Country, Code, Date, Sex)]

# Select only most recent date, both genders combined

DecDE <- DecDE %>% filter(Sex=="b") %>% group_by(Country) %>% slice(which.max(Date))
DecIT <- DecIT %>% filter(Sex=="b") %>% group_by(Country) %>% slice(which.max(Date))
DecSK <- DecSK %>% filter(Sex=="b") %>% group_by(Country) %>% slice(which.max(Date))

# Drop unnecessary variables
DecDE <- DecDE %>% select(Country,Date,CFR2,Diff,AgeComp,RateComp)
DecIT <- DecIT %>% select(Country,Date,CFR2,Diff,AgeComp,RateComp)
DecSK <- DecSK %>% select(Country,Date,CFR2,Diff,AgeComp,RateComp)

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
DecDE <- DecDE %>% arrange(CFR2)
DecIT <- DecIT %>% arrange(CFR2)
DecSK <- DecSK %>% arrange(CFR2)


# Italy trend
ITtrend <- dat %>% 
  filter(Code == "IT09.03.2020",
         Sex == "b")

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

# Output
library(writexl)

write_xlsx(x=DecSK,
           path="Output/Table1.xlsx")

write_xlsx(x=DecITtrend,
           path="Output/Table2.xlsx")

write_xlsx(x=DecDE,
           path="Output/AppendixTab1.xlsx")

write_xlsx(x=DecIT,
           path="Output/AppendixTab2.xlsx")


# ----------------------------------------------
# testing re AvR's comment:
#  We always use the same reference point (9 March). If we used 19 March, after 
# which the CFR kept increasing, but not by as much relatively speaking would
# our relative results change? i.e. how robust are our results to the choice 
# of reference?

do.this <- FALSE
if (do.this){
dat %>% 
  filter(Country == "Italy") %>% 
  pull(Code) %>% 
  unique()


ITtrend2 <- dat %>% 
  filter(Code == "IT19.03.2020",
         Sex == "b")

DecITtrend <- as.data.table(dat)[,
                                 kitagawa_cfr4(Cases,ascfr,ITtrend2$Cases, ITtrend2$ascfr),
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
}

