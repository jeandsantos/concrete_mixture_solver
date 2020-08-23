# Load Packages
if(!require(shiny)) {install.packages("shiny")} else {require(shiny)}
if(!require(shinythemes)) {install.packages("shinythemes")} else {require(shinythemes)}
if(!require(plotly)) {install.packages("plotly")} else {require(plotly)}
# if(!require(ggthemes)) {install.packages("ggthemes")} else {require(ggthemes)}
if(!require(shinycssloaders)) {install.packages("shinycssloaders")} else {require(shinycssloaders)}

slider_ranges <- function(id, label, value, step=0.5, min = 0, max = 100, post="%") {
  sliderInput(id, label = label, min = min, max = max, value = value, step = step, post = post)
}

# Define UI 
shinyUI(
  navbarPage(title = "StrengthFinder",
             theme = shinytheme("flatly"),
             windowTitle = "StrengthFinder: Concrete Mixture Optimization",
             tabPanel(title = "Solver",
                      icon = icon("bullseye"),
                      sidebarLayout(
                        sidebarPanel(
                          actionButton("run_GA", "Run Solver", width = "250px", icon = icon("bullseye")), br(), br(),
                          h4(strong("Component Ranges")),
                          slider_ranges("Cement_range", "Cement", value = c(4, 25)),
                          slider_ranges("Ash_range", "Ash", value = c(0, 10)), 
                          slider_ranges("Coarse_Aggregate_range", "Coarse Aggregate", value = c(30, 55)),
                          slider_ranges("Fine_Aggregate_range", "Fine Aggregate",  value = c(20, 45)),
                          slider_ranges("Slag_range", "Slag",  value = c(0, 20)),
                          slider_ranges("Superplasticizer_range", "Superplasticizer",  value = c(0, 1), step = 0.05, max = 3),
                          slider_ranges("Water_range", "Water", value = c(5, 12), max=15),
                          downloadButton("downloadData", "Download Results"), br(),br(),
                          downloadButton("report", "Generate report   "),
                          width = 3
                        ),
                        mainPanel(
                          # tableOutput(outputId = "min_limits_GA_table"),
                          h4(textOutput(outputId = "GA_output_print")),
                          tableOutput(outputId = "GA_solution"),
                          withSpinner(plotlyOutput("GA_plot"), size = 3)
                          )
                        )
                      ),
             tabPanel(title = "Settings",
                      icon = icon("cog"),
                      h4("Settings for genetic algorithm"),
                      fluidRow(
                        column(3, sliderInput("pop_size", "Population Size", value = 10, min = 5, max = 500, step = 5)),
                        column(3, sliderInput("max_iter", "Maximum Iterations", value = 3, min = 3, max = 1000, step = 5)),
                        column(3, sliderInput("pcrossover", "Probability of crossover", value = 0.8, min = 0, max = 1, step = 0.01))
                        ),
                      fluidRow(
                        column(3, sliderInput("pmutation", "Probability of mutation", value = 0.1, min = 0, max = 1, step = 0.01)),
                        column(3, sliderInput("elitism", "Elitism (%)", value = 5, min = 1, max = 99, post = "%")),
                        column(3, sliderInput("run", "Run (% of Maximum Iterations)", value = 0.25, min = 0.05, max = 0.90, step = 0.05, post = "%"))
                        ),
                      fluidRow(
                        column(3, sliderInput("age", "Age of concrete (days)", value = 28, min = 1, max = 180, step = 0.01))
                      ),
                      checkboxInput(inputId = "local_search", "Perform Local Search", value = TRUE),
                      # checkboxInput(inputId = "parallel", "Parallel Computing ", value = FALSE),
                      numericInput("seed", "Seed", value = 1, min = 1, max = Inf, step = 1, width = "100px"),
                      br()
                      ),
             tabPanel(title = "Instructions",
                      icon = icon("align-left"),
                      br(),
                      ("1. Use the sliders to define the lower and upper limits for each component to be used in the concrete mixture."), br(),
                      ("2. Click on 'Run Solver' to start the search for an optimized mixture under the previously defined constraints."), br(),
                      ("3. Once the solver optimization algorithm has completed its search, the results will be display on the main pane of the solver tab."), br(),
                      ("4. You can download the results by clicking on the 'Download Results' button or create a report by clicking on 'Generate Report'."), br(),
                      hr(), br(),
                      ("The parameters for the optimization algorithm can be changed on the 'Settings' tab."), br(),
                      ("Higher values for the population size and the maximum number of iterations generally result in better outcomes at the cost of longer computing times."), br(),
                      br(),br()
             ),
             tabPanel(title = "About",
                      icon = icon("info-circle"),
                      br(),
                      ("For app documentation and code visit the "), 
                      a(href = "https://github.com/jeandsantos/concrete_mixture_solver", "GitHub repository."),
                      br(),br(),
                      ("Information about the predictive model used is available via this "), 
                      a(href = "https://rpubs.com/jeandsantos88/Concrete_Mixture_Optimization", "link."),
                      br(),br(),
                      ("For questions or feedback please contact via "), a(href = "https://www.linkedin.com/in/jeandsantos/", "LinkedIn"), 
                      (", "), a(href = "https://github.com/jeandsantos/", "GitHub"),
                      (" or "), a(href = "mailto:jeandsantos88@gmail.com", "email.")
                      ),
             tags$hr(),
             tags$span(style="color:grey", tags$footer(h4(("Made by "),strong(tags$a(href = "https://www.linkedin.com/in/jeandsantos/", target = "_blank", "Jean Dos Santos"))),
                                                       align = "center"))
             )
  )