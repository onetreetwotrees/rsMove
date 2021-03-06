#' @title backSample
#'
#' @description Background sample selection.
#' @param x Object of class \emph{SpatialPoints} of \emph{SpatialPointsDataFrame}.
#' @param z Vector of region identifiers for each sample.
#' @param sampling.method One of \emph{random} or \emph{pca}. Default is \emph{random}.
#' @param y Object of class \emph{RasterLayer}, \emph{RasterStack} or \emph{RasterBrick}.
#' @param nr.samples Number of random background samples.
#' @importFrom raster cellFromXY xyFromCell crs ncell
#' @importFrom sp SpatialPoints SpatialPointsDataFrame
#' @importFrom stats complete.cases prcomp median
#' @references \href{10.1002/rse2.70}{Remelgado, R., Leutner, B., Safi, K., Sonnenschein, R., Kuebert, C. and Wegmann, M. (2017), Linking animal movement and remote sensing - mapping resource suitability from a remote sensing perspective. Remote Sens Ecol Conserv.}
#' @return A \emph{SpatialPoints} or a \emph{SpatialPointsDataFrame}.
#' @details {First, the function determines the unique pixel coordinates for \emph{x} based on the dimensions of \emph{y} and retrieves
#' \emph{n}, random background samples where \emph{n} is determined by \emph{nr.samples}. If \emph{sampling.method} is set to \emph{"random"},
#' the function will return the selected samples as a \emph{SpatialPoints} object. However, if \emph{sampling.method} is set to \emph{"pca"}, the
#' function performs a Principal Components Analysis (PCA) over \emph{y} to evaluate the similarity between the samples associated to \emph{x} and
#' the initial set of random samples. To achieve this, the function selects the most important Principal Components (PC's) using the kaiser rule
#' (i.e. PC's with eigenvalues greater than 1) and, for each PC, estimates the median and the Median Absolute Deviation (MAD) based on the samples
#' of related ot each unique identifier in \emph{z}). Based on this data, the function selects background samples where the difference between their
#' variance and the variance of the region samples exceeds the absolute difference between the median and the MAD. Finally, the algorithm filteres out
#' all the background samples that were not selected by all sample regions. The ouptut is a \emph{SpatialPointsDataFrame} containing the selected samples
#' and the corresponding \emph{y} values. If \emph{nr.samples} is not provided all background pixels are considered.}
#' @seealso \code{\link{labelSample}} \code{\link{hotMove}} \code{\link{dataQuery}}
#' @examples {
#'
#'  require(raster)
#'
#'  # read raster data
#'  file <- list.files(system.file('extdata', '', package="rsMove"), 'ndvi.tif', full.names=TRUE)
#'  r.stk <- stack(file)
#'
#'  # read movement data
#'  data(shortMove)
#'
#'  # find sample regions
#'  label <- labelSample(shortMove, 30, agg.radius=30, nr.pixels=2)
#'
#'  # select background samples (pca)
#'  bSamples <- backSample(shortMove, r.stk, label, sampling.method='pca')
#'
#'  # select background samples (random)
#'  bSamples <- backSample(shortMove, r.stk, sampling.method='random')
#'
#' }
#' @export
#'
#-------------------------------------------------------------------------------------------------------------------------------#

backSample <- function(x, y, z, sampling.method="random", nr.samples=NULL) {

  #-------------------------------------------------------------------------------------------------------------------------------#
  # 1. check input variables
  #-------------------------------------------------------------------------------------------------------------------------------#

  if (missing("z")) {z <- replicate(length(x), 1)} else {if (length(z)!=length(x)) {stop('"x" and "z" have different lengths')}}

  if (!class(x)[1]%in%c('SpatialPoints', 'SpatialPointsDataFrame')) {stop('"x" is not of a valid class')}
  if (is.null(crs(x)@projargs)) {stop('"x" is missing a valid projection')}
  if (!sampling.method%in%c('random', 'pca')) {stop('"sampling.method" is not a valid keyword')}

  if (!class(y)[1]%in%c('RasterLayer', 'RasterStack', 'RasterBrick')) {stop('"y" is not of a valid class')}
  if (crs(x)@projargs!=crs(y)@projargs) {stop('"x" and "y" have different projections')}
  np <- ncell(y[[1]]) # number of pixels
  op <- crs(y) # output projection

  if (!is.null(nr.samples)) {if (!is.numeric(nr.samples) | length(nr.samples)!=1) {stop('"nr.samples" is not a valid input')}}

  #-------------------------------------------------------------------------------------------------------------------------------#
  # 2. extract random background samples
  #-------------------------------------------------------------------------------------------------------------------------------#

  # convert presences to pixel positions
  sp <- cellFromXY(y[[1]], x)

  # remove duplicated records
  dr <- !duplicated(sp) & !is.na(z)
  sp <- sp[dr]
  z <- z[dr]

  # derice background samples
  ind <- which(!(1:np)%in%sp)
  if (!is.null(nr.samples)) {ind <- ind[sample(1:length(ind), nr.samples, replace=TRUE)]}
  x <- rbind(xyFromCell(y[[1]], sp), xyFromCell(y[[1]], ind))
  z <- c(z, replicate(length(ind), 0))

  rm(sp, ind)

  #-------------------------------------------------------------------------------------------------------------------------------#
  # 3. select background samples
  #-------------------------------------------------------------------------------------------------------------------------------#

  if (sampling.method=='pca') {

    # extract environmental information
    y <- as.data.frame(extract(y, x))
    cc <- complete.cases(y) # index to remove NA's
    y <- y[cc,]
    z <- z[cc]
    x <- x[cc,]

    # kaiser rule
    pcf = function(x) {which((x$sdev^2) > 1)}

    # estimate pca and apply kaiser rule
    pca <- prcomp(y, scale=TRUE, center=TRUE)
    npc <- pcf(pca)
    pca <- data.frame(pca$x[,npc])

    # select absences
    uv <- unique(z[which(z > 0)])
    i0 = which(z==0)
    ai = vector('list', ncol(pca))
    for (p in 1:length(npc)) {
      usr = vector('list', length(uv))
      for (j in 1:length(uv)) {
        ri <- which(z==uv[j])
        s1 <- median(pca[ri,p])
        s2 <- median(abs(pca[ri,p]-s1))
        usr[[j]] <- i0[which(abs(pca[i0,p]-s1) > s2)]
      }
      usr <- unlist(usr)
      ui <- unique(usr)
      count <- vector('numeric', length(ui))
      for (j in 1:length(ui)) {count[j] <- length(which(usr==ui[j]))}
      ai[[p]] <- ui[which(count==length(uv))]
    }

    # return samples
    ai <- unique(unlist(ai))
    return(SpatialPointsDataFrame(x[ai,], as.data.frame(y[ai,]), proj4string=op))

  }

  if (sampling.method=='random') {

    # return samples
    ind <- which(z==0)
    return(SpatialPoints(x[ind,], proj4string=op))

  }

}
