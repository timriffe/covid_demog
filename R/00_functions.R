### Monitoring trends and differences in COVID-19 case fatality  ##############
### rates using decomposition methods: A demographic perspective ##############

  ### File 1 of 2
  
  ### Last updated: 2020-04-28 13:33:20 CEST
  
  ### Contact:
  ### riffe@demogr.mpg.de
  ### acosta@demogr.mpg.de
  ### dudel@demogr.mpg.de


### Load packages #############################################################

  library(tidyverse)
  library(data.table)
  library(writexl)


### Case fatality rate #######################################################

  # cc = case-age distribution
  # rr = age-specific case fatality rates
  cfr <- function(cc,rr){
    sum(cc * rr)
  }

  
### Kitagawa decomposition ####################################################

  # c1 = Age distribution population 1
  # r1 = Case fatality rates population 1
  # c2 = Age distribution population 2
  # r2 = Case fatality rates population 2
  
  kitagawa_cfr <- function(c1, r1, c2, r2){
    
    # Calculate age-distribution of cases
    c1  <- c1 / sum(c1)
    c2  <- c2 / sum(c2)
    
    # Total difference
    Tot <- cfr(c1, r1) - cfr(c2, r2)
    
    # Age component
    Aa  <- sum((c1 - c2) * (r1 + r2) / 2)
    
    # Case fatality component
    Bb  <- sum((r1 - r2) * (c1 + c2) / 2)
    
    # Output
    list(Diff = Tot, 
         AgeComp = Aa,
         RateComp = Bb, 
         CFR1 = weighted.mean(r1,c1), 
         CFR2 = weighted.mean(r2,c2))
  }
