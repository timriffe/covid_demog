
library(here)
source("R/02_data_prep.R")

# pick a standard

ST <- dat %>% 
  filter(Code == "CN11.02.2020")


# dat %>% 
#   filter(Country == "Italy",
#          Sex == "b") %>% 
#   # doing the David Spiegelhalter trick of plotting on 7s
#   ggplot(mapping = aes(x = Age+7, y = ascfr, color = Date))+
#   geom_line() +
#   scale_y_log10() + 
#   ylim(1e-4,.3) +
#   xlim(25,97) + 
#   geom_line(ST,mapping=aes(x=Age+7, y=ascfr),color="black") + 
#   geom_lin(filter(dat,Country = "SouthKorea"))
  

