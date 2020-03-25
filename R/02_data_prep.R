# TR: THIS DOESN"T DO ANYTHING YET, I"LL GET BACK TO IT


# creates object 'dat'
source(here("R/01_input_data.R"))

head(dat)

# first, let's standardize age groups of deaths and cases.
# to 5 or 10-year age groups 0-100.

# 1) redistribute unknown cases and deaths.

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

.data <- dat %>% 
  filter(Country == "Spain",
         Sex == "b",
         Date == "24.03.2020")

standardize_chunk <- function(.chunk, N = 10){
  n <- nrow(.chunk)
  pclm(x = .chunk$Age, 
       y = .chunk$Cases, 
       nlast = .chunk$AgeInt[n])
}


dat %>% 
  nest(Code, Sex) %>% 
  do(redistribute_NAs(.chunk = .data))
  

