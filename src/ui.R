library(shiny)
library(shinyWidgets)
library(threejs)


shinyUI(fluidPage(

    titlePanel("3d flow viz"),

    sidebarLayout(
        sidebarPanel(
            
            fileInput("fcs_file", "Choose .fcs/.csv.gz File",
                      accept = c(".fcs", '.gz'),
            ),
            
            selectizeInput("channels", "Plot 3 channels:",
                           NULL, multiple = TRUE,
                           options = list(maxItems = 3)),
            
            radioGroupButtons(
                inputId = "scale1",
                label = "Scale for channel 1", 
                choices = c("Linear", "Log", "Pseudolog"),
                size = "xs"
            ),
            
            radioGroupButtons(
                inputId = "scale2",
                label = "Scale for channel 2", 
                choices = c("Linear", "Log", "Pseudolog"),
                size = "xs"
            ),
            
            radioGroupButtons(
                inputId = "scale3",
                label = "Scale for channel 3", 
                choices = c("Linear", "Log", "Pseudolog"),
                size = "xs"
            ),
            
            selectizeInput("color", "Color:",
                           NULL, multiple = TRUE,
                           options = list(maxItems = 1)),
             
            radioGroupButtons(
                inputId = "color_scale",
                label = "Scale for color",
                choices = c("Linear", "Log", "Pseudolog"),
                size = "xs"
            ),
            
            checkboxInput("subsample", "subsample", FALSE),
            
            actionButton("button_plot", "Plot"),
            
            sliderInput('pointsize', 'Size', min=0.001, max=0.1, value = 0.001),
            
            selectizeInput("channels_project", "Project channels:",
                           NULL, multiple = TRUE),
            
            actionButton("button_project", "Add projections"),
            
            downloadButton("button_download", "Download Data(.csv)"),
            width = 2
        ),

        # Show a plot of the generated distribution
        mainPanel(
            #scatterplotThreeOutput('scatterplot'),
            #scatterplotThreeOutput('scatterplot', width = "800", height = "800"),
            scatterplotThreeOutput('scatterplot', width = "1000", height = "1000"),
            width = 10
         
        )
    )
))
