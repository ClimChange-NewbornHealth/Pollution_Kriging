# Create function to calculate exposure for each window

calculate_exposure <- function(pm25, o3, births) {
  
  # Convert dates to Date objects
  
  pm25$fecha <- as.Date(pm25$fecha)
  o3$fecha <- as.Date(o3$fecha)
  births$date_start_week_gest <- as.Date(births$date_start_week_gest)
  births$date_ends_week_gest <- as.Date(births$date_ends_week_gest)
  
  # Create columns for exposure in each window
  
  births$o3_gest <- NA
  births$pm25_gest <- NA
  births$o3_mes <- NA
  births$pm25_mes <- NA
  births$o3_4d <- NA
  births$pm25_4d <- NA
  
  # Iterate through each row in the birth data
  
  for (i in 1:nrow(births)) {
    # Extract relevant information
    comuna <- births$name_com[i]
    start_date <- births$date_start_week_gest[i]
    end_date <- births$date_ends_week_gest[i]
    
    # Filter pm25 and o3 data by comuna and date range
    
    pm25_comuna <- pm25[pm25$municipio == comuna, ]
    o3_comuna <- o3[o3$municipio == comuna, ]
    
    # Get pm25 and o3 exposure for each window (gestation, month, 4 days)
    
    pm25_gest <- pm25_comuna[pm25_comuna$fecha >= start_date & pm25_comuna$fecha <= end_date, "var1.pred"]
    o3_gest <- o3_comuna[o3_comuna$fecha >= start_date & o3_comuna$fecha <= end_date, "var1.pred"]
    
    pm25_mes <- pm25_comuna[pm25_comuna$fecha > (end_date - 30) & pm25_comuna$fecha <= end_date, "var1.pred"]
    o3_mes <- o3_comuna[o3_comuna$fecha > (end_date - 30) & o3_comuna$fecha <= end_date, "var1.pred"]
    
    pm25_4d <- pm25_comuna[pm25_comuna$fecha > (end_date - 4) & pm25_comuna$fecha <= end_date, "var1.pred"]
    o3_4d <- o3_comuna[o3_comuna$fecha > (end_date - 4) & o3_comuna$fecha <= end_date, "var1.pred"]
    
    # Calculate averages and assign to the corresponding row
    
    births$o3_gest[i] <- mean(o3_gest, na.rm = TRUE)
    births$pm25_gest[i] <- mean(pm25_gest, na.rm = TRUE)
    
    births$o3_mes[i] <- mean(o3_mes, na.rm = TRUE)
    births$pm25_mes[i] <- mean(pm25_mes, na.rm = TRUE)
    
    births$o3_4d[i] <- mean(o3_4d, na.rm = TRUE)
    births$pm25_4d[i] <- mean(pm25_4d, na.rm = TRUE)
  }
  
  return(births)
}

# Initialize a list to store results

expo_list <- list()

# Iterate over each year from 2009 to 2020

for (year in 2009:2020) {

  # Filter births by year
  
  births_year <- births %>% filter(year_nac == year)
  
  # Calculate exposure for the year
  
  expo_year <- calculate_exposure(pm25, o3, births_year)
  
  # Store the results in the list
  
  expo_list[[as.character(year)]] <- expo_year
}

# Combine all years into a single dataframe

expo_combined <- bind_rows(expo_list, .id = "year")

# Save the results to a CSV file

write.csv(expo_combined, "exposure.csv")
