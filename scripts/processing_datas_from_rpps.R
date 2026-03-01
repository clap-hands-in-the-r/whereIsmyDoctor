# to source file or
setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")

library(data.table)
library(tidyverse)
library(janitor)

file1 <- "../raw_data/rpps_data/PS_LibreAcces_Personne_activite_202504040839.txt"
df1 <- fread(file1) ## need a certain time to load

# get clean names esaily for df1 thanks to janitor
df1 <- clean_names(df1)

# substet df1 in order to keep only useful informations to our purpose
# and making it lighter
df1l <- df1[code_profession == 10,c(2,3,4,5,6,7,8,9,10,11,16,17,18,19,29,30,32,33,36,37,38)]

obj_size(df1) #1.10 GB
obj_size(df1l) #98.86 MB

# remove df1 in order to get rid of this too heavy stuff!
rm(df1)

# obtain a list of specialties in order to have quick look
# l_spe stand for list of specialties
l_spe <- df1l |> select(code_savoir_faire,libelle_savoir_faire) |> 
    distinct() 
# save our files if we want to reuse them directly

save(df1l, file = "../processed_data/df1l.rda")
save(l_spe, file = "../processed_data/l_spe.rda")

# if we need to reload the file previously saved
load(file = "../processed_data/df1l.rda")

# for actual purpose we will keep SM32 Neurologie and SM88 Pédiatrie option neuropédiatrie
# the two disciplines are closely related and can ben somehow gathered in one group


### Processing data for neurologie and neuropediatry
## SM88 is accountable for a very few people in the database
df1l_neuro <- df1l[df1l$code_savoir_faire == "SM32" | df1l$code_savoir_faire == "SM88",]
df1l_neuro |> nrow() # [1] 5091

# we can now get rid of df1l
rm(df1l)


# we need to get rid of doctors who are not practicing any more
df1l_neuro <- df1l_neuro |> filter(code_commune_coord_structure!= "")
df1l_neuro |> nrow() # [1] 4267

# arbitratry unicity of work location because we do not have another mean
# some data are not totaly public
# df1l_u _u stands for unique
df1l_neuro <- df1l_neuro |> group_by(identifiant_pp) |> slice(1)
df1l_neuro |> nrow() # [1] 3272

df1l_neuro  <- df1l_neuro |> mutate(dpt = str_sub(code_commune_coord_structure,1,2))

# exploring datas
df1l_neuro |> select(dpt) |> head()
df1l_neuro |> select(dpt) |> tail()


df1l_neuro_gp <- df1l_neuro |> 
    group_by(dpt) |> 
    summarize(eff = n())


# removing over seas dpt cause we don't already have the dedicated shapes
df1l_neuro_gp <- df1l_neuro_gp |> 
    filter(!(dpt %in% c('97','98')))


save(df1l_neuro_gp, file = "../processed_data/df1l_neuro_gp.rda")



########################### Project with another specialty that is psychiatry


df1l |> select(code_savoir_faire,libelle_savoir_faire) |> 
    distinct() |> 
    filter(libelle_savoir_faire %like% '*Psy*') #warning like is case sensitive


# code_savoir_faire                               libelle_savoir_faire
# <char>                                             <char>
#     1:              SM33                                  Neuro-psychiatrie
# 2:              SM93 Psychiatrie option psychiatrie de la personne âgée

# df1l_psy <- df1l[code_savoir_faire == "SM93",] ##### this is an error SM93 is too restrictive


# just if we want a better understanding of the datas
eff_by_code_svf <- df1l |> group_by(code_savoir_faire,libelle_savoir_faire) |> 
    summarize(eff = n()) |> 
    as.data.frame() |> 
    adorn_totals()

df1l_sm42 <- df1l[code_savoir_faire == "SM42",]