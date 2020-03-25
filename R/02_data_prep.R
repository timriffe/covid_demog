# TR: THIS DOESN"T DO ANYTHING YET, I"LL GET BACK TO IT


# creates object 'dat'
source(here("R/01_input_data.R"))
source(here("R/00_functions.R"))


# first, let's standardize age groups of deaths and cases.
# to 5 or 10-year age groups 0-100.

# 1) redistribute unknown cases and deaths.


# TR: Q: I'
dat <- dat %>% 
  filter(Country != "Canada") %>% 
  group_by(Country, Date, Code, Sex) %>% 
  do(redistribute_NAs(.chunk = .data)) %>% 
  do(standardize_chunk(.chunk = .data)) %>% 
  unnest(cols = c())

  



  

