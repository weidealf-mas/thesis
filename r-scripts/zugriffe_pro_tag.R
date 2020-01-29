library(readxl)

dat <- read_excel("anzahl_zugriffe_pro_tag.xlsx")

# example how to create a date sequence
# index <- seq(as.Date("2019-04-01"), as.Date("2019-09-30"), by = "day")
# ts.dat <- ts(dat$Anzahl, start = c(2019, as.numeric(format(index[1], "%j"))), frequency = 365)
# plot(ts.dat)

ts.dat<-ts(dat$Anzahl, start=c(2019, as.POSIXlt("2019-04-01")$yday+1), frequency=7)
ts.dat

plot(ts.dat, main="Anzahl Zugriffe pro Tag", xlab="Tage", ylab="Zugriffe", xaxt = 'n', col = "darkred")
axis(side=1, at=c(2035,2040,2045,2050,2055), labels=c("Mai","Juni","Juli","August","September"))

dc.dat <- decompose(ts.dat)
plot(dc.dat,xaxt = 'n', col = "darkred")

stl.dat <- stl(ts.dat, s.window = 'periodic')
plot(stl.dat, xaxt = 'n', col = "darkred")

