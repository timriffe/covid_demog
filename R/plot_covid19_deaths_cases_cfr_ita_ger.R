rm(list=ls())

library(tidyverse)
library(ggrepel)
library(scales)

#### covid19 deaths
corona_deaths <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv") %>%
  gather(date, deaths, 5:ncol(.)) %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  rename(country = 'Country/Region') %>%  
  group_by(country, date) %>%
  summarise(deaths = sum(deaths)) %>%
  ungroup() %>% 
  mutate(country = case_when(country == "United Kingdom" ~ "UK",
                             country == "Taiwan*" ~ "Taiwan",
                             country == "Korea, South" ~ "South Korea",
                             country == "Taiwan*" ~ "Taiwan",
                             TRUE ~ country))


#### covid19 cases
corona_cases <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv") %>%
  gather(date, cases, 5:ncol(.)) %>%
  mutate(date = as.Date(date, "%m/%d/%y")) %>%
  rename(country = 'Country/Region') %>%  
  group_by(country, date) %>%
  summarise(cases = sum(cases)) %>%
  ungroup() %>% 
  mutate(country = case_when(country == "United Kingdom" ~ "UK",
                             country == "Taiwan*" ~ "Taiwan",
                             country == "Korea, South" ~ "South Korea",
                             country == "Taiwan*" ~ "Taiwan",
                             TRUE ~ country))



#### All data togethter
corona <- corona_cases %>% 
  left_join(corona_deaths) %>% 
  mutate(cfr = deaths / cases)

min_case <- 100

count_included <- c(
  "Germany",
  "Italy"
)

corona_2 <- corona %>%
  filter(country %in% count_included) %>%
  group_by(country) %>%
  ungroup() 

counts <- corona_2 %>% 
  select(country, deaths, cases, date) %>% 
  gather(deaths, cases, key = type, value = val) %>% 
  filter(val != 0,
         date <= as.Date(c('2020-03-29'))) %>% 
  mutate(country_count = paste0(country, "\n", type))

col_country <- c("Italy" = "#2ca25f",
                 "Germany" = "black")



cfrs <- corona_2 %>% 
  select(country, cfr, date) %>% 
  drop_na()

labs <- counts %>%
  group_by(country_count) %>% 
  filter(date == max(date))

labs_cfrs <- cfrs %>%
  group_by(country) %>% 
  filter(date == max(date))

tx <- 6

source(here("Figures/"))

counts %>%
  ggplot(aes(date, val, col = country, linetype = type)) +
  geom_line(size = 1, alpha = .7) +
  scale_y_log10(expand = c(0,0), labels = scales::comma_format(accuracy = 1), 
                breaks = c(1, 10, 100, 1000, 10000, 100000)) +
  scale_x_date(expand = c(0,0), date_breaks = "2 days", 
               labels=date_format("%b %d"),
               limits = as.Date(c('2020-03-01','2020-04-5')))+
  coord_cartesian(clip = "off", ylim = c(1, 300000)) +
  scale_colour_manual(values = c("black", "#2ca25f"))+
  geom_text_repel(data = labs, aes(date, val, label = country_count), nudge_x = 0.3, 
            size = tx * .35, hjust = 0, fontface = "bold", lineheight = .7,
            segment.color = NA, force = .005, direction = "y") +
  theme_classic()+
  labs(x = paste0("Date"), 
       y = "Counts (log scale)")+
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "none",
    plot.margin = margin(5,5,5,5,"mm"),
    axis.text.x = element_text(size = tx, angle = 60, hjust = 1),
    axis.text.y = element_text(size = tx),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1)
  )

ggsave("figure1a.jpg", width = 3, height = 3, dpi = 600)


cfrs %>%
  ggplot(aes(date, cfr, col = country)) +
  geom_line(size = 1, alpha = .7) +
  scale_y_continuous(expand = c(0,0), labels = percent_format(accuracy = 2),
  breaks = seq(0, .12, .02)) +
  scale_x_date(expand = c(0,0), date_breaks = "2 days", 
               labels=date_format("%b %d"),
               limits = as.Date(c('2020-03-01','2020-04-1')))+
  coord_cartesian(clip = "off", ylim = c(0, 0.12)) +
  scale_colour_manual(values = c("black", "#2ca25f"))+
  geom_text(data = labs_cfrs, aes(date, cfr, label = country), nudge_x = 0.3, 
            size = tx * .35, hjust = 0, fontface = "bold") +
  theme_classic()+
  labs(x = paste0("Date"), 
       y = "CFR")+
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "none",
    plot.margin = margin(5,5,5,5,"mm"),
    axis.text.x = element_text(size = tx, angle = 60, hjust = 1),
    axis.text.y = element_text(size = tx),
    axis.title.x = element_text(size = tx + 1),
    axis.title.y = element_text(size = tx + 1)
  )

ggsave("figure1b.jpg", width = 3, height = 3, dpi = 600)


