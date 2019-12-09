library(shiny)
library(tidyverse)
library(sf)
library(leaflet)

df = st_read('geocoded_soldiers.geojson')

#data bounding box for map
bbox <- st_bbox(df) %>% 
  as.vector()

#Shiny UI
ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                style="z-index:500;", # legend over my map (map z = 400)
                tags$h3("Soldiers Ineffective "), 
                sliderInput("yearrange", "Chronology",
                            min(df$Year),
                            max(df$Year),
                            value = range(df$Year),
                            step = 1,
                            sep = ""
                )
  )
)

#Shiny Server
server <- function(input, output, session) {
  
  # reactive filtering data from UI
  
  reactive_data_chrono <- reactive({
    df %>%
      filter(Year >= input$yearrange[1] & Year <= input$yearrange[2])
  })
  
  
  # static backround map
  output$map <- renderLeaflet({
    leaflet(df) %>%
      addProviderTiles(providers$Stamen.TerrainBackground) %>% 
      fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])
  })  
  
  # reactive circles map
  observe({
    leafletProxy("map", data = reactive_data_chrono()) %>%
      clearMarkerClusters() %>% 
      clearPopups() %>% 
      addMarkers(
        clusterOptions = markerClusterOptions()
      )
  })
}

shinyApp(ui, server)