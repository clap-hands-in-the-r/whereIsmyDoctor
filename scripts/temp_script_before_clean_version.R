

df1l_sm42 <- df1l[code_savoir_faire == "SM42",]

df1l_sm42 |> names()
# remove practitionnes with no locations - after some research it seams to pretend they don"t practice anymore

df1l_sm42 <- df1l_sm42 |> filter(code_commune_coord_structure!= "")





# arbitratry unicity of work location because we do not have another mean
# some data are not public
# df1l_u _u stands for unique
df1l_sm42_u <- df1l_sm42 |> group_by(identifiant_pp) |> slice(1)

df1l_sm42_u  <- df1l_sm42_u |> mutate(dpt = str_sub(code_commune_coord_structure,1,2))
df1l_sm42_u |> select(dpt) |> head()
df1l_sm42_u |> select(dpt) |> tail()

df1l_sm42_u_gp <- df1l_sm42_u |> 
    group_by(dpt) |> 
    summarize(eff = n())

psy <- df1l_sm42_u_gp |> 
    left_join(dep_pop, by = c("dpt"="INSEE_DEP"))

psy_eff_to_pop <- psy |> 
    mutate(eff_to_pop =
               eff/pop * 100000)


psy_eff_to_pop_loc <- psy_eff_to_pop |> 
    ungroup() |> 
    left_join(dpt_lght, by = c("dpt"="INSEE_DEP"))
obj_size(psy_eff_to_pop_loc)



psy_eff_to_pop_loc <- psy_eff_to_pop_loc |> 
    mutate(deciles_gp=
               as.factor(
                   ntile(eff_to_pop,10)
               ))

sum(df1l_sm42_u_gp$eff) # [1] 14759 OK

############## one version
df1l_urgec <- df1l_urge |> 
    mutate(code_insee_commune_nouvelle =
               ifelse(is.na(code_insee_commune_nouvelle),
                      code_commune_coord_structure,
                      code_insee_commune_nouvelle)
    )

df1l_urgec <- df1l_urge |> 
    mutate(CODGEO_2025 =
               ifelse(is.na(CODGEO_2025),
                      code_commune_coord_structure,
                      CODGEO_2025),
           LIBGEO_2025 =
               ifelse(is.na(LIBGEO_2025),
                      libelle_commune_coord_structure,
                      LIBGEO_2025)
    )


df1l_urgecl <- df1l_urgec |> left_join(commune_et_arrond_l, 
                                       by = c("CODGEO_2025" =
                                                  "INSEE_COM") )
df1l_urgecl_sub_psy <- df1l_urgecl |> filter(code_spe_rgpe == "SM42r")
loc_datas_lght <- df1l_urgecl_sub_psy |> 
    select(1:2,5:8,11:12)


