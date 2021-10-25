#' Reproject raster using gdalUtils R package
#'
#' @param raster_obj string path indicating location of Raster or RasterBrick
#' @param new_crs sp CRS object for target coordinate ref system
#' @param write_path string path indicating where we want to write the
#'   reprojected (modified) raster object. If nothing is supplied the
#'   reprojected raster will not be written to disk
#' @param align_raster
#' @param res optional integer value indicating resolution - default 30x30
#' @param brick optional boolean indicating whether or not the raster is a RasterBrick -
#'   default is FALSE
#' @param method optional string indicating resampling method - default is
#'   bilinear. See gdalwarp docs for other options
#'
#' @return Reprojected Raster or RasterBrick object
reproject_gdal <- function(raster_brick, new_crs,
                           write_path,
                           align_raster = NULL, res = 30,
                           method = "bilinear",
                           brick = FALSE) {

  if (class(raster_brick) != "character") {
    stop("raster_brick must be passed as file path")
  }
  if (!is.null(align_raster)) {
    if(crs(align_raster)@projargs != new_crs@projargs) {
      stop("ERROR - align raster epsg must match new_epsg")
    }
    if (all(c(res, res) != res(align_raster))) {
      stop("ERROR - align_raster resolution must match desired res")
    }
    input_ext  <- extent(projectExtent(raster(raster_brick), new_crs))
    align_raster <- crop(align_raster, input_ext, snap = "out")
    align_ext <- c(align_raster@extent@xmin,
                   align_raster@extent@ymin,
                   align_raster@extent@xmax,
                   align_raster@extent@ymax)

    gdalUtilities::gdalwarp(srcfile = raster_brick, dstfile = write_path,
                            t_srs = new_crs@projargs, te = align_ext, tr = c(res, res),
                            r = method, co="COMPRESS=LZW")
  } else {
    gdalUtilities::gdalwarp(srcfile = raster_brick, dstfile = write_path,
                            t_srs = new_crs@projargs, tr = c(res, res),
                            r = method, co="COMPRESS=LZW")
  }

  if (brick) {
    reprojected <- raster::brick(write_path)
  } else {
    reprojected <- raster::raster(write_path)
  }

  # Remove extra no-data values around borders
  na_matrix <- is.na(as.matrix(reprojected))
  colNotNa <- which(colSums(na_matrix) != nrow(reprojected))
  rowNotNa <- which(rowSums(na_matrix) != ncol(reprojected))
  crop_extent <- extent(
    reprojected,
    rowNotNa[1],
    rowNotNa[length(rowNotNa)],
    colNotNa[1],
    colNotNa[length(colNotNa)])
  if (crop_extent != extent(reprojected)) {
    # TODO: FIX writeRaster() with same source and destination file name

    trimmed <- crop(reprojected, crop_extent)
    writeRaster(trimmed, write_path, overwrite = TRUE)
    return(trimmed)
  } else {
    return(reprojected)
  }

}
