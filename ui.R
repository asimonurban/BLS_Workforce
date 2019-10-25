library(ggvis)
# For dropdown menu
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}

fluidPage(
  titlePanel("Job Quality"),
  fluidRow(
    column(3,
           wellPanel(
             h4("Filter"),
             sliderInput("Employment_Num", "Minimum number of Jobs",
                         0, 4000, 100, step = 100),
             sliderInput("Employment_Growth", "Employment Growth Filter",
                         0, 4000, 100, step = 100),
             sliderInput("Median_Wage", "Median Wage",
                         0, 200000, c(0, 200000), step = 200)
           ),
           wellPanel(
             selectInput("xvar", "X-axis variable", axis_vars, selected = "Employment_Num"),
             selectInput("yvar", "Y-axis variable", axis_vars, selected = "Median_Wage"),
           )
    ),
    column(3,
           ggvisOutput("plot1"),
           wellPanel(
             span("Jobs Quality Index:",
                  textOutput("n_movies")
             )
           )
    )
  )
)