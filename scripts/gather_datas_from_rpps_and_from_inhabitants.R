

load(file = "../processed_data/df1l_neuro_gp.rda")
load(file = "../processed_data/dep_pop.rda")
load(file = "../processed_data/dpt_shp.rda")


neuro <- df1l_neuro_gp |> 
    left_join(dep_pop, by = c("dpt"="INSEE_DEP"))

# adding effectif to pop ratio
neuro <- neuro |> 
    mutate(eff_to_pop =
               eff/pop * 100000)

# grouping datas with shapes of dpts
neuro <- neuro |> 
    ungroup() |> 
    left_join(dpt_shp, by = c("dpt"="INSEE_DEP"))
library(lobstr)
obj_size(neuro) # 718.22 kB

# names(neuro)
neuro <- janitor::clean_names(neuro)
neuro <- neuro |> 
    rename(lib_dpt = nom)

# exploring data
neuro |> head()

# get rid of fields - columns we don't need in the datas


neuro <- neuro |> 
    mutate(deciles_gp=
               as.factor(
                   ntile(eff_to_pop,10)
               ))



quantile(neuro$eff_to_pop, probs = seq(0.1,1, by = 0.1))
# exploring quantiles
# 10%       20%       30%       40%       50%       60%       70%       80%       90% 
# 1.604671  1.921576  2.524885  2.768666  3.331619  4.015331  5.031104  5.926763  6.430470 
# 100% 
# 21.289631

save(neuro, file = "../processed_data/neuro.Rda")
load(file = "../processed_data/neuro.Rda")

# second version dividing population in two
neuro2 <- neuro |> 
    mutate(deciles_gp=
               as.factor(
                   ntile(eff_to_pop,2)
               ))
