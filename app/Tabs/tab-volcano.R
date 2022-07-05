tabPanel("Volcano Plot",
         pageWithSidebar(
           headerPanel(''),
           sidebarPanel(
             #Inputs buttons here
           ),
           mainPanel(
             plotlyOutput('Volcano')
           )
         )
)