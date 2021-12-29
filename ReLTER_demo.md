Demonstrating the Use of the `ReLTER` package
================
Micha Silver
29/12/2021

-   [Install and load packages](#install-and-load-packages)
-   [Query DEIMS SDR](#query-deims-sdr)
-   [General information](#general-information)
-   [Spatial queries](#spatial-queries)
    -   [Get boundary of site](#get-boundary-of-site)
    -   [Save boundary as shapefile/geopackage for
        later](#save-boundary-as-shapefilegeopackage-for-later)
-   [Dependency on quality of data in DEIMS
    SDR](#dependency-on-quality-of-data-in-deims-sdr)

## Install and load packages

Begin by installing packages and loading them.

``` r
# These packages are required
pkg_list = c("remotes",            # to install from github
             "tmap", "tmaptools",  # to visualize maps
             "sf", "terra",        # spatial packages
             "OpenStreetMap"       # basemaps
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
```

    ## [[1]]
    ## [1] TRUE
    ## 
    ## [[2]]
    ## [1] TRUE
    ## 
    ## [[3]]
    ## [1] TRUE
    ## 
    ## [[4]]
    ## [1] TRUE
    ## 
    ## [[5]]
    ## [1] TRUE
    ## 
    ## [[6]]
    ## [1] TRUE

``` r
# Now install `ReLTER` from github and load
remotes::install_github("oggioniale/ReLTER")
library(ReLTER)
```

## Query DEIMS SDR

We can query the DEIMS database, and get a few DEIMS IDs. This code
retrieves the full URL to each eLTER site. Sites can be selected by
country name, site name or both. Note that partial matching is also
supported. So `country_name = "Austri"` will find sites in Austria, but
not Australia.

``` r
eisen<- get_ilter_generalinfo(country="Austria",
                              site_name = "Eisen")
eisen_deimsid <- eisen$uri
cairngorms <- get_ilter_generalinfo(country = "United K",
                                   # To differentiate from United States
                                   site_name = "Cairngorms National")
cairngorms_deimsid <- cairngorms$uri
```

## General information

In `ReLTER` there are functions to grab metadata for the sites. These
categories are available: - ‘Affiliations’ - ‘Boundaries’ (spatial
layer) - ‘Contacts’ - ‘EnvCharacts’ (environmental characteristics) -
‘General’, - ‘Infrastructure’ - ‘Parameters’ (which parameters are
collected) - ‘RelateRes’ (related research) - ‘ResearchTop’ (research
topics)

``` r
response <- get_site_info(eisen_deimsid, category = "ResearchTop")
response$researchTopics
```

    ## [[1]]
    ##              researchTopicsLabel                           researchTopicsUri
    ## 1                    agriculture http://vocabs.lter-europe.net/EnvThes/21605
    ## 2                  air chemistry http://vocabs.lter-europe.net/EnvThes/21657
    ## 3                 animal ecology    http://vocabs.lter-europe.net/EnvThes/71
    ## 4                    aquaculture http://vocabs.lter-europe.net/EnvThes/30003
    ## 5                   biodiversity http://vocabs.lter-europe.net/EnvThes/21673
    ## 6                biogeochemistry http://vocabs.lter-europe.net/EnvThes/21609
    ## 7                        biology http://vocabs.lter-europe.net/EnvThes/21611
    ## 8                 climate change http://vocabs.lter-europe.net/EnvThes/21754
    ## 9             climate monitoring http://vocabs.lter-europe.net/EnvThes/21757
    ## 10            community dynamics http://vocabs.lter-europe.net/EnvThes/21680
    ## 11                  conservation http://vocabs.lter-europe.net/EnvThes/21663
    ## 12                 ecophysiology http://vocabs.lter-europe.net/EnvThes/21652
    ## 13             ecosystem ecology http://vocabs.lter-europe.net/EnvThes/21689
    ## 14            ecosystem function http://vocabs.lter-europe.net/EnvThes/20519
    ## 15             ecosystem service http://vocabs.lter-europe.net/EnvThes/20520
    ## 16                forest ecology http://vocabs.lter-europe.net/EnvThes/21693
    ## 17                       geology http://vocabs.lter-europe.net/EnvThes/21740
    ## 18                     hydrology http://vocabs.lter-europe.net/EnvThes/21747
    ## 19                  lake ecology    http://vocabs.lter-europe.net/EnvThes/69
    ## 20              land use history http://vocabs.lter-europe.net/EnvThes/21744
    ## 21             landscape ecology http://vocabs.lter-europe.net/EnvThes/21703
    ## 22                     limnology http://vocabs.lter-europe.net/EnvThes/21749
    ## 23 long term ecological research http://vocabs.lter-europe.net/EnvThes/21751
    ## 24             microbial ecology    http://vocabs.lter-europe.net/EnvThes/77
    ## 25               natural science http://vocabs.lter-europe.net/EnvThes/30031
    ## 26                    physiology http://vocabs.lter-europe.net/EnvThes/21651
    ## 27                 plant ecology http://vocabs.lter-europe.net/EnvThes/21710
    ## 28              plant physiology http://vocabs.lter-europe.net/EnvThes/21653
    ## 29                  silviculture http://vocabs.lter-europe.net/EnvThes/21608
    ## 30               social sciences http://vocabs.lter-europe.net/EnvThes/30006
    ## 31                     sociology http://vocabs.lter-europe.net/EnvThes/30012
    ## 32                soil chemistry http://vocabs.lter-europe.net/EnvThes/21660
    ## 33             species diversity http://vocabs.lter-europe.net/EnvThes/21679
    ## 34                stream ecology    http://vocabs.lter-europe.net/EnvThes/72
    ## 35           terrestrial ecology    http://vocabs.lter-europe.net/EnvThes/79
    ## 36              trophic dynamics http://vocabs.lter-europe.net/EnvThes/21682
    ## 37           vegetation dynamics http://vocabs.lter-europe.net/EnvThes/21711

``` r
response <- get_site_info(cairngorms_deimsid, category = "Affiliations")
response$affiliation.projects
```

    ## [[1]]
    ##                                    label
    ## 1                            Natura 2000
    ## 2          Ramsar Convention on Wetlands
    ## 3                                 Teabag
    ## 4 Water Framework Directive (2000/60/EC)
    ## 5                          eLTER (H2020)
    ## 6                        eLTER catalogue
    ##                                                                    uri
    ## 1                                                                 <NA>
    ## 2                                               https://www.ramsar.org
    ## 3                                                                 <NA>
    ## 4 https://ec.europa.eu/environment/water/water-framework/index_en.html
    ## 5                           https://cordis.europa.eu/project/id/654359
    ## 6                                                                 <NA>

## Spatial queries

### Get boundary of site

``` r
eisen_boundary <- get_site_info(eisen_deimsid, "Boundaries")
osm <- read_osm(eisen_boundary, ext = 1.2)
tmap_mode("plot")
```

    ## tmap mode set to plotting

``` r
# tm_basemap('Stamen.TerrainBackground') + tm_basemap('OpenStreetMap') +
tm_shape(osm) + tm_rgb() + tm_shape(eisen_boundary) + tm_polygons(col = "skyblue",
    alpha = 0.25, border.col = "blue")
```

![](ReLTER_demo_files/figure-gfm/boundary-1.png)<!-- -->

### Save boundary as shapefile/geopackage for later

``` r
boundary_file <- file.path("~", "eisen_boundary.gpkg")

# Remove country column since it is a list
eisen_boundary <- subset(eisen_boundary, select = -country)
st_write(eisen_boundary, dsn = boundary_file, append = FALSE)
```

    ## Deleting layer `eisen_boundary' using driver `GPKG'
    ## Writing layer `eisen_boundary' to data source 
    ##   `/home/micha/eisen_boundary.gpkg' using driver `GPKG'
    ## Writing 1 features with 7 fields and geometry type Polygon.

## Dependency on quality of data in DEIMS SDR

-   Missing information
-   Duplicate names
-   Missing boundary shapefile

``` r
eisen_contact <- get_site_info(eisen_deimsid, "Contact")
names(eisen_contact)
## [1] "title"        "uri"          "geoCoord"     "country"      "geoElev.avg" 
## [6] "geoElev.min"  "geoElev.max"  "geoElev.unit"
# No contact information :-(

kiskun <- get_ilter_generalinfo(country_name = "Hungary", site_name = "KISKUN LTER")
kiskun_deimsid <- kiskun$uri
length(kiskun_deimsid)
## [1] 8
# Multiple sites with similar name :-( Which to choose?
kiskun$title
## [1] "Kiskun Forest Reserve Sites, KISKUN LTER - Hungary"   
## [2] "VULCAN Kiskunsag, KISKUN LTER - Hungary"              
## [3] "Kiskun Restoration Experiments, KISKUN LTER - Hungary"
## [4] "Kiskun Site Network (Jedlik), KISKUN LTER - Hungary"  
## [5] "KISKUN LTER - Hungary"                                
## [6] "LTER Fulophaza Site, KISKUN LTER - Hungary"           
## [7] "Bugac-Bocsa-Orgovany Site, KISKUN LTER - Hungary"     
## [8] "Orgovany Site, KISKUN LTER - Hungary"
kiskun_deimsid <- kiskun$uri[5]
length(kiskun_deimsid)
## [1] 1
kiskun_boundary <- get_site_info(kiskun_deimsid, "Boundaries")
## 
## ----
## This site does not have boundaries uploaded to DEIMS-SDR.
## Please verify in the site page: https://deims.org/124f227a-787d-4378-bc29-aa94f29e1732
## ----

# Oops, no boundary for this site!
```
