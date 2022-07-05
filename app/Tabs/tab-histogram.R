tabPanel("Histogram",
         pageWithSidebar(
           headerPanel('Choose a column to plot'),
           sidebarPanel(
             
             # "Empty inputs" - they will be updated after the data is uploaded
             selectInput('xcol_hist', 'X Variable', ""),
             textInput('hist_fill_color', 'Fill color', value = "#69b3a2", width = NULL, placeholder = NULL),
             textInput('hist_border_color', 'Border color', value = "#e9ecef", width = NULL, placeholder = NULL),
             sliderInput("hist_binwidth", "Bin width",
                         min = 0.1, max = 30,
                         value = 0.5, step = 0.1),
             sliderInput("hist_alpha", "Opacity",
                         min = 0, max = 1,
                         value = 0.8, step = 0.01)
           ),
           mainPanel(
             plotlyOutput('Hist'),
             downloadButton(outputId = "download_hist", label = "Download the plot"),
             h5("Select figure dimensions and resolution from the boxes above.")
           )
         )
)