# Cell Line Playground

Interactive Shiny app for exploring DepMap cell line mutation data.

## Features

- Select DepMap data versions (24Q4, 25Q2)
- Choose cell lines and genes of interest
- Paste tables to automatically extract cell line and gene names
- Interactive mutation heatmap visualization

## Data Attribution

This project uses data from DepMap (https://depmap.org), which is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0).  
License details: https://creativecommons.org/licenses/by/4.0/

## Deployment

This app is designed to be deployed on shinyapps.io due to the large data files.

### Deploy to shinyapps.io

1. Install required packages:
```r
install.packages(c("rsconnect", "shiny", "readr", "dplyr", "heatmaply", "tidyr", "plotly", "viridisLite"))
```

2. Set up your shinyapps.io account and configure rsconnect:
```r
library(rsconnect)
setAccountInfo(name='your-account', token='your-token', secret='your-secret')
```

3. Deploy the app from the project directory:
```r
library(rsconnect)
deployApp()
```

## Local Development

To run locally:
1. Install R and required packages: `shiny`, `readr`, `dplyr`, `heatmaply`, `tidyr`, `plotly`, `viridisLite`
2. Ensure DepMap data files are in the `data/DepMap/` directories
3. Run `shiny::runApp("app.R")`
