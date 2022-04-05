# Maximum size = 30MB for uploaded files
options(shiny.maxRequestSize = 100 * 1024 ^ 2)

# install dev version
#if(!require("devtools")) install.packages("devtools")
#devtools::install_github("bwlewis/rthreejs")

#devtools::install_github("EmilHvitfeldt/paletteer")

#if (!require("BiocManager", quietly = TRUE))
#    install.packages("BiocManager")
# BiocManager::install("flowCore")

# Load libraries
library(shiny)
library(flowCore)
library(tidyr)
library(threejs)
library(RColorBrewer)
library(scales)
library(viridisLite)
library(paletteknife)
library(data.table)

library(tsne)
library(umap)

library(reticulate)

pacmap <- import("pacmap")



# do this once to use the python implementation of umap
# TODO could also add other python algorithms this way (trimap etc)
# py_install("umap-learn")
# py_install(c('pacmap', 'umap-learn', 'trimap', 'scikit-learn'), pip=TRUE) 

# define available transformations
# TODO add FlowJo transformations if needed (biex)
transformations <- list(
    'Linear' = identity,
    'Log' = log10,
    'Pseudolog' = pseudo_log_trans(base = 10)$trans
)

shinyServer(function(input, output, session) {
    
    plot_data <- reactiveVal()
    
    observeEvent(input$fcs_file, {
        print('updating plot data')
        infile <- input$fcs_file
        if (is.null(infile)) {
            return(NULL)
        }
        ext <- tools::file_ext(infile$datapath)
        print(ext)
        validate(need(ext %in% c('fcs', 'gz'), "Please upload .fcs or .csv.gz file"))
        
        if (ext == 'fcs'){
            plot_data(data.matrix(exprs(read.FCS(infile$datapath)))) # return as a matrix
        } else if (ext == 'gz') {
            print('csv file')
            plot_data(data.matrix(fread(infile$datapath)))
        } else {
            print('unknown data')
        }
            
        
    })
    
    # update color and channel choices
    observeEvent(plot_data(), {
        updateSelectizeInput(session,
                             "channels",
                             choices = unname(colnames(plot_data())))
        
        updateSelectizeInput(session,
                             "color",
                             choices = unname(colnames(plot_data())))
        
        updateSelectizeInput(session,
                             "channels_project",
                             choices = unname(colnames(plot_data())))
        
    })

    event_plot <-  eventReactive(input$button_plot, {
        fcsdata <- plot_data()
        if (is.null(fcsdata))
            return(NULL)
        if (length(input$channels) != 3)
            return(NULL)
        
        # get the requested channels and apply transformations
        x <- fcsdata[, input$channels]
        x[, 1] <- transformations[[input$scale1]](x[, 1])
        x[, 2] <- transformations[[input$scale2]](x[, 2])
        x[, 3] <- transformations[[input$scale3]](x[, 3])
        
        # drop any rows with NA or inf values
        finite_rows <- apply(x, 1, function(x) { all(is.finite(x))})
        
        # use color info if defined
        if (is.null(input$color)){
            color = 'black'
        } else {
            color_vec <- fcsdata[, input$color]
            color_vec <- transformations[[input$color_scale]](color_vec)
            finite_rows <- finite_rows & is.finite(color_vec)
            color_vec <- color_vec[finite_rows]
            color <- autocol(color_vec)

        }
        
        x <- x[finite_rows,]
        
        if (input$subsample){
            x <- x[sample(nrow(x), size=floor(0.2 * nrow(x)), replace=FALSE),]
        }
        scatterplot3js(
            x = x,
            #axisLabels = c(input$channels[1], input$channels[3], input$channels[2]),
            size = 0.01,
            color = color,
            stroke = 0.00001,
            grid = FALSE,
            signif = 6,
            pch = ".",
            #width = 800,
            #height = 800
        )
        
    })
    
    output$scatterplot <- renderScatterplotThree({
        event_plot()
    })
    
    observeEvent(input$button_project, {
        print('Projecting raw data')
        
        fcsdata <- plot_data()
        if (is.null(fcsdata))
            return(NULL)
        if (length(input$channels_project) < 3)
            return(NULL)
        
        # get the requested channels and apply transformations
        x <- fcsdata[, input$channels_project]
        mapper <- pacmap$PaCMAP()
        mapped <- mapper$fit_transform(x, init="pca", verbose=TRUE)
        colnames(mapped) <- c('pacmap1', 'pacmap2')
        
        # add the projected values to the plot data
        fcsdata <- cbind(fcsdata, mapped)
        plot_data(fcsdata)
        
        #fwrite(data2, file='~/Desktop/flowviz/test.csv.gz', row.names = FALSE, compress = 'gzip')    
    })
    
    # Download as csv data
    output$button_download <- downloadHandler(
        filename = function() {
            paste0("data", ".csv.gz") # better names needed
        },
        content = function(file) {
            fwrite(plot_data(), file, row.names = FALSE, compress='gzip')
        }
    )
    
})
