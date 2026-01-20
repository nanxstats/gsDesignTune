#' MD5 hash for raw vectors
#'
#' Compute an MD5 hash of a raw vector. Uses [digest::digest()] to support
#' R versions < 4.5.0 where `tools::md5sum(bytes = )` is unavailable.
#'
#' @param bytes A raw vector.
#'
#' @return A length-1 character vector.
#'
#' @noRd
gstune_md5_bytes <- function(bytes) {
  digest::digest(bytes, algo = "md5", serialize = FALSE)
}
