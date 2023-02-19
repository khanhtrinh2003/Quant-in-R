#### Code for merge data ###

#setwd---------------------------------------------------------------------------------------
rm(list = ls())
setwd("D:/KTrinh/python/quant/Kapital AMC")
#load libraries------------------------------------------------------------------------------
if(!require(xts)) install.packages("xts")
library(xts)

if(!require(data.table)) install.packages("data.table")
library(data.table)

#User defined function:----------------------------------------------------------------------



#input data :--------------------------------------------------------------------------------
source("D:/KTrinh/python/rquant/Kapital AMC/clean data code/3_OHLCadj.R")
source("D:/KTrinh/python/rquant/Kapital AMC/clean data code/4_index.R")
source("D:/KTrinh/python/rquant/Kapital AMC/clean data code/5_financialReport.R")
source("D:/KTrinh/python/rquant/Kapital AMC/clean data code/6_CapClassification.R")

#merged data:
dataFull <- OHLCadj
rm(OHLCadj)

setkey(dataFull,ticker,date)
setkey(adjustedMarketValue,ticker,date)
dataFull <- adjustedMarketValue[dataFull]
rm(adjustedMarketValue)

setkey(dataFull,ticker,year,quarter)
setkey(financialReport,ticker,year,quarter)
dataFull <- financialReport[dataFull]
rm(financialReport)

setkey(dataFull,date)
setkey(marketIndex,date)
dataFull<- marketIndex[dataFull]
rm(marketIndex)

setkey(dataFull,ticker)
setkey(vietstockIndustryClassification,ticker)
dataFull <- vietstockIndustryClassification[dataFull]
rm(vietstockIndustryClassification)



#output data:
save(dataFull,file = "D:/KTrinh/python/rquant/Kapital AMC/output data/dataFull.Rdata")


