gstune_md5_bytes <- function(bytes) {
  digest::digest(bytes, algo = "md5", serialize = FALSE)
}
