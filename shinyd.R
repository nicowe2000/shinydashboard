#load packages
library(shiny)
library(shinydashboard)
library(leaflet)
library(DT)
library(readr)
library(dplyr)

#scrape data from Web
url <- "https://data.bs.ch/api/v2/catalog/datasets/100126/exports/csv"
population_data <- read_delim(url, delim = ";") 

#check column names
colnames(population_data)

# UI-definition
ui <- dashboardPage(
  dashboardHeader(title = "Bevölkerungsdashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Karte", tabName = "map", icon = icon("globe")),
      menuItem("Daten", tabName = "data", icon = icon("table"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              fluidRow(
                box(width = 12, leafletOutput("populationMap"))
              )),
      tabItem(tabName = "data",
              fluidRow(
                box(width = 12,
                    selectInput("gemeinde", "Wählen Sie eine Gemeinde:", choices = unique(population_data$gemeinde)),
                    DTOutput("populationTable"))
              ))
    )
  )
)

# server logic
server <- function(input, output, session) {
  
  # reactive data on chosen "gemeinde"
  selected_data <- reactive({
    population_data %>% filter(gemeinde == input$gemeinde)
  })
  
  # Leaflet
  output$populationMap <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 7.5886, lat = 47.5596, zoom = 12)  # coordinates of basel
  
  # load table
  output$populationTable <- renderDT({
    datatable(selected_data())
  })
}

# start dashboard
shinyApp(ui = ui, server = server)
