#####################################
### Cargar datos de contaminación ###
#####################################

load("data/serie_mf.RData")

####################################
### Crear datos de interpolación ###
####################################

interpol <- data.frame(
  municipio = c("Cerrillos", "Cerro Navia", "Conchalí", "El Bosque", "Estación Central", "Huechuraba", 
                "Independencia", "La Cisterna", "La Florida", "La Granja", "La Pintana", "La Reina", 
                "Las Condes", "Lo Barnechea", "Lo Espejo", "Lo Prado", "Macul", "Maipú", "Ñuñoa", 
                "Pedro Aguirre Cerda", "Peñalolén", "Providencia", "Pudahuel", "Puente Alto", "Quilicura", 
                "Quinta Normal", "Recoleta", "Renca", "San Joaquín", "San Miguel", "San Ramón", "Santiago", 
                "Vitacura"),
  long = c(-70.70296543799745, -70.72918515988233, -70.67072694243639, -70.66560743797827, 
               -70.68968897667844, -70.63499695788776, -70.65516260918014, -70.66398059565581, 
               -70.58697500365915, -70.63216515763008, -70.6297199027309, -70.53075157149945, 
               -70.59479280366511, -70.51998205948868, -70.69839545763092, -70.71834744001521, 
               -70.5983008008645, -70.75681813799201, -70.59361231715611, -70.66421074784127, 
               -70.54222073249846, -70.60979994599282, -70.74405934784309, -70.57927951344881, 
               -70.7319775190104, -70.70195197667901, -70.64318033485851, -70.70423139754325, 
               -70.64180916920813, -70.64940518793082, -70.64383902634013, -70.6502137459926, 
               -70.60127564599428),
  lat = c(-33.4880371697236, -33.43400728577421, -33.396357425673976, -33.555787714445195, 
              -33.45398550011404, -33.37527659137017, -33.422229485115835, -33.534475258870735, 
              -33.558461737545095, -33.54337634652961, -33.58204453281347, -33.453851685950745, 
              -33.41595503102711, -33.35325729143183, -33.52255435335837, -33.44243338653336, 
              -33.483042200082295, -33.507082541166916, -33.45398324602997, -33.48852423505769, 
              -33.47726524934056, -33.432018778970004, -33.44550873300792, -33.59499013315161, 
              -33.368839890070355, -33.44010955903038, -33.40004756293326, -33.40441272701848, 
              -33.478310908324865, -33.48539726770371, -33.543003929931196, -33.436823898107754, 
              -33.39831027441586)
)

###############################
### Obtener coordenadas UTM ###
###############################

# Convertir puntos del data frame 'df' a objeto espacial
df_sf <- st_as_sf(df, coords = c("long", "lat"), crs = 4326)  # CRS 4326 = WGS84

# Transformar a coordenadas UTM (Zona 19S, CRS 32719)
df_utm <- st_transform(df_sf, crs = 32719)

# Añadir columnas con coordenadas UTM al data frame original
df <- df %>% 
  bind_cols(
    st_coordinates(df_utm) %>%
      as.data.frame() %>%
      rename(utm_x = X, utm_y = Y)
  )

# Convertir 'interpol' a objeto espacial
interpol_sf <- st_as_sf(interpol, coords = c("long", "lat"), crs = 4326)

# Transformar a UTM
interpol_utm <- st_transform(interpol_sf, crs = 32719)

# Añadir columnas con coordenadas UTM
interpol <- interpol %>%
  bind_cols(
    st_coordinates(interpol_utm) %>%
      as.data.frame() %>%
      rename(utm_x = X, utm_y = Y)
  )

#####################
### Guardar datos ###
#####################

save(df, interpol, file = "outputs/kriging_2/pollution_inter.RData")
