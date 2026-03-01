# Session / Set working directory / To source file location
setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")
# we are now in ./scripts dir

# departements

library(sf)
library(dplyr)

# be careful with the load on your computer - this is not a huge but a really big file
dpt <- st_read(dsn="../raw_data/dpt_shapes/DEPARTEMENT.shp") |>
    mutate(AREA=st_area(geometry))

# using st_simplify to try to lighten the dpt map object
# it is important to make the map easyer to draw and manipulate
# be careful this conversion itself can be time consuming

# we can omit this one - precision isnt enough
# dpt_lght <-  st_simplify(dpt, dTolerance = 3e3) # 3000m

dpt_lght2 <-  st_simplify(dpt, dTolerance = 300) # 300m


# sizes comparisons
library(lobstr)
obj_size(dpt) # 75.53 MB
obj_size(dpt_lght) # 155.61 kB
obj_size(dpt_lght2) #769.61 kB

# we can discard the heavy first one file
rm(dpt)

# if we wat to save of our file for direct reusing
save(dpt_lght2, file = "../processed_data/dpt_lght2.rda")
load(file = "../processed_data/dpt_lght2.rda")

dpt_lght2 <- dpt_lght2 |> 
    filter(!(INSEE_DEP %in% c('971','972','973','974','976')))

# this is our simple dpt shape file with only "france metropole"
dpt_shp <- dpt_lght2 |> 
    select(3,4,6)

save(dpt_shp, file = "../processed_data/dpt_shp.rda")



