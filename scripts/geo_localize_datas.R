# Session / Set working directory / To source file location
# we are now in ./scripts dir

library(sf)
library(dplyr)
library(mapview)

# we need at files related to COMMUNE object in order the below command works
# COMMUNE.shp and COMMUNE.shp and others COMMUNE. in the folder
# files from 
#https://www.data.gouv.fr/fr/datasets/admin-express-admin-express-cog-admin-express-cog-carto-admin-express-cog-carto-pe/#/resources

commune_geo <- st_read(dsn="../raw_data/COMMUNE.shp") |>
    mutate(AREA=st_area(geometry))

# l stands for light
commune_geo_l <- commune_geo |> 
    select(INSEE_COM,POPULATION,geometry)
commune_geo_l <- st_as_sf(commune_geo_l)

save(commune_geo_l, file = "../transf_data/commune_geo_l.rda")


#--------------

#obtenir le centroide d'un polygone ou multipolygone
#st_point_on_surface


poly_codes_geo_zone <- reg_pdl_poly3 |> filter(code_geo %in% code_geo_selec)

poly_codes_geo_zone2 <- st_transform(poly_codes_geo_zone,4326)
# combiner les polygones en une seule forme géométrique sans les formes internes

z_80 <<- st_union(poly_codes_geo_zone2)

make_map <- function(finess,activite_name = "chirurgie",annee = 2023){
    
    # au préalable, construction des points géographiques correspondant aux trois étab ciblés
    loc_finess <- read.csv2("../ext_data_raw_data/GEOLOCALISATION_FINESS.csv")
    loc_finess <- loc_finess |> 
        filter(finess %in% c("490007929","490000262","370000093") )|>  
        filter(annee_fin == "31/12/2022") |> 
        select(finess,longitude, latitude)
    ccl_point <- loc_finess |> filter(finess == "490007929")
    stjo_point <- loc_finess |> filter(finess == "490000262")
    nct_point <- loc_finess |> filter(finess == "370000093")    
    
    if (length(code_geo_selec) > 0){
        
        
        # construire la carte avec la zone des 80%
        my_map <- leaflet() %>% addProviderTiles(
            "OpenStreetMap",
            # give the layer a name
            group = "OpenStreetMap") %>%
            addPolygons(
                data = z_80) 
        
        # Ajouter la légende pour zone des 80%
        my_map <- my_map |> addLegend("bottomleft", colors = c("blue"),
                                      labels = c("Zone des 80% de l'établissement pour l'activité"))
        
        # Ajouter le titre à la carte
        tag.map.title <- tags$style(HTML("
  .leaflet-control.map-title { 
    transform: translate(-50%,20%);
    position: fixed !important;
    left: 50%;
    text-align: center;
    padding-left: 10px; 
    padding-right: 10px; 
    background: rgba(255,255,255,0.75);
    font-weight: bold;
    font-size: 15px;
  }
"))
        #annee <- 2023
        
        if (finess == 490007929) {etab = "Clinique de la Loire"}
        if (finess == 490000262) {etab = "Clinique Saint-Joseph"}
        if (finess == 370000093) {etab = "NCT+"}
        
        
        my_title <- paste(etab ," - ", "Cartographie du marché local pour l'activité ", activite_name, " ", annee)
        
        title <- tags$div(
            tag.map.title, HTML(my_title)
        )  
        my_map <- my_map |> addControl(title, position = "topleft", className="map-title")
        
        # ajouter le point pour CCL
        my_map <- my_map |> 
            addCircleMarkers(lng = as.numeric(ccl_point$longitude),
                             lat = as.numeric(ccl_point$latitude),
                             radius = 5,
                             color = "blue", opacity = 1, fillColor = "blue", fillOpacity = 1,
                             label = "CLINIQUE DE LA LOIRE",
                             labelOptions = labelOptions(noHide = TRUE, offset=c(5,-5))
            )
        
        # ajouter le point pour STJO
        my_map <- my_map |> 
            addCircleMarkers(lng = as.numeric(stjo_point$longitude),
                             lat = as.numeric(stjo_point$latitude),
                             radius = 5,
                             color = "green", opacity = 1, fillColor = "green", fillOpacity = 1,
                             label = "CLINIQUE SAINT JOSEPH",
                             labelOptions = labelOptions(noHide = TRUE, offset=c(5,-5))
            )
        
        # Ajouter le point associé à NCT+
        my_map <- my_map |> 
            addCircleMarkers(lng = as.numeric(nct_point$longitude),
                             lat = as.numeric(nct_point$latitude),
                             radius = 5,
                             color = "green", opacity = 1, fillColor = "green", fillOpacity = 1,
                             label = "SAS NOUVELLE CLINIQUE DE TOURS +",
                             labelOptions = labelOptions(noHide = TRUE, offset=c(-12,-10))
            )
        
        my_map_file_name <- paste0("../outputs/",finess,"_","Zones_d_attractivite_",activite_name,"_",annee,".html")
        
        save_widget(my_map, my_map_file_name)
    }
}