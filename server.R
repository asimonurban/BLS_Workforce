library(ggvis)
library(dplyr)
if (FALSE) {
  library(RSQLite)
  library(dbplyr)
}
library("openxlsx")
library("shiny")

df <- read.xlsx("D:/Users/asimon/Desktop/BLS_App/Example/Employment_Projections.xlsx")

df <- df %>%
  mutate(Employment_growth = ifelse(Employment_growth < 0, 0, Employment_growth)) 

  function(input, output, session) { 
  # Filter
  bls <- reactive({
    employment_Num <- input$employment_Num
    oscars <- input$oscars
    employment_growth <- input$employment_growth
    median_Wage <- input$median_Wage
    ojt <- input$ojt
    
    # Apply filters
    m <- df %>%
      filter(
        Employment_Num >= employment_Num,
        Employment_growth <= employment_growth,
        Median_Wage >= median_Wage
      ) %>%
      
    # Optional: filter by Education
    if (input$education != "All") {
      education <- paste0("%", input$education, "%")
      m <- m %>% filter(Education %like% education)
    }
    # Optional: filter by Work Experience
    if (input$work_exp != "All") {
      work_exp <- paste0("%", input$work_exp, "%")
      m <- m %>% filter(Work_Exp %like% work_exp)
    }
    # Optional: filter by On the Job Training
    if (input$ojt != "All") {
      ojt <- paste0("%", input$ojt, "%")
      m <- m %>% filter(OJT %like% ojt)
    }
    m <- as.data.frame(m)
    m
  }
    )
  # Function for generating tooltip text
  movie_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$ID)) return(NULL)
    
    # Pick out the movie with this ID
    df <- isolate(bls())
    movie <- df[df$ID == df$ID, ]
    
    paste0("<b>", movie$Title, "</b><br>",
           movie$Employment_Num, "<br>",
           "$", movie$Median_Wage)
  }
  
  # A reactive expression with the ggvis plot
  vis <- reactive({
    # Lables for axes
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]
    
    bls %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 20, size.hover := 200,
                   fillOpacity := 0.2, fillOpacity.hover := 0.5,
                  key := ~ID) %>%
      add_tooltip(movie_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      set_options(width = 500, height = 500)
  })
  
  vis %>% bind_shiny("plot1")
  
  output$n_movies <- renderText({ nrow(bls()) })
}



