gwlars.nen.sel = function(formula, data=list(), coords, adapt=FALSE, gweight=gwr.Gauss, mode, s, method="cv", verbose=FALSE, longlat=FALSE, RMSE=FALSE, weights, tol=.Machine$double.eps^0.25) {
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
    m <- match(c("formula", "data", "weights"), names(mf), 0)
    mf <- mf[c(1, m)]
    mf$drop.unused.levels <- TRUE
    mf[[1]] <- as.name("model.frame")
    mf <- eval(mf, parent.frame())
    mt <- attr(mf, "terms")
    dp.n <- length(model.extract(mf, "response"))
    weights <- as.vector(model.extract(mf, "weights"))
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
    if (!adapt) {
        bbox <- cbind(range(coords[, 1]), range(coords[, 2]))
        difmin <- spDistsN1(bbox, bbox[2, ], longlat)[1]
        if (any(!is.finite(difmin))) 
            difmin[which(!is.finite(difmin))] <- 0
        beta1 <- difmin/1000
        beta2 <- difmin
        if (method == "cv") {
            opt <- optimize(gwlars.cv.f, lower=beta1, upper=beta2, 
                maximum=FALSE, formula=formula, coords=coords, s=s, mode=mode,
                gweight=gweight, verbose=verbose, longlat=longlat, data=data, 
                RMSE=RMSE, weights=weights, tol=tol, adapt=FALSE)
        }
        else if (method=='knn') {
            opt <- optimize(gwr.aic.f, lower = beta1, upper = beta2, 
                maximum = FALSE, y = y, x = x, coords = coords, 
                gweight = gweight, verbose = verbose, longlat = longlat, 
                tol = tol)
        }
        else if (method=='nen') {
            opt <- optimize(gwr.aic.f, lower = beta1, upper = beta2, 
                maximum = FALSE, y = y, x = x, coords = coords, 
                gweight = gweight, verbose = verbose, longlat = longlat, 
                tol = tol)
        }
        bdwt <- opt$minimum
        res <- bdwt
    }
    else {
        bbox <- cbind(range(coords[, 1]), range(coords[, 2]))
        difmin <- spDistsN1(bbox, bbox[2, ], longlat)[1]
        if (any(!is.finite(difmin))) 
            difmin[which(!is.finite(difmin))] <- 0
        beta1 <- difmin/1000
        beta2 <- difmin
        if (method == "cv") {
            opt <- optimize(gwlars.cv.f, lower=beta1, upper=beta2, 
                maximum=FALSE, formula=formula, coords=coords, s=s, mode=mode,
                gweight=gweight, verbose=verbose, longlat=longlat, data=data, 
                RMSE=RMSE, weights=weights, tol=tol, adapt=TRUE)
        }
        else {
            opt <- optimize(gwr.aic.f, lower = beta1, upper = beta2, 
                maximum = FALSE, y = y, x = x, coords = coords, 
                gweight = gweight, verbose = verbose, longlat = longlat, 
                tol = tol)
        }
        bdwt <- opt$minimum
        res <- bdwt
    }
    res
}
