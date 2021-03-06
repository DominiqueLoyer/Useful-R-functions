SSlogis.bounded<-function (input, Asym, xmid, scal, lower=c(0,0,0), upper=c(Inf, Inf, Inf)) 
{
  .expr1 <- xmid - input
  .expr3 <- exp(.e2 <- .expr1/scal)
  .expr4 <- 1 + .expr3
  .value <- Asym/.expr4
  .actualArgs <- as.list(match.call()[c("Asym", "xmid", "scal")])
  if (all(unlist(lapply(.actualArgs, is.name)))) {
    .expr10 <- .expr4^2
    .grad <- array(0, c(length(.value), 3L), list(NULL, c("Asym", 
                                                          "xmid", "scal")))
    .grad[, "Asym"] <- 1/.expr4
    .grad[, "xmid"] <- -(xm <- Asym * .expr3/scal/.expr10)
    .grad[, "scal"] <- xm * .e2
    dimnames(.grad) <- list(NULL, .actualArgs)
    attr(.value, "gradient") <- .grad
  }
  .value
}


function (mCall, data, LHS) 
{
  xy <- data.frame(sortedXyData(mCall[["input"]], LHS, data))
  if (nrow(xy) < 4) {
    stop("too few distinct input values to fit a logistic model")
  }
  z <- xy[["y"]]
  if (min(z) < 0) {
    z <- z - 1.05 * min(z)
  }
  if (min(z) == 0) {
    z <- z + 0.01 * (max(z)-min(z))
  }
  z <- z/(1.05 * max(z))
  xy[["z"]] <- log(z/(1 - z))
  aux <- coef(lm(x ~ z, xy))
  pars <- as.vector(coef(nls(y ~ 1/(1 + exp((xmid - x)/scal)), 
                             data = xy, start = list(xmid = aux[1L], scal = aux[2L]), 
                             algorithm = "plinear")))
  
  value <- c(pars[3L], pars[1L], pars[2L])
  
  value[value<lower]<-lower[value<lower]
  value[value>upper]<-lower[value<upper]
  
  
  
  names(value) <- mCall[c("Asym", "xmid", "scal")]
  return(value)
}