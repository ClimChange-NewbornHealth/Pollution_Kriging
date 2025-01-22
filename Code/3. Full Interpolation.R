# Get the unique measurement dates

fechas_unicas <- unique(combined_data$fecha)

# Create empty lists to store interpolation results

resultados_o3 <- list()
resultados_pm25 <- list()

# Iterate through each unique date

for (fecha_actual in fechas_unicas) {
  
  # Filter data for the current date and remove NA values
  
  ejemplo <- combined_data %>%
    filter(fecha == fecha_actual) %>%
    filter(!is.na(o3) & !is.na(pm25))
  
  # Ensure the "ejemplo" object has spatial coordinates
  
  coordinates(ejemplo) <- ~longitud + latitud
  
  # Calculate and fit variograms using automap
  
  variogram_o3 <- autofitVariogram(o3 ~ 1, ejemplo, verbose = FALSE)  # Fit variogram for o3
  variogram_pm25 <- autofitVariogram(pm25 ~ 1, ejemplo, verbose = FALSE)  # Fit variogram for pm25
  
  # Interpolation for o3
  
  krige_o3 <- krige(
    formula = o3 ~ 1,
    locations = ejemplo,
    newdata = interpol,
    model = variogram_o3$var_model  # Use the fitted variogram model for o3
  )
  
  # Interpolation for pm25
  
  krige_pm25 <- krige(
    formula = pm25 ~ 1,
    locations = ejemplo,
    newdata = interpol,
    model = variogram_pm25$var_model  # Use the fitted variogram model for pm25
  )
  
  # Convert results to data.frames
  
  krige_o3_df <- as.data.frame(krige_o3)
  krige_pm25_df <- as.data.frame(krige_pm25)
  interpol_df <- as.data.frame(interpol)
  
  # Add the date column and perform a join with interpolation points
  
  krige_o3 <- krige_o3_df %>%
    left_join(interpol_df, by = c("longitud", "latitud"))
  krige_o3$fecha <- fecha_actual
  
  krige_pm25 <- krige_pm25_df %>%
    left_join(interpol_df, by = c("longitud", "latitud"))
  krige_pm25$fecha <- fecha_actual
  
  # Add the results to the lists
  
  resultados_o3[[as.character(fecha_actual)]] <- krige_o3
  resultados_pm25[[as.character(fecha_actual)]] <- krige_pm25
}

# Combine the results into final tables

final_o3 <- bind_rows(resultados_o3) 
final_pm25 <- bind_rows(resultados_pm25)

# Change the date format

final_o3$fecha <- as.Date(final_o3$fecha, origin = "1970-01-01")
final_pm25$fecha <- as.Date(final_pm25$fecha, origin = "1970-01-01")

# Save the interpolation results

write.csv(final_o3, "interpolacion_o3.csv", row.names = FALSE)
write.csv(final_pm25, "interpolacion_pm25.csv", row.names = FALSE)
