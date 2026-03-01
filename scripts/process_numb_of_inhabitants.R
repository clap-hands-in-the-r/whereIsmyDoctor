# to source file or
setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")

library(data.table)
library(tidyverse)
library(janitor)


# obtenir la population des departements par le fichier communes

# big work for the processor. polygons are highly precise so they are heavy
# we don't need this for now - we give up the idea to load communes shapes
# it's feasible but file obtained is heavy and slow to manipulate
# we don't need this level of precision for now 
# commune_geo <- st_read(dsn="../raw_data/comm_shapes/COMMUNE.shp") |>
#     mutate(AREA=st_area(geometry))
# l stands for light
# commune_geo_l <- commune_geo |> 
#     select(INSEE_COM,POPULATION)


# this one is lighter when not transforming the geometries
comm_pop <- st_read(dsn="../raw_data/comm_shapes/COMMUNE.shp") |> st_drop_geometry()

# if we want to analyse our data - is pop per dept correctly defined
library(openxlsx)
comm_pop |> 
    group_by(INSEE_DEP) |> 
    summarize(pop = sum(POPULATION)) |>
    as.data.frame() |> 
    write.xlsx("../processed_data/ctl_pop.xlsx")
file.show("../processed_data/ctl_pop.xlsx")                  


dep_pop <- comm_pop |> 
    group_by(INSEE_DEP) |> 
    summarize(pop = sum(POPULATION)) |>
    ungroup()

# we need to remove dpt 97 cause we don't have the shapes now
# it corresponds to overseas dpts

dep_pop <- dep_pop |> 
    filter(!(INSEE_DEP %in% c('971','972','973','974','976')))

# save our data if we want to reuse it directly
save(dep_pop,file = "../processed_data/dep_pop.rda")


