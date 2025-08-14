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

## Live App

Visit the deployed app: [https://dnageek.github.io/cell-line-playground/](https://dnageek.github.io/cell-line-playground/)

## Local Development

To run locally:
1. Install R and required packages: `shiny`, `shinylive`, `readr`, `dplyr`, `heatmaply`, `tidyr`, `plotly`
2. Run `shiny::runApp("app/app.R")`
