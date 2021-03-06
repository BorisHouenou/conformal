#' Random forests training and prediction functions.
#'
#' Construct training and prediction functions for random forests.
#'
#' @param ntree Number of trees to grow. Default is 500.
#' @param varfrac Determines the number of variables used as candidates at each
#'   split: this is floor(varfrac * p), where p is the total number of
#'   variables. Default is 0.333.
#' @param replace Should sampling of observations done with or without
#'   replacement? Default is FALSE.
#' @param obsfrac Determines the number of observations used by each tree: this
#'   is floor(obsfrac * n), where n is the number of training observations.
#'   Default is 1 when replace is TRUE, and 0.632 when replace is FALSE.
#' @param nodesize Sought size of terminal nodes, in growing each tree. Default
#'   is 5.
#'
#' @return A list with three components: train.fun, predict.fun, active.fun.
#'   The third function is designed to take the output of train.fun, and
#'   reports which features are active for the fitted model contained in
#'   this output. 
#'
#' @details This function is based on the packages \code{\link{randomForest}} 
#'   and \code{\link{plyr}}. If these packages are not installed, then the 
#'   function will abort. 
#'
#' @examples ## See examples for sam.funs function
#' @export rf.funs

rf.funs = function(ntree=500, varfrac=0.333, replace=TRUE,
  obsfrac=ifelse(replace,1,0.632), nodesize=5) {
  
  # Check for randomForest
  if (!require("randomForest",quietly=TRUE)) {
    stop("Package randomForest not installed (required here)!")
  }

  # Check arguments
  check.pos.int(ntree)
  check.num.01(varfrac)
  check.bool(replace)
  check.num.01(obsfrac)
  check.pos.int(nodesize)
  
  train.fun = function(x,y,out=NULL) {
    n = nrow(x)
    p = ncol(x)
    return(randomForest(x,y,ntree=ntree,mtry=floor(varfrac*p),replace=replace,
                        sampsize=floor(obsfrac*n),nodesize=nodesize))
  }

  predict.fun = function(out,newx) {
    return(predict(out,newx))
  }

  active.fun = function(out) {
    return(list(which(out$importance>0)))
  }
  
  return(list(train.fun=train.fun, predict.fun=predict.fun,
              active.fun=active.fun))
}

