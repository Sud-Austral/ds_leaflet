#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
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
ee_Initialize() 
library(ggplot2)
library(ggthemes)

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    shinythemes::themeSelector(),
    # Application title
    titlePanel("Controlando Rgee desde shiny"),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            
            h3("Filtros por variable y fecha"),
            
            sliderInput("control_del_zoom",
                        "Seleccione el nivel del zoom:",
                        min = 1,
                        max = 24,
                        value = 10),
            
            # selectInput(inputId = "parametro1",
            #             label = "transmitterReceiverPolarisation 1",
            #             choices = c("VV" = "VV",
            #                         "HH" = "HH",
            #                         "VV,VH" = "'VV','VH'",
            #                         "HH,VH" = "'HH','HV'")),
            # 
            # selectInput(inputId = "parametro2",
            #             label = "transmitterReceiverPolarisation 2",
            #             choices = c("VV" = "VV",
            #                         "HH" = "HH",
            #                         "VV,VH" = "'VV','VH'",
            #                         "HH,VH" = "'HH','HV'")),
            # 
            
            
            # Copy the line below to make a date selector 
            dateInput("fecha1", label = h3("Fecha inicio"), value = "2019-03-01"),
            dateInput("fecha2", label = h3("Fecha final"), value = "2020-03-01"),
            
            radioButtons("radio1", "",
                         c("X0_VH" = 'X0_VH', "X1_VV" = 'X1_VV', "X2_VH" = 'X2_VH'),c("X1_VV" = 'X1_VV'), TRUE),
            
             
        ),
 
        mainPanel(
            leafletOutput("mapita"),
            br(),
            
        ),
        
        
    ),
    
    tabPanel(
        br(),
        column(width = 6, align = "center", downloadButton("descargar_tb", "Descargar"), DT::dataTableOutput("tablagraf")),
        column(width = 6, align = "center", downloadButton("descargar_graf", "Descargar"), br(),br(),br(), plotOutput("grafica1"))
        
    ),
    
    tabPanel(
        br(),
        column(width = 6, align = "center", downloadButton("descargar_graf2", "Descargar"), br(),br(),br(), plotOutput("grafica2"))
        
    ),
    
    h4("Generacion de muestras personalizadas"),
    br(),
    h4("muestras aleatorias"),
    br(),
    h4("muestreo sistematico"),
    br(),
    
))







































