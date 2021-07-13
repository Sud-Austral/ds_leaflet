



library(shiny)
library(leaflet)
library(raster)



ui <- fluidPage(
    leafletOutput("mymap")
)

server <- function(input, output, session) {
    

    
    output$mymap <- renderLeaflet({
        
        variablesss <- raster("C:/Users/usuario/AppData/Local/Temp/RtmpuebU6F/noid_image.tif")
        leaflet() %>%
            
            
            
            addProviderTiles(variablesss 
                      
            )
    })
}

shinyApp(ui, server)
