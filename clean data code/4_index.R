##### CLEAN marketIndex DATA #####
#OHLC data of cafef have many errors(including :missing data, mistake in calculate adjusted price,....)

#setwd---------------------------------------------------------------------------------------


#load libraries------------------------------------------------------------------------------
if(!require(xts)) install.packages("xts")
library(xts)

if(!require(data.table)) install.packages("data.table")
library(data.table)

# Input data --------------------------------------------------------------------------------
files <- list.files(path = "D:/KTrinh/python/rquant/Kapital AMC/input data/4.Index",full.names = TRUE)
marketIndex <- rbindlist(lapply(files, fread))
names(marketIndex) <- c("ticker","date","open","high","low","close","volume")
marketIndex <- unique(marketIndex)

# Process data-------------------------------------------------------------------------------
marketIndex$ticker <- substr(marketIndex$ticker,1,3)
marketIndex <- dcast(marketIndex,date~ticker ,value.var = c("open","high","low","close","volume"))

#date :
marketIndex$date <- as.Date(as.character(marketIndex$date),format = "%Y%m%d")
rm(files)

#Check high,low indez
#VnmarketIndex
nrow(marketIndex[high_VNI < open_VNI| high_VNI< close_VNI]) #7
nrow(marketIndex[low_VNI > open_VNI | low_VNI > close_VNI]) #8

#clean Data
marketIndex[,maxoc_VNI := ifelse(close_VNI>open_VNI,close_VNI,open_VNI)
      ][,high_VNI := ifelse(high_VNI < open_VNI| high_VNI< close_VNI,maxoc_VNI,high_VNI)
        ][,maxoc_VNI:= NULL]

marketIndex[,minoc_VNI := ifelse(open_VNI<close_VNI,open_VNI,close_VNI)
      ][,low_VNI := ifelse(low_VNI > open_VNI | low_VNI > close_VNI,minoc_VNI,low_VNI)
        ][,minoc_VNI := NULL]

#HNXmarketIndex
nrow(marketIndex[high_HNX < open_HNX| high_HNX< close_HNX]) #203
nrow(marketIndex[low_HNX > open_HNX | low_HNX > close_HNX]) #185

#clean Data
marketIndex[,maxoc_HNX := ifelse(close_HNX>open_HNX,close_HNX,open_HNX)
      ][,high_HNX := ifelse(high_HNX < open_HNX| high_HNX< close_HNX,maxoc_HNX,high_HNX)
        ][,maxoc_HNX:= NULL]

marketIndex[,minoc_HNX := ifelse(open_HNX<close_HNX,open_HNX,close_HNX)
      ][,low_HNX := ifelse(low_HNX > open_HNX | low_HNX > close_HNX,minoc_HNX,low_HNX)
        ][,minoc_HNX := NULL]

#check data:
nrow(marketIndex[high_VNI < open_VNI| high_VNI< close_VNI]) #0
nrow(marketIndex[low_VNI > open_VNI | low_VNI > close_VNI]) #0

nrow(marketIndex[high_HNX < open_HNX| high_HNX< close_HNX]) #0
nrow(marketIndex[low_HNX > open_HNX | low_HNX > close_HNX]) #0





