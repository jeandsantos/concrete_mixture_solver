GA_summary_plot <- function(GA_output, ...) {
  
  GA_output@summary %>% 
    .[,c("max", "mean", "median")] %>% 
    data.frame() %>% 
    select(Best = max, Mean = mean, Median = median) %>% 
    mutate(Iteration = 1:GA_output@iter) %>% 
    gather(key = "Parameter", value = "Value", -Iteration) %>% 
    ggplot(mapping = aes(x = Iteration, y = Value, col = Parameter)) +
      geom_line(size = 0.5, alpha = 0.7) +
      theme_bw() + 
      # theme(aspect.ratio = 0.7) +
      scale_x_continuous(limits = c(1, GA_output@iter), breaks = scales::pretty_breaks(10), expand = c(0.01, 0.01)) +
      scale_color_brewer(type = "qual", palette = "Set1") +
      labs(x = "Generation", y = "Fitness Value", 
           title = "Fitness value at each generation" #, 
           # subtitle = "Results using Genetic Algorithm"
      )
  }