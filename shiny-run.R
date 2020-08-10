# This script is used to run the application defined in app.R in the background
options(shiny.autoreload = TRUE)
model_strength <- base::readRDS("models/avNNet_model.rds")
message(Sys.time(),": Model imported")

# Import Functions
eval_function_with_limits <- base::source("helpers/eval_function_with_limits.R")
GA_summary_plot <- base::source("helpers/GA_summary_plot.R")
message(Sys.time(),": Supporting functions imported")

shiny::runApp()