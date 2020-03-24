### Data South Korea ####

  # Source: https://www.cdc.go.kr/board/board.es?mid=a30402000000&bid=0030&act=view&list_no=366578
  # Age groups
  # 0-9,10-19,...,70-79,80+
  # Missing age: Unclear whether there are cases with missing age
  
  cases_SK  <- c(86,436,2330,856,1164,1602,1033,539,274)
  deaths_SK <- c(0,0,0,1,1,6,16,29,28)
  cfr_age_SK <- deaths_SK/cases_SK



### Data Italy ####

  # Source (old): https://www.epicentro.iss.it/coronavirus/bollettino/Bollettino%20sorveglianza%20integrata%20COVID-19_16%20marzo%202020.pdf
  # Data up to March 16
  # Source (new): https://www.epicentro.iss.it/coronavirus/bollettino/Bollettino%20sorveglianza%20integrata%20COVID-19_19-marzo%202020.pdf
  # Data up to March 19
  # Age groups:
  # 0-9,10-19,...,80-89,90+
  # Missing age: Just a few cases, ignored (179 cases, no deaths)
  
  cases_IT_old  <- c(121,186,970,1676,2995,4734,4438,5123,3873,763)
  deaths_IT_old <- c(0,0,0,4,9,46,144,602,727,165)
  cfr_age_IT_old <- deaths_IT_old/cases_IT_old
  
  cases_IT  <- c(205,270,1374,2525,4396,6834,6337,7121,5352,1115)
  deaths_IT <- c(0,0,0,9,25,83,312,1090,1243,285)
  cfr_age_IT <- deaths_IT/cases_IT



### Data Germany ####

  # Source cases: https://experience.arcgis.com/experience/478220a4c454480e823b17327b2bf1d4 
  # Retrived on 23/March/2020, data up to that day, kind of rounded, counts by gender summed
  # Total deaths up to that day: 86
  # Age groups:
  # 0-4, 5-14, 15-34, 35-59, 60-79, 80+  
  # Age deaths: https://de.wikipedia.org/wiki/COVID-19-Pandemie_in_Deutschland/Todesf%C3%A4lle_mit_Einzelangaben_laut_Medien
  # Only 80 deaths; sometimes 80+ or 90+ etc, but does not matter given age bands of
  # cases; sometimes "?lter", coded as NA, but then assumed that 80+ is fine
  
  cases_DE <- c(60+97,239+251,2800+3100,5000+6700,1400+2000,296+313)
  deaths_DE <- c(89,78,73,67,80,78,80,85,84,76,86,83,80,81,94,81,
                 85,80,88,90,80,80,80,80,68,78,87,83,84,85,80,80,
                 71,90,84,80,90,90,90,82,87,80,80,80,80,95,89,87,
                 83,49,55,84,NA,81,80,80,80,80,80,58,70,84,54,NA,
                 95,85,80,68,71,87,66,92,84,79,90,NA,74,84,60,NA)
  
  # Category "?lter" and one case without age
  deaths_DE[is.na(deaths_DE)] <- 80
  
  # What to do with 6 missing deaths? Assume age is 80
  deaths_DE <- c(deaths_DE,rep(80,6))
  
  # Aggregate
  deaths_DE <- table(cut(deaths_DE,breaks=c(0,5,15,35,60,80,99),right=F))
  
  cfr_age_DE <- deaths_DE/cases_DE



### Data Spain ####

  # Source: https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov-China/documentos/Actualizacion_52_COVID-19.pdf
  # Data up to March 22 2020
  # Agr groups: 0-9,10-19,...,70-79,80+
  # Missing age unclear to me
  
  cases_ES <- c(129,221,1285,2208,2919,3129,2916,3132,3020)
  deaths_ES <- c(0,1,4,3,9,20,63,164,541)
  cfr_age_ES <- deaths_ES/cases_ES



### Function: Raw case fatality rate ####

  cfr <- function(cases,deaths=NULL,cfr_age=NULL) {
    
    age_dis <- cases/sum(cases)
    if(is.null(cfr_age)) cfr_age <- deaths/cases
    
    sum(age_dis*cfr_age)
    
  }

  # Some checks: Matches with numbers on websites
  cfr(cases=cases_IT,death=deaths_IT)
  cfr(cases=cases_SK,death=deaths_SK)  
  
  cfr(cases=cases_IT,cfr_age=cfr_age_IT)
  cfr(cases=cases_SK,cfr_age=cfr_age_SK)  



### Decomposition Italy South Korea ####

  # Formula
  # Kitagawa
  # Total diff: f(A,B)-f(a,b)
  # Contribution of A/a: 0.5 * [f(A,B)-f(a,B)+f(A,b)-f(a,b)]
  # Contribution of B/b: 0.5 * [f(A,B)-f(A,b)+f(a,B)-f(a,b)]
  
  # Combine 80-89 and 90+ to 80+ for Italy
  cases_IT_a  <- c(cases_IT[1:8],sum(cases_IT[9:10]))
  deaths_IT_a <- c(deaths_IT[1:8],sum(deaths_IT[9:10]))
  cfr_age_IT_a <- deaths_IT_a/cases_IT_a
  
  
  # Total difference
  total_diff <- cfr(cases=cases_IT_a,cfr_age=cfr_age_IT_a)-
    cfr(cases=cases_SK,cfr_age=cfr_age_SK)  
  
  # Age distribution
  age_diff <- 0.5*(cfr(cases=cases_IT_a,cfr_age=cfr_age_IT_a)-
                     cfr(cases=cases_SK,cfr_age=cfr_age_IT_a)+
                     cfr(cases=cases_IT_a,cfr_age=cfr_age_SK)-
                     cfr(cases=cases_SK,cfr_age=cfr_age_SK))
  
  # Mortaltiy difference
  mort_diff <- 0.5*(cfr(cases=cases_IT_a,cfr_age=cfr_age_IT_a)-
                      cfr(cases=cases_IT_a,cfr_age=cfr_age_SK)+
                      cfr(cases=cases_SK,cfr_age=cfr_age_IT_a)-
                      cfr(cases=cases_SK,cfr_age=cfr_age_SK))
  
  # Check
  total_diff
  age_diff+mort_diff
  
  # Relative
  abs(age_diff)/(abs(age_diff)+abs(mort_diff))
  abs(mort_diff)/(abs(age_diff)+abs(mort_diff))



### Decomposition Italy Spain ####


  # Total difference
  total_diff <- cfr(cases=cases_IT_a,cfr_age=cfr_age_IT_a)-
    cfr(cases=cases_ES,cfr_age=cfr_age_ES)  
  
  # Age distribution
  age_diff <- 0.5*(cfr(cases=cases_IT_a,cfr_age=cfr_age_IT_a)-
                     cfr(cases=cases_ES,cfr_age=cfr_age_IT_a)+
                     cfr(cases=cases_IT_a,cfr_age=cfr_age_ES)-
                     cfr(cases=cases_ES,cfr_age=cfr_age_ES))
  
  # Mortaltiy difference
  mort_diff <- 0.5*(cfr(cases=cases_IT_a,cfr_age=cfr_age_IT_a)-
                      cfr(cases=cases_IT_a,cfr_age=cfr_age_ES)+
                      cfr(cases=cases_ES,cfr_age=cfr_age_IT_a)-
                      cfr(cases=cases_ES,cfr_age=cfr_age_ES))
  
  # Check
  total_diff
  age_diff+mort_diff
  
  # Relative
  abs(age_diff)/(abs(age_diff)+abs(mort_diff))
  abs(mort_diff)/(abs(age_diff)+abs(mort_diff))  

  
  
### Decomposition Italy Germany ####

  # Aggregate to three age classes: under 60, 60-79, 80+
  
  # Italy
  cases_IT_a  <- c(sum(cases_IT[1:6]),
                   sum(cases_IT[7:8]),
                   cases_IT[9])
  
  deaths_IT_a <- c(sum(deaths_IT[1:6]),
                   sum(deaths_IT[7:8]),
                   deaths_IT[9])
  
  cfr_age_IT_a <- deaths_IT_a/cases_IT_a
  
  # Germany
  cases_DE_a  <- c(sum(cases_DE[1:4]),
                   cases_DE[5],
                   cases_DE[6])
  
  deaths_DE_a <- c(sum(deaths_DE[1:4]),
                   deaths_DE[5],
                   deaths_DE[6])
  
  cfr_age_DE_a <- deaths_DE_a/cases_DE_a
  
  
  # Total difference
  total_diff <- cfr(cases=cases_IT_a,cfr_age=cfr_age_IT_a)-
    cfr(cases=cases_DE_a,cfr_age=cfr_age_DE_a)  
  
  # Age distribution
  age_diff <- 0.5*(cfr(cases=cases_IT_a,cfr_age=cfr_age_IT_a)-
                     cfr(cases=cases_DE_a,cfr_age=cfr_age_IT_a)+
                     cfr(cases=cases_IT_a,cfr_age=cfr_age_DE_a)-
                     cfr(cases=cases_DE_a,cfr_age=cfr_age_DE_a))
  
  # Mortaltiy difference
  mort_diff <- 0.5*(cfr(cases=cases_IT_a,cfr_age=cfr_age_IT_a)-
                      cfr(cases=cases_IT_a,cfr_age=cfr_age_DE_a)+
                      cfr(cases=cases_DE_a,cfr_age=cfr_age_IT_a)-
                      cfr(cases=cases_DE_a,cfr_age=cfr_age_DE_a))
  
  # Check
  total_diff
  age_diff+mort_diff
  
  # Relative
  abs(age_diff)/(abs(age_diff)+abs(mort_diff))
  abs(mort_diff)/(abs(age_diff)+abs(mort_diff))



### Decomposing Germany Korea ####  

  # Aggregate to three age classes: under 60, 60-79, 80+
  
  # Italy
  cases_SK_a  <- c(sum(cases_SK[1:6]),
                   sum(cases_SK[7:8]),
                   cases_SK[9])
  
  deaths_SK_a <- c(sum(deaths_SK[1:6]),
                   sum(deaths_SK[7:8]),
                   deaths_SK[9])
  
  cfr_age_SK_a <- deaths_SK_a/cases_SK_a
  
  # Total difference
  total_diff <- cfr(cases=cases_SK_a,cfr_age=cfr_age_SK_a)-
    cfr(cases=cases_DE_a,cfr_age=cfr_age_DE_a)  
  
  # Age distribution
  age_diff <- 0.5*(cfr(cases=cases_SK_a,cfr_age=cfr_age_SK_a)-
                     cfr(cases=cases_DE_a,cfr_age=cfr_age_SK_a)+
                     cfr(cases=cases_SK_a,cfr_age=cfr_age_DE_a)-
                     cfr(cases=cases_DE_a,cfr_age=cfr_age_DE_a))
  
  # Mortaltiy difference
  mort_diff <- 0.5*(cfr(cases=cases_SK_a,cfr_age=cfr_age_SK_a)-
                      cfr(cases=cases_SK_a,cfr_age=cfr_age_DE_a)+
                      cfr(cases=cases_DE_a,cfr_age=cfr_age_SK_a)-
                      cfr(cases=cases_DE_a,cfr_age=cfr_age_DE_a))
  
  # Check
  total_diff
  age_diff+mort_diff
  
  # Relative
  abs(age_diff)/(abs(age_diff)+abs(mort_diff))
  abs(mort_diff)/(abs(age_diff)+abs(mort_diff))
  


### Comparing Italy to itself  

  # Total difference
  total_diff <- cfr(cases=cases_IT,cfr_age=cfr_age_IT)-
    cfr(cases=cases_IT_old,cfr_age=cfr_age_IT_old)  
  
  # Age distribution
  age_diff <- 0.5*(cfr(cases=cases_IT,cfr_age=cfr_age_IT)-
                     cfr(cases=cases_IT_old,cfr_age=cfr_age_IT)+
                     cfr(cases=cases_IT,cfr_age=cfr_age_IT_old)-
                     cfr(cases=cases_IT_old,cfr_age=cfr_age_IT_old))
  
  # Mortaltiy difference
  mort_diff <- 0.5*(cfr(cases=cases_IT,cfr_age=cfr_age_IT)-
                      cfr(cases=cases_IT,cfr_age=cfr_age_IT_old)+
                      cfr(cases=cases_IT_old,cfr_age=cfr_age_IT)-
                      cfr(cases=cases_IT_old,cfr_age=cfr_age_IT_old))
  
  # Check
  total_diff
  age_diff+mort_diff
  
  # Relative
  abs(age_diff)/(abs(age_diff)+abs(mort_diff))
  abs(mort_diff)/(abs(age_diff)+abs(mort_diff))

  
  
### Age aggregation ####
  
  library(tidyverse)
  library(HMDHFDplus)
  
  IT <- readHMDweb("ITA", "Population", us, pw)  
  DE <- readHMDweb("DEUTNP", "Population", us, pw) 
  
  wmean <- function(x,w){
    sum(x*w)/sum(w)
  }
  
  # age within interval checks
  IT %>% 
    filter(Year == max(Year)) %>% 
    mutate(Age10 = Age - Age %% 10) %>% 
    group_by(Age10) %>% 
    summarize(MaleMean = wmean(x = Age + .5, w = Male2),
              FemaleMean = wmean(x = Age + .5, w = Female2))
    
  DE %>% 
    filter(Year == max(Year)) %>% 
    mutate(Age10 = Age - Age %% 10) %>% 
    group_by(Age10) %>% 
    summarize(MaleMean = wmean(x = Age + .5, w = Male2),
              FemaleMean = wmean(x = Age + .5, w = Female2))
  
  # sex ratio within interval checks
  SR_IT <- IT %>% 
    filter(Year == max(Year)) %>% 
    mutate(Age10 = Age - Age %% 10) %>% 
    group_by(Age10) %>% 
    summarize(Male1 = sum(Male1),
              Female1 = sum(Female1)) %>% 
    mutate(PM) 
  
  SR_DE <- DE %>% 
    filter(Year == max(Year)) %>% 
    mutate(Age10 = Age - Age %% 10) %>% 
    group_by(Age10) %>% 
    summarize(Male1 = sum(Male1),
              Female1 = sum(Female1)) %>% 
    mutate(PM = Male1 / (Male1 + Female1))
  
  
  SR_IT$Country = "IT"
  SR_DE$Country = "DE"
  
  
  rbind(SR_IT, SR_DE) %>% 
    ggplot(mapping = aes(x = Age10, y = PM, color = Country)) + 
    geom_line()


