# to source file location first
# ie setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")

link_to_the_file = "https://annuaire.sante.fr/web/site-pro/extractions-publiques?p_p_id=abonnementportlet_WAR_Inscriptionportlet_INSTANCE_gGMT6fhOPMYV&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_cacheability=cacheLevelPage&_abonnementportlet_WAR_Inscriptionportlet_INSTANCE_gGMT6fhOPMYV_nomFichier=PS_LibreAcces_202504040839.zip"


# downloading time can be long cause file is heavy so on my pc, i needed to
# extend timeout
getOption('timeout')# [1] 60
options(timeout = 300)



download.file(link_to_the_file, destfile = "../raw_data/le_zip_telecharge.zip")
# dont forget .zip at the end of the destfile otherwise we load a strang something
unzip("../raw_data/le_zip_telecharge.zip", exdir = "../raw_data/")


library(sf)


link_to_geo_datas <- "https://data.geopf.fr/telechargement/download/ADMIN-EXPRESS/ADMIN-EXPRESS_3-2__SHP_WGS84G_FRA_2025-02-17/ADMIN-EXPRESS_3-2__SHP_WGS84G_FRA_2025-02-17.7z"

download.file(link_to_geo_datas, destfile = "../raw_data/france_entiere.7z")
# archive_extract("../raw_data/france_entiere.7z", dir = "../raw_data/")
# 
# #install.packages("archive")
# library(archive)
# a <- system.file(package = "archive", "extdata", "../raw_data/france_entiere.7z")
# d <- tempfile()
# archive_extract(a, dir = "../raw_data/")
