# flow_viz
Interactive cytometry visualisation

## installation

clone this app with git:

```bash
git clone git@github.com:obi-ds/flow_viz.git
```

download and install [RStudio]('https://www.rstudio.com/products/rstudio/download/') and [R](https://cloud.r-project.org)

```R

# install devtools
if(!require("devtools")) install.packages("devtools")

# rthreejs
devtools::install_github("bwlewis/rthreejs")

# flowCore
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("flowCore")

# data.table, reticulate etc.
install.packages(c('data.table', 'paletteknife', 'reticulate))
```

for dimension reduction, install a few more python packages:
```R

library(reticulate)
py_install(c('pacmap', 'umap-learn', 'trimap', 'scikit-learn'), pip=TRUE) 

```
