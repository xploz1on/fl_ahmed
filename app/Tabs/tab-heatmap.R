tabPanel("Heat Map",
         pageWithSidebar(
           headerPanel('Under development...'),
           sidebarPanel(
             
             # "Empty inputs" - they will be updated after the data is uploaded
             #selectInput('xcol_hist', 'X Variable', ""),
             
           ),
           mainPanel(
             plotlyOutput('Heatmap')
           )
         )
)