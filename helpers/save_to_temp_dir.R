save_to_temp_dir <- function(filename, verbose = TRUE){
  
  temp_dir <- gsub("\\\\", "/", paste0(tempdir(), "\\", filename))
  file.copy(from = filename, to = temp_dir, overwrite = TRUE)
  message(paste0(Sys.time(), ": copied `", filename, "` into ", temp_dir))
  
  return(temp_dir)
}