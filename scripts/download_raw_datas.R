# to source file location first
# ie setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")

link_to_the_file = "https://annuaire.sante.fr/web/site-pro/extractions-publiques?p_p_id=abonnementportlet_WAR_Inscriptionportlet_INSTANCE_gGMT6fhOPMYV&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_cacheability=cacheLevelPage&_abonnementportlet_WAR_Inscriptionportlet_INSTANCE_gGMT6fhOPMYV_nomFichier=PS_LibreAcces_202504040839.zip"


# downloading time can be long cause file is heavy so on my pc, i needed to
# extend timeout
getOption('timeout')# [1] 60
options(timeout = 100)



download.file(link_to_the_file, destfile = "../raw_data/le_zip_telecharge.zip")
# dont forget .zip at the end of the destfile otherwise we load a strang something
unzip("../raw_data/le_zip_telecharge.zip", exdir = "../raw_data/")

