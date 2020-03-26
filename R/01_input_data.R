

library(googlesheets4)

ss  <- "https://docs.google.com/spreadsheets/d/1LdMsCq7JAgeWpJ-veobTDTzeZ9A3WIAx-ghjF49JDGE"

dat <- sheets_read(ss, skip =1)


do.this <- FALSE
if (do.this){}
# https://github.com/beoutbreakprepared/nCoV2019/
# grabbing from 
library(RCurl)
x <- getURL("https://raw.githubusercontent.com/beoutbreakprepared/nCoV2019/master/latest_data/latestdata.csv")
y <- read.csv(text = x,stringsAsFactors = FALSE)
str(y)
unique(y$outcome)
# needs cleaning
sort(unique(y$age))

# this data will need lots of cleaning.

}