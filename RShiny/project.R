
library(shiny)
library(shinydashboard)
library(fmsb)
library(bslib)
library(dplyr)
library(ggplot2)
library(shinythemes)
library(geniusr)
library(DT)
library(fmsb)
options(shiny.maxRequestSize = 30 * 1024^2)
source("/Users/yobahbertrandyonkou/Downloads/D and D/classification_module/classify.R")

Sys.setenv(GENIUS_API_TOKEN = "OErgxm17PVFBmG7fjQHdptxCUBJPzxK1KYKJYjYt7ZVXBZplslV12Tp6L2Mj-Io0")

# Genius Authorization
genius_token()

dataset <- read.csv("use_this_cleaned_dataset_for_eda.csv")

# ui code starts here
ui <- fluidPage(dashboardPage(
  skin = c("purple"),
  header <- dashboardHeader(title = "Drink and Derive", titleWidth = 230),
  sidebar <- dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard"),
      menuItem("EDA Analysis", tabName = "edaanalysis"),
      menuItem("Dataset", tabName = "dataset"),
      menuItem("Case Study", tabName = "casestudy"),
      menuItem("About Us", tabName = "aboutus")
    )
  ),
  body <- dashboardBody(
    fluidRow(
      column(
        selectInput("artseries", "Choose an Artist:", choices = dataset[, 3]),
        song <- selectInput("songseries", "Choose a song:", choices = c()),
        dance <- filter(dataset, title == song)$danceability,
        acoustic <- filter(dataset, title == song)$acousticness,
        popular <- filter(dataset, title == song)$popularity,
        loud <- filter(dataset, title == song)$loudness,
        parleg <- filter(dataset, title == song)$energy,
        live <- filter(dataset, title == song)$liveness,
        actionButton("goButton", "Analyze Lyrics"),
        dataTableOutput("result"),
        width = 6, height = 6
      ),
      column(
        h4("Results"),
        plotOutput("plot"),
        width = 6
      ),
      fluidRow(
        box(
          plotOutput("radarPlot", width = "100%")
        )
      )
    )
  )
))

server <- shinyServer(function(session, input, output) {
  music <- read.csv("MUSIC.csv", header = TRUE, sep = ",")

  # listening to artist name change
  observeEvent(input$artseries, {
    artist <- input$artseries
    songs <- dataset[dataset$artist == artist, ]

    output$result <- renderDataTable({
      df <- get_lyrics_search(input$artseries, input$songseries)
      datatable(head(df, 100), options = list(
        columnDefs = list(list(className = "dt-center", targets = c("section_artist", "song_name", "section_name", "artist_name"), visible = FALSE)), # nolint
        pageLength = 15,
        lengthMenu = c(5, 10, 15)
      ))
    })

    updateSelectInput(
      session,
      inputId = "songseries",
      choices = unlist(songs$title)
    )
  })

  # # listening to song title selected
  # observeEvent(input$songseries, {
  #   req(input$songseries)

  # })
  # observing search lyrics button
  observeEvent(input$goButton, {
    artist <- input$artseries
    title <- input$songseries
    song <- dataset[dataset$artist == artist & dataset$title == title, ]

    # passing lyrics to model
    result <- classify_lyrics(song$lyrics)
    labels <- result[1:3]
    probs <- as.numeric(result[5:7])
    scaled_dataset <- transform(
      data.frame(
        probabilities = probs,
        sentiments = labels
      ),
      probabilities = (probabilities - min(probs)) / max(probs) - min(probs)
    )

    # updating plot
    output$plot <- renderPlot({
      g <- ggplot(
        scaled_dataset,
        aes(y = probabilities, x = sentiments)
      )
      g + geom_bar(stat = "sum")
    })

    # output$result <- renderDataTable({
    #   df <- get_lyrics_search(input$artseries, input$songseries)
    #   datatable(head(df, 100), options = list(
    #     columnDefs = list(list(className = "dt-center", targets = c("section_artist", "song_name", "section_name", "artist_name"), visible = FALSE)), # nolint
    #     pageLength = 15,
    #     lengthMenu = c(5, 10, 15)
    #   ))
    # })
    # spider curve
    output$radarPlot <- renderPlot({
      # fetching song details based on title and artist
      artist <- input$artseries
      title <- input$songseries
      song <- dataset[dataset$artist == artist & dataset$title == title, ]
      print(song$artist)
      print(song$title)
      # getting min and max values of audio descriptors
      values <- c(song$danceability, song$acousticness, song$valence, song$loudness, song$energy, song$liveness)
      min_values <- min(values)
      max_values <- max(values)
      danceability <- c(max_values, min_values, song$danceability)
      acousticness <- c(max_values, min_values, song$acousticness)
      valence <- c(max_values, min_values, song$valence)
      loudness <- c(max_values, min_values, song$loudness)
      energy <- c(max_values, min_values, song$energy)
      liveness <- c(max_values, min_values, song$liveness)

      data <- data.frame(
        danceability,
        acousticness,
        valence,
        loudness,
        energy,
        liveness,
        row.names = c("max", "min", "descriptors")
      )
      # Create plot
      graph <- radarchart(data,
        title = "Music Spider Chart",
      )
    })
  })

  # spider curve
  output$radarPlot <- renderPlot({
    # fetching song details based on title and artist
    artist <- input$artseries
    title <- input$songseries
    song <- dataset[dataset$artist == artist & dataset$title == title, ]
    print(song$artist)
    print(song$title)
    
    # getting min and max values of audio descriptors
    values <- c(song$danceability, song$acousticness, song$valence, song$loudness, song$energy, song$liveness)
    min_values <- min(values)
    max_values <- max(values)

    danceability <- c(max_values, min_values, song$danceability)
    acousticness <- c(max_values, min_values, song$acousticness)
    valence <- c(max_values, min_values, song$valence)
    loudness <- c(max_values, min_values, song$loudness)
    energy <- c(max_values, min_values, song$energy)
    liveness <- c(max_values, min_values, song$liveness)

    data <- data.frame(
      danceability,
      acousticness,
      valence,
      loudness,
      energy,
      liveness,
      row.names = c("max", "min", "descriptors")
    )
    # Create plot
    graph <- radarchart(data,
      title = "Music Spider Chart",
    )
  })


  # outputting results
  output$plot <- renderPlot({
    g <- ggplot(
      data.frame(
        probabilities = c(1, 1, 1),
        sentiments = c("angry", "happy", "sad")
      ),
      aes(y = probabilities, x = sentiments),
    )
    g + geom_bar(stat = "sum")
  })
})

# Run the application
shinyApp(ui = ui, server = server)
