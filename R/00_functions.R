

# session setup

# TODO: set this up with pacman or renv in a separate step
library(here)
library(tidyverse)
library(ungroup)
library(DemoTools)
# 

# --------------------------------
# redistribute unknown age cases and deaths, tidy
# designed for tidy pipeline. Changes number of rows,
# so do it inside do()
redistribute_NAs <- function(.chunk){
  if (any(.chunk$Age == "UNK")){
    UNK <- .chunk %>% filter(Age == "UNK")
    KN  <- .chunk %>% filter(Age != "UNK")
    .chunk <- 
      KN %>% mutate(Cases = Cases + (Cases / sum(Cases)) * UNK$Cases,
                    Deaths = Deaths + (Deaths / sum(Deaths)) * UNK$Deaths)
  }
  .chunk
}
# --------------------------------
# standardize age groups cases and deaths, using pclm
# designed for tidy pipeline. Changes number of rows,
# so do it inside do()
standardize_chunk <- function(.chunk, N = 10){
  
  n       <- nrow(.chunk)
  nlast   <- .chunk %>% pull(AgeInt) %>% "[["(n)
  x       <- .chunk %>% pull(Age) %>% unlist()
  y_cases <- .chunk %>% pull(Cases) %>% unlist()
  y_deaths <- .chunk %>% pull(Deaths) %>% unlist()
  offset  <- pclm(x = x, 
                  y = y_cases, 
                  nlast = nlast,
                  control = list(lambda = 100))$fitted
  
  # age-specific case fataity rates, single ages.
  ascfr  <- pclm(x = x,
                 y = y_deaths,
                 offset = offset,
                 nlast = nlast,
                 control = list(lambda = 100))$fitted
  deaths <- ascfr * offset
  # sry hard coded for now
  x1     <- 0:104
  
  # group deaths and cases back up to N-year age groups
  Dhat   <- groupAges(deaths, Age = x1, N = N, OAnew = 100)
  Chat   <- groupAges(offset, Age = x1, N = N, OAnew = 100)
  Age    <- names2age(Dhat)
  AgeInt <- age2int(Age,OAvalue = 5)
  tibble(Age = Age, AgeInt = AgeInt, Cases = Chat, Deaths = Dhat)
}


# cfr CD's version
cfr <- function(cases,deaths=NULL,cfr_age=NULL) {
  
  age_dis <- cases/sum(cases)
  if(is.null(cfr_age)) cfr_age <- deaths/cases
  
  sum(age_dis*cfr_age)
  
}

# this one takes age specific cases and case fatality rates, just a sum product
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
