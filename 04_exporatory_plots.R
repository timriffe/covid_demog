library(here)
source(here("R/02_data_prep.R"))

# Italy time series both-sex, with China and USA on top
dat %>% 
  filter(Country == "Italy",
         Sex == "b") %>% 
  # doing the David Spiegelhalter trick of plotting on 7s
  ggplot(mapping = aes(x = Age+7, y = ascfr, color = Date, group = as.factor(Date)))+
  geom_line() +
  scale_y_log10() + 
  ylim(1e-4,.3) +
  xlim(25,97) + 
  geom_line(ST,mapping=aes(x=Age+7, y=ascfr),color="black",size=2) + 
  geom_line(filter(dat,
                   Code == "SK26.03.2020",
                   Sex == "b"),
            mapping=aes(x=Age+7, y=ascfr), color = "red",size=2)+
  geom_line(filter(dat,
                   Country == "USA",
                   Sex == "b"),
            mapping=aes(x=Age+7, y=ascfr), color = "green",size=2)


# Spain time series both-sex
dat %>% 
  filter(Country == "Spain",
         Sex == "b") %>% 
  # doing the David Spiegelhalter trick of plotting on 7s
  ggplot(mapping = aes(x = Age+7, y = ascfr, color = Date, group = interaction(Code)))+
  geom_line() +
  scale_y_log10() + 
  ylim(1e-4,.6) +
  xlim(25,97) 

library(colorspace)
# Spain both sexes
dat %>% 
  filter(Country == "Spain",
         Sex == "m") %>% 
  # doing the David Spiegelhalter trick of plotting on 7s
  ggplot(mapping = aes(x = Age+7, y = ascfr, color = Date, group = interaction(Code))) +
  geom_line() +
  scale_y_log10() + 
  ylim(1e-4,.5) +
  xlim(25,97) 

dat %>% 
  filter(Country == "Spain",
         Sex == "f") %>% 
  # doing the David Spiegelhalter trick of plotting on 7s
  ggplot(mapping = aes(x = Age+7, y = ascfr, color = Date, group = interaction(Code))) +
  geom_line() +
  scale_y_log10() + 
  ylim(1e-4,.5) +
  xlim(25,97) 

# comparing one both-sex sample from each country

codes <- c("ES25.03.2020","ITinfo26.03.2020","SK26.03.2020", "CN11.02.2020","FR15.03.2020","US16.03.2020","DE25.03.2020","NYC24.03.2020")

dat %>% pull(Code) %>% unique()

library(directlabels)
require(scales)

dat %>% 
  filter(Sex == "b",
         Code %in% codes,
         Age >= 30) %>% 
  ggplot(mapping = aes(x = Age+7, y = ascfr*1000, color = Country)) +
  geom_line(size = 2) +
 # xlim(25,97) +
  geom_dl(aes(label=Country),method="first.points")+
  scale_x_continuous(labels = scales::comma)+
  scale_y_log10() 
