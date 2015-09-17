rm(list=ls())
setwd(paste("/Users/benjaminknight/Documents",
            "/Personal Training/Trade Project/GitVersion", sep=""))
# install.packages("knitr")
library(knitr)
knit2html("HO.Rmd") 