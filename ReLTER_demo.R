knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(tidy = TRUE)

# These packages are required
pkg_list  <-  c("remotes",
             "tmap", "tmaptools",
             "sf", "terra",
             "OpenStreetMap",
             "raster"
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
remotes::install_github("oggioniale/ReLTER@dev")
library(ReLTER)

# Choose where to save outputs
Output_dir = "./Output"

eisen <- get_ilter_generalinfo(country="Austria",
                              site_name = "LTSER Platform Eisen")
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

# Edit here to choose your output directory 
boundary_file <- file.path(Output_dir, "eisen_boundary.gpkg")

# Remove country column since it is a list
# (Some sites extend across country boundaries)
eisen_boundary <- subset(eisen_boundary, select = -country)
st_write(eisen_boundary, dsn = boundary_file, append = FALSE)

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

# Takes several minutes
eisen_ndvi <- get_site_ODS(eisen_deimsid, "ndvi_spring")
tm_shape(osm) +
	tm_rgb() + 
  tm_shape(eisen_ndvi) +
  tm_raster(style = "pretty", palette = "RdYlGn", alpha=0.75)

# Acquire Tereno DEIMS ID and boundary
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
## landcover_file <- file.path(Output_dir, "tereno_landcover.tif")
## writeRaster(tereno_landcover, landcover_file, overwrite=TRUE)

saldur <- get_ilter_generalinfo(country="Italy",
                              site_name = "Saldur River Catchment")
saldur_deimsid <- saldur$uri
saldurRiver_osmLandUse <- get_site_ODS(
  deimsid = saldur_deimsid, dataset = "osm_buildings"
)
saldur_boundary <- get_site_info(
  deimsid = saldur_deimsid, "Boundaries"
)
# Prepare OSM background tile and plot
osm <- read_osm(saldur_boundary, ext = 1.2)
# Hillshade of Saldur river bounding box
saldur_hs <- raster::raster("ReLTER_demo_files/saldur_hillshade.tif")

tm_shape(osm) +
  tm_rgb() +
  tm_compass(type = "arrow", position = c("right", "bottom"), text.size = 1) +
  tm_scale_bar(position = c(0.6, "bottom"), text.size = .8) +
  tm_credits("Data from lcv building Copernicus", position = c("left", "top"), size = 1) +
  tm_layout(legend.position = c("left", "bottom")) +
  tm_shape(saldur_hs) +
  tm_raster(palette = "-Greys", style = "cont", legend.show = FALSE, alpha = .4) +
  tm_shape(saldur_boundary) +
  tm_polygons(col = "skyblue", alpha = 0.2, border.col = "gray") +
  tm_shape(saldurRiver_osmLandUse) +
  tm_raster(style = "cont") +
  tm_layout(legend.outside = TRUE)

source("~/work/EU_Projects/ReLTER/R/get_site_MODIS.R")
get_site_MODIS(show_products = TRUE)
get_site_MODIS(show_bands = "Vegetation_Indexes_Monthly_1Km (M*D13A3)" )

# Username and password saved in advance
# For example:

# creds <- list("username"="homer", password="Simpsons")
# saveRDS(creds, "earthdata_credentials.rds)

# Then...
creds <- readRDS("earthdata_credentials.rds")

# Set which product and which bands to get
product = "Vegetation_Indexes_Monthly_1Km (M*D13A3)"
bands = "NDVI"    # Also EVI is available

eisen_ndvi <- get_site_MODIS(eisen_deimsid,               # Which site
                          earthdata_user = creds$username, # From above
                          earthdata_passwd = creds$password,
                          product = product,
                          bands = bands,
                          from_date = "2020.01.01", 
                          to_date =  "2020.12.31",        # From-To dates
                          scale = TRUE,          # Rescale COG back to real values
                          out_folder = Output_dir,        # Where to save outputs
                          save_ts_dir = Output_dir
                          )

# Plot was saved to:
plot_file <- paste("time_series", paste(bands, collapse="_"), sep="_")
plot_path <- file.path(Output_dir, paste0(plot_file, ".png"))
knitr::include_graphics(plot_path)
