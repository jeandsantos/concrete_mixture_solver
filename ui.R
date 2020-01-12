# Load Packages
if(!require(shiny)) {install.packages("shiny")} else {require(shiny)}
if(!require(shinythemes)) {install.packages("shinythemes")} else {require(shinythemes)}

# Define UI for application that draws a histogram
shinyUI(
  navbarPage("StrengthFinder: Generating Concrete Mixtures with improved compressive strength",
             theme = shinytheme("cerulean"),
             fluidPage(
               # # Application title
               # titlePanel(""),
               # Sidebar with a slider input for number of bins 
               sidebarLayout(
                 sidebarPanel(
                   sliderInput("Cement_range", "Cement", post = "%",
                               min = 0, max = 100, value = c(4, 25), step = 0.5),
                   sliderInput("Ash_range", "Ash",  post = "%",
                               min = 0, max = 100, value = c(0, 10), step = 0.5), post = "%",
                   sliderInput("Coarse_Aggregate_range", "Coarse Aggregate",  post = "%",
                               min = 0, max = 100, value = c(30, 55), step = 0.5),
                   sliderInput("Fine_Aggregate_range", "Fine Aggregate",  post = "%",
                               min = 0, max = 100, value = c(20, 45), step = 0.5),
                   sliderInput("Slag_range", "Slag",  post = "%",
                               min = 0, max = 100, value = c(0, 20), step = 0.5),
                   sliderInput("Superplasticizer_range", "Superplasticizer",  post = "%",
                               min = 0, max = 3, value = c(0, 1), step = 0.05),
                   sliderInput("Water_range", "Water", post = "%",
                               min = 5, max = 15, value = c(5, 12), step = 0.5),
                   actionButton("run_GA", "Run GA"), br(),
                   p("Click the button to generate optimized concrete recipes")
               ),
               mainPanel(
                 tabsetPanel(id = "tabspabel", type = "tabs",
                             tabPanel(title = "Concrete Mixtures",
                                      tableOutput(outputId = "min_limits_GA_table"),
                                      textOutput(outputId = "GA_output_print"),
                                      tableOutput(outputId = "GA_solution"),
                                      plotOutput("GA_plot", width = "60%"),
                                      br()),
                             tabPanel(title = "Search Parameters",
                                      h4("Settings for genetic algorithm"),
                                      fluidRow(
                                        column(3, sliderInput("pop_size", "Population Size", value = 30, min = 10, max = 1000, step = 10)),
                                        column(3, sliderInput("max_iter", "Maximum Iterations", value = 10, min = 1, max = 10000, step = 10)),
                                        column(3, sliderInput("pcrossover", "Probability of crossover", value = 0.8, min = 0, max = 1, step = 0.01))
                                        ),
                                      fluidRow(
                                        column(3, sliderInput("pmutation", "Probability of mutation", value = 0.1, min = 0, max = 1, step = 0.01)),
                                        column(3, sliderInput("elitism", "Elitism (%)", value = 5, min = 1, max = 99, post = "%")),
                                        column(3, sliderInput("run", "Run (% of Maximum Iterations)", value = 0.25, min = 0.05, max = 0.90, step = 0.05, post = "%"))
                                        ),
                                      checkboxInput(inputId = "local_search", "Perform Local Search", value = TRUE),
                                      # checkboxInput(inputId = "parallel", "Parallel Computing ", value = FALSE),
                                      numericInput("seed", "Seed", value = 1, min = 1, max = Inf, step = 1, width = "100px"),
                                      br()
                                      )
                             )
                 )
               )
               )
             )
  )