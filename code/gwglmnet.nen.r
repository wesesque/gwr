gwglmnet.nen <- function(formula, data, coords, gweight, bw, D=NULL, verbose=FALSE, longlat=FALSE, adapt=FALSE, s=NULL, family, weights=NULL, tolerance=.Machine$double.eps^0.25, beta1=NULL, beta2=NULL, type, parallel=FALSE) {
    if (!is.logical(adapt)) 
        stop("adapt must be logical")
    if (is(data, "Spatial")) {
        if (!missing(coords)) 
            warning("data is Spatial* object, ignoring coords argument")
        coords <- coordinates(data)
        if ((is.null(longlat) || !is.logical(longlat)) && !is.na(is.projected(data)) && 
            !is.projected(data)) {
            longlat <- TRUE
        }
        else longlat <- FALSE
        data <- as(data, "data.frame")
    }
    if (is.null(longlat) || !is.logical(longlat)) 
        longlat <- FALSE
    if (missing(coords)) 
        stop("Observation coordinates have to be given")
    mf <- match.call(expand.dots = FALSE)    
    #m <- match(c("formula", "data", "weights"), names(mf), 0)
    m <- match(c("formula", "data"), names(mf), 0)
    mf <- mf[c(1, m)]
    mf$drop.unused.levels <- TRUE
    mf[[1]] <- as.name("model.frame")
    mf <- eval(mf, parent.frame())
    mt <- attr(mf, "terms")
    dp.n <- length(model.extract(mf, "response"))      
    #weights <- as.vector(model.extract(mf, "weights"))    
    if (!is.null(weights) && !is.numeric(weights)) 
        stop("'weights' must be a numeric vector")
    if (is.null(weights)) 
        weights <- rep(as.numeric(1), dp.n)
    if (any(is.na(weights))) 
        stop("NAs in weights")
    if (any(weights < 0)) 
        stop("negative weights")
    y <- model.extract(mf, "response")
    x <- model.matrix(mt, mf)

    if (is.null(D)) {
        #Get the matrix of distances
        n = dim(coords)[1]
        if (longlat) {
            D = as.matrix(earth.dist(coords),n,n)
        } else {
            Xmat = matrix(rep(coords[,1], times=n), n, n)
            Ymat = matrix(rep(coords[,2], times=n), n, n)
            D = sqrt((Xmat-t(Xmat))**2 + (Ymat-t(Ymat))**2)
        }
    }    

    #Get the weight matrix
    n = dim(D)[1]

    if (is.null(beta1) || is.null(beta2)) {
        bbox <- cbind(range(coords[, 1]), range(coords[, 2]))
        difmin <- spDistsN1(bbox, bbox[2, ], longlat)[1]
        if (any(!is.finite(difmin))) 
            difmin[which(!is.finite(difmin))] <- 0
        beta1 <- difmin/1000
        beta2 <- 2 * difmin        
    }

    res=list()

    if (adapt) {
        if (parallel) {
            res[['model']] = gwglmnet.nen.adaptive.fit.parallel(x, y, coords, D, s, verbose, family, weights, gweight, bw, beta1, beta2, type, tol=tolerance, longlat=longlat)
        } else {
            res[['model']] = gwglmnet.nen.adaptive.fit(x, y, coords, D, s, verbose, family, weights, gweight, bw, beta1, beta2, type, tol=tolerance, longlat=longlat)
        }
    }
    if (!adapt) {        
        if (!parallel) {
            res[['model']] = gwglmnet.nen.fit(x, y, coords, D, s, verbose, family, weights, gweight, bw, beta1, beta2, type=type, tol=tolerance, longlat=longlat)
        } else {
            res[['model']] = gwglmnet.nen.fit.parallel(x, y, coords, D, s, verbose, family, weights, gweight, bw, beta1, beta2, type=type, tol=tolerance, longlat=longlat)
        }
    }

    res[['data']] = data
    res[['response']] = as.character(formula[[2]])
    res
}