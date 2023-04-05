library(shiny)
library(ggplot2)
ui <- fluidPage(
  titlePanel("Analysis of Returns Data"),
  fileInput("file1", "C:/Users/nixon/Downloads/use_this_cleaned_dataset_for_eda.csv"),
  selectInput("series", "Choose a stock ticker:", choices=c()),
  
  mainPanel(
    plotOutput("time",width="63%",height="275px")
    # tableOutput("TBL")
  )
)

#################################################################################
#
# Server function
#
server <- function(session,input,output) {
  
  data1 <- reactive({
    cat(file = stderr(), "Inside this\n")
    validate(need(input$file1,""))
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    df <- read.csv(inFile$datapath,na.strings = c("", "NA", "#N/A"))
    df2 <- head(df, 8)
    return(df2)    
  })
  
  data2 <- reactive({
    df3 <- data1()[,-1]
    print(df3)
    updateSelectInput(session,"series",choices=colnames(df3))    
    return(df3)    
  })
  
  output$time <- renderPlot({
    ggplot(data=data2(), aes_string(x="Country",y=input$series)) + geom_point(color="darkblue")   
  })
}
shinyApp(ui = ui, server = server)