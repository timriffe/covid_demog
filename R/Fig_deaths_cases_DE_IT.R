### Monitoring trends and differences in COVID-19 case fatality  ##############
### rates using decomposition methods: A demographic perspective ##############

  ### Last updated: 2020-07-16 09:50:25 CEST
  
  ### Contact:
  ### riffe@demogr.mpg.de
  ### acosta@demogr.mpg.de
  ### dudel@demogr.mpg.de


### Packages ##################################################################

  library(tidyverse)
  library(ggrepel)
  library(scales)


### Load data #################################################################

  # Load data
  db_gh <- read_csv("Data/inputdata.csv")

    
### Aggregate data ############################################################
  
  # Filter date
  db_gh$Date <- as.Date(db_gh$Date,"%d.%m.%y")
  db_gh2 <- db_gh %>% filter(Date<=as.Date("30.06.2020","%d.%m.%y"))

  # Sum data over age groups
  db_gh2 <- db_gh2 %>% 
            filter(Country == "Germany" | Country == "Italy",
                   Region == "All",
                   Sex == "b") %>% 
            group_by(Country, Code,Date) %>% 
            summarise(Cases = sum(Cases),
                      Deaths = sum(Deaths))
  
  # Exclude bolletino 
  db_gh2 <- db_gh2 %>%
    filter(str_sub(Code, 1, 5) != "ITbol")
  
  # Sort by date
  db_gh2 <- db_gh2 %>% group_by(Country) %>% arrange(Date)
  
  # Smooth reporting issues
  for(country in unique(db_gh2$Country)) {
    
    days <- db_gh2$Date[db_gh2$Country==country]
    
    for(day in 2:length(days)) {
      current <- db_gh2$Cases[db_gh2$Country==country & db_gh2$Date==days[day]]
      previous <- db_gh2$Cases[db_gh2$Country==country & db_gh2$Date==days[day-1]]
      
      if(current<previous) db_gh2$Cases[db_gh2$Country==country & db_gh2$Date==days[day]] <- previous
      
    }
    
  }
  
  
  
### Plot settings #############################################################

  # Set colors
  col_country <- c("Italy" = "#2ca25f",
                   "Germany" = "black")

  # Axis
  labs <- db_gh2 %>%
    group_by(Country) %>% 
    filter(Cases == max(Cases)) %>% 
    mutate(Cases = Cases + 3000)

  # Including all reports
  tx <- 6
  lim_x <- 240000
  
  
### Plot ######################################################################

  db_gh2 %>% 
    ggplot(aes(Cases, Deaths, col = Country))+
    geom_line(size = 1, alpha = .9)+
    scale_x_continuous(expand = c(0,0), breaks = seq(0, 300000, 50000), limits = c(0, lim_x + 20000), labels = comma)+
    scale_y_continuous(expand = c(0,0), breaks = seq(0, 40000, 5000), limits = c(0, 40000), labels = comma)+
    annotate("segment", x = 0, y = 0, xend = lim_x, yend = lim_x * .02, colour = "grey40", size = .5, alpha = .3, linetype = 2)+
    annotate("segment", x = 0, y = 0, xend = lim_x, yend = lim_x * .05, colour = "grey40", size = .5, alpha = .3, linetype = 2)+
    annotate("segment", x = 0, y = 0, xend = lim_x, yend = lim_x * .10, colour = "grey40", size = .5, alpha = .3, linetype = 2)+
    annotate("segment", x = 0, y = 0, xend = lim_x, yend = lim_x * .15, colour = "grey40", size = .5, alpha = .3, linetype = 2)+
    annotate("text", label = "2% CFR", x = lim_x + 1000, y = lim_x * .02,
             color="grey30", size = tx * .3, alpha = .6, hjust = 0, lineheight = .8) +
    annotate("text", label = "5% CFR", x = lim_x + 1000, y = lim_x * .05,
             color="grey30", size = tx * .3, alpha = .6, hjust = 0, lineheight = .8) +
    annotate("text", label = "10% CFR", x = lim_x + 1000, y = lim_x * .10,
             color="grey30", size = tx * .3, alpha = .6, hjust = 0, lineheight = .8) +
    annotate("text", label = "15% CFR", x = lim_x + 1000, y = lim_x * .15,
             color="grey30", size = tx * .3, alpha = .6, hjust = 0, lineheight = .8) +
    scale_colour_manual(values = c("black", "#2ca25f"))+
    geom_text(data = labs, aes(Cases, Deaths, label = Country),
              size = tx * .35, hjust = 0, fontface = "bold") +
    theme_classic()+
    labs(x = "Cases", 
         y = "Deaths")+
    theme(
      panel.grid.minor = element_blank(),
      legend.position = "none",
      plot.margin = margin(5,5,5,5,"mm"),
      axis.text.x = element_text(size = tx),
      axis.text.y = element_text(size = tx),
      axis.title.x = element_text(size = tx + 1),
      axis.title.y = element_text(size = tx + 1)
    )
  
  # Save
  ggsave("Output/Fig_1.jpg", width = 4, height = 3, dpi = 600)

