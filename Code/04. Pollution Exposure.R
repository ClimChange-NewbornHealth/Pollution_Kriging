####################
### Cargar datos ###
####################

load("outputs/kriging_2/utm_interpol.RData")
load("outputs/kriging_2/longlat_interpol.RData")
births <- import("data/births.RData")

####################################
### Homologación nombres comunas ###
####################################

utm_o3 <- utm_o3 %>%
  mutate(
    municipio = case_when(
      municipio == "Peñalolén" ~ "Penalolen",
      municipio == "Ñuñoa" ~ "Nunoa",
      municipio == "San Joaquín" ~ "San Joaquin",
      municipio == "Maipú" ~ "Maipu",
      municipio == "Conchalí" ~ "Conchali",
      municipio == "San Ramón" ~ "San Ramon",
      municipio == "Estación Central" ~ "Estacion Central",
      TRUE ~ municipio
    )
  )

utm_pm25 <- utm_pm25 %>%
  mutate(
    municipio = case_when(
      municipio == "Peñalolén" ~ "Penalolen",
      municipio == "Ñuñoa" ~ "Nunoa",
      municipio == "San Joaquín" ~ "San Joaquin",
      municipio == "Maipú" ~ "Maipu",
      municipio == "Conchalí" ~ "Conchali",
      municipio == "San Ramón" ~ "San Ramon",
      municipio == "Estación Central" ~ "Estacion Central",
      TRUE ~ municipio
    )
  )

longlat_o3 <- longlat_o3 %>%
  mutate(
    municipio = case_when(
      municipio == "Peñalolén" ~ "Penalolen",
      municipio == "Ñuñoa" ~ "Nunoa",
      municipio == "San Joaquín" ~ "San Joaquin",
      municipio == "Maipú" ~ "Maipu",
      municipio == "Conchalí" ~ "Conchali",
      municipio == "San Ramón" ~ "San Ramon",
      municipio == "Estación Central" ~ "Estacion Central",
      TRUE ~ municipio
    )
  )

longlat_pm25 <- longlat_pm25 %>%
  mutate(
    municipio = case_when(
      municipio == "Peñalolén" ~ "Penalolen",
      municipio == "Ñuñoa" ~ "Nunoa",
      municipio == "San Joaquín" ~ "San Joaquin",
      municipio == "Maipú" ~ "Maipu",
      municipio == "Conchalí" ~ "Conchali",
      municipio == "San Ramón" ~ "San Ramon",
      municipio == "Estación Central" ~ "Estacion Central",
      TRUE ~ municipio
    )
  )

############################################
### Asignar exposición a gestantes (UTM) ###
############################################

pm25 <- utm_pm25
o3 <- utm_o3

# Crear función de cálculo de exposición por ventana 
calculate_exposure <- function(pm25, o3, births) {
  pm25$date <- as.Date(pm25$date)
  o3$date <- as.Date(o3$date)
  births$date_start_week_gest <- as.Date(births$date_start_week_gest)
  births$date_ends_week_gest <- as.Date(births$date_ends_week_gest)
  
  # Crear columnas para exposición de cada ventana
  births$o3_gest <- NA
  births$pm25_gest <- NA
  births$o3_mes <- NA
  births$pm25_mes <- NA
  births$o3_4d <- NA
  births$pm25_4d <- NA
  
  # Iterar por cada fila en births
  for (i in 1:nrow(births)) {
    # Extraer información relevante
    comuna <- births$name_com[i]
    start_date <- births$date_start_week_gest[i]
    end_date <- births$date_ends_week_gest[i]
    
    # Filtrar pm25 y o3 por comuna y rango de fechas
    pm25_comuna <- pm25[pm25$municipio == comuna, ]
    o3_comuna <- o3[o3$municipio == comuna, ]
    
    pm25_gest <- pm25_comuna[pm25_comuna$date >= start_date & pm25_comuna$date <= end_date, "var1.pred"]
    o3_gest <- o3_comuna[o3_comuna$date >= start_date & o3_comuna$date <= end_date, "var1.pred"]
    
    pm25_mes <- pm25_comuna[pm25_comuna$date > (end_date - 30) & pm25_comuna$date <= end_date, "var1.pred"]
    o3_mes <- o3_comuna[o3_comuna$date > (end_date - 30) & o3_comuna$date <= end_date, "var1.pred"]
    
    pm25_4d <- pm25_comuna[pm25_comuna$date > (end_date - 4) & pm25_comuna$date <= end_date, "var1.pred"]
    o3_4d <- o3_comuna[o3_comuna$date > (end_date - 4) & o3_comuna$date <= end_date, "var1.pred"]
    
    # Calcular promedios y asignarlos a la fila correspondiente
    births$o3_gest[i] <- mean(o3_gest, na.rm = TRUE)
    births$pm25_gest[i] <- mean(pm25_gest, na.rm = TRUE)
    
    births$o3_mes[i] <- mean(o3_mes, na.rm = TRUE)
    births$pm25_mes[i] <- mean(pm25_mes, na.rm = TRUE)
    
    births$o3_4d[i] <- mean(o3_4d, na.rm = TRUE)
    births$pm25_4d[i] <- mean(pm25_4d, na.rm = TRUE)
  }
  
  return(births)
}

# Inicializar una lista para almacenar los resultados
expo_list <- list()

# Iterar por cada año desde 2009 hasta 2020
for (year in 2009:2020) {
  # Filtrar nacimientos por año
  births_year <- births %>% filter(year_nac == year)
  
  # Calcular exposición para el año
  expo_year <- calculate_exposure(pm25, o3, births_year)
  
  # Almacenar los resultados en la lista
  expo_list[[as.character(year)]] <- expo_year
}

# Combinar todos los años en un solo dataframe
exposure_utm <- bind_rows(expo_list, .id = "year")

#################################################
### Asignar exposición a gestantes (Long-Lat) ###
#################################################

pm25 <- longlat_pm25
o3 <- longlat_o3

# Crear función de cálculo de exposición por ventana 
calculate_exposure <- function(pm25, o3, births) {
  pm25$date <- as.Date(pm25$date)
  o3$date <- as.Date(o3$date)
  births$date_start_week_gest <- as.Date(births$date_start_week_gest)
  births$date_ends_week_gest <- as.Date(births$date_ends_week_gest)
  
  # Crear columnas para exposición de cada ventana
  births$o3_gest <- NA
  births$pm25_gest <- NA
  births$o3_mes <- NA
  births$pm25_mes <- NA
  births$o3_4d <- NA
  births$pm25_4d <- NA
  
  # Iterar por cada fila en births
  for (i in 1:nrow(births)) {
    # Extraer información relevante
    comuna <- births$name_com[i]
    start_date <- births$date_start_week_gest[i]
    end_date <- births$date_ends_week_gest[i]
    
    # Filtrar pm25 y o3 por comuna y rango de fechas
    pm25_comuna <- pm25[pm25$municipio == comuna, ]
    o3_comuna <- o3[o3$municipio == comuna, ]
    
    pm25_gest <- pm25_comuna[pm25_comuna$date >= start_date & pm25_comuna$date <= end_date, "var1.pred"]
    o3_gest <- o3_comuna[o3_comuna$date >= start_date & o3_comuna$date <= end_date, "var1.pred"]
    
    pm25_mes <- pm25_comuna[pm25_comuna$date > (end_date - 30) & pm25_comuna$date <= end_date, "var1.pred"]
    o3_mes <- o3_comuna[o3_comuna$date > (end_date - 30) & o3_comuna$date <= end_date, "var1.pred"]
    
    pm25_4d <- pm25_comuna[pm25_comuna$date > (end_date - 4) & pm25_comuna$date <= end_date, "var1.pred"]
    o3_4d <- o3_comuna[o3_comuna$date > (end_date - 4) & o3_comuna$date <= end_date, "var1.pred"]
    
    # Calcular promedios y asignarlos a la fila correspondiente
    births$o3_gest[i] <- mean(o3_gest, na.rm = TRUE)
    births$pm25_gest[i] <- mean(pm25_gest, na.rm = TRUE)
    
    births$o3_mes[i] <- mean(o3_mes, na.rm = TRUE)
    births$pm25_mes[i] <- mean(pm25_mes, na.rm = TRUE)
    
    births$o3_4d[i] <- mean(o3_4d, na.rm = TRUE)
    births$pm25_4d[i] <- mean(pm25_4d, na.rm = TRUE)
  }
  
  return(births)
}

# Inicializar una lista para almacenar los resultados
expo_list <- list()

# Iterar por cada año desde 2009 hasta 2020
for (year in 2009:2020) {
  # Filtrar nacimientos por año
  births_year <- births %>% filter(year_nac == year)
  
  # Calcular exposición para el año
  expo_year <- calculate_exposure(pm25, o3, births_year)
  
  # Almacenar los resultados en la lista
  expo_list[[as.character(year)]] <- expo_year
}

# Combinar todos los años en un solo dataframe
exposure_longlat  <- bind_rows(expo_list, .id = "year")

##########################
### Guardar resultados ###
##########################

write.csv(exposure_utm, "outputs/kriging_2/utm_exposure.csv", row.names = FALSE)
write.csv(exposure_longlat, "outputs/kriging_2/longlat_exposure.csv", row.names = FALSE)
save(exposure_utm, exposure_longlat, file = "outputs/kriging_2/exposure.RData")
