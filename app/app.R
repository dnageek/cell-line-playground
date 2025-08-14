library(shinylive)

ui <- fluidPage(
  titlePanel("Cell Line Playground"),
  # Add UI components here
)

server <- function(input, output, session) {
  # Add server logic here
}

shinyApp(ui, server)
library(shiny)
library(shinylive)
library(readr)
library(dplyr)

# Helper to list available versions
get_versions <- function() {
  data_dir <- "../data/DepMap"
  versions <- list.dirs(data_dir, full.names = FALSE, recursive = FALSE)
  versions[versions != ""]
}

ui <- fluidPage(
  titlePanel("Cell Line Playground"),
  sidebarLayout(
    sidebarPanel(
        selectInput("version", "Select DepMap Version", choices = get_versions()),
        uiOutput("cellline_ui"),
        uiOutput("gene_ui"),
        tags$hr(),
        textAreaInput("paste_table", "Paste Table (cell lines and/or genes)", rows = 5, placeholder = "Paste your table here (tab or comma separated)"),
        actionButton("extract_btn", "Extract IDs from Table")
      ),
    mainPanel(
      verbatimTextOutput("summary"),
      plotlyOutput("mutation_heatmap")
    )
  )
)

server <- function(input, output, session) {
  library(heatmaply)
  library(tidyr)
  library(plotly)

  # For R CMD check: declare global variables
  utils::globalVariables(c("StrippedCellLineName", "HugoSymbol", "VariantInfo", "HasMutation", "ModelID"))
  # Reactive to load Model.csv
  model_data <- reactive({
    req(input$version)
    path <- file.path("../data/DepMap", input$version, "Model.csv")
    read_csv(path, show_col_types = FALSE)
  })

  # Reactive to load OmicsSomaticMutations.csv
  mutation_data <- reactive({
    req(input$version)
    path <- file.path("../data/DepMap", input$version, "OmicsSomaticMutations.csv")
    read_csv(path, show_col_types = FALSE)
  })

  # UI for cell line selection
  output$cellline_ui <- renderUI({
    df <- model_data()
    selectizeInput("celllines", "Select Cell Lines", choices = unique(df$StrippedCellLineName), multiple = TRUE)
  })

  # UI for gene selection
  output$gene_ui <- renderUI({
    df <- mutation_data()
    selectizeInput("genes", "Select Genes", choices = unique(df$HugoSymbol), multiple = TRUE)
  })

  # Extract cell line IDs and gene names from pasted table
  observeEvent(input$extract_btn, {
    txt <- input$paste_table
    if (nzchar(txt)) {
      # Try to parse pasted text as a table
      lines <- strsplit(txt, "\n")[[1]]
      # Split each line by tab or comma
      split_lines <- lapply(lines, function(x) strsplit(x, "[\t,]")[[1]])
      # Flatten and trim whitespace
      vals <- unique(trimws(unlist(split_lines)))
      # Get valid cell lines and genes from loaded data
      valid_celllines <- unique(model_data()$StrippedCellLineName)
      valid_genes <- unique(mutation_data()$HugoSymbol)
      # Find matches
      found_celllines <- intersect(vals, valid_celllines)
      found_genes <- intersect(vals, valid_genes)
      # Update selections
      updateSelectizeInput(session, "celllines", selected = found_celllines)
      updateSelectizeInput(session, "genes", selected = found_genes)
    }
  })

  # Show summary of selections
  output$summary <- renderPrint({
    list(
      version = input$version,
      celllines = input$celllines,
      genes = input$genes
    )
  })

  # Render mutation heatmap
  output$mutation_heatmap <- plotly::renderPlotly({
    req(input$celllines, input$genes)
    
    # Get ModelIDs for selected cell lines
    model_df <- model_data()
    selected_models <- model_df %>%
      filter(StrippedCellLineName %in% input$celllines) %>%
      select(ModelID, StrippedCellLineName)
    
    mut_df <- mutation_data()
    # Filter for selected ModelIDs and genes
    filtered <- mut_df %>%
      filter(ModelID %in% selected_models$ModelID, HugoSymbol %in% input$genes) %>%
      # Join with model data to get cell line names for display
      left_join(selected_models, by = "ModelID")
    
    # Summarize multiple entries per cell line-gene combination by concatenating
    mat <- filtered %>%
      select(StrippedCellLineName, HugoSymbol, VariantInfo) %>%
      group_by(StrippedCellLineName, HugoSymbol) %>%
      summarise(VariantInfo = paste(VariantInfo, collapse = "; "), .groups = "drop") %>%
      # Create binary matrix: 1 if mutation present, 0 if not
      mutate(HasMutation = ifelse(nchar(VariantInfo) > 0, 1, 0)) %>%
      select(StrippedCellLineName, HugoSymbol, HasMutation) %>%
      tidyr::pivot_wider(names_from = HugoSymbol, values_from = HasMutation, values_fill = 0)
    # Remove cell line column for rownames
    mat_matrix <- as.data.frame(mat)
    rownames(mat_matrix) <- mat_matrix$StrippedCellLineName
    mat_matrix$StrippedCellLineName <- NULL
    # Convert to matrix
    m <- as.matrix(mat_matrix)
    
    # Calculate height based on number of cell lines (minimum 400px, ~30px per cell line)
    plot_height <- max(400, nrow(m) * 30)
    
    # Plot heatmap with binary colors
    heatmaply::heatmaply(m, xlab = "Genes", ylab = "Cell Lines", main = "Mutation Heatmap", colors = c("white", "red"), 
                        dendrogram = "none", cluster_rows = FALSE, cluster_cols = FALSE,
                        width = NULL, height = plot_height,
                        grid_color = "black", grid_width = 1)
  })
}

shinyApp(ui, server)
