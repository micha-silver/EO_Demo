knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(tidy = TRUE)

# These packages are required
pkg_list  <-  c("remotes",
             "tmap", "tmaptools",
             "sf", "terra",
             "OpenStreetMap"
            )

# Check if already installed, install if not
installed_packages <- pkg_list %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(pkg_list[!installed_packages])
}
# Load Packages
lapply(pkg_list,
       function(p) {require(p,
                            character.only = TRUE,
                            quietly=TRUE)})

# Now install `ReLTER` from github and load
remotes::install_github("oggioniale/ReLTER")
library(ReLTER)

eisen <- get_ilter_generalinfo(country="Austria",
                              site_name = "Eisen")
eisen_deimsid <- eisen$uri

# Using abbreviated "United K" to differentiate from United States
cairngorms <- get_ilter_generalinfo(country = "United K",
                                   site_name = "Cairngorms National")
cairngorms_deimsid <- cairngorms$uri

response <- get_site_info(eisen_deimsid, category = "ResearchTop")
response$researchTopics

response <- get_site_info(cairngorms_deimsid, category = "Affiliations")
response$affiliation.projects


# Acquire boundary for site
eisen_boundary <- get_site_info(eisen_deimsid, "Boundaries")

# Prepare OSM background tile and plot
osm <- read_osm(eisen_boundary, ext = 1.2)
tmap_mode("plot")

# For interactive maps use:
# tmap_mode("view")
# Then these basemaps are available:
# tm_basemap("Stamen.TerrainBackground") +
# tm_basemap("OpenStreetMap") +

tm_shape(osm) +
	tm_rgb() + 
tm_shape(eisen_boundary) +
  tm_polygons(col = "skyblue", alpha = 0.25, border.col = "blue")

## # Edit here to choose your output directory
## boundary_file <- file.path("~", "eisen_boundary.gpkg")
## 
## # Remove country column since it is a list
## # (Some sites extend across country boundaries)
## eisen_boundary <- subset(eisen_boundary, select = -country)
## st_write(eisen_boundary, dsn = boundary_file, append = FALSE)

eisen_contact <- get_site_info(eisen_deimsid, "Contact")
names(eisen_contact)
# No contact information :-(

kiskun <- get_ilter_generalinfo(country_name = "Hungary",
                                site_name = "KISKUN LTER")
kiskun_deimsid <- kiskun$uri
length(kiskun_deimsid)
# Multiple sites with similar name :-(
# Which to choose? View the list...
kiskun$title
kiskun_deimsid <- kiskun$uri[5]
length(kiskun_deimsid)
kiskun_boundary <- get_site_info(kiskun_deimsid, "Boundaries")

# Oops, no boundary for this site!

# Use boundary and OSM tile from above
eisen_landcover <- get_site_ODS(eisen_deimsid, "landcover")

tm_shape(osm) +
	tm_rgb() + 
  tm_shape(eisen_landcover) +
  tm_raster(style = "pretty", palette = "RdYlBu", alpha=0.75)

eisen_corine <- get_site_ODS(eisen_deimsid, "clc2018")

tm_shape(osm) +
	tm_rgb() + 
  tm_shape(eisen_corine) +
  tm_raster(style = "pretty", palette = "Spectral", alpha=0.75)

eisen_ndvi <- get_site_ODS(eisen_deimsid, "ndvi_spring")
eisen_ndvi <- eisen_ndvi / 255
tm_shape(osm) +
	tm_rgb() + 
  tm_shape(eisen_ndvi) +
  tm_raster(style = "pretty", palette = "RdYlGn", alpha=0.75)

# Acquire Tereno ID and boundary
tereno <- get_ilter_generalinfo(country_name = "Germany",
                                 site_name = "Tereno - Harsleben")
tereno_deimsid <- tereno$uri
tereno_boundary <- get_site_info(tereno_deimsid, "Boundaries")

# Prepare new OSM background and plot
osm <- read_osm(tereno_boundary, ext = 1.2)
tereno_ndvi <- get_site_ODS(tereno_deimsid, "ndvi_autumn")
tm_shape(osm) +
	tm_rgb() + 
  tm_shape(tereno_ndvi) +
  tm_raster(style = "pretty", palette = "RdYlGn", alpha=0.75)

tereno_landcover <- get_site_ODS(tereno_deimsid, "landcover")
tm_shape(osm) +
	tm_rgb() + 
  tm_shape(tereno_landcover) +
  tm_raster(style = "pretty", palette = "Spectral", alpha=0.75)
tereno_corine <- get_site_ODS(tereno_deimsid, "clc2018")
tm_shape(osm) +
	tm_rgb() + 
  tm_shape(tereno_corine) +
  tm_raster(style = "pretty", palette = "Spectral", alpha=0.75)

## # Edit here to choose your output directory
## landcover_file <- file.path("~", "tereno_landcover.tif")
## writeRaster(tereno_landcover, landcover_file, overwrite=TRUE)
