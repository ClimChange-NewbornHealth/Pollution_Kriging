# Filter the pm25 dataset for one specific date

pm25_filtrado <- pm25 %>%
  filter(fecha == "2015-12-20")

# Select the column with pm25 predictions

pm25_filtrado_pred <- pm25_filtrado %>%
  select(municipio, var1.pred)

# Join the pm25_filtrado_pred dataset with comunas_santiago

pm25_comunas <- comunas_santiago %>%
  left_join(pm25_filtrado_pred, by = c("comuna" = "municipio"))

# Create the interpolated map for pm25

g_pm <- ggplot() +
  geom_sf(data = pm25_comunas, aes(fill = var1.pred), color = "black") +
  scale_fill_viridis_c(name = expression("PM"[2.5] * " Concentration (µg/m³)")) +
  ggtitle(expression("Community-Level PM"[2.5])) +
  labs(subtitle = "2015-12-20") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Filter the o3 dataset for one specific date

o3_filtrado <- o3 %>%
  filter(fecha == "2015-12-20")

# Select only the column with o3 predictions

o3_filtrado_pred <- o3_filtrado %>%
  select(municipio, var1.pred)

# Join the o3_filtrado_pred dataset with comunas_santiago

o3_comunas <- comunas_santiago %>%
  left_join(o3_filtrado_pred, by = c("comuna" = "municipio"))

# Create the interpolated map for o3

g_o3 <- ggplot() +
  geom_sf(data = o3_comunas, aes(fill = var1.pred), color = "black") + 
  scale_fill_viridis_c(name = expression("O"[3] * " Concentration (µg/m³)")) +
  ggtitle(expression("Community-Level O"[3])) +
  labs(subtitle = "2015-12-20") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Generate a grid with both maps

grid.arrange(g_pm, g_o3, ncol = 2)

# Save the figure

muestra <- grid.arrange(g_pm, g_o3, ncol = 2)
ggsave("interpolation_example1.jpg", plot = muestra, dpi = 800)
