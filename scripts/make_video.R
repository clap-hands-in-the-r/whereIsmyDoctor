



### ci dessous le fichier trash qui m'avait permis de produire la vidéo 
my_video.mp4

#C:\Users\maele\Documents\WORK\JHOPKINS\DataVizCapstone\data_viz_capstone


setwd("C:/Users/maele/Documents/WORK/JHOPKINS/DataVizCapstone/data_viz_capstone")

library(readr)
my_clean_df <- read_csv(url("https://dl.dropboxusercontent.com/s/jm0krff08hlx5t8/my_clean_df.csv?dl=0"))

readLines(url("https://dl.dropboxusercontent.com/s/jm0krff08hlx5t8/my_clean_df.csv?dl=0"))



library(dplyr)
library(data.table)
my_clean_df %>% names()


df_france <- my_clean_df %>% filter(sexe_praticien != 'Ensemble')
df_france <- df_france %>% filter(specialite_praticien != 'Ensemble')
df_france <- df_france %>% filter(departement_inscription_praticien != 'Ensemble')


df_france_for_map <- df_france %>% select(-c(5,7)) %>% group_by(departement_inscription_praticien, annee) %>% summarize(practitionner_number = sum(nb_statut_indifferencie))

library(leaflet)



setView(lng=-0.7669906,lat=48.0785146,zoom=10)


addMarkers(lng=-0.7669906,lat=48.0785146,popup = "Laval") %>% 
    addCircles(lng=~longitude,lat=~latitude,weight=5,radius=~sqrt(effectifs)*30,popup=~paste(praticien_adresseur,adresse_med_traitant2," nb patients adressés: ",effectifs) )

dpt <- df_france_for_map %>% select(departement_inscription_praticien) %>% unique() 


### travail sur les départements et surtout sur leur centre
# from https://www.ign.fr/reperes/centre-geographique-des-departements-metropolitains
library(readxl)
dept_centers <- read_xlsx("Centre_departement.xlsx", skip =1)
names(dept_centers) <- c("code_dpt","lib_dpt","aire","lng","lat","commune")



# conv_unit is from library measurements
# it permits us to convert lat and long from degrees min sec to decimals

#install.packages("measurements")
library(measurements)
library(stringr)
library(dplyr)
dept_centers <- dept_centers %>% mutate(est_ouest = str_sub(lng,-1)) %>% 
    mutate(lng = str_sub(lng,start=1,end=7)) %>% 
    mutate(lng = str_replace(lng,"°", " ")) %>% 
    mutate(lng = str_replace(lng,"'"," ")) %>% 
    mutate(lng = str_replace(lng,","," ")) %>% 
    mutate(lng= conv_unit(lng,from = "deg_min_sec",to = "dec_deg")) %>% 
    mutate(lng = ifelse(est_ouest=="O",paste0("-",lng),lng)) %>% 
    mutate(lng = as.numeric(lng)) %>% select(-c(est_ouest))


dept_centers <- dept_centers %>% mutate(lat =
                                            str_sub(lat,start=1,end=7)) %>% 
    mutate(lat = str_replace(lat,"°", " ")) %>% 
    mutate(lat = str_replace(lat,"'"," ")) %>% 
    mutate(lat = str_replace(lat,","," ")) %>% 
    mutate(lat= conv_unit(lat,from = "deg_min_sec",to = "dec_deg")) %>% 
    mutate(lat = as.numeric(lat))


dept_centers %>% leaflet() %>% addTiles() %>% addMarkers(popup = dept_centers$commune)

save(dept_centers,file = "dept_centers.Rda")

# filtering out overseas departments
df_france_for_map <- df_france_for_map %>% mutate(start_code_dpt = str_sub(departement_inscription_praticien, start = 1, end = 1)) %>% filter(start_code_dpt ==0)
df_france_for_map <- df_france_for_map %>% select(-start_code_dpt)
df_france_for_map <- df_france_for_map %>% mutate(code_dpt = str_sub(departement_inscription_praticien,start=2,
                                                                     end=3))

df_france_for_map_geo <- df_france_for_map %>% left_join(dept_centers, by = c("code_dpt"="code_dpt"))



an_vec <- df_france_for_map_geo %>% ungroup() %>% select(annee) %>% arrange(annee) %>% unique(.) %>% pull()


df_france_for_map_geo_2012 <- df_france_for_map_geo %>% filter(annee=='2012-01-01')

df_france_for_map_geo_2012 %>% 
    leaflet() %>% addTiles() %>% 
    addCircles(weight = 1,radius=sqrt(df_france_for_map_geo_2012$practitionner_number)*600,
               popup = paste(df_france_for_map_geo_2012$commune, df_france_for_map_geo_2012$practitionner_number)) 




for (i in 1:length(an_vec)) {
    
    an <- an_vec[i]
    an_char <- str_sub(an,1,4)
    my_map <- paste0("map_",an_char)
    df_france_for_map_geo_temp <- df_france_for_map_geo %>% filter(annee==an)
    
    my_map <- df_france_for_map_geo_temp %>% 
        leaflet() %>% addTiles() %>% 
        addCircles(weight = 1,radius=sqrt(df_france_for_map_geo_temp$practitionner_number)*600,
                   popup = paste(df_france_for_map_geo_temp$commune, df_france_for_map_geo_temp$practitionner_number)) %>% 
        addControl(an_char,"topright")
    
    saveWidget(my_map, "temp.html", selfcontained = F)
    webshot("temp.html",file = paste0("map_",an_char,'.png'), cliprect = "viewport")
    
}





my_map_2022 <- df_france_for_map_geo %>% filter(annee=='2013-01-01') %>% 
    leaflet() %>% addTiles() %>% 
    addCircles(weight = 1,radius=sqrt(df_france_for_map_geo$practitionner_number)*300,
               popup = paste(df_france_for_map_geo$commune, df_france_for_map_geo$practitionner_number)) %>% addControl('2022',"topright")

my_map_2022

?addControl

format(an_vec[2],"%Y")

str(df_france_for_map_geo)

library(leaflet)
my_map <- df_france_for_map_geo %>% filter(annee==an) %>% 
    leaflet() %>% addTiles() %>% 
    addCircles(weight = 1,radius=sqrt(df_france_for_map_geo$practitionner_number)*300,
               popup = paste(df_france_for_map_geo$commune, df_france_for_map_geo$practitionner_number))


saveWidget(my_map, "temp.html", selfcontained = F)
webshot("temp.html",file = paste0(my_map,'.png'), cliprect = "viewport")


install.packages("mapshot2")
library(gganimate)
library(mapview)
library(mapshot2)
library(webshot)
library(htmlwidgets)

install.packages('mapmate')
library(mapmate)

#install.packages("remotes")
#remotes::install_github("leonawicz/mapmate", force = TRUE)
# librairie pour obtenir la fonction ffmpeg


ffmpeg(pattern="map_%04d.png", start = 2012, rate =1, output="my_video.mp4", details=TRUE, fps.out = 30, overwrite = TRUE)   



View(ffmpeg)

match(list.files())

saveWidget(my_map, "temp.html", selfcontained = F)
webshot("temp.html",file = "map_2016.png", cliprect = "viewport")

# Gganimate only works with ggplot2, so no leaflet compatibility.
# 
# However, you can also create animations (gif, mpg, etc. not html) with leaflet using the following kind of approach:
#     
#     Generate a map for each frame of your animation. You can use loops or applys to do this, filtering to one day for each iteration.
# 
# Export each frame as a png using mapshot from mapview
# 
# Piece the animation together using a system call to ffmpeg



install.packages("mapview")

