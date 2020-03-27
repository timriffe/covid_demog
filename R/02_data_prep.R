
# creates object 'dat'
source(("R/00_functions.R"))
source(("R/01_input_data.R"))



# first, let's standardize age groups of deaths and cases.
# 10-year age groups 0-90+
# where needed, splitting is done using pclm()

dat <- dat %>% 
  # figure out which subsets have both cases and deaths
  group_by(Country, Date, Code, Sex) %>% 
  mutate(keep = all(!is.na(Cases)) & all(!is.na(Deaths))) %>% 
  filter(keep) %>% 
  # distribute, then standardize
  do(redistribute_NAs(.chunk = .data)) %>% 
  do(standardize_chunk(.chunk = .data, N = 10, OA = 90)) %>% 
  unnest(cols = c()) %>% 
  # get back age-specific case fatality rates
  mutate(ascfr = Deaths / Cases,
         ascfr = replace_na(ascfr, 0)) %>% 
  ungroup() %>% 
  mutate(Date = dmy(Date))

# TR: for testing
# .chunk <- dat %>% 
#   # figure out which subsets have both cases and deaths
#   group_by(Country, Date, Code, Sex) %>% 
#   mutate(keep = all(!is.na(Cases)) & all(!is.na(Deaths))) %>% 
#   filter(keep) %>% 
#   do(redistribute_NAs(.chunk = .data)) %>% 
#   filter(Code == "ES25.03.2020" & Sex == "b")

  

