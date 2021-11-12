#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(leaflet)
library(rgee)
library(mapedit) # (OPTIONAL) Interactive editing of vector data
library(raster)  # Manipulate raster data
library(scales)  # Scale functions for visualization
library(cptcity)  # cptcity color gradients!
#library(tmap)    # Thematic Map Visualization <3
library(kableExtra)
library(slickR)
library(ggiraph)
library(ggplot2)
library(ggthemes)

ee_Initialize() 


library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = control_del_zoom, col = 'darkgray', border = 'white')

    })

    
    output$fechai <- renderPrint({ input$fecha1 })
    output$fechaf <- renderPrint({ input$fecha2 })
    
    
    output$mapita <- renderLeaflet({

    g <- ee$ImageCollection("LANDSAT/LC08/C01/T1")$
        filter(ee$Filter()$eq("WRS_PATH", 233))$
        filter(ee$Filter()$eq("WRS_ROW", 83))$
        filterMetadata ('CLOUD_COVER', 'Less_Than', 20)$
        filterDate("2020-03-01", "2020-04-01")
    # Representa la imagen a traves de una composicion RGB
    first <- g$first()

    vizParams <- list(
        bands = c("B5", "B4", "B3"),
        min = 5000,
        max = 15000,
        gamma = 1.3
    )
    Map$setCenter(lon = -70.64724, lat = -33.47269, zoom = input$control_del_zoom)

    h <- Map$addLayer(first, vizParams, "Landsat 8")

    return(h)


    })
    
    
    
    
    # selections2 = reactive({
        
        # req(input$radio1)
        # lista <- c("IW","EW","SM")
        # lista <- as.data.frame(lista)
        # colnames(lista) <- "opciones"
        # lista[lista$opciones == input$radio1,]
        
        # paste(input$fecha2)
        
        # req()
    # })
    
    fecha_1 = reactive({
        paste(input$fecha1) 
    })
    
    fecha_2 = reactive({
        paste(input$fecha2) 
    })
    
    radio_1 = reactive({
        paste(input$radio1) 
    })
    
    grafico1 = reactive({
        habitats = ee$FeatureCollection(
            list(
                ee$Feature(ee$Geometry$Polygon(
                    list(
                        c(-1.345864517292552, 59.97338078318311),
                        c(-1.345864517292552, 59.97237144577356),
                        c(-1.3438904114575911, 59.97237144577356),
                        c(-1.3438904114575911, 59.97338078318311)
                    )
                ), list(name = "Debemos poner algo"))
            )
        )
        
        sentinel1 = ee$ImageCollection('COPERNICUS/S1_GRD')$filterDate(fecha_1(), fecha_2() )
        
        # Filter by metadata properties
        vvvh = sentinel1$
            filter(ee$Filter$listContains('transmitterReceiverPolarisation', 'VV'))$
            filter(ee$Filter$listContains('transmitterReceiverPolarisation', 'VH'))$
            filter(ee$Filter$eq('instrumentMode', 'IW'))$
            filter(ee$Filter$eq('resolution_meters', 10))
        
        # Filter to get images from different look angles.
        vhAscending = vvvh$filter(ee$Filter$eq('orbitProperties_pass', 'ASCENDING'))
        vhDescending = vvvh$filter(ee$Filter$eq('orbitProperties_pass', 'DESCENDING'))
        
        # Calculate mean of VH ascending polarisation
        VH_Ascending_mean <- vhAscending$select("VH")$mean()
        
        # Calculate mean of VH descending polarisation
        VH_Descending_mean <- vhDescending$select("VH")$mean()
        
        # Merge VV and VH and calculate mean
        VV_Ascending_Descending_mean <- vhAscending$select("VV") %>%
            ee$ImageCollection$merge(vhDescending$select("VV")) %>%
            ee$ImageCollection$mean()
        
        # Create single image containing bands of interest
        collection <- ee$ImageCollection$fromImages(list(VH_Ascending_mean,VV_Ascending_Descending_mean,VH_Descending_mean))$toBands()
        
        
        
        mySamples <- collection$sampleRegions(
            collection = ee$Feature(habitats$first()),
            scale= 10,
            geometries=TRUE
        )
        
        mySamples_sf_batch <<- ee_as_sf(mySamples)
        
        
        
        
        output$descargar_tb  <- downloadHandler(
            filename = function() {
                paste("Tabla01", ".xlsx", sep="")
            },
            content = function(file) {
                
                df<-mySamples_sf_batch
                
                write_xlsx(df, file)    }
        )
        
        
        output$tablagraf = 
            DT::renderDataTable({
                DT::datatable(mySamples_sf_batch,
                              colnames = colnames(mySamples_sf_batch),
                              options = list(scrollX=TRUE),
                              rownames = FALSE, escape = FALSE
                              
                )
            })
        
        
        
        
        output$descargar_graf <- downloadHandler(
            filename = function() { paste("Histograma of X / ",fecha_1()," / ",fecha_2(),'.png', sep='') },
            content = function(file) {
                device <- function(..., width, height) grDevices::png(..., width = width, height = height, res = 300, units = "in")
                ggsave(file, plot = grafico1(), device = device)
            }
        )
        
        mySamples_sf_batch2 <- as.data.frame(mySamples_sf_batch)
        
        titulo_grafica1 <- paste("Histograma of X / ",fecha_1()," / ",fecha_2(), sep = "")
        # https://drsimonj.svbtle.com/pretty-histograms-with-ggplot2
        ggplot(mySamples_sf_batch2, aes(mySamples_sf_batch2[,c(radio_1())], fill = cut(mySamples_sf_batch2[,c(radio_1())], 100))) +
            geom_histogram(show.legend = FALSE,bins=30) +
            scale_fill_discrete(h = c(240, 10), c = 120, l = 70) +
            scale_colour_economist() +
            labs(x = "X", y = "Cantidad de casos") +
            geom_density(alpha = .5, fill = "#ff4d4d") +
            ggtitle(titulo_grafica1)
            
        
        
        
    })
    
    
    output$grafica1 <- renderPlot({
        
        grafico1()
        
    })
    
    
    output$grafica2 <- renderPlot({

        bp <- ggplot(iris, aes(x = factor(Species), y = Sepal.Width))
        bp + geom_boxplot()

    })
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
})






