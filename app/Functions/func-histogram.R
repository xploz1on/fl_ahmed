hist_plot <- function(input_table)
{
  #req(credentials()$user_auth)
  ggplot(input_table, aes(x=input_table[, input$xcol_hist])) + 
    geom_histogram(binwidth=input$hist_binwidth, fill=input$hist_fill_color, color=input$hist_border_color, alpha=input$hist_alpha)+
    theme_ipsum() +
    labs(x=input$xcol_hist)+
    theme(
      plot.title = element_text(size=12)
    )
}