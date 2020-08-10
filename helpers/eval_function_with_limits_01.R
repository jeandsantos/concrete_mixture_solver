eval_function_with_limits <- function(Cement, Ash, Coarse_Aggregate, Fine_Aggregate, Slag, Superplasticizer, min_limits_GA, max_limits_GA, Age = 28) {
  
  Water = 1 - sum(Cement, Ash, Coarse_Aggregate, Fine_Aggregate, Slag, Superplasticizer)
  
  # Create dataframe with predictors
  input_data <- tibble(
    Cement = Cement,
    Ash = Ash,
    Coarse_Aggregate = Coarse_Aggregate,
    Fine_Aggregate = Fine_Aggregate,
    Slag = Slag,
    Superplasticizer = Superplasticizer,
    Water = Water,
    Age = Age
  )
  
  # Create penalty score for solutions with parameters outside of range
  if (Cement >= min_limits_GA$Cement & Cement <= max_limits_GA$Cement &
      Ash >= min_limits_GA$Ash & Ash <= max_limits_GA$Ash &
      Coarse_Aggregate >= min_limits_GA$Coarse_Aggregate & Coarse_Aggregate <= max_limits_GA$Coarse_Aggregate &
      Fine_Aggregate >= min_limits_GA$Fine_Aggregate & Fine_Aggregate <= max_limits_GA$Fine_Aggregate &
      Slag >= min_limits_GA$Slag & Slag <= max_limits_GA$Slag &
      Superplasticizer >= min_limits_GA$Superplasticizer & Superplasticizer <= max_limits_GA$Superplasticizer &
      Water >= min_limits_GA$Water & Water <= max_limits_GA$Water) {
    
    predict(model_strength, newdata = input_data)[[1]]
    
  } else {
    
      -1 * if_else(Cement < min_limits_GA$Cement | Cement > max_limits_GA$Cement, 
                100*abs(Cement - mean(c(max_limits_GA$Cement, min_limits_GA$Cement))), 1) *
      if_else(Ash < min_limits_GA$Ash | Ash > max_limits_GA$Ash, 
              100*abs(Ash - mean(c(max_limits_GA$Ash, min_limits_GA$Ash))), 1) *
      if_else(Coarse_Aggregate < min_limits_GA$Coarse_Aggregate | Coarse_Aggregate > max_limits_GA$Coarse_Aggregate, 
              100*abs(Coarse_Aggregate - mean(c(max_limits_GA$Coarse_Aggregate, min_limits_GA$Coarse_Aggregate))), 1) *
      if_else(Fine_Aggregate < min_limits_GA$Fine_Aggregate | Fine_Aggregate > max_limits_GA$Fine_Aggregate, 
              100*abs(Fine_Aggregate - mean(c(max_limits_GA$Fine_Aggregate, min_limits_GA$Fine_Aggregate))), 1) *
      if_else(Slag < min_limits_GA$Slag | Slag > max_limits_GA$Slag, 
              100*abs(Slag - mean(c(max_limits_GA$Slag, min_limits_GA$Slag))), 1) *
      if_else(Superplasticizer < min_limits_GA$Superplasticizer | Superplasticizer > max_limits_GA$Superplasticizer, 
              100*abs(Superplasticizer - mean(c(max_limits_GA$Superplasticizer, min_limits_GA$Superplasticizer))), 1) *
      if_else(Water < min_limits_GA$Water | Water > max_limits_GA$Water, 
              100*abs(Water - mean(c(max_limits_GA$Water, min_limits_GA$Water))), 1)
    }
  
}