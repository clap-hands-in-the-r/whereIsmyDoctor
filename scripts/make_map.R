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


# to sousfheaders# to source file or
# setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")

# construire la carte avec les depts
# simple sample of map to begin
# we'll get to a little more complicated one just later
my_map <- leaflet() |>  
    addTiles() |> 
    setView(lng=2.3333,lat=46.866667,zoom=6.45) |> 
    addProviderTiles(
    "OpenStreetMap",
    # give the layer a name
    group = "OpenStreetMap") |> 
    addPolygons(
        data = dpt_lght2)


## keeping my pal and my_pal3 in stock!
# my_pal <- data.frame(
#     deciles_gp = as.factor(10:1),
#     colours = c('#e5f5e0','#ffffcc','#ffeda0','#fed976',
#                 '#feb24c','#fd8d3c', '#fc4e2a','#e31a1c',
#                 '#bd0026','#800026')
# )
# 
# my_pal3 <- data.frame(
#     deciles_gp = as.factor(10:1),
#     colours = c('#1a9850','#66bd63','#a6d96a','#d9ef8b',
#                 '#ffffbf','#fee08b', '#fdae61','#e31a1c',
#                 '#bd0026','#b2182b')
# )

my_pal2 <- data.frame(
    deciles_gp = as.factor(10:1),
    colours = c('#1a9850','#66bd63','#a6d96a','#d9ef8b',
                '#ffffbf','#fee08b', '#fdae61','#e31a1c',
                '#bd0026','#800026')
)



neuro <- neuro |> 
    left_join(my_pal2)

neuro <- st_as_sf(neuro)

save(neuro, file = "../processed_data/neuro.Rda")
load(file = "../processed_data/neuro.Rda")


my_map2 <- leaflet() |> 
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



# get the centers of the polygons constituting dpts
dpt_centers <- neuro |> st_centroid()

# get the geometry obtained in the previous operation into long / lat

dpt_centers <- dpt_centers |> 
    mutate(long = unlist(map(dpt_centers$geometry,1)),
           lat = unlist(map(dpt_centers$geometry,2)))

# removing unesuf datas 
dpt_centers <- dpt_centers |> 
    st_drop_geometry() |> 
    select(1,4,5,8,9)
    
# alternatively
load(file = "../processed_data/dpt_centers.rda")

my_map3 <- my_map2 |> 
    addTiles() |> 
    addLabelOnlyMarkers(
        data = dpt_centers,
        lng = dpt_centers$long,
        lat = dpt_centers$lat,
        label = paste(dpt_centers$lib_dpt,
                      round(dpt_centers$eff_to_pop,2)
                      , sep = "\n"),
        labelOptions =
            labelOptions(noHide = TRUE, direction = 'center', textOnly = TRUE,
                         style = list("color" ="black", "font-size" = "10px")
            )
        
    )
my_map3
save_widget(my_map3, "../processed_data/neuro_map.html")


save(dpt_centers, file = "../processed_data/dpt_centers.rda")



    


# construction du nom de la carte
my_map_file_name <- paste0("../output/france map - neurologues_per_inhabitants.html")

# enregistrement de la carte
save_widget(my_map2, my_map_file_name)


# https://colorbrewer2.org/#type=sequential&scheme=YlOrRd&n=9
#e5f5e0
#['#ffffcc','#ffeda0','#fed976','#feb24c','#fd8d3c','#fc4e2a','#e31a1c','#bd0026','#800026']



#### second version : dividing pop in two

my_pal5 <- data.frame(
    deciles_gp = as.factor(2:1),
    colours = c('#1a9850','#e31a1c')#'#66bd63','#a6d96a','#d9ef8b',
    #'#ffffbf','#fee08b', '#fdae61',,
    #'#bd0026','#800026')
)

neuro2 <- neuro2 |> 
    select(-colours)
neuro2 <- neuro2 |> 
    left_join(my_pal5)

neuro2 <- st_as_sf(neuro2)

save(neuro2, file = "../processed_data/neuro2.rda")


# get the centers of the polygons constituting dpts
dpt_centers2 <- neuro2 |> st_centroid()

# get the geometry obtained in the previous operation into long / lat

dpt_centers2 <- dpt_centers2 |> 
    mutate(long = unlist(map(dpt_centers2$geometry,1)),
           lat = unlist(map(dpt_centers2$geometry,2)))

# removing unesuf datas 
dpt_centers2 <- dpt_centers2 |> 
    st_drop_geometry() |> 
    select(1,4,5,8,9)

save(dpt_centers2, file = "../processed_data/dpt_centers2.rda")

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

save(my_map2, file = "../processed_data/my_map2.rda")


my_map5 <- my_map2 |> 
    addTiles() |> 
    addLabelOnlyMarkers(
        data = dpt_centers2,
        lng = dpt_centers2$long,
        lat = dpt_centers2$lat,
        label = paste(dpt_centers2$lib_dpt, "<br>",
                      round(dpt_centers2$eff_to_pop,2)
                      ),
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


#multiple lines labels

labels <- paste(dpt_centers2$lib_dpt, "<br>",
      round(dpt_centers2$eff_to_pop,2)) |> 
    lapply(htmltools::HTML)


my_map6 <- my_map2 |> 
    addTiles() |> 
    addLabelOnlyMarkers(
        data = dpt_centers2,
        lng = dpt_centers2$long,
        lat = dpt_centers2$lat,
        label = labels,
        labelOptions =
            labelOptions(noHide = TRUE, direction = 'center', textOnly = TRUE,
                         style = list("color" ="black", "font-size" = "10px")
            )
)


my_map7 <- my_map6 |> 
    addLegend(pal = my_pal5, values = dpt_centers2$eff_to_pop, opacity = 0.7, title = NULL,
              position = "bottomright")
?addLegend


# https://stackoverflow.com/questions/56241152/addlegend-display-value-range-instead-of-percentage-when-using-colorquantile
qpal <- colorQuantile(c('#e31a1c','#1a9850'), 
                         domain = neuro2$eff_to_pop,
                        n = 2)
qpal_colors <- unique(qpal(sort(neuro2$eff_to_pop)))

qpal_labs <- round(quantile(neuro2$eff_to_pop, seq(0, 1, .5)),2) # depends on n from pal

qpal_labs <- paste(lag(qpal_labs), 
                   qpal_labs, 
                   sep = " to ")[-1] # first lag is NA



my_map2bis |> 
    addLegend(colors = qpal_colors, labels = qpal_labs,
              opacity = 1,
              position = "bottomright")




