# to source file location first
# ie setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")

library(sf) # needed to work with spatial data
library(archive) # required to unzip the 7z file

# download data from RPPS "en libre accès"
link_to_the_file = "https://annuaire.sante.fr/web/site-pro/extractions-publiques?p_p_id=abonnementportlet_WAR_Inscriptionportlet_INSTANCE_gGMT6fhOPMYV&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_cacheability=cacheLevelPage&_abonnementportlet_WAR_Inscriptionportlet_INSTANCE_gGMT6fhOPMYV_nomFichier=PS_LibreAcces_202504040839.zip"


# downloading time can be long cause file is heavy so on my pc, i needed to
# extend timeout
getOption('timeout')# [1] 60
options(timeout = 300)



download.file(link_to_the_file, destfile = "../raw_data/zip_downloaded.zip")
# dont forget .zip at the end of the destfile otherwise we load a strang something
unzip("../raw_data/zip_downloaded.zip", exdir = "../raw_data/rpps_data")

# download spatial data from admin-express
# link france entière
link_fr_entier = "https://data.geopf.fr/telechargement/download/ADMIN-EXPRESS/ADMIN-EXPRESS_3-2__SHP_WGS84G_FRA_2025-02-17/ADMIN-EXPRESS_3-2__SHP_WGS84G_FRA_2025-02-17.7z"

tf <- tempfile()
td <- tempdir()
download.file(link_fr_entier, tf, mode = "wb")
archive_extract(tf, dir = "../raw_data/fr_sp_data_files")


