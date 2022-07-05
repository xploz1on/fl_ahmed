tabPanel("Scatter/ Dot Plot",
         pageWithSidebar(
           headerPanel('Choose 2 columns to plot'),
           sidebarPanel(
             #Input buttons here
           ),
           mainPanel(
             plotlyOutput('Scatter')
           )
         )
)