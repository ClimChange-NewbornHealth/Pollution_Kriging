# Filter and prepare data

ejemplo <- combined_data %>%
  filter(fecha == as.Date("2010-06-10")) %>%  # Filter data for the specified date
  filter(!is.na(o3) & !is.na(pm25))          # Remove rows with missing values for o3 and pm25

coordinates(ejemplo) <- ~longitud + latitud  # Assign spatial coordinates to the dataset
coordinates(interpol) <- ~longitud + latitud # Assign spatial coordinates to the interpolation points

# Calculate and fit variograms

variogram_o3 <- autofitVariogram(o3 ~ 1, ejemplo, verbose = TRUE) # Fit variogram for o3 (the verbose argument displays the entire model fitting procedure)
plot(variogram_o3)                                               # Plot the variogram for o3

variogram_pm25 <- autofitVariogram(pm25 ~ 1, ejemplo, verbose = TRUE) # Fit variogram for pm25 (the verbose argument displays the entire model fitting procedure)
plot(variogram_pm25)                                                 # Plot the variogram for pm25

# Point interpolation for pollutants

krige_o3 <- krige(
  formula = o3 ~ 1,
  locations = ejemplo,
  newdata = interpol,
  model = variogram_o3$var_model  # Use the fitted variogram model for o3
)

krige_pm25 <- krige(
  formula = pm25 ~ 1,
  locations = ejemplo,
  newdata = interpol,
  model = variogram_pm25$var_model  # Use the fitted variogram model for pm25
)

# Convert to data.frame

krige_pm25_df <- as.data.frame(krige_pm25)  
krige_o3_df <- as.data.frame(krige_o3)
interpol_df <- as.data.frame(interpol)      

# Perform join

krige_o3 <- krige_o3_df %>%
  left_join(interpol_df, by = c("longitud", "latitud")) # Join kriging results with interpolation points
krige_o3$fecha <- ejemplo$fecha                        # Add the date to the kriging results for o3

krige_pm25 <- krige_pm25_df %>%
  left_join(interpol_df, by = c("longitud", "latitud")) # Join kriging results with interpolation points
krige_pm25$fecha <- ejemplo$fecha                      # Add the date to the kriging results for pm25
