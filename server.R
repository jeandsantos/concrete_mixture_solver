# Import model
model_strength <<- base::readRDS("models/avNNet_model.rds")
message(Sys.time(),": Model imported")

# Import Functions
base::source("helpers/eval_function_with_limits.R")
base::source("helpers/GA_summary_plot.R")
base::source("helpers/save_to_temp_dir.R")
message(Sys.time(),": Supporting functions imported")

# Load required packages
if(!require(shiny)) {install.packages("shiny")} else {require(shiny)}
if(!require(shinythemes)) {install.packages("shinythemes")} else {require(shinythemes)}
if(!require(plotly)) {install.packages("plotly")} else {require(plotly)}
if(!require(GA)) {install.packages("GA")} else {require(GA)}
if(!require(knitr)) {install.packages("knitr")} else {require(knitr)}
# if(!require(tidyverse)) {install.packages("tidyverse")} else {require(tidyverse)}
if(!require(caret)) {install.packages("caret")} else {require(caret)}
# if(!require(nnet)) {install.packages("nnet")} else {require(nnet)}
# if(!require(parallel)) {install.packages("parallel")} else {require(parallel)}
message(Sys.time(),": Packages loaded")

# Create vectors for variable names and ID
# features_ID <- c("Cement", "Slag", "Ash", "Water", "Superplasticizer", "Coarse_Aggregate", "Fine_Aggregate", "Age", "Strength")
# features_title <- c("Cement", "Blast Furncace Slag", "Fly Ash", "Water", "Superplasticizer", "Coarse Aggregate", "Fine Aggregate", "Age (days)", "Strength (MPa)")
# predictors_ID <- c("Cement", "Slag", "Ash", "Water", "Superplasticizer", "Coarse_Aggregate", "Fine_Aggregate")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    range_table <- function(idx, div=100){
        
        tibble(
            Cement = input$Cement_range[idx]/div,
            Ash = input$Ash_range[idx]/div,
            Coarse_Aggregate = input$Coarse_Aggregate_range[idx]/div,
            Fine_Aggregate = input$Fine_Aggregate_range[idx]/div,
            Slag = input$Slag_range[idx]/div,
            Superplasticizer = input$Superplasticizer_range[idx]/div,
            Water = input$Water_range[idx]/div
        )
    }
    
    min_limits_GA <- eventReactive(eventExpr = input$run_GA, valueExpr = { range_table(idx = 1) })
    max_limits_GA <- eventReactive(eventExpr = input$run_GA, valueExpr = { range_table(idx = 2) })
    
    GA_output <- eventReactive(eventExpr = input$run_GA, {
        message(Sys.time(),": Starting optimization algorithm")
        
        GA::ga(type = "real-valued",
               fitness = function(x) { eval_function_with_limits(x[1], x[2], x[3], x[4], x[5], x[6], 
                                                                 min_limits_GA = min_limits_GA(), 
                                                                 max_limits_GA = max_limits_GA(), 
                                                                 Age = input$age) },
               names = c("Cement", "Ash", "Coarse Aggregate", "Fine Aggregate", "Slag", "Superplasticizer"),
               lower = c(min_limits_GA()$Cement, min_limits_GA()$Ash, 
                         min_limits_GA()$Coarse_Aggregate, min_limits_GA()$Fine_Aggregate, 
                         min_limits_GA()$Slag, min_limits_GA()$Superplasticizer), 
               upper = c(max_limits_GA()$Cement, max_limits_GA()$Ash, 
                         max_limits_GA()$Coarse_Aggregate, max_limits_GA()$Fine_Aggregate, 
                         max_limits_GA()$Slag, max_limits_GA()$Superplasticizer),
               popSize = input$pop_size, 
               maxiter = input$max_iter, 
               optim = input$local_search, 
               seed = input$seed, 
               parallel = FALSE,
               keepBest = FALSE,
               updatePop = FALSE,
               monitor = FALSE
               )
        })
    
    GA_solution_table <- eventReactive(eventExpr = input$run_GA, {
        message(Sys.time(),": Creating solution table")
        
        tibble(
            Cement = round(GA_output()@solution[1, 1]*100, 3),
            Ash = round(GA_output()@solution[1, 2]*100, 3),
            Coarse_Aggregate = round(GA_output()@solution[1, 3]*100, 3),
            Fine_Aggregate = round(GA_output()@solution[1, 4]*100, 3),
            Slag = round(GA_output()@solution[1, 5]*100, 3),
            Superplasticizer = round(GA_output()@solution[1, 6]*100, 3),
            Water = round((1 - sum(GA_output()@solution[1,]))*100, 3),
            Age = input$age,
            Strength = GA_output()@fitnessValue,
            .name_repair = ~ c("Cement (%)", 
                               "Ash (%)", 
                               "Coarse Aggregate (%)", 
                               "Fine Aggregate (%)", 
                               "Slag (%)", 
                               "Superplasticizer (%)", 
                               "Water (%)", 
                               "Age (days)", 
                               "Strength (MPa)")
        )
        })
    
    output$GA_solution <- renderTable({ GA_solution_table() })
    
    output$GA_output_print <- renderText({ 
        if (GA_output()@fitnessValue > 0) {
            
            (paste0("Genetic Algorithm successfully found a feasible solution after ", GA_output()@iter, " iterations. ", 
                         "Final fitness value: ", round(GA_output()@fitnessValue, 3)))
            
        } else { paste("Genetic Algorithm did not find a feasible solution") }
        
        })
    
    output$GA_plot <- renderPlotly({
        
        if(input$run_GA >= 1) { print( ggplotly( GA_summary_plot(GA_output()) ) ) } 
        })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("GA_solution_", gsub(pattern = "-|:| ", replacement = "_", Sys.time()), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(GA_solution_table(), file, row.names = FALSE)
        }
    )
    
    output$report <- downloadHandler(
        filename = paste("StrenthFinder solution report - ", gsub(pattern = ":", replacement = "", Sys.time()), ".html", sep = ""),
        content = function(file) { 
            
            search_output <- isolate({ GA_output() })
            saveRDS(search_output, file = "search_output.rds")
            message(paste0(Sys.time(), ": created `search_output.rds`"))
            search_output_dir <- save_to_temp_dir("search_output.rds")
            
            df <- isolate({ GA_solution_table() })
            write.csv(df, "export_df.csv")
            message(paste0(Sys.time(), ": created `export_df.csv`"))
            temp_df_dir <- save_to_temp_dir("export_df.csv")
            
            # Set up parameters to pass to Rmd document
            params <- list(
                temp_df_dir = temp_df_dir,
                search_output_dir = search_output_dir,
                age = input$age)
            
            # Copy the report file to a temporary directory before processing it
            tempReport <- file.path(tempdir(), "report.Rmd")
            file.copy("report.Rmd", tempReport, overwrite = TRUE)
            
            id <- showNotification("Rendering report...", duration = NULL, closeButton = FALSE)
            on.exit(removeNotification(id), add = TRUE)
            
            # Knit the document
            rmarkdown::render(tempReport, 
                              output_file = file,
                              params = params,
                              envir = new.env(parent = globalenv())
            )
            }
        )
})



















