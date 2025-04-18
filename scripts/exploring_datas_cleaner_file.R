
setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")
library(data.table)
library(skimr)
library(janitor)
library(lobstr)
library(dplyr)

load(file = "../transf_data/df1l_urg.rda")


com_nouv_tot_histo <- read.csv2(file = "../raw_data/communes_nouvelles.csv", sep = ",")


comm_nouvelles <- read.csv2("../raw_data/communes_nouvelles.csv", sep = ",")


comm_nouvelles <- clean_names(comm_nouvelles)
comm_nouvelles <- comm_nouvelles[,1:5]
comm_nouvelles <- comm_nouvelles |> 
    mutate(code_insee_commune_nouvelle = as.character(code_insee_commune_nouvelle),
           code_insee_commune_deleguee_non_actif = as.character(code_insee_commune_deleguee_non_actif)
    )


comm_nouvelles <- comm_nouvelles[,c(1,2,4)]
# remove the date in order to remove duplicates
comm_nouvelles <- comm_nouvelles[,2:3]
comm_nouvelles <- comm_nouvelles[!duplicated(comm_nouvelles),]
# manage of 49065 haut anjou multiple dates in initial table
comm_nouvelles <- comm_nouvelles[!(comm_nouvelles$code_insee_commune_nouvelle == "49065" &
                                       comm_nouvelles$code_insee_commune_deleguee_non_actif == "49065" ),]

comm_nouvelles <- comm_nouvelles[!(comm_nouvelles$code_insee_commune_nouvelle == "49149" &
                                       comm_nouvelles$code_insee_commune_deleguee_non_actif == "49149" ),]




# e stands for enriched
df1l_urge <- df1l_urg |> left_join(comm_nouvelles, 
                                   by = c("code_commune_coord_structure" ="code_insee_commune_deleguee_non_actif"))


# file elaborated in dowload_raw_datas.R
load(file = "../transf_data/commune_et_arrond_l.rda")

# c stands for corrected
# keep commune nouvelle if existe
df1l_urgec <- df1l_urge |> 
    mutate(code_insee_commune_nouvelle =
               ifelse(is.na(code_insee_commune_nouvelle),
                      code_commune_coord_structure,
                      code_insee_commune_nouvelle)
    )


# l stands for localised
df1l_urgecl <- df1l_urgec |> left_join(commune_et_arrond_l, 
                                       by = c("code_insee_commune_nouvelle" =
                                                  "INSEE_COM") )

no_match <- df1l_urgecl |> filter(is.na(POPULATION))


