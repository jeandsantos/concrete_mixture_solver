# Import model
model_strength <<- base::readRDS("models/avNNet_model.rds")
message(Sys.time(),": Model imported")

# Load required packages
if(!require(shiny)) {install.packages("shiny")} else {require(shiny)}
if(!require(shinythemes)) {install.packages("shinythemes")} else {require(shinythemes)}
if(!require(plotly)) {install.packages("plotly")} else {require(plotly)}
if(!require(GA)) {install.packages("GA")} else {require(GA)}
if(!require(tidyverse)) {install.packages("tidyverse")} else {require(tidyverse)}
if(!require(caret)) {install.packages("caret")} else {require(caret)}
if(!require(nnet)) {install.packages("nnet")} else {require(nnet)}
# if(!require(parallel)) {install.packages("parallel")} else {require(parallel)}
message(Sys.time(),": Packages loaded")

# Create vectors for variable names and ID
# features_ID <- c("Cement", "Slag", "Ash", "Water", "Superplasticizer", "Coarse_Aggregate", "Fine_Aggregate", "Age", "Strength")
# features_title <- c("Cement", "Blast Furncace Slag", "Fly Ash", "Water", "Superplasticizer", "Coarse Aggregate", "Fine Aggregate", "Age (days)", "Strength (MPa)")
# predictors_ID <- c("Cement", "Slag", "Ash", "Water", "Superplasticizer", "Coarse_Aggregate", "Fine_Aggregate")
age_selected <- 28 # Days of aging


# Import Functions
eval_function_with_limits <- base::source("helpers/eval_function_with_limits.R")
GA_summary_plot <- base::source("helpers/GA_summary_plot.R")
message(Sys.time(),": Supporting functions imported")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    min_limits_GA <- eventReactive(eventExpr = input$run_GA, valueExpr = { # 
        
        data_frame(
           Cement = input$Cement_range[1]/100,
           Ash = input$Ash_range[1]/100,
           Coarse_Aggregate = input$Coarse_Aggregate_range[1]/100,
           Fine_Aggregate = input$Fine_Aggregate_range[1]/100,
           Slag = input$Slag_range[1]/100,
           Superplasticizer = input$Superplasticizer_range[1]/100,
           Water = input$Water_range[1]/100
           )
    })
    
    max_limits_GA <- eventReactive(eventExpr = input$run_GA, valueExpr = {
        
        data_frame(
            Cement = input$Cement_range[2]/100,
            Ash = input$Ash_range[2]/100,
            Coarse_Aggregate = input$Coarse_Aggregate_range[2]/100,
            Fine_Aggregate = input$Fine_Aggregate_range[2]/100,
            Slag = input$Slag_range[2]/100,
            Superplasticizer = input$Superplasticizer_range[2]/100,
            Water = input$Water_range[2]/100
        )
    })
    
    # output$min_limits_GA_table <- renderTable({
    #     
    #     rbind(min_limits_GA(),
    #           min_limits_GA())
    #     
    # })

    GA_output <- eventReactive(eventExpr = input$run_GA, {
        
        # model_strength <- base::readRDS("models/avNNet_model.rds")
        
        GA::ga(type = "real-valued",
               fitness = function(x) { eval_function_with_limits(x[1], x[2], x[3], x[4], x[5], x[6], 
                                                                 min_limits_GA = min_limits_GA(), max_limits_GA = max_limits_GA()) },
               names = c("Cement", "Ash", "Coarse Aggregate", "Fine Aggregate", "Slag", "Superplasticizer"),
               lower = c(min_limits_GA()$Cement, min_limits_GA()$Ash, min_limits_GA()$Coarse_Aggregate, min_limits_GA()$Fine_Aggregate, min_limits_GA()$Slag, min_limits_GA()$Superplasticizer), 
               upper = c(max_limits_GA()$Cement, max_limits_GA()$Ash, max_limits_GA()$Coarse_Aggregate, max_limits_GA()$Fine_Aggregate, max_limits_GA()$Slag, max_limits_GA()$Superplasticizer),
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
        
        tibble(
            Cement = GA_output()@solution[1, 1]*100,
            Ash = GA_output()@solution[1, 2]*100,
            Coarse_Aggregate = GA_output()@solution[1, 3]*100,
            Fine_Aggregate = GA_output()@solution[1, 4]*100,
            Slag = GA_output()@solution[1, 5]*100,
            Superplasticizer = GA_output()@solution[1, 6]*100,
            Water = (1 - sum(GA_output()@solution[1,]))*100,
            Age = age_selected,
            Strength = GA_output()@fitnessValue,
            , .name_repair = ~ c("Cement (%)", 
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
        
        if(input$run_GA >= 1) { 
            
            print(
                ggplotly( GA_summary_plot(GA_output()) )
            )
            } # else {}
        })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("GA_solution_", gsub(pattern = "-|:| ", replacement = "_", Sys.time()), ".csv", sep = "")
        },
        content = function(file) {
            write.csv(GA_solution_table(), file, row.names = FALSE)
        }
    )
    
    
})



















