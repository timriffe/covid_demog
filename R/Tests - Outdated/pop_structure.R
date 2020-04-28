
# TR: what would a 2-stage decomposition look like?
library(here)
source("R/02_data_prep.R")
library(HMDHFDplus)
library(DemoDecomp)

# decide some standard patterns

DE <- dat %>% 
  filter(Code == "DE25.03.2020",
         Sex == "b")
IT <- dat %>% 
  filter(Code == "IT26.03.2020",
         Sex == "b")
# 
cfr_pop_trans_mort <- function(pop,   # underlying population
                               ascr,  # age-specific case rate
                               ascfr){# age-specific case fatality rate

  cases <- pop * ascr
  wmean(x = ascfr, w = cases)
}
# need a vec version of the above...
vec_cfr_pop_trans_mort <- function(pars){
  n3 <- length(pars)
  dim(pars) <- c(n3 / 3, 3)
  cfr_pop_trans_mort(pop = pars[,1], ascr = pars[,2], ascfr = pars[,3])
}


pop1 <- readHMDweb("DEUTNP","Population",us,pw) %>% 
  filter(Year == max(Year)) %>% 
  pull(Total2) %>% 
  groupAges(Age = 0:110, N = 10, OAnew = 90)
ascr1  <- DE$Cases / pop1
ascfr1 <- DE$ascfr



pop2 <- readHMDweb("ITA","Population",us,pw) %>% 
  filter(Year == max(Year)) %>% 
  pull(Total2) %>% 
  groupAges(, Age = 0:110, N = 10, OAnew = 90)

ascr2  <- IT$Cases / pop2
ascfr2 <- IT$ascfr



cfr_pop_trans_mort(pop1, ascr1, ascfr1)
cfr_pop_trans_mort(pop2, ascr2, ascfr2)

cc <- horiuchi(vec_cfr_pop_trans_mort, 
         pars1 = c(pop1,ascr1,ascfr1),
         pars2 = c(pop2,ascr2,ascfr2),
         N = 20)
dim(cc) <- c(length(cc)/3,3)
comp <- colSums(cc)

comp / sum(comp) * 100

# -------------------------------- #
# Kitagawa test                    #
# -------------------------------- # 

vec_cfr <- function(pars){
  dim(pars) <- c(length(pars)/2,2)
  cfr2(pars[,1], pars[,2])
}
vec_cfr(c(IT$Cases / sum(IT$Cases), IT$ascfr))
cc1 <- DE$Cases / sum(DE$Cases)
cc2 <- IT$Cases / sum(IT$Cases)
ccK <- horiuchi(vec_cfr, 
               pars1 = c(cc1,ascfr1),
               pars2 = c(cc2,ascfr2),
               N = 20)
dim(ccK) <- c(length(ccK)/2,2)
compK <- colSums(ccK)
compK # this corroborates Kitagawa, but the above puts our result in question.
