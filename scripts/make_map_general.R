library(mapview)
library(leaflet)
library(htmlwidgets)
library(htmltools)
# devtools::install_github("mvanhala/rutils")
library("rutils")
library(sp)
library(sf)
library(dplyr)
library(purrr)
library(htmltools)


# to source file or
# setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")



my_pal5 <- data.frame(
    deciles_gp = as.factor(2:1),
    colours = c('#1a9850','#e31a1c'))

all_doc2 <- all_doc2 |> 
    left_join(my_pal5)

save(all_doc2, file = "../processed_data/all_doc2.Rda")
load(file = "../processed_data/all_doc2.Rda")

all_doc2 <- all_doc2 |> ungroup()

all_doc2 <- st_as_sf(all_doc2)


# get the centers of the polygons constituting dpts
all_doc3 <- all_doc2 |> st_centroid()

# get the geometry obtained in the previous operation into long / lat

all_doc3 <- all_doc3 |> 
    mutate(long = unlist(map(all_doc3$geometry,1)),
           lat = unlist(map(all_doc3$geometry,2)))

save(all_doc3, file = "../processed_data/all_doc3.rda")


# removing geometry
all_doc4 <- all_doc3 |> 
    st_drop_geometry()

save(all_doc4, file = "../processed_data/all_doc4.rda")


my_map2 <- leaflet() |> 
    addTiles() |> 
    addProviderTiles(
        "OpenStreetMap",
        # give the layer a name
        group = "OpenStreetMap") |> 
    setView(lng=2.3333,lat=46.866667,zoom=6.45) |> 
    addPolygons(
        data = neuro2,
        stroke = FALSE,
        fillOpacity = 0.7,
        fillColor = neuro2$colours)

my_map5 <- my_map2 |> 
    addTiles() |> 
    addLabelOnlyMarkers(
        data = dpt_centers2,
        lng = dpt_centers2$long,
        lat = dpt_centers2$lat,
        label = paste(dpt_centers2$lib_dpt,
                      round(dpt_centers2$eff_to_pop,2)
                      , sep = "\n"),
        labelOptions =
            labelOptions(noHide = TRUE, direction = 'center', textOnly = TRUE,
                         style = list("color" ="black", "font-size" = "10px")
            )
        
    )


my_map5



# construction du nom de la carte
my_map_file_name <- paste0("../output/france map - neurologues_per_inhabitants_v5.html")

# enregistrement de la carte
save_widget(my_map5, my_map_file_name)

load(file = my_map_file_name)


# construction du nom de la carte
my_map_file_name <- paste0("../output/france map - neurologues_per_inhabitants.html")

# enregistrement de la carte
save_widget(my_map2, my_map_file_name)





##### tests

load(file = "../processed_data/neuro.rda")

leaflet() |> 
    addTiles() |> 
    addProviderTiles(
        "OpenStreetMap",
        # give the layer a name
        group = "OpenStreetMap") |> 
    setView(lng=2.3333,lat=46.866667,zoom=6.45) |> 
    addPolygons(
        data = neuro,
        stroke = FALSE,
        fillOpacity = 0.7,
        fillColor = neuro$colours)


S3Class(neuro)
S3Class(all_doc4)
