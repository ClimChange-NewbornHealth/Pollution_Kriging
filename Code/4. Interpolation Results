# Load interpolation data

pm25 <- import("interpolacion_pm25.csv")
o3 <- import("interpolacion_o3.csv")

# Standardize municipality names for merging datasets

o3 <- o3 %>%
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

pm25 <- pm25 %>%
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
