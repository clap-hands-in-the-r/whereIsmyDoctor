#used to group certain specialties

write.xlsx(eff_by_code_svf_u, "../transf_data/activities_group_table.xlsx", row.names = F)
file.show("../transf_data/activities_group_table.xlsx")

file.show("../transf_data/activities_group_table_processed.xlsx")
acti_group_t <- read.xlsx2("../transf_data/activities_group_table_processed.xlsx", sheetIndex = 1)

acti_group_t <- acti_group_t[,-c(2,3)]