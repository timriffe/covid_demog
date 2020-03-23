library(tidyverse)
library(HMDHFDplus)

IT <- readHMDweb("ITA", "Population", us, pw)  
DE <- readHMDweb("DEUTNP", "Population", us, pw) 
ES <- readHMDweb("ESP", "Population", us, pw)
wmean <- function(x,w){
  sum(x*w)/sum(w)
}

# age within interval checks
IT %>% 
  filter(Year == max(Year)) %>% 
  mutate(Age10 = Age - Age %% 10) %>% 
  group_by(Age10) %>% 
  summarize(MaleMean = wmean(x = Age + .5, w = Male2),
            FemaleMean = wmean(x = Age + .5, w = Female2))

DE %>% 
  filter(Year == max(Year)) %>% 
  mutate(Age10 = Age - Age %% 10) %>% 
  group_by(Age10) %>% 
  summarize(MaleMean = wmean(x = Age + .5, w = Male2),
            FemaleMean = wmean(x = Age + .5, w = Female2))

ES %>% 
  filter(Year == max(Year)) %>% 
  mutate(Age10 = Age - Age %% 10) %>% 
  group_by(Age10) %>% 
  summarize(MaleMean = wmean(x = Age + .5, w = Male2),
            FemaleMean = wmean(x = Age + .5, w = Female2))

# sex ratio within interval checks
SR_IT <- IT %>% 
  filter(Year == max(Year)) %>% 
  mutate(Age10 = Age - Age %% 10) %>% 
  group_by(Age10) %>% 
  summarize(Male1 = sum(Male1),
            Female1 = sum(Female1)) %>% 
  mutate(PM = Male1 / (Male1 + Female1),
         Country = "IT")

SR_DE <- DE %>% 
  filter(Year == max(Year)) %>% 
  mutate(Age10 = Age - Age %% 10) %>% 
  group_by(Age10) %>% 
  summarize(Male1 = sum(Male1),
            Female1 = sum(Female1)) %>% 
  mutate(PM = Male1 / (Male1 + Female1),
         Country = "DE")

SR_ES <- ES %>% 
  filter(Year == max(Year)) %>% 
  mutate(Age10 = Age - Age %% 10) %>% 
  group_by(Age10) %>% 
  summarize(Male1 = sum(Male1),
            Female1 = sum(Female1)) %>% 
  mutate(PM = Male1 / (Male1 + Female1),
         Country = "ES")



rbind(SR_IT, SR_DE, SR_ES) %>% 
  ggplot(mapping = aes(x = Age10, y = PM, color = Country)) + 
  geom_line()
