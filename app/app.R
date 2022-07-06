library(ggrepel)
library(shiny) 
library(ggplot2)
library(hrbrthemes)
library(plotly)
library(dplyr)
library(magrittr)
library(shinyauthr)
library(shinydisconnect)
library(shinymanager)
library(RSQLite)


# define some credentials manually
#credentials <- data.frame(
#  user = c("a", "test"), # mandatory
#  password = c("a", "test"), # mandatory
#  start = c("2019-04-15"), # optinal (all others)
#  expire = c(NA, "2022-12-31"),
#  admin = c(TRUE, FALSE),
#  comment = "Test.",
#  stringsAsFactors = FALSE
#)

# Init the database
#create_db(
#  credentials_data = credentials,
#  sqlite_path = "database.sqlite", # will be created
#  passphrase = "_CytoTalk_"
#  #key_get("cytotalk-key", "_CytoTalk_")
#   #passphrase = "passphrase_wihtout_keyring"
#)


conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = "database.sqlite")
credentials = read_db_decrypt(conn = conn, name = "credentials", passphrase = "_CytoTalk_")

# Wrap your UI with secure_app, enabled admin mode or not
ui <- fluidPage(
  
  disconnectMessage(
    text = "Your session has timed out.",
    refresh = "Reload now",
    background = "#646464e6",
    size = 36,
    width = "full",
    top = "center",
    colour = "white",
    overlayColour = "#999",
    overlayOpacity = 0.4,
    refreshColour = "#8dbdd4"
  ),
  
  #actionButton("disconnect", "Disconnect the app"),
  
  tags$a(href="https://cytotalk.com", h2(HTML("<b>CytoTalk LLC</b>"),style="text-align:center")),
  h4(HTML("Demo Visualization App"), 
     style="text-align:center"),

  # logout button
  #div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
  
  # login section
  #shinyauthr::loginUI(id = "login"),
  
  #uiOutput("main_titlePanel"),
  uiOutput("plot_dimensions"),
  uiOutput('app_tabs'),
  #uiOutput('admin_tabs')
  
  #actionButton("close", "Close window")
  
)

# Wrap your UI with secure_app
ui <- secure_app(ui, enable_admin = TRUE)


server <- function(input, output, session) {
  
  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(
    check_credentials = check_credentials(
      "database.sqlite",
      passphrase = "_CytoTalk_"
      #key_get("cytotalk-key", "cytotalk")
      # passphrase = "passphrase_wihtout_keyring"
    )
  )
  
  #Close session upon pressing a button
  #observeEvent(input$disconnect, {
    #session$close()
  #})
  
  #observeEvent(input$close, {
    #session$close()
    #stopApp()
  #})
  
  #Close session after closing the browser
  session$onSessionEnded(function() {
    session$close()
    #stopApp()
  })

  options(shiny.maxRequestSize=3000000*1024^2)
  
  # Source code for functions
  source("Functions/func-scatter.R", local = TRUE)$value
  source("Functions/func-histogram.R", local = TRUE)$value
  source("Functions/func-volcano.R", local = TRUE)$value
  
  # Require login
  #credentials <- shinyauthr::loginServer(
  #  id = "login",
  #  data = user_base,
  #  user_col = user,
  #  pwd_col = password,
  #  sodium_hashed = TRUE,
  #  log_out = reactive(logout_init()),
  #  session$reload()
  #)
  
  # Logout to hide when user is not logged in
  #logout_init <- shinyauthr::logoutServer(
  #  id = "logout",
  #  active = reactive(credentials()$user_auth)
  #)

  #observeEvent(input$logout, {
  #  session$close()
  #})
  
  
  output$main_titlePanel <- renderUI({
    #req(credentials()$user_auth)
    titlePanel("CytoTalk App 1")
  })
  
  output$plot_dimensions <- renderUI({
    
    # Show only when authenticated
    #req(credentials()$user_auth)
    h4("Dimensions of plot to download")
    fluidRow(
      column(1,
             numericInput("fig_width", "Width", value = 2400, min = 100, max = 15000, step = 50)
      ),
      column(1,
             numericInput("fig_height", "Height", value = 1800, min = 100, max = 15000, step = 50)
      ),
      column(1,
             numericInput("fig_res", "Resolution", value = 500, min = 100, max = 1000, step = 50)
      )
    )
  })
  
  output$app_tabs <- renderUI({
    
    # Show only when authenticated
    #req(credentials()$user_auth)
    
    tabsetPanel(
      source("Tabs/tab-upload_file.R", local = TRUE)$value,
      source("Tabs/tab-scatter.R", local = TRUE)$value,
      source("Tabs/tab-histogram.R", local = TRUE)$value,
      source("Tabs/tab-volcano.R", local = TRUE)$value,
      source("Tabs/tab-heatmap.R", local = TRUE)$value
    )
  })
  
  data <- reactive({
    #req(credentials()$user_auth)
    req(input$file1)
    
    inFile <- input$file1
    df <- read.csv(inFile$datapath, header = input$header, sep = input$sep,
                   quote = input$quote)
    
    updateSelectInput(session, inputId = 'xcol', label = 'X Variable',
                      choices = c('None',names(df)), selected = NULL)
    updateSelectInput(session, inputId = 'ycol', label = 'Y Variable',
                      choices = c('None',names(df)), selected = NULL)
    updateSelectInput(session, inputId = 'xcol_hist', label = 'Select a column for the histogram',
                      choices = c('None',names(df)), selected = NULL)
    updateSelectInput(session, inputId = 'color_by', label = 'Select a column for coloration',
                      choices = c('None',names(df)), selected = NULL)
    updateSelectInput(session, inputId = 'volcano_logFC_col', label = 'Select a column x axis (ex. fold change)',
                      choices = c('None',names(df)), selected = NULL)
    updateSelectInput(session, inputId = 'volcano_pval_col', label = 'Select a column for Y axis (ex. log10 P value)',
                      choices = c('None',names(df)), selected = NULL)
    updateSelectInput(session, inputId = 'volcano_row_names', label = 'Select a column for gene names',
                      choices = c('None',names(df)), selected = NULL)
    updateSelectInput(session, inputId = 'scatter_size', label = 'Select a column for size',
                      choices = c('None',names(df)), selected = NULL)
    updateSelectInput(session, inputId = 'scatter_hovercol', label = 'Select a column for labeling points upon hovering',
                      choices = c(names(df)), selected = NULL)
    updateSelectInput(session, inputId = 'volcano_hovercol', label = 'Select a column for labeling points upon hovering',
                      choices = c(names(df)), selected = NULL)
    return(df)
  })
  
  output$contents <- renderTable({
    #req(credentials()$user_auth)
    data()
  })
  
  
  
  output$Scatter <- renderPlotly({
    #req(credentials()$user_auth)
    p = scatter_plot(data())
    ggplotly(p) %>% layout(autosize=TRUE) %>% style(hoverinfo = 'text', hovertext = paste(data()[,input$scatter_hovercol]))
  })

  output$Hist <- renderPlotly({
    #req(credentials()$user_auth)
    p = hist_plot(data())
    ggplotly(p) %>% layout(autosize=TRUE) %>% style(hoverinfo = "none")
  })
  
  output$Volcano <- renderPlotly({
    #req(credentials()$user_auth)
    temp_df = data()
    exp_categories = ifelse((data()[, input$volcano_logFC_col] <= -input$volcano_fc & data()[, input$volcano_pval_col] < input$volcano_pcuttoff), input$volcano_color_down,
                            ifelse((data()[, input$volcano_logFC_col] >= input$volcano_fc & data()[, input$volcano_pval_col] < input$volcano_pcuttoff), input$volcano_color_up, input$volcano_color_not))
    temp_df['new_col'] = exp_categories
    p = volcano_plot(data())
    ggplotly(p) %>% layout(autosize=TRUE) %>% style(hoverinfo = 'text', hovertext = paste(temp_df[,input$volcano_hovercol]))
  })
  
  output$download_hist <- downloadHandler(
    filename =  function() {
      paste("CytoTalk Histogram.png")
    },
    content = function(file)
    {
      png(file, width = input$fig_width, height = input$fig_height, res = input$fig_res)
      p = hist_plot(data())
      print(p)
      dev.off()
    })
  
  output$download_scatter <- downloadHandler(
    filename =  function() {
      paste("CytoTalk Scatter plot.png")
    },
    content = function(file)
    {
      png(file, width = input$fig_width, height = input$fig_height, res = input$fig_res)
      p = scatter_plot(data())
      print(p)
      dev.off()
    })
  
  output$download_volcano <- downloadHandler(
    filename =  function() {
      paste("CytoTalk Volcano plot.png")
    },
    content = function(file)
    {
      png(file, width = input$fig_width, height = input$fig_height, res = input$fig_res)
      p = volcano_plot(data())
      print(p)
      dev.off()    
    })
}



shinyApp(ui, server)