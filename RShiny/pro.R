library(shiny)
library(shinydashboard)
library(fmsb)
library(bslib)
library(dplyr)
library(ggplot2)


ui <- fluidPage(dashboardPage(skin = c("purple"),
  header <- dashboardHeader(title = "Drink and Derive", titleWidth = 230),
  sidebar <- dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("EDA Analysis", tabName = "edaanalysis", icon = icon("chart-line")),
      menuItem("Dataset", tabName = "dataset", icon = icon("database")),
      menuItem("Case Study", tabName = "casestudy", icon = icon("table")),
      menuItem("About Us", tabName = "aboutus", icon = icon("user"))
    )
  ),
  body <- dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
          fluidRow(
               selectInput(inputId = "sel_Mood",
               label = "Choose Mood",
               list("Happy","Sad","Angry","Relaxed")),
               plotOutput("plot"),
               column(6),
               box(
                 plotOutput('radarPlot')
                 ))),
      tabItem(tabName = "edanalysis","This panel is left blank"),
      tabItem(tabName = "dataset", "This panel is left blank"),
      tabItem(tabName = "casestudy", "This panel is left blank"),
      tabItem(tabName = "aboutus", "This panel is left blank")
    ))))
server <- shinyServer(function(input, output) {
  music = read.csv("MUSIC.csv", header = TRUE,  sep = ",")
  
  #Summarize Data and then Plot
  data <- reactive({
    req(input$sel_Mood)
    df <- music %>% filter(Mood %in% input$sel_Mood) %>%  group_by(Rank) %>% summarise(Views = sum(Views))
  })
  
  #Plot 
  output$plot <- renderPlot({
    g <- ggplot(data(), aes( y = Views, x = Rank))
    g + geom_bar(stat = "sum")
  })
  output$radarPlot <- renderPlot({
    data <- data.frame(Danceability = c(7, 0, 6, 7, 4, 3),
                       Acousticness = c(7, 0, 5, 7, 3, 2),
                       Popularity = c(7, 0, 6, 2, 4, 3),
                       Loudness = c(7, 0, 4, 4, 4, 6),
                       Energy = c(7, 0, 6, 6, 1, 1),
                       Liveness = c(7, 0, 6, 6, 3, 3),
                       row.names = c("max", "min", "Happy", "Sad", 
                                     "Angry", "Relaxed"))
    
    # Define fill colors
    colors_fill <- c(scales::alpha("gray", 0.1),
                     scales::alpha("gold", 0.1),
                     scales::alpha("tomato", 0.2),
                     scales::alpha("skyblue", 0.2))
    
    # Define line colors
    colors_line <- c(scales::alpha("darkgray", 0.9),
                     scales::alpha("gold", 0.9),
                     scales::alpha("tomato", 0.9),
                     scales::alpha("royalblue", 0.9))
    
    # Create plot
    radarchart(data,
               seg = 7,  # Number of axis segments
               title = "Music Spider Chart",
               pcol = colors_line,
               pfcol = colors_fill,
               plwd = 2)
    
    # Add a legend
    legend(x=0.6, 
           y=1.35, 
           legend = rownames(data[-c(1,2),]), 
           bty = "n", pch=20 , col = colors_line, cex = 1.05, pt.cex = 3)
  })
})

# Run the application
shinyApp(ui = ui, server = server)

