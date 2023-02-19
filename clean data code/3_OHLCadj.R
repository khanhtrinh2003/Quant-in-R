##### CLEAN OHLC-V DATA #####
  #OHLC data of cafef have many errors(including :missing data, mistake in calculate adjusted price,....)

#setwd---------------------------------------------------------------------------------------


#load libraries------------------------------------------------------------------------------
  if(!require(xts)) install.packages("xts")
  library(xts)
  
  if(!require(data.table)) install.packages("data.table")
  library(data.table)

#User defined function:----------------------------------------------------------------------
  #Describe: only fill NA of stocks that missing value (middle value), 
  #not fill stock out or when it not public
  f_fillNa <- function(var){
    dt1 = na.locf(var, na.rm = FALSE,fromLast = TRUE)
    dt2 = na.locf(var, na.rm = FALSE,fromLast = FALSE)
    dt = ifelse(is.na(dt1),dt1,dt2)
    return(dt)
  }
    #test
  a<-c(NA,1,2,3,NA,5,6,NA)
  f_fillNa(a)  
  
  #t?nh returns
  f_ROC = function(var,i=1){
    if(i>=0){
      a= var/ shift(var, n=i, fill=NA, type="lag") -1  
    }
    else{
      a= shift(var, n=abs(i), fill=NA, type="lead")/var -1
    }
  }     
#Input data----------------------------------------------------------------------------------
  files <- list.files(path = "D:/KTrinh/python/rquant/Kapital AMC/input data/2.stock price adjusted",full.names = TRUE)
  tmp.OHLC <- lapply(files, fread)
  
  #add exchange:
    #HNX
    tmp.OHLC_HNX <- tmp.OHLC[[1]]
    tmp.OHLC_HNX$ex <-"HNX"
    #HSX
    tmp.OHLC_HSX <- tmp.OHLC[[2]]
    tmp.OHLC_HSX$ex <-"HSX"
    #UPCOM
    tmp.OHLC_UPCOM <- tmp.OHLC[[3]]
    tmp.OHLC_UPCOM$ex <-"UPCOM"
    
  #rbind + names
    tmp.OHLC <- rbind(tmp.OHLC_HNX,tmp.OHLC_HSX,tmp.OHLC_UPCOM)
    tmp.OHLC <- unique(tmp.OHLC)
    names(tmp.OHLC) <- c("ticker","date","open","high","low","close","volume","exchange")
    rm(tmp.OHLC_HNX,tmp.OHLC_HSX,tmp.OHLC_UPCOM)

#Process data -------------------------------------------------------------------------------
  dim(tmp.OHLC)
  #process date
    tmp.OHLC[,date:= as.Date(as.character(date),format="%Y%m%d")]
  
  #fill all data
    tmp.ticker <- unique(tmp.OHLC$ticker)
    tmp.date <- unique(tmp.OHLC$date)  
    OHLCadj <- data.table(merge(tmp.ticker,tmp.date))
    names(OHLCadj)<- c("ticker","date")
    setkey(OHLCadj,ticker,date)
    setkey(tmp.OHLC,ticker,date)
    #merge data
    OHLCadj <- tmp.OHLC[OHLCadj]
    #fill data
    OHLCadj[,':='(open=f_fillNa(open),
                  high=f_fillNa(high),
                  low=f_fillNa(low),
                  close=f_fillNa(close),
                  exchange =f_fillNa(exchange))
                  ,by="ticker"]
    OHLCadj <- OHLCadj[is.na(open)==FALSE]
    
  #Create additional variable
    OHLCadj[,':='(year=year(date),
                  quarter =quarter(date),
                  month=month(date),
                  weekdays=weekdays(date)
    ),]

#summary data + fix data-------------------------------------------------------------------
  #date is Sat, Sun
    nrow(OHLCadj[weekdays%in%c("Saturday","Sunday")]) #7 not 6699
    #Treatment
    OHLCadj <- OHLCadj[weekdays%in%c("Monday","Tuesday","Wednesday","Thursday","Friday")]
    
  #high + low price:
    nrow(OHLCadj[high<open | high<close]) #440827
    nrow(OHLCadj[low>open | low>close]) #4744
    #Treatment
    #high price
    OHLCadj <- OHLCadj[,maxoc:= ifelse(open>close,open,close),
                       ][,high:=ifelse(high<maxoc,maxoc,high)
                         ] 
    #low price
    OHLCadj <- OHLCadj[,minoc:= ifelse(open<close,open,close),
                       ][,low:=ifelse(low>minoc,minoc,low)
                         ] 
    OHLCadj <- OHLCadj[,':='(maxoc=NULL,minoc=NULL)]
  #test:
    nrow(OHLCadj[high<open | high<close]) #0
    nrow(OHLCadj[low>open | low>close]) #0
    setcolorder(OHLCadj,c("ticker","year","quarter","month","weekdays","date","exchange","open","high","low","close","volume"))

  #add returns:
    OHLCadj[,return:=f_ROC(close),by=ticker]
    
rm(list = ls()[ls()!='OHLCadj'])
