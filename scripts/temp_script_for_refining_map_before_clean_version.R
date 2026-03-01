# paramétrage du titre de la carte
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

# construction intitulé du titre
my_title <- paste(etab ," - ", "Cartographie du marché local pour l'activité ", activite_name, " ", annee)

# affectation du titre
title <- tags$div(
    tag.map.title, HTML(my_title)
)  
# ajout du titre à la carte
my_map <- my_map |> addControl(title, position = "topleft", className="map-title")

# construction du nom de la carte
my_map_file_name <- paste0("../outputs/",finess,"_","Zones_d_attractivite_",activite_name,"_",annee,".html")

# enregistrement de la carte
save_widget(my_map, my_map_file_name)

# proportional circles library for leaflet
# https://github.com/scottsfarley93/leaflet.proportionalClusters

# leaflet mini charts
https://cran.r-project.org/web/packages/leaflet.minicharts/vignettes/introduction.html

# r doc for leaflet
https://www.rdocumentation.org/packages/leaflet/versions/2.2.2

# dynamic maps with leaflet
https://r-charts.com/spatial/interactive-maps-leaflet/
    
    
    #vignette
    
    https://cran.r-project.org/web/packages/leaflet/leaflet.pdf


# from here
# C:\Users\maele\Documents\WORK\3H\PMSI\PDM
# pdm_medecin_correspondants_2018_2022.R
base_map %>% 
    addMinicharts(
        ortho_geo_wide_15$longitude,ortho_geo_wide_15$latitude,
        type = "pie",
        chartdata = dplyr::select(ortho_geo_wide_15,`2018`,`2022`),
        #popupArgs(supLabels =ortho_geo_wide_15$praticien_adresseur ),
        width= sqrt(ortho_geo_wide_15$`2018`)*5,
        popup = popupArgs(html = toto),
        transitionTime = 0)