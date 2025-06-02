####################
### Cargar datos ###
####################

load("outputs/kriging_2/pollution_inter.RData")

############################################
### Ajuste kriging e interpolación (UTM) ###
############################################

# Aseguramos que 'fecha' está en formato Date
df$date <- as.Date(df$date)

# Obtener fechas únicas
fechas_unicas <- unique(df$date)

# Crear listas vacías para resultados
resultados_o3 <- list()
resultados_pm25 <- list()

# Convertir la base de interpolación a SpatialPointsDataFrame con coordenadas UTM
coordinates(interpol) <- ~utm_x + utm_y
proj4string(interpol) <- CRS("+proj=utm +zone=19 +south +datum=WGS84 +units=m +no_defs")

for (fecha_actual in fechas_unicas) {
  
  # Filtrar datos para la fecha actual y sin NA en o3 y pm25
  ejemplo <- df %>%
    filter(date == fecha_actual) %>%
    filter(!is.na(daily_o3) & !is.na(daily_pm25))
  
  # Convertir ejemplo a SpatialPointsDataFrame con UTM
  coordinates(ejemplo) <- ~utm_x + utm_y
  proj4string(ejemplo) <- CRS("+proj=utm +zone=19 +south +datum=WGS84 +units=m +no_defs")
  
  # Ajustar variogramas con automap
  variogram_o3 <- autofitVariogram(daily_o3 ~ 1, ejemplo, verbose = FALSE)
  variogram_pm25 <- autofitVariogram(daily_pm25 ~ 1, ejemplo, verbose = FALSE)
  
  # Kriging para O3
  krige_o3 <- krige(
    formula = daily_o3 ~ 1,
    locations = ejemplo,
    newdata = interpol,
    model = variogram_o3$var_model
  )
  
  # Kriging para PM2.5
  krige_pm25 <- krige(
    formula = daily_pm25 ~ 1,
    locations = ejemplo,
    newdata = interpol,
    model = variogram_pm25$var_model
  )
  
  # Convertir resultados a data.frame
  krige_o3_df <- as.data.frame(krige_o3)
  krige_pm25_df <- as.data.frame(krige_pm25)
  
  # Convertir interpol a data.frame para hacer join
  interpol_df <- as.data.frame(interpol)
  
  # Agregar fecha y unir con municipio (si tienes esa columna en interpol_df)
  krige_o3_df <- krige_o3_df %>%
    left_join(interpol_df %>% select(utm_x, utm_y, municipio), by = c("utm_x", "utm_y")) %>%
    mutate(date = fecha_actual)
  
  krige_pm25_df <- krige_pm25_df %>%
    left_join(interpol_df %>% select(utm_x, utm_y, municipio), by = c("utm_x", "utm_y")) %>%
    mutate(date = fecha_actual)
  
  # Guardar resultados en listas
  resultados_o3[[as.character(fecha_actual)]] <- krige_o3_df
  resultados_pm25[[as.character(fecha_actual)]] <- krige_pm25_df
}

# Combinar resultados en un solo data.frame
final_o3 <- bind_rows(resultados_o3)
final_pm25 <- bind_rows(resultados_pm25)

# Convertir fecha a Date
final_o3$date <- as.Date(final_o3$date)
final_pm25$date <- as.Date(final_pm25$date)

# Cambiar nombre
utm_o3 <- final_o3
utm_pm25 <- final_pm25

# Guardar resultados
write.csv(utm_o3, "outputs/kriging_2/utm_interpol_o3.csv", row.names = FALSE)
write.csv(utm_pm25, "outputs/kriging_2/utm_interpol_pm25.csv", row.names = FALSE)
save(utm_o3, utm_pm25, file = "outputs/kriging_2/utm_interpol.RData")

#################################################
### Ajuste kriging e interpolación (Long-Lat) ###
#################################################

# Asegurar formato de fecha
df$date <- as.Date(df$date)

# Fechas únicas
fechas_unicas <- unique(df$date)

# Crear listas vacías
resultados_o3 <- list()
resultados_pm25 <- list()

# Convertir interpol a SpatialPointsDataFrame (coordenadas geográficas)
coordinates(interpol) <- ~long + lat
proj4string(interpol) <- CRS("+proj=longlat +datum=WGS84 +no_defs")

for (fecha_actual in fechas_unicas) {
  
  # Filtrar datos sin NA
  ejemplo <- df %>%
    filter(date == fecha_actual) %>%
    filter(!is.na(daily_o3) & !is.na(daily_pm25))
  
  # Convertir a SpatialPointsDataFrame
  coordinates(ejemplo) <- ~long + lat
  proj4string(ejemplo) <- CRS("+proj=longlat +datum=WGS84 +no_defs")
  
  # Ajustar variogramas
  variogram_o3 <- autofitVariogram(daily_o3 ~ 1, ejemplo, verbose = FALSE)
  variogram_pm25 <- autofitVariogram(daily_pm25 ~ 1, ejemplo, verbose = FALSE)
  
  # Kriging para O3
  krige_o3 <- krige(
    formula = daily_o3 ~ 1,
    locations = ejemplo,
    newdata = interpol,
    model = variogram_o3$var_model
  )
  
  # Kriging para PM2.5
  krige_pm25 <- krige(
    formula = daily_pm25 ~ 1,
    locations = ejemplo,
    newdata = interpol,
    model = variogram_pm25$var_model
  )
  
  # Convertir resultados a data.frame
  krige_o3_df <- as.data.frame(krige_o3)
  krige_pm25_df <- as.data.frame(krige_pm25)
  
  # Convertir interpol a data.frame para unir
  interpol_df <- as.data.frame(interpol)
  
  # Unir con info adicional
  krige_o3_df <- krige_o3_df %>%
    left_join(interpol_df %>% select(long, lat, municipio), by = c("long", "lat")) %>%
    mutate(date = fecha_actual)
  
  krige_pm25_df <- krige_pm25_df %>%
    left_join(interpol_df %>% select(long, lat, municipio), by = c("long", "lat")) %>%
    mutate(date = fecha_actual)
  
  # Guardar en listas
  resultados_o3[[as.character(fecha_actual)]] <- krige_o3_df
  resultados_pm25[[as.character(fecha_actual)]] <- krige_pm25_df
}

# Combinar resultados
final_o3 <- bind_rows(resultados_o3)
final_pm25 <- bind_rows(resultados_pm25)

# Convertir fecha a Date
final_o3$date <- as.Date(final_o3$date)
final_pm25$date <- as.Date(final_pm25$date)

# Cambiar nombre
longlat_o3 <- final_o3
longlat_pm25 <- final_pm25

# Guardar resultados
write.csv(longlat_o3, "outputs/kriging_2/longlat_interpol_o3.csv", row.names = FALSE)
write.csv(longlat_pm25, "outputs/kriging_2/longlat_interpol_pm25.csv", row.names = FALSE)
save(longlat_o3, longlat_pm25, file = "outputs/kriging_2/longlat_interpol.RData")
