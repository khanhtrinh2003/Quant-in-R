#### Market value data + classification data ###

#setwd---------------------------------------------------------------------------------------

#load libraries------------------------------------------------------------------------------
if(!require(xts)) install.packages("xts")
library(xts)

if(!require(data.table)) install.packages("data.table")
library(data.table)

#User defined function:----------------------------------------------------------------------



#Input data----------------------------------------------------------------------------------
files <- list.files(path = "D:/KTrinh/python/rquant/Kapital AMC/input data/6.industy classification",full.names = TRUE)
Index <- load(files)
rm(files,Index)
vietstockIndustryClassification <- data.table(vietstockIndustryClassification)

files <- list.files(path = "D:/KTrinh/python/rquant/Kapital AMC/input data/7.market value",full.names = TRUE)
Index <- load(files)
rm(files,Index)
adjustedMarketValue <- data.table(adjustedMarketValue)

#process data-------------------------------------------------------------------------------
#classification:
vietstockIndustryClassification <- vietstockIndustryClassification[,c(1:5)]
names(vietstockIndustryClassification) <- c("ticker","companyName","sector","industry","subindustry")


#adjusted market value:
adjustedMarketValue[,date:= as.Date(creationDate)]
adjustedMarketValue <- adjustedMarketValue[,c(1,2,4)]
names(adjustedMarketValue) <- c("ticker","marketCap","date")


