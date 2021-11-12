



library(shiny)
library(leaflet)
library(raster)



ui <- fluidPage(
    leafletOutput("mymap")
)

server <- function(input, output, session) {
    

    
    output$mymap <- renderLeaflet({
        

        holc <- raster("C:/Users/usuario/AppData/Local/Temp/RtmpuebU6F/noid_image.tif")
        plot(holc)
    })
}

shinyApp(ui, server)
