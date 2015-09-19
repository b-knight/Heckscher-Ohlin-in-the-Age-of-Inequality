################################################################################
## File name: 	Reexamining_Heckscher-Ohlin.R
## Date: 		    August 29, 2015
## Author: 		  Benjamin S. Knight (knight.benjamin@gmail.com)
## Purpose: 	  Downloads and creates data tables of economic inequality from
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
require(haven)
# NOTE: You may need to update Java from 
# https://support.apple.com/kb/DL1572?locale=en_US to run the xlsx package 
require(xlsx)
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
  rm(fileUrl_1)
}
if (!file.exists("EHII-UPDATED-10-30-2013.xlsx")) {
  fileUrl_2 <- "http://utip.gov.utexas.edu/data/EHII-UPDATED-10-30-2013.xlsx"
  download.file(fileUrl_2, destfile = "./EHII-UPDATED-10-30-2013.xlsx", 
                method = "curl")
  rm(fileUrl_2)
}
if (!file.exists("SWIIDv5_0.zip")) {
  fileUrl_3 <- "https://dataverse.harvard.edu/api/access/datafile/2503756"
  download.file(fileUrl_3, destfile = "./SWIIDv5_0.zip", method = "curl") # 11.1mb
  rm(fileUrl_3)
}
# Read the downloaded data into R
WIID <- data.table(read.xls("WIID3b_1.xls", sheet = "Sheet1")) # 4mb
EHII <- data.table(read.xlsx2("EHII-UPDATED-10-30-2013.xlsx", 
                              sheetName = "Sheet1")) # 70kb
unzip("SWIIDv5_0.zip", unzip = "internal")
setwd("./SWIIDv5_0")
SWIID <- data.table(read_dta("SWIIDv5_0.dta"))



