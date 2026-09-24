Nigeria Population and Spatial Visualization Map
================
Ezekiel
2026-09-24

echo = TRUE, warning = FALSE, message = FALSE, fig.path =
“README_files/figure-markdown_github/” )


    # Nigeria Population and Spatial Visualization Map

    This project downloads and plots administrative boundaries, water lines, and WOPR population data for Nigeria using `ggplot2` and `sf`.

    ## 🛠️ Load Packages
    We use `pacman::p_load` to check, install, and load all necessary libraries.


    ``` r
    if (!require("pacman")) install.packages("pacman")

    ## Loading required package: pacman

``` r
pacman::p_load(tidyverse, inspectdf, plotly, janitor, visdat, esquisse, survey, srvyr,
               gtsummary, likert, tidytext, sf, malariaAtlas, rnaturalearth)
```

------------------------------------------------------------------------

## 🗺️ 1. Getting Administrative Boundaries using rnaturalearthdata

### Country Boundary

``` r
nigeria <- ne_countries(scale = 10, country = "Nigeria", returnclass = "sf")
print(as_tibble(nigeria))
```

    ## # A tibble: 1 × 169
    ##   featurecla    scalerank labelrank sovereignt sov_a3 adm0_dif level type  tlc  
    ##   <chr>             <int>     <int> <chr>      <chr>     <int> <int> <chr> <chr>
    ## 1 Admin-0 coun…         0         2 Nigeria    NGA           0     2 Sove… 1    
    ## # ℹ 160 more variables: admin <chr>, adm0_a3 <chr>, geou_dif <int>,
    ## #   geounit <chr>, gu_a3 <chr>, su_dif <int>, subunit <chr>, su_a3 <chr>,
    ## #   brk_diff <int>, name <chr>, name_long <chr>, brk_a3 <chr>, brk_name <chr>,
    ## #   brk_group <chr>, abbrev <chr>, postal <chr>, formal_en <chr>,
    ## #   formal_fr <chr>, name_ciawf <chr>, note_adm0 <chr>, note_brk <chr>,
    ## #   name_sort <chr>, name_alt <chr>, mapcolor7 <int>, mapcolor8 <int>,
    ## #   mapcolor9 <int>, mapcolor13 <int>, pop_est <dbl>, pop_rank <int>, …

``` r
# Visualising country data
ggplot() +
  geom_sf(data = nigeria, color = 'red', fill = 'beige') +
  theme_minimal()
```

![](ezekiel_pop_files/figure-gfm/country-boundary-1.png)<!-- -->

### State Boundaries

``` r
stateboundaries <- ne_states(country = "Nigeria", returnclass = "sf") 
ggplot() +
  geom_sf(data = stateboundaries) +
  theme_minimal()
```

![](ezekiel_pop_files/figure-gfm/state-boundaries-1.png)<!-- -->

### Local Government Boundaries

``` r
Nig_LG <- st_read("C:/Users/OLALERU/Desktop/New folder/New folder/Desktop/gis/NGA_adm/NGA_adm2.shp")
```

    ## Reading layer `NGA_adm2' from data source 
    ##   `C:\Users\OLALERU\Desktop\New folder\New folder\Desktop\gis\NGA_adm\NGA_adm2.shp' 
    ##   using driver `ESRI Shapefile'
    ## Simple feature collection with 775 features and 11 fields
    ## Geometry type: MULTIPOLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 2.668431 ymin: 4.270418 xmax: 14.67642 ymax: 13.89201
    ## Geodetic CRS:  WGS 84

``` r
# Renaming columns with select function
Nig_LG <- Nig_LG %>% select(statename = NAME_1, Lg = NAME_2, everything())
```

------------------------------------------------------------------------

## 🌊 2. Loading Nigeria Water Boundaries

``` r
Water_NIG <- st_read("C:/Users/OLALERU/Desktop/R_EZEKIEL/data_input/NGA_wat/NGA_water_lines_dcw.shp")
```

    ## Reading layer `NGA_water_lines_dcw' from data source 
    ##   `C:\Users\OLALERU\Desktop\R_EZEKIEL\data_input\NGA_wat\NGA_water_lines_dcw.shp' 
    ##   using driver `ESRI Shapefile'
    ## Simple feature collection with 5162 features and 5 fields
    ## Geometry type: MULTILINESTRING
    ## Dimension:     XY
    ## Bounding box:  xmin: 2.675009 ymin: 4.300013 xmax: 14.68334 ymax: 13.89166
    ## Geodetic CRS:  WGS 84

``` r
Water_NIG2 <- st_read("C:/Users/OLALERU/Desktop/R_EZEKIEL/data_input/NGA_wat/NGA_water_areas_dcw.shp")
```

    ## Reading layer `NGA_water_areas_dcw' from data source 
    ##   `C:\Users\OLALERU\Desktop\R_EZEKIEL\data_input\NGA_wat\NGA_water_areas_dcw.shp' 
    ##   using driver `ESRI Shapefile'
    ## Simple feature collection with 1186 features and 5 fields
    ## Geometry type: MULTIPOLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 2.708342 ymin: 4.280746 xmax: 14.68334 ymax: 13.75
    ## Geodetic CRS:  WGS 84

### Visualizing Water Areas Over State Boundaries

``` r
ggplot() + 
  geom_sf(data = stateboundaries, color = 'black', fill = 'white') +
  geom_sf(data = filter(Water_NIG2, !is.na(NAME)), fill = 'blue', color = 'blue') +
  geom_sf_text(data = stateboundaries, aes(label = name), size = 2, colour = 'black') +
  theme_minimal()
```

    ## Warning in st_point_on_surface.sfc(sf::st_zm(x)): st_point_on_surface may not
    ## give correct results for longitude/latitude data

![](ezekiel_pop_files/figure-gfm/water-map-1.png)<!-- -->

------------------------------------------------------------------------

## 📊 3. Working with Population Data (WOPR)

``` r
Nig_pop <- read.csv("C:/Users/OLALERU/Desktop/R_EZEKIEL/data_input/Pop/lga_pop_total_scaled.csv")
s_Population <- read.csv("C:/Users/OLALERU/Desktop/R_EZEKIEL/data_input/Pop/states_pop_total_scaled.csv")

# Spatial Join
Nigpopulation <- Nig_LG %>% 
  left_join(Nig_pop, by = "statename")
```

    ## Warning in sf_column %in% names(g): Detected an unexpected many-to-many relationship between `x` and `y`.
    ## ℹ Row 1 of `x` matches multiple rows in `y`.
    ## ℹ Row 1 of `y` matches multiple rows in `x`.
    ## ℹ If a many-to-many relationship is expected, set `relationship =
    ##   "many-to-many"` to silence this warning.

------------------------------------------------------------------------

## 🧼 4. Preparing State Data and Text Cleaning

``` r
# FIX: Keep spatial geometry column explicitly so your map vectors are not discarded!
stateboundaries <- stateboundaries %>% select(statename = name, latitude, longitude, geometry)

# Standardize names to Title Case to bypass hidden space and case issues
stateboundaries <- stateboundaries %>% mutate(statename = str_to_title(str_trim(statename)))
s_Population <- s_Population %>% mutate(statename = str_to_title(str_trim(statename)))

# FIX: Replaced broken replace_values() syntax with production-stable case_match()
stateboundaries <- stateboundaries %>% mutate(statename = case_match(statename,
  "Nassarawa"                 ~ "Nasarawa", 
  "Federal Capital Territory" ~ "Federal Capital",
  "Cross River"               ~ "Cross-River",
  .default = statename
))
```

    ## Warning: There was 1 warning in `stopifnot()`.
    ## ℹ In argument: `statename = case_match(...)`.
    ## Caused by warning:
    ## ! `case_match()` was deprecated in dplyr 1.2.0.
    ## ℹ Please use `recode_values()` instead.

``` r
# Join state boundaries to population data
statepopulation <- stateboundaries %>% left_join(s_Population, by = "statename")
```

------------------------------------------------------------------------

## 📐 5. Coordinate Transformations

``` r
Nigpopulation <- st_transform(Nigpopulation, crs = 32631)
stateboundaries <- st_transform(stateboundaries, crs = 32631)
statepopulation <- st_transform(statepopulation, crs = 32631)
```

------------------------------------------------------------------------

## 📍 6. Final Population Map of Nigeria

This maps population densities directly onto state geometries, matching
your desired visual expectations layout on your GitHub landing page.

``` r
# This chunk runs the population visualization and prints the image directly beneath the code block
ggplot() +
  # Map population to fill color, add white border grids
  geom_sf(data = statepopulation, aes(fill = population), color = "white", size = 0.2) + 
  
  # Reverse color spectrum so highest populated zones catch the eye immediately
  scale_fill_continuous(name = "Population", trans = "reverse") +
  
  # Set up readable state text indicators
  geom_sf_text(data = statepopulation, aes(label = statename), size = 2, colour = 'white') +
  
  theme_minimal() +
  labs(title = "Population Map of Nigeria",
       subtitle = "Distribution by State",
       caption = "Source: World Open Population Repository")
```

![](ezekiel_pop_files/figure-gfm/final-map-1.png)<!-- -->

``` r
# Export high quality graphic file copy
ggsave("nigeria_population_map.png", width = 8, height = 6, dpi = 300)
```
