if (!requireNamespace("remotes")) { install.packages("remotes") }
remotes::install_github("rstudio/renv")

# renv::init()\
renv::snapshot()
# renv::restore() 