# to source file or
# setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")

list.files("../raw_data/")


dat <- readLines("../raw_data/PS_LibreAcces_Personne_activite_202504040839.txt", n = 3)
?readLines


library(data.table)

file1 <- "../raw_data/PS_LibreAcces_Personne_activite_202504040839.txt"
ex1 <- fread(file1,nrows = 2)

file2 <- "../raw_data/PS_LibreAcces_Dipl_AutExerc_202504040839.txt"
ex2 <- fread(file2,nrows = 2)

file3 <- "../raw_data/PS_LibreAcces_SavoirFaire_202504040839.txt"
ex3 <- fread(file3,nrows = 2)



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
# Code postal (coord. structure) : 56000
# Code commune (coord. structure) : 56260
# Libellé commune (coord. structure) : Vannes
# Code mode exercice : S
# Libellé mode exercice : Salarié


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