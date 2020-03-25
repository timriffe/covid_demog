

# session setup
library(here)
library(tidyverse)
library(ungroup)




# redistribute unknown age cases and deaths, tidy

# standardize age groups cases and deaths, using pclm



# cfr
cfr <- function(cases,deaths=NULL,cfr_age=NULL) {
  
  age_dis <- cases/sum(cases)
  if(is.null(cfr_age)) cfr_age <- deaths/cases
  
  sum(age_dis*cfr_age)
  
}

# this one takes age specific cases and case fatality rates
cfr2 <- function(cc,rr){
  sum(cc * rr)
}

# kitagawa

# v1, mirrors below formulas exactly
kitagawa_cfr <- function(c1, r1, c2, r2){
  c1  <- c1 / sum(c1)
  c2  <- c2 / sum(c2)
  
  Tot <- cfr2(c1,r1) - cfr2(c2,r2)
  Aa  <- 0.5 * (cfr2(c1,r1)-cfr2(c2,r1)+cfr2(c1,r2)-cfr2(c2,r2))
  Bb  <- 0.5 * (cfr2(c1,r1)-cfr2(c1,r2)+cfr2(c2,r1)-cfr2(c2,r2))
  list(Diff = Tot, AgeComp = Aa, RateComp = Bb)
}

# v2 simplifies the above
kitagawa_cfr2 <- function(c1, r1, c2, r2){
  c1  <- c1 / sum(c1)
  c2  <- c2 / sum(c2)
  
  Tot <- cfr2(c1, r1) - cfr2(c2, r2)
  Aa  <- 0.5 * (Tot + cfr2(c1, r2) - cfr2(c2, r1))
  Bb  <- 0.5 * (Tot + cfr2(c2, r1) - cfr2(c1, r2))
  list(Diff = Tot, AgeComp = Aa, RateComp = Bb)
}

# v3 is one most would recognize, fewer computations too.
kitagawa_cfr3 <- function(c1, r1, c2, r2){
  c1  <- c1 / sum(c1)
  c2  <- c2 / sum(c2)
  
  Tot <- cfr2(c1, r1) - cfr2(c2, r2)
  Aa  <- sum((c1 - c2) * (r1 + r2) / 2)
  Bb  <- sum((r1 - r2) * (c1 + c2) / 2)
  list(Diff = Tot, AgeComp = Aa, RateComp = Bb)
}
