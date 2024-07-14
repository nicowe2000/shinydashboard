# Benötigte Pakete laden
library(shiny)
library(shinydashboard)
library(leaflet)
library(DT)
library(readr)
library(dplyr)

# Daten von der URL einlesen
url <- "https://data.bs.ch/api/v2/catalog/datasets/100126/exports/csv"
population_data <- read_delim(url, delim = ";")  # Korrekte Funktion und Argumente

# Überprüfen der Spaltennamen
colnames(population_data)

# UI-Definition
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

# Server-Logik
server <- function(input, output, session) {
  
  # Reaktive Daten basierend auf der ausgewählten Gemeinde
  selected_data <- reactive({
    population_data %>% filter(gemeinde == input$gemeinde)
  })
  
  # Leaflet-Karte rendern
  output$populationMap <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 7.5886, lat = 47.5596, zoom = 12)  # Beispielkoordinaten für Basel
  })
  
  # Daten-Tabelle rendern
  output$populationTable <- renderDT({
    datatable(selected_data())
  })
}

# Anwendung starten
shinyApp(ui = ui, server = server)
