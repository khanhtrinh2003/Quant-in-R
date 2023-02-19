##### CLEAN OHLC-V DATA #####

#setwd---------------------------------------------------------------------------------------

#load libraries------------------------------------------------------------------------------
if(!require(xts)) install.packages("xts")
library(xts)

if(!require(data.table)) install.packages("data.table")
library(data.table)

#User defined function:----------------------------------------------------------------------



#Input data----------------------------------------------------------------------------------
files <- list.files(path = "D:/KTrinh/python/rquant/Kapital AMC/input data/5.financial report",full.names = TRUE)
Index <- load(files)
rm(files,Index)
financialReport <- data.table(financialReport)

#Process data--------------------------------------------------------------------------------
#Split data:
tmp.BS <- financialReport[,c(1:27,63:80)]
tmp.BS <- tmp.BS[CurrentAssets >0]
setkey(tmp.BS,stockName,timeOfData)

tmp.IS <- financialReport[,c(1:2,29:44,47:60,81:86)]
tmp.IS <- tmp.IS[is.na(GrossSaleRevenues)==FALSE]
setkey(tmp.IS,stockName,timeOfData)

#Merge back data: 
financialReport <- tmp.IS[tmp.BS]
rm(tmp.BS,tmp.IS)

#set new names:
names(financialReport) <- c("ticker", "timeOfdata", "Sales_gross", 
                            "Sales_deduc", "Sales_net", "COGS", "GrossProfit", "Fin_rev", 
                            "Fin_expense", "Selling_expense", "Managing_expense", 
                            "Opearting_income", "Other_income", "Other_expense", 
                            "Other_profit", "EBT", "Tax_expense", "Income", "insu_revenue", 
                            "insu_reinsuranceRev", "insu_tangGiamDuPhongToanHoc", "insu_hoaHongNhuongTaiBH", 
                            "insu_thuKhacKinhDoanhBH", "insu_chiBoithuongBaoHiemGoc", "insu_chiBoiThuongTaiBaoHiem", 
                            "insu_cacKhoanGiamTru", "insu_tangGiamDuPhongBoiThuong", "insu_soTrichDuPhongDaoDongLonTrongNam", 
                            "insu_chiKhacHoatDongKinhDoanhBH", "insu_loiNhuanTaiChinh", "insu_LoiNhuanKhac", 
                            "insur_cacKhoanDieuChinh", "bk_service_income", "bk_exchange_gain", "bk_trading_income", 
                            "bk_investment_income", "bk_other_operatin_income", "bk_associate_income", 
                            "assets_cur", "cash_equi", "short_investment", "short_receivable", "Inventory", 
                            "other_assets_cur", "assets_noncur", "long_receivable", "fixed_assets", "depre_cum", 
                            "depre_lease_cum", "armort_cum", "goodwill", "long_investment_realestate", 
                            "long_investment_financial", "other_assets_noncur", "assets", "liabilities", 
                            "liabilities_st", "liabilities_lt", "allowance", "Otherliabilities", "Equity_total", 
                            "Equity_other_fund", "Equity_minority_int", "bk_tienMatChungTuCoGiaNgoaiTe", 
                            "bk_tienGuiNHNN", "bk_tinPhieuGiayToCoGiaNganHan", "bk_tienVangTaiCacTCTD", 
                            "bk_chungKhoanKinhDoanh", "bk_phaiSinhCongCuTaiChinhKhac", "bk_choVayKhachHang", 
                            "bk_chungKhoanDauTu", "bk_gopVonDauTuDaiHan", "bk_taiSanCoDinh", "bk_BDSDautu", 
                            "bk_taiSanCoKhac", "bk_noCPNHNN", "bk_TienGuiChovayTCTDkhac", "bk_tienGuiKH", 
                            "bk_CongCuphaisinhTaiSanTaiChinhKhac", "bk_taiTroUyThacDauTu", "bk_phatHanhGiayToCoGia")

#Yearly_quarterly data separated
financialReport$char <- nchar(financialReport$timeOfdata)
financialReport <- financialReport[char==6]
financialReport[,char:=NULL]

#Process Date
financialReport <- financialReport[,':='(year=as.numeric(substr(timeOfdata,3,6)),quarter=as.numeric(substr(timeOfdata,2,2)))
                                   ]
setkey(financialReport,ticker,year,quarter)
#Create date key
financialReport[,':='(year2=ifelse(quarter==3|quarter==4,year+1,year),
                      quarter2=ifelse(quarter==4,2,ifelse(quarter==3,1,quarter+2)))]
financialReport[,':='(year=year2,quarter=quarter2)
                ][,':='(year2=NULL,quarter2=NULL)]

setkey(financialReport,ticker,year,quarter)


#Summary + clean  ---------------------------------------------------------------------------
#BS
# Current assets
#Check All item >0:
nrow(financialReport[assets_cur<=0]) #0
nrow(financialReport[cash_equi<=0]) #29
nrow(financialReport[short_investment<0]) #33
nrow(financialReport[short_receivable<=0])#70
nrow(financialReport[other_assets_cur<0]) #10
#check logic:
nrow(financialReport[abs(assets_cur- cash_equi- short_investment -short_receivable
                       -Inventory- other_assets_cur)>2])
#Toan bo cac cong ty chung khoan bi hong
#Clean: