library(shiny)
library(leaflet)
library(dplyr)
#library(purrr)
# |> library(sf)

#session / set wking dir / to source file loc

# il faut que all_doc2 soit chargé dans l'environnement
#save(all_doc2, file = "./all_doc2.Rda")
#load(file = "../../processed_data/all_doc2.Rda")
# all_doc2 <- st_as_sf(all_doc2)

# j'ai modifié la liste initiale. il faut aussi que le df eff_by_spe soit chargé
#load(file = "../../processed_data/eff_by_spe.Rda")
#save(eff_by_spe, file = "./eff_by_spe.Rda")
# car je l'utilise pour venir alimenter la liste déroulante

ui <- fluidPage(
    leafletOutput("mymap",height = "100vh"),
    absolutePanel(top = 10, right = 10,
                  selectInput(inputId = "specialite", label = "specialites",
                              choices = eff_by_spe$specialite |> unique())
    )

)

server <- function(input, output, session) {
    
    # il me faut deux "chouches de données"
    # une couche spatiale pour les polygones
    # et une couche non spatiales avec les valeurs à afficher
    # cela correspondait à dpt_centrers et maintenant all_doc5 éventullement
    # mais j'ai fait l'erreur de penser que all_doc5 suffisait
    # donc shiny ne trouvait pas les polygones évidemment
    # et l'erreur est qu'il ne trouvait pas  le path avec objet de type tbl_df
    # tout simplement il n'y avait pas de geometry dans mes données... pfff..

            
    dataset <- reactive({
        all_doc2 |> 
            filter(specialite == input$specialite)
    })
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
    font-size: 28px;
    }
    "))
    
    title <- reactive({
        tags$div(
        tag.map.title, HTML(all_doc2 |> 
                                st_drop_geometry() |> 
                                ungroup() |> 
                                filter(specialite == input$specialite) |> 
                                select(libelle_savoir_faire) |> 
                                unique() |> 
                                pull())
    )  
    })

    
    # leaflet dans shiny par ici :
    # https://rstudio.github.io/leaflet/articles/shiny.html
    
    output$mymap <- renderLeaflet({
        leaflet() %>%
            addProviderTiles("OpenStreetMap",group = "OpenStreetMap") |> 
            setView(lng=2.3333,lat=46.866667,zoom=6.45) |> 
            
            addPolygons(
                data = dataset(), # les objets reactive doivent être suivis de parenthèses
                                # dataset non / dataset() oui
                stroke = FALSE,
                fillOpacity = 0.7,
                fillColor = dataset()$colours) |> 
                addTiles() |> 
                addControl(title(), position = "topleft", className="map-title")
    })
    # observe({
    # 
    #     leafletProxy("map", data = dataset())  |> 
    #         addPolygons(
    #             data = dataset(),
    #             stroke = FALSE,
    #             fillOpacity = 0.7,
    #             fillColor = dataset()$colours
    #         )
    # })
    
}

shinyApp(ui, server)