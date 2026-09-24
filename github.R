# ==============================================================================
# Script Name: Nigeria Population and Spatial Visualization Map
# Description: Downloading and plotting administrative boundaries, water lines,
#              and WOPR population data for Nigeria using ggplot2 and sf.
# ==============================================================================

# Load required libraries
library(sf)
library(ggplot2)
library(dplyr)
library(stringr)
library(rnaturalearth)
library(rnaturalearthdata)

# ------------------------------------------------------------------------------
# 1. Getting Administrative Boundaries using rnaturalearth
# ------------------------------------------------------------------------------

# Country Boundary
nigeria <- ne_countries(scale = 10, country = "Nigeria", returnclass = "sf")
print(as_tibble(nigeria)) # FIX: Cleaned up print pipe syntax
# utils::View(nigeria)     # Commented out for GitHub automation stability

# Visualising country data
ggplot() +
  geom_sf(data = nigeria, color = 'red', fill = 'beige') # FIX: Removed mapping = aes() for constants

# State Boundaries
stateboundaries <- ne_states(country = "Nigeria", returnclass = "sf") 
ggplot() +
  geom_sf(data = stateboundaries)

# Local Government Boundaries (Shp)
# FIX: Using forward slashes or escaped backslashes prevents Windows file path issues
Nig_LG <- st_read("C:/Users/OLALERU/Desktop/New folder/New folder/Desktop/gis/NGA_adm/NGA_adm2.shp")

# Renaming columns cleanly
Nig_LG <- Nig_LG %>% 
  select(statename = NAME_1, Lg = NAME_2, everything())

# ------------------------------------------------------------------------------
# 2. Loading Nigeria Water Boundaries & Layering Maps
# ------------------------------------------------------------------------------

Water_NIG <- st_read("C:/Users/OLALERU/Desktop/R_EZEKIEL/data_input/NGA_wat/NGA_water_lines_dcw.shp")
Water_NIG2 <- st_read("C:/Users/OLALERU/Desktop/R_EZEKIEL/data_input/NGA_wat/NGA_water_areas_dcw.shp")

# Visualise the water_nig2
ggplot() +
  geom_sf(data = Water_NIG2, fill = 'blue', color = 'blue')

# Layering water features over state boundaries
ggplot() + 
  geom_sf(data = stateboundaries, color = 'black') +
  geom_sf(data = filter(Water_NIG2, !is.na(NAME)), fill = 'blue', color = 'blue') +
  geom_sf_text(data = stateboundaries, aes(label = name), size = 2, colour = 'black') 

# ------------------------------------------------------------------------------
# 3. Working with Population Data (WOPR)
# ------------------------------------------------------------------------------

Nig_pop <- read.csv("C:/Users/OLALERU/Desktop/R_EZEKIEL/data_input/Pop/lga_pop_total_scaled.csv")
s_Population <- read.csv("C:/Users/OLALERU/Desktop/R_EZEKIEL/data_input/Pop/states_pop_total_scaled.csv")

# Spatial Join (LGA level)
Nigpopulation <- Nig_LG %>% 
  left_join(Nig_pop, by = "statename")

# ------------------------------------------------------------------------------
# 4. Preparing State Data and Text Cleaning (Crucial Fixes Here)
# ------------------------------------------------------------------------------

# Select columns in state boundaries
stateboundaries <- stateboundaries %>% 
  select(statename = name, latitude, longitude, geometry) # FIX: Keep geometry explicitly to prevent errors

# --- Data Cleaning Sequence ---
# 1. Clean the original text first to remove spaces and standardize casing
stateboundaries <- stateboundaries %>% 
  mutate(statename = str_to_title(str_trim(statename))) # Standardizes as Title Case (e.g. "Cross River")

s_Population <- s_Population %>% 
  mutate(statename = str_to_title(str_trim(statename)))

# 2. Fix the spelling mismatches explicitly using Title Case matches
# FIX: Removed the buggy 'replace_values()' syntax and used standard dplyr logic
stateboundaries <- stateboundaries %>% 
  mutate(statename = case_match(statename,
                                "Nassarawa"                 ~ "Nasarawa",
                                "Federal Capital Territory" ~ "Federal Capital",
                                "Cross River"               ~ "Cross-River",
                                .default = statename
  ))

# Join state boundaries to population data
statepopulation <- stateboundaries %>% 
  left_join(s_Population, by = "statename")

# ------------------------------------------------------------------------------
# 5. Coordinate Transformations
# ------------------------------------------------------------------------------
Nigpopulation <- st_transform(Nigpopulation, crs = 32631)
stateboundaries <- st_transform(stateboundaries, crs = 32631)

# Ensure statepopulation matches the transformation for map rendering
statepopulation <- st_transform(statepopulation, crs = 32631)

# ------------------------------------------------------------------------------
# 6. Final Population Map of Nigeria
# ------------------------------------------------------------------------------
ggplot() +
  # Map population to fill color, add white borders between states
  geom_sf(data = statepopulation, aes(fill = population), color = "white", size = 0.2) + 
  
  # Reverse scale color so high populations stand out boldly
  scale_fill_continuous(name = "Population", trans = "reverse") +
  
  # Map text labels for the states
  geom_sf_text(data = statepopulation, aes(label = statename), size = 2, colour = 'white') +
  
  theme_minimal() +
  labs(
    title = "Population Map of Nigeria",
    subtitle = "Distribution by State",
    caption = "Source: World Open Population Repository"
  )
