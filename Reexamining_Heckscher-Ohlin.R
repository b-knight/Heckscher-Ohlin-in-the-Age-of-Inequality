################################################################################
## File name: 	Reexamining_Heckscher-Ohlin.R
## Started:     August 29, 2015
## Updated:     September 20, 2015
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
dropped_countries <- c("Ussr", "Belarus", "Puerto Rico", "Taiwan", "West Bank And Gaza", 
                       "East Timor", "Yugoslavia", "Bhutan", "Cape Verde", "Chad", 
                       "Comoros", "Congo", "Czechoslovakia", "Djibouti", "Guinea",
                       "Guinea-Bissau", "Guyana", "Laos", "Lebanon", "St. Lucia",
                       "Maldives", "Mali", "Mauritania", "Micronesia, Federated States Of",
                       "Montenegro", "Namibia", "Niger", "Reunion", "Sao Tome And Principe",
                       "Serbia", "Serbia And Montenegro", "Sierra Leone", "Tajikistan", 
                       "Turkmenistan", "Uzbekistan", "Vietnam")
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
WIID$Country <- as.character(WIID$Country)
WIID$Country[WIID$Country == "Bosnia And Herzegowina"] <- "Bosnia and Herzegovina"
WIID$Country[WIID$Country == "Central Affrican Republic"] <- "Central African Republic"
WIID$Country[WIID$Country == "Congo, The Drc"] <- "Congo"
WIID$Country[WIID$Country == "Cote D'Ivoire"] <- "Ivory Coast"
WIID$Country[WIID$Country == "Korea, Republic Of"] <- "Republic of Korea"
WIID$Country[WIID$Country == "Slovak Republic"] <- "Slovakia"
WIID$Country[WIID$Country == "Macedonia, Fyr"] <- "Macedonia"
WIID$Country[WIID$Country == "Slovak Republic"] <- "Slovakia"
WIID$Country[WIID$Country == "Trinidad And Tobago"] <- "Trinidad and Tobago"
WIID$Country[WIID$Country == "Zimbabwe\xa0"] <- "Zimbabwe"
WIID <- WIID[order(WIID$Country),]
rownames(WIID) <- seq(length=nrow(WIID))

# Clean the EHII data
library(data.table)
EHII <- setnames(EHII, old = c("X1963", "X1964", "X1965", "X1966", "X1967",
        "X1968", "X1969", "X1970", "X1971", "X1972", "X1973", "X1974", "X1975",   
        "X1976", "X1977", "X1978", "X1979", "X1980", "X1981", "X1982", "X1983",   
        "X1984", "X1985", "X1986", "X1987", "X1988", "X1989", "X1990", "X1991",   
        "X1992", "X1993", "X1994", "X1995", "X1996", "X1997", "X1998", "X1999",   
        "X2000", "X2001", "X2002", "X2003", "X2004", "X2005", "X2006", "X2007",
        "X2008"), new = c("1963", "1964", "1965", "1966", "1967", "1968", "1969",
        "1970", "1971", "1972", "1973", "1974", "1975", "1976", "1977", "1978",
        "1979", "1980", "1981", "1982", "1983", "1984", "1985", "1986", "1987",
        "1988", "1989", "1990", "1991", "1992", "1993", "1994", "1995", "1996",
        "1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004", "2005",
        "2006", "2007", "2008"))
EHII <- setnames(EHII, old = "Code..", new = "drop")
EHII$drop <- NULL
EHII$Code <- NULL
EHII$Country <- as.character(EHII$Country)
EHII$Country[EHII$Country == "Bolivia (Plurinational State of)"] <- "Bolivia"
EHII$Country[EHII$Country == "Iran (Islamic Republic of)"] <- "Iran"
EHII$Country[EHII$Country == "China (Hong Kong SAR)"] <- "Hong Kong"
EHII$Country[EHII$Country == "Myanmar (Burma)"] <- "Myanmar"
EHII$Country[EHII$Country == "Peru*"] <- "Peru"
EHII$Country[EHII$Country == "Republic of Moldova"] <- "Moldova"
EHII$Country[EHII$Country == "Côte d'Ivoire"] <- "Ivory Coast"
EHII$Country[EHII$Country == "Syrian Arab Republic"] <- "Syria"
EHII$Country[EHII$Country == "The f. Yugosl. Rep. of Macedonia"] <- "Macedonia"
EHII$Country[EHII$Country == "United Republic of Tanzania"] <- "Tanzania"
EHII$Country[EHII$Country == "United States of America"] <- "United States"
dropped_countries_EHII <- c("China (Macao SAR)", "China (Taiwan Province)",
                            "Eritrea", "Germany, Dem.Rep", "Germany, Fed.Rep",
                            "Kuwait", "Libyan Arab Jamahiriya", "Oman",
                            "Puerto Rico", "Tonga", "United Arab Emirates",
                            "Yugoslavia")
EHII <- filter(EHII, !(Country %in% dropped_countries_EHII))
EHII <- EHII[order(EHII$Country),] 


