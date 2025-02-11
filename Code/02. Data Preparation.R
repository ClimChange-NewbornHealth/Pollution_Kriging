# Create the combined_data object from the data in "pollution.csv".

combined_data <- import("pollution.csv")

# Generate a data frame with the coordinates of the points you wish to interpolate, including a label to identify each point. Optionally, you can perform interpolation on a grid.

interpol <- data.frame(
  municipio = c("Cerrillos", "Cerro Navia", "Conchalí", "El Bosque", "Estación Central", "Huechuraba", 
                "Independencia", "La Cisterna", "La Florida", "La Granja", "La Pintana", "La Reina", 
                "Las Condes", "Lo Barnechea", "Lo Espejo", "Lo Prado", "Macul", "Maipú", "Ñuñoa", 
                "Pedro Aguirre Cerda", "Peñalolén", "Providencia", "Pudahuel", "Puente Alto", "Quilicura", 
                "Quinta Normal", "Recoleta", "Renca", "San Joaquín", "San Miguel", "San Ramón", "Santiago", 
                "Vitacura"),
  longitud = c(-70.70296543799745, -70.72918515988233, -70.67072694243639, -70.66560743797827, 
               -70.68968897667844, -70.63499695788776, -70.65516260918014, -70.66398059565581, 
               -70.58697500365915, -70.63216515763008, -70.6297199027309, -70.53075157149945, 
               -70.59479280366511, -70.51998205948868, -70.69839545763092, -70.71834744001521, 
               -70.5983008008645, -70.75681813799201, -70.59361231715611, -70.66421074784127, 
               -70.54222073249846, -70.60979994599282, -70.74405934784309, -70.57927951344881, 
               -70.7319775190104, -70.70195197667901, -70.64318033485851, -70.70423139754325, 
               -70.64180916920813, -70.64940518793082, -70.64383902634013, -70.6502137459926, 
               -70.60127564599428),
  latitud = c(-33.4880371697236, -33.43400728577421, -33.396357425673976, -33.555787714445195, 
              -33.45398550011404, -33.37527659137017, -33.422229485115835, -33.534475258870735, 
              -33.558461737545095, -33.54337634652961, -33.58204453281347, -33.453851685950745, 
              -33.41595503102711, -33.35325729143183, -33.52255435335837, -33.44243338653336, 
              -33.483042200082295, -33.507082541166916, -33.45398324602997, -33.48852423505769, 
              -33.47726524934056, -33.432018778970004, -33.44550873300792, -33.59499013315161, 
              -33.368839890070355, -33.44010955903038, -33.40004756293326, -33.40441272701848, 
              -33.478310908324865, -33.48539726770371, -33.543003929931196, -33.436823898107754, 
              -33.39831027441586)
)

# Import georeferenced dataset

comunas <- st_read("comunas.shp")

# Clean variable names

comunas <- clean_names(comunas)

# Standardize municipality names

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

# Select the Santiago metropolitan area

comunas_santiago <- comunas %>% 
  filter(provincia == "Santiago" | comuna == "Puente Alto")

# Process coordinates
comunas_santiago <- st_transform(comunas_santiago, crs = 4326)

# Import birth dataset

births <- import("datos/births.RData")
