eval_function_with_limits <- function(Cement, Ash, Coarse_Aggregate, Fine_Aggregate, Slag, Superplasticizer, min_limits_GA, max_limits_GA) {
  
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
    Age = 28
  )
  
  # predict(model_strength, newdata = input_data)[[1]]
  
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
    
    -1 * if_else(Cement < min_limits_GA$Cement | Cement > max_limits_GA$Cement, 100, 1) *
      if_else(Ash < min_limits_GA$Ash | Ash > max_limits_GA$Ash, 100, 1) *
      if_else(Coarse_Aggregate < min_limits_GA$Coarse_Aggregate | Coarse_Aggregate > max_limits_GA$Coarse_Aggregate, 100, 1) *
      if_else(Fine_Aggregate < min_limits_GA$Fine_Aggregate | Fine_Aggregate > max_limits_GA$Fine_Aggregate, 100, 1) *
      if_else(Slag < min_limits_GA$Slag | Slag > max_limits_GA$Slag, 100, 1) *
      if_else(Superplasticizer < min_limits_GA$Superplasticizer | Superplasticizer > max_limits_GA$Superplasticizer, 100, 1) *
      if_else(Water < min_limits_GA$Water | Water > max_limits_GA$Water, 100, 1)
  }
  
}