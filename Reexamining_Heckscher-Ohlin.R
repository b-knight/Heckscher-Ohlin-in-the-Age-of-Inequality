################################################################################
## File name: 	Reexamining_Heckscher-Ohlin.R
## Date:        August 29, 2015
## Author:      Benjamin S. Knight (knight.benjamin@gmail.com)
## Purpose: 	Downloads and creates data tables of economic inequality from
##              three major datasets: The Standardized World Income Inequality 
##              Database (SWIID) by Frederick Solt, the Estimated Household 
##              Income Inequality Data Set by the University of Texas Inequality 
##              Project, and the UNU-WIDER World Income Inequality Database 
##              (WIID) from the United Nations University World Institute for 
##              Development Economics Research
################################################################################

# clear working environment
rm(list=ls())
# install necessary packages
# install.packages("xlsx")
# install.packages("gdata")
# install.packages("data.table")
devtools::install_github("hadley/haven")
require(haven)     # NOTE: You may need to update Java from 
require(xlsx)      # https://support.apple.com/kb/DL1572?locale=en_US to run the xlsx package 
library(gdata)
library(readstata13)
library(data.table)
setwd(paste("/Users/benjaminknight/Documents",
            "/Personal Training/Trade Project",
            "/GitVersion", sep=""))
if (!file.exists("data")) {dir.create("data")}
setwd("./data")
if (!file.exists("WIID3b_1.xls")) {
  fileUrl_1 <- paste("http://www.wider.unu.edu/research/WIID3-0B",
                     "/en_GB/wiid/_files/92393927664936620",
                     "/default/WIID3b.xls", sep="")
  download.file(fileUrl_1, destfile = "./WIID3b_1.xls")
  rm(fileUrl_1)}
if (!file.exists("EHII-UPDATED-10-30-2013.xlsx")) {
  fileUrl_2 <- "http://utip.gov.utexas.edu/data/EHII-UPDATED-10-30-2013.xlsx"
  download.file(fileUrl_2, destfile = "./EHII-UPDATED-10-30-2013.xlsx", 
                method = "curl")
  rm(fileUrl_2)}
if (!file.exists("SWIIDv5_0.zip")) {
  fileUrl_3 <- "https://dataverse.harvard.edu/api/access/datafile/2503756"
  download.file(fileUrl_3, destfile = "./SWIIDv5_0.zip", method = "curl") # 11.1mb
  rm(fileUrl_3)}
# Read the downloaded data into R
WIID <- data.table(read.xls("WIID3b_1.xls", sheet = "Sheet1")) # 4mb
EHII <- data.table(read.xlsx2("EHII-UPDATED-10-30-2013.xlsx", 
                              sheetName = "Sheet1")) # 70kb
unzip("SWIIDv5_0.zip", unzip = "internal")
setwd("./SWIIDv5_0")
SWIID <- data.table(read_dta("SWIIDv5_0.dta"))

# Clean the WIID data
library(dplyr)
WIID <- select(WIID, Countrycode2, Countrycode3, Country, Year, Gini, Quality)
WIID$Quality <- as.character(WIID$Quality)
WIID <- filter(WIID,  Year >= 1963 & Year <= 2008)
dropped_countries <- c("Ussr", "Puerto Rico", "Taiwan", "West Bank And Gaza", "East Timor", "Yugoslavia")
WIID <- filter(WIID,  !(Country %in% dropped_countries))
WIID$Quality[WIID$Quality == "High"] <- 3              # assign numeric code to the quality estimate
WIID$Quality[WIID$Quality == "Average"] <- 2
WIID$Quality[WIID$Quality == "Low"] <- 1
WIID$Quality[WIID$Quality == "Not known"] <- 0
WIID$Quality <- as.numeric(WIID$Quality)                                                 
WIID$ID <- as.character(paste(WIID$Country, WIID$Year, sep = ""))                    # create an ID variable
max <- aggregate(x = WIID$Quality, by = list(WIID$Country, WIID$Year), FUN = "max")  # create a max value
max$ID <- as.character(paste(max$Group.1, max$Group.2, sep = ""))                    # create an ID variable 
combined <- merge(WIID, max, by = "ID")                                              # merge data sets
combined <- select(combined, Countrycode2, Countrycode3, Country, Year, Gini, Quality, x)
combined <- combined[combined$Quality >= combined$x]
library(doBy)
combined <- summaryBy(Gini ~ Country + Year, data = combined)
library(reshape2)
WIID <- dcast(combined, Country ~ Year, value.var = "Gini.mean")
rm(max, combined, dropped_countries)





