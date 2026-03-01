# to source file or

library(dplyr)
library(sf)
library(lobstr)


setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")

load(file = "../processed_data/df1l_affected_gp.rda")
#load(file = "../processed_data/df1l_neuro_gp.rda")
load(file = "../processed_data/dep_pop.rda")
load(file = "../processed_data/dpt_shp.rda")


all_doc <- df1l_affected_gp |> 
    left_join(dep_pop, by = c("dpt"="INSEE_DEP"))

# sum(is.na(all_doc$pop))
# remove one outlier where no dpt is known "00"

all_doc <- all_doc |> 
    filter(dpt != '00')


# adding effectif to pop ratio
all_doc <- all_doc |> 
    mutate(eff_to_pop =
               round(eff/pop * 100000,2))

save(all_doc, file = "../processed_data/all_doc.rda")
load(file = "../processed_data/all_doc.rda")


# size before
obj_size(all_doc) #680.92 kB

# grouping datas with shapes of dpts
all_doc <- all_doc |> 
    ungroup() |> 
    left_join(dpt_shp, by = c("dpt"="INSEE_DEP"))

# size after
obj_size(all_doc) #1.02 MB



all_doc <- janitor::clean_names(all_doc)

all_doc <- all_doc |> 
    rename(lib_dpt = nom)

save(all_doc, file = "../processed_data/all_doc.Rda")


# second version dividing population in two
all_doc2 <- all_doc |> 
    group_by(code_savoir_faire) |> 
    mutate(deciles_gp=
               as.factor(
                   ntile(eff_to_pop,2)
               ))

all_doc2 <- all_doc2 |> 
    mutate(specialite = paste(code_savoir_faire,libelle_savoir_faire, sep = " - "))


save(all_doc2, file = "../processed_data/all_doc2.Rda")



eff_by_spe <- all_doc2 |> 
    st_drop_geometry() |> 
    group_by(specialite) |> 
    summarise(eff = sum(eff)) |> 
    arrange(desc(eff))



save(eff_by_spe, file = "../processed_data/eff_by_spe.Rda")
