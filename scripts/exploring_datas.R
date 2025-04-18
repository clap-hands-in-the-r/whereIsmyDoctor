# to source file or
# setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")

setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")
list.files("../raw_data/")


dat <- readLines("../raw_data/PS_LibreAcces_Personne_activite_202504040839.txt", n = 3)
?readLines


library(data.table)

# Un fichier intitulé « PS_LibreAcces_Personne_activite » comprenant des données relatives à l’identité, à l’exercice professionnel et à la structure dans laquelle exerce le professionnel ;
file1 <- "../raw_data/PS_LibreAcces_Personne_activite_202504040839.txt"
ex1 <- fread(file1,nrows = 2)
ex1_1500 <- fread(file1,nrows = 1500)


# Un fichier intitulé « PS_LibreAcces_Dipl_AutExerc » comprenant les données de diplôme et d’autorisation d’exercice des professionnels ;
file2 <- "../raw_data/PS_LibreAcces_Dipl_AutExerc_202504040839.txt"
ex2 <- fread(file2,nrows = 2)
t_ex2 <- data.table::transpose(ex2)
colnames(t_ex2) <- rownames(ex2)
rownames(t_ex2) <- colnames(ex2)

#Un fichier intitulé « PS_LibreAcces_SavoirFaire » comprenant les données de l’ensemble des savoir-faire des professionnels, dont les spécialités.
file3 <- "../raw_data/PS_LibreAcces_SavoirFaire_202504040839.txt"
ex3 <- fread(file3,nrows = 2)
t_ex3 <- data.table::transpose(ex3) #necessary to spec data.table otherwise transpose is masked from another library and resulting object is a list not a data frame
colnames(t_ex3) <- rownames(ex3)
rownames(t_ex3) <- colnames(ex3)

#Sys.setLanguage('en')

# in order to see easily the fields of my df size 2 sample
# transpose a data frame
#http://stackoverflow.com/questions/6778908/transpose-a-data-frame
t_ex1 <- transpose(ex1)

# get row and colnames in order
colnames(t_ex1) <- rownames(ex1)
rownames(t_ex1) <- colnames(ex1)

#fields that can be interesting in the context of our study

#Libellé civilité d'exercice : Docteur
#Code profession : 10
#Libellé profession : Médecin
#Code savoir-faire  : SM53
#Libellé savoir-faire : Spécialiste en Médecine Générale
# Code mode exercice : S
# Libellé mode exercice : Salarié
# Numéro Voie (coord. structure)
# Indice répétition voie (coord. structure)
# Libellé type de voie (coord. structure)
# Libellé Voie (coord. structure
# Code postal (coord. structure) : 56000
# Code commune (coord. structure) : 56260
# Libellé commune (coord. structure) : Vannes


# number of rows for each file

# I dont really know why but the two forms below with cat doesn't work
# well. return is [1] 126 but we already know there are more lines
#as.numeric(system("cat ../raw_data/PS_LibreAcces_Personne_activite_202504040839.txt | wc-l", intern = FALSE)) -1
#as.numeric(system("cat file1 | wc-l", intern = FALSE)) -1

length(readLines(file1))
# file personne activite
#[1] 2 122 570


length(readLines(file2))
# file diplome autexerc
#[1] 2 101 632

# other technique much faster with data table
NROW(fread(file3))
# file savoirs faires
# [1] 405 502

# we will now focus on exploring df1

df1 <- fread(file1)
object.size(df1)
#save(df1, file = "../raw_data/df1.rda")
#load(file = "../raw_data/df1.rda")

#install.packages("skimr")
library(skimr)
#install.packages("stringr")
library(stringr)
skim(ex1_1500)


#colnames(ex1_1500) <- str_replace_all(colnames(ex1_1500)," ","_")
library(janitor)
ex1 <- clean_names(ex1)

# using janitor is easier and more efficient than writting our own function to clean names
# what a shame ! ;-) 


ex1_1500 <- clean_names(ex1_1500)


# Code_profession == 10 means "Médecin" (doctor)

#install.packages("lobstr")
library(lobstr)
S3Class(ex1)
#[1] "data.table" "data.frame"


ex1_1500l <- ex1_1500[]

names(ex1_1500)

# get clean names for df1
df1 <- clean_names(df1)

names(ex1_1500)

# keep an id?? unicity?
# [2] "identifiant_pp"                               
# [3] "identification_nationale_pp"                  
# [4] "code_civilite_dexercice"                      
# [5] "libelle_civilite_dexercice"                   
# [6] "code_civilite"                                
# [7] "libelle_civilite"                             
# [8] "nom_dexercice"                                
# [9] "prenom_dexercice"                             
# [10] "code_profession"                              
# [11] "libelle_profession" 
# [16] "code_savoir_faire"                            
# [17] "libelle_savoir_faire"                         
# [18] "code_mode_exercice"                           
# [19] "libelle_mode_exercice" 
# [29] "numero_voie_coord_structure"                  
# [30] "indice_repetition_voie_coord_structure"
# [32] "libelle_type_de_voie_coord_structure"         
# [33] "libelle_voie_coord_structure"  
# [36] "code_postal_coord_structure"                  
# [37] "code_commune_coord_structure"                 
# [38] "libelle_commune_coord_structure"   


# substet df1 in order to keep only useful informations to our purpose
# and making it lighter
df1l <- df1[code_profession == 10,c(2,3,4,5,6,7,8,9,10,11,16,17,18,19,29,30,32,33,36,37,38)]

library(tidyverse)
df1l |> select(code_savoir_faire,libelle_savoir_faire) |> 
    distinct() |> 
    filter(libelle_savoir_faire %like% '*Psy*') #warning like is case sensitive

# code_savoir_faire                               libelle_savoir_faire
# <char>                                             <char>
#     1:              SM33                                  Neuro-psychiatrie
# 2:              SM93 Psychiatrie option psychiatrie de la personne âgée

# df1l_psy <- df1l[code_savoir_faire == "SM93",] ##### this is an error SM93 is too restrictive

eff_by_code_svf <- df1l |> group_by(code_savoir_faire,libelle_savoir_faire) |> 
        summarize(eff = n()) |> 
    as.data.frame() |> 
    adorn_totals()
    
df1l_sm42 <- df1l[code_savoir_faire == "SM42",]

df1l_who_is_nope <- df1l[code_savoir_faire == "",]
# it seems that those professionnals don't have a location where they work
# I formulate the hypotesis they are not in activity anymore


table(eff_by_code_svf$code_savoir_faire)
str(eff_by_code_svf$code_savoir_faire)
# exploring file "savoir -faires"

# we need to play with file 1 and file 3 I think at this step of the exploration process
# not sure there is more informations about specialties in file 3 than in file 1 - I must check
# I do not understand why some "savoirs faires" are empty in file 1
# I do not know if a notion of principle activity is specified somewhere in the rpps data system
# If not I have to find a mean to locate a professionnal to one of her activity place


df3 <- fread(file3)
df3 <- clean_names(df3)

names(df3)
df3[identifiant_pp == 10108173468,]

# I m almost sure the professionnals in file 1 are still students that's why they don't have a "savoir-faire"

# construire la table d'aggrégation des spécialités (ex regrouper SM42 Psychiatrie + SM43 Psychiatrie option enfant & adolescent)


# exploring duplicates in file 1

# first example 

df1_10100652055 <- df1[identifiant_pp == 10100652055,]
t_df1_10100652055 <- data.table::transpose(df1_10100652055)
colnames(t_df1_10100652055) <- rownames(df1_10100652055)
rownames(t_df1_10100652055) <- colnames(df1_10100652055)

# number max of places of activity for one professional
df1l_sm42 |> 
    group_by(identifiant_pp) |> 
    summarise(eff = n()) |> 
    arrange(desc(eff))


df1_10002738473 <- df1[identifiant_pp == 10002738473,]
t_df1_10002738473 <- data.table::transpose(df1_10002738473)
colnames(t_df1_10002738473) <- rownames(df1_10002738473)
rownames(t_df1_10002738473) <- colnames(df1_10002738473)

# this following works but it takes long time to run whereas I'm only testing
# on df1l_sm42 which is a substract of our larger database df1
df1l_first_occ <- df1l_sm42 |> group_by(identifiant_pp) |> slice(1)

# I just discovered there is a lot of professionnals who have a "savoir faire"
# but don't have a location of activity
# with some researchs by individuals (first names, last names, specialty)
# I am now pretty sure those individuals in the data base doesn't work anymore

# so I have to clean my file1
# keep only practitionneers (code profession = 10)
# keep only those with a "savoir faire"
# keep only lines in the file whose location is filled
# keep only first rows which is arbitrary

# select only physical practicionners code_profession == 10 
# retain only useful columns for our study with c(2...)
df1l <- df1[code_profession == 10,c(2,3,4,5,6,7,8,9,10,11,16,17,18,19,29,30,32,33,36,37,38)]
df1l <- df1l[code_savoir_faire != "",]
df1l <- df1l[code_postal_coord_structure != "",]


eff_by_code_svf <- df1l |> group_by(code_savoir_faire,libelle_savoir_faire) |> 
    summarize(eff = n()) |> 
    as.data.frame() |> 
    adorn_totals()

# arbitratry unicity of work location because we do not have another mean
# some data are not public
# df1l_u _u stands for unique
df1l_u <- df1l |> group_by(identifiant_pp) |> slice(1)

eff_by_code_svf_u <- df1l_u |> group_by(code_savoir_faire,libelle_savoir_faire) |> 
    summarize(eff = n()) |> 
    as.data.frame() |> 
    adorn_totals()

# description of activities is not absolutely clean
# so we're going to create a table to group some of them
library(xlsx)
write.xlsx(eff_by_code_svf_u, "../transf_data/activities_group_table.xlsx", row.names = F)
file.show("../transf_data/activities_group_table.xlsx")

file.show("../transf_data/activities_group_table_processed.xlsx")
acti_group_t <- read.xlsx2("../transf_data/activities_group_table_processed.xlsx", sheetIndex = 1)

acti_group_t <- acti_group_t[,-c(2,3)]

# r stand for recoded (ie activities recoded according to previous table)
df1l_ur <- df1l_u |> 
    left_join(acti_group_t, by = c("code_savoir_faire"="code_savoir_faire"))

eff_by_code_svf_ur <- df1l_ur |> group_by(code_savoir_faire,libelle_savoir_faire) |> 
    summarize(eff = n()) |> 
    as.data.frame() |> 
    adorn_totals()

save(df1l_ur, file = "../transf_data/df1l_ur.rda")

library(lobstr)
S3Class(df1l_ur)

# g stands for grouped
df1l_urg <-  df1l_ur |> 
    group_by(code_spe_rgpe,lib_spe_rgpe,code_commune_coord_structure,libelle_commune_coord_structure) |> 
    summarize(eff = n()) |> 
    ungroup()

sum(df1l_urg$eff) # 223455 OK



# l stands for localised
df1l_urgl <- df1l_urg |> left_join(commune_geo_l, 
                                   by = c("code_commune_coord_structure" =
                                              "INSEE_COM") )
# we have to retreat paris marseilles

# test
df1l_urg_test <-  df1l_ur |> 
    group_by(code_commune_coord_structure,libelle_commune_coord_structure) |> 
    summarize(eff = n()) |> 
    ungroup()

# Communes that does not match...
df1l_urgl_test <- df1l_urg_test|> left_join(commune_geo_l, 
                                            by = c("code_commune_coord_structure" =
                                                       "INSEE_COM") )
empty_poly <- df1l_urgl_test |> 
    filter(is.na(POPULATION))

save(df1l_urg,file = "../transf_data/df1l_urg.rda")
save(df1l_urg_test,file = "../transf_data/df1l_urg_test.rda")
save(df1l_urgl_test,file = "../transf_data/df1l_urgl_test.rda")
save(df1l_urgl,file = "../transf_data/df1l_urgl.rda")

lry <- commune_geo_l |> 
    filter(INSEE_COM == "85191")

lry_center <- st_centroid(lry)

names(commune_geo_l)
S3Class(commune_geo_l)
S3Class(lry)

st_centroid(lry)
st_point_on_surface(lry)

load("../transf_data/df1l_urg_test.rda")
load("../transf_data/df1l_urgl_test.rda")

no_matchs <- df1l_urgl_test |> filter(is.na(POPULATION))

is_it_better <- no_matchs |> left_join(comm_ass, by = c("code_commune_coord_structure"= "INSEE_COM"))

#### test with arrondissement

is_it_better <- no_matchs |> 
    left_join(arrond,by = c("code_commune_coord_structure"= "INSEE_COM"))

#### test with arrondissement municipal

is_it_better <- no_matchs |> 
    left_join(arrond_mun,by = c("code_commune_coord_structure"= "INSEE_ARM"))
# it is better!

# what is left
no_matchs2 <- is_it_better |> filter(is.na(AREA))

sum(no_matchs2$eff)
sum(df1l_urg_test$eff)
# rate of losses
sum(no_matchs2$eff)/sum(df1l_urg_test$eff)
#[1] 0.006878342



comm_nouvelles <- read.csv2("../raw_data/communes_nouvelles.csv", sep = ",")

names(comm_nouvelles)


comm_nouvelles <- clean_names(comm_nouvelles)
comm_nouvelles <- comm_nouvelles[,1:5]
comm_nouvelles <- comm_nouvelles |> 
    mutate(code_insee_commune_nouvelle = as.character(code_insee_commune_nouvelle),
           code_insee_commune_deleguee_non_actif = as.character(code_insee_commune_deleguee_non_actif)
    )

zz <- df1l_urg_test |> 
    left_join(comm_nouvelles, 
                                 by = c("code_commune_coord_structure" ="code_insee_commune_deleguee_non_actif"))
zztop <- zz |> filter(!is.na(date))


load(file = "../transf_data/df1l_urg.rda")

com_nouv_tot_histo <- read.csv2(file = "../raw_data/communes_nouvelles.csv", sep = ",")

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

names(no_match)

expl_no_matchs <- no_match |> select(code_commune_coord_structure,code_insee_commune_nouvelle,
                   libelle_commune_coord_structure) |> unique()
