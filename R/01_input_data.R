

library(googlesheets4)

ss  <- "https://docs.google.com/spreadsheets/d/1LdMsCq7JAgeWpJ-veobTDTzeZ9A3WIAx-ghjF49JDGE"

dat <- sheets_read(ss, skip =1)



