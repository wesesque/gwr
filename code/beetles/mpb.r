library(gwselect)
#registerCores(n=7)

mpb = read.csv("~/git/gwr/data/SouthernPineBeetle/Code-Andy/mpb.csv", head=TRUE)

#Remove rows with NAs:
n = nrow(mpb)
indx = which(is.na(mpb))
na.rows = (indx-1) %% n + 1
mpb = mpb[-na.rows,]

n = nrow(mpb)
weights = rep(1, n)

bw = gwglmnet.sel(nifestations~meanelevation+warm+Tmin+Tmean+Tmax+cold+precip+dd+ddegg, data=mpb, coords=mpb[,c('X','Y')], weights=weights, gweight=bisquare, tol=1, s=NULL, method='nen', family='poisson', parallel=FALSE, longlat=FALSE, adapt=TRUE, precondition=FALSE)

#model = gwglmnet.nen(nifestations~meanelevation+warm+Tmin+Tmean+Tmax+cold+precip+dd+ddegg, data=mpb, coords=mpb[,c('X','Y')], gweight=bisquare, s=seq(0,5,0.001), tol=10, bw=200000, type='pearson', family='poisson', parallel=TRUE, weights=weights)