

# session setup

# TODO: set this up with pacman or renv in a separate step
library(here)
library(tidyverse)
library(ungroup)
library(DemoTools)
library(lubridate)
library(data.table)
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
standardize_chunk <- function(.chunk, N = 10, OA = 90){
  
  n       <- nrow(.chunk)
  nlast   <- .chunk %>% pull(AgeInt) %>% "[["(n)
  x       <- .chunk %>% pull(Age) %>% unlist()
  xi      <- .chunk %>% pull(AgeInt) %>% unlist()
  
  # indicator
  isN     <- x %% N == 0 & xi == N & x < OA
  
  # incoming counts
  Din    <- .chunk %>% pull(Deaths) %>% unlist()
  Cin    <- .chunk %>% pull(Cases) %>% unlist()
  
  # if we're already in 10-year age groups, skip this altogether
  if (!all(isN[x < OA]) | OA > max(x)){
   
    Chat  <- pclm(x = x, 
                    y = Cin, 
                    nlast = nlast,
                    control = list(lambda = 100))$fitted
    
    # age-specific case fataity rates, single ages.
    ascfr  <- pclm(x = x,
                   y = Din,
                   offset = Chat,
                   nlast = nlast,
                   control = list(lambda = 100))$fitted
    Dhat   <- ascfr * Chat
    # sry hard coded for now
    x     <- 0:104
  } else {
    Dhat <- Din
    Chat <- Cin
  }
  
  # group deaths and cases back up to N-year age groups if graduated,
  # and for both cases group DOWN to OA.
  Dhat      <- groupAges(Dhat, Age = x, N = N, OAnew = OA)
  Chat      <- groupAges(Chat, Age = x, N = N, OAnew = OA)
  
  Age       <- names2age(Dhat)
  AgeInt    <- c(rep(N,length(Age) - 1),105 - OA + 1)
  
  # let's not overwrite (age groups could be mixed including
  # canonical values)
  # these indicators will only hold if incoming ages & intervals match
  # outgoing ages & intervals
  n               <- min(length(Age),length(x))
  ind             <- 1:n
  indL            <- Age[ind] == x[ind] & AgeInt[ind] == xi[ind]
  indR            <- x[ind] == Age[ind] & xi[ind] == AgeInt[ind]
  
  Dhat[ind][indL] <- Din[ind][indR]
  Chat[ind][indL] <- Cin[ind][indR]
  
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

wmean <- function(x,w){
  sum(x*w)/sum(w)
}

# TR: this one returns more
kitagawa_cfr4 <- function(c1, r1, c2, r2){
  c1  <- c1 / sum(c1)
  c2  <- c2 / sum(c2)
  
  Tot <- cfr2(c1, r1) - cfr2(c2, r2)
  Aa  <- sum((c1 - c2) * (r1 + r2) / 2)
  Bb  <- sum((r1 - r2) * (c1 + c2) / 2)
  list(Diff = Tot, 
       AgeComp = Aa,
       RateComp = Bb, 
       CFR1 = wmean(r1,c1), 
       CFR2 = wmean(r2,c2))
}
