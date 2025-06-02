####################
### Cargar datos ###
####################

load("outputs/kriging_2/longlat_interpol.RData")
load("outputs/kriging_2/utm_interpol.RData")

##########################
### Homologar comunas ####
##########################

homologar_municipios <- function(df, municipio_col = "municipio") {
  df %>%
    mutate(
      {{ municipio_col }} := case_when(
        !!sym(municipio_col) == "Peñalolén" ~ "Penalolen",
        !!sym(municipio_col) == "Ñuñoa" ~ "Nunoa",
        !!sym(municipio_col) == "San Joaquín" ~ "San Joaquin",
        !!sym(municipio_col) == "Maipú" ~ "Maipu",
        !!sym(municipio_col) == "Conchalí" ~ "Conchali",
        !!sym(municipio_col) == "San Ramón" ~ "San Ramon",
        !!sym(municipio_col) == "Estación Central" ~ "Estacion Central",
        TRUE ~ !!sym(municipio_col)
      )
    )
}

longlat_o3   <- homologar_municipios(longlat_o3)
longlat_pm25 <- homologar_municipios(longlat_pm25)
utm_o3       <- homologar_municipios(utm_o3)
utm_pm25     <- homologar_municipios(utm_pm25)

#########################
### Preparar comunas ####
#########################

# Importar base georreferenciada
comunas <- st_read("data/comunas/comunas.shp")

# Limpiar nombres de variables
comunas <- clean_names(comunas)

# Homologar nombres de comunas
comunas <- comunas %>%
  mutate(
    comuna = case_when(
      comuna == "Peñalolén" ~ "Penalolen",
      comuna == "Ñuñoa" ~ "Nunoa",
      comuna == "San Joaquín" ~ "San Joaquin",
      comuna == "Maipú" ~ "Maipu",
      comuna == "Conchalí" ~ "Conchali",
      comuna == "San Ramón" ~ "San Ramon",
      comuna == "Estación Central" ~ "Estacion Central",
      TRUE ~ comuna
    )
  )

# Seleccionar conurbación de Santiago
comunas_santiago <- comunas %>% 
  filter(provincia == "Santiago" | comuna == "Puente Alto")

# Procesar coordenadas
comunas_santiago <- st_transform(comunas_santiago, crs = 4326)

######################
### Verificar CRS ####
######################

# Transformar todos los objetos al CRS de comunas_santiago
longlat_o3 <- st_as_sf(longlat_o3, coords = c("long", "lat"), crs = 4326)
longlat_o3 <- st_transform(longlat_o3, st_crs(comunas_santiago))
longlat_pm25 <- st_as_sf(longlat_pm25, coords = c("long", "lat"), crs = 4326)
longlat_pm25 <- st_transform(longlat_pm25, st_crs(comunas_santiago))
utm_o3 <- st_as_sf(utm_o3, coords = c("utm_x", "utm_y"), crs = 32719) 
utm_o3 <- st_transform(utm_o3, st_crs(comunas_santiago))
utm_pm25 <- st_as_sf(utm_pm25, coords = c("utm_x", "utm_y"), crs = 32719)
utm_pm25 <- st_transform(utm_pm25, st_crs(comunas_santiago))

# Corroborar CRS
st_crs(comunas_santiago)
st_crs(longlat_o3)
st_crs(longlat_pm25)
st_crs(utm_o3)
st_crs(utm_pm25)

#####################################
### Función para generar figuras ####
#####################################

graficar_interpolacion <- function(data, 
                                   contaminante = "PM25", 
                                   fecha = "2015-12-20", 
                                   comunas = comunas_santiago,
                                   color_scale = "viridis") {
  
  # Elimina geometría si es un objeto sf
  if (inherits(data, "sf")) {
    data <- data %>% st_drop_geometry()
  }
  
  # Filtra datos por fecha y selecciona columnas necesarias
  data_filtered <- data %>%
    filter(date == fecha) %>%
    select(municipio, var1.pred)
  
  # Join con geometría de comunas
  data_comunas <- comunas %>%
    left_join(data_filtered, by = c("comuna" = "municipio"))
  
  # Títulos según contaminante
  if (toupper(contaminante) == "PM25") {
    title <- expression("Atmospheric Concentration of PM"[2.5]*"")
    legend_name <- expression("PM"[2.5]*" concentration (µg/m³)")
  } else if (toupper(contaminante) == "O3") {
    title <- expression("Atmospheric Concentration of O"[3]*"")
    legend_name <- expression("O"[3]*" concentration (µg/m³)")
  } else {
    stop("Contaminante no reconocido. Usa 'PM25' o 'O3'.")
  }
  
  # Escalas de color personalizadas con scale_fill_gradientn()
  color_scale_used <- switch(
    tolower(color_scale),
    viridis = scale_fill_gradientn(name = legend_name, colors = viridisLite::viridis(9)),
    blues   = scale_fill_gradientn(name = legend_name, colors = RColorBrewer::brewer.pal(9, "Blues")),
    reds    = scale_fill_gradientn(name = legend_name, colors = RColorBrewer::brewer.pal(9, "Reds")),
    stop("color_scale no reconocido. Usa 'viridis', 'blues' o 'reds'.")
  )
  
  # Generación del gráfico
  plot <- ggplot() +
    geom_sf(data = data_comunas, aes(fill = var1.pred), color = "black") +
    color_scale_used +
    ggtitle(title) +
    labs(subtitle = fecha) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      legend.title = element_text(size = 9),
      legend.text = element_text(size = 7)
    )
  
  return(plot)
}

#########################
### Utilizar función ####
#########################

# Crear gráfico 1
g1 <- graficar_interpolacion(utm_pm25, # Seleccionar base
                             contaminante = "PM25", # Seleccionar contaminante
                             fecha = "2012-01-06", # Seleccionar fecha
                             color_scale = "reds") # Seleccionar escala (reds, blues, viridis)


# Crear gráfico 2
g2 <- graficar_interpolacion(utm_o3,
                             contaminante = "O3",
                             fecha = "2012-01-06",
                             color_scale = "reds")

# Mostrar los dos gráficos
grid.arrange(g1, g2, ncol = 2)

# Guardar figura
muestra <- grid.arrange(g1, g2, ncol = 2)
ggsave("outputs/kriging_2/figures/figure2.jpg", 
       plot = muestra, dpi = 800, width = 12, height = 6)
