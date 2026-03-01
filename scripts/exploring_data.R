library(ggplot2)
library(dplyr)
#setwd("ggplot2#setwd("C:/Users/maele/projects/whereIsmyDoctor/scripts")


load(file = "../processed_data/all_doc2.Rda")
load(file = "../processed_data/eff_by_spe.Rda")


eff_by_spe <- all_doc2 |> 
    st_drop_geometry() |> 
    group_by(specialite) |> 
    summarise(eff = sum(eff)) |> 
    arrange(desc(eff))


ggplot(eff_by_spe, aes(x = specialite, y = eff)) +
    geom_bar(stat = "identity")

eff_by_spe


expl_sm26 <- df1[df1$"Code savoir-faire"=='SM26',]
expl_sm53 <- df1[df1$"Code savoir-faire"=='SM53',]


level_order <- eff_by_spe |> 
    select(specialite) |> 
    pull(1)

eff_by_spe <- eff_by_spe |> 
    mutate(specialite = factor(specialite, level = level_order))

eff_by_spe2 <- eff_by_spe |> 
    


ggplot(data = eff_by_spe, aes(x = specialite, y = eff)) +
    geom_bar(stat = 'identity')+
    theme(axis.text.x = element_text(
        angle = 60,vjust = 1, hjust =1
    ))


