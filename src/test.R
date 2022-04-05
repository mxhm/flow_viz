library(data.table)
library(shiny)
library(flowCore)
library(tidyr)
library(threejs)
library(RColorBrewer)
library(paletteknife)

#install.packages("reticulate")

datapath <- '~/Desktop/flowviz/RBC depletion_trial1_Specimen_001_Syto9 p1.fcs'

fcs_data <- read.FCS(datapath, truncate_max_range = TRUE, transformation = FALSE, alter.names=TRUE)
summary(fcs_data)

autocol(exprs(fcs_data)[,1])

library(ggcyto)



spillover(fcs_data)
autoplot(fcs_data, 'SSC.A', 'FSC.A')

autoplot(
  transform(fcs_data, 'SSC.A'=log(SSC.A)),
  'SSC.A', 'FSC.A')



ggplot(fcs_data, aes(x=log(SSC.A), y=FSC.A)) +
  #geom_bin_2d(bins=256) +
  #stat_density_2d() +
  #scale_y_log10() +
  geom_hex(bins=256) +
  #scale_x_log10() +
  scale_fill_gradientn(colours = hcl.colors(7), trans = "sqrt")

scatterplot3js(
  x = log(exprs(fcs_data$SSC.A)),
  y = exprs(fcs_data$FSC.A),
  z = exprs(fcs_data$FITC.A),
  #axisLabels = c(input$channel[1], input$channel[3], input$channel[2]),
  # Correct order?
  #size = 0.1,
  #color = hex_colors
)

plot_data <- exprs(fcs_data[,c('SSC.A', 'FSC.A', 'FITC.A')])
plot_data[,1] <- log(plot_data[,1])
plot_data[,3] <- log(plot_data[,3])

plot_mat <- data.matrix(plot_data)

finite_rows <- apply(plot_mat, 1, function(x) { all(is.finite(x))})

plot_data <- plot_data[finite_rows,]

#names(plot_data)
scatterplot3js(
  x = exprs(fcs_data[,c('SSC.A', 'FSC.A', 'FITC.A')]),
  size = 1
)
#plot_data_ <- na.exclude(plot_data)
scatterplot3js(
  x = plot_data,
  size = 0.01
)


#+
#  scale_fill_viridis_b()

#data_mat1 <- data.matrix(exprs(read.FCS(datapath, truncate_max_range = TRUE))) # return as a matrix
#data_mat2 <- data.matrix(exprs(read.FCS(datapath, truncate_max_range = FALSE))) # return as a matrix
#data_mat3 <- data.matrix(exprs(read.FCS(datapath, truncate_max_range = FALSE, transformation = FALSE))) # return as a matrix

#exprs(read.FCS(datapath, truncate_max_range = FALSE, transformation = FALSE)))

plot_df <- data.table(exprs(read.FCS(datapath, truncate_max_range = TRUE, transformation = FALSE)))

data_mat1 - data_mat2


#install.packages("ggplot2")

library(ggplot2)

# ggplot(plot_df, aes(x=`SSC-A`, y=`FSC-A`)) +
#   geom_hex() +
#   scale_y_log10() +
#   scale_x_log10()

ggplot(plot_df, aes(x=`SSC-A`, y=`FSC-A`)) +
  #geom_bin_2d(bins=128) +
  stat_density_2d() +
  #scale_y_log10() +
  scale_x_log10() +
  scale_fill_viridis_b()

max(plot_df)
min(plot_df)
sum(!is.finite(plot_df$`SSC-A`))

#
