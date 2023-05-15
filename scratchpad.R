# set a seed in case we use any random items
set.seed(1337)


# Set the names of the packages and libraries you want to install
required_libraries <- c("dplyr")

# Install missing packages and load all required libraries
for (lib in required_libraries) {
  if (!requireNamespace(lib, quietly = TRUE)) {
    install.packages(lib)
  }
  library(lib, character.only = TRUE)
}


if(file.exists("Objects/nibrs_trimmed.rds")) {
  
  nibrs_trimmed <- readRDS("Objects/nibrs_trimmed.rds")
  
} else {
  
  victim <- readRDS("Objects/nibrs_victim_segment_2021.rds")
  offender <- readRDS("Objects/nibrs_offender_segment_2021.rds")
  offense <- readRDS("Objects/nibrs_offense_segment_2021.rds")
  
  
  nibrs_full <- inner_join(offender, offense, by = "unique_incident_id", relationship = "many-to-many") %>%
    inner_join(victim, by = "unique_incident_id", relationship = "many-to-many")
  
  saveRDS(nibrs_full, "Objects/nibrs_full.rds")
  
  # Selecting specific columns from the original dataframe
  selected_cols <- c("ucr_offense_code", "year", "state", "state_abb", 
                     "incident_date", "age_of_offender", "sex_of_offender", 
                     "race_of_offender", "ethnicity_of_offender", 
                     "offense_attempted_or_completed",
                     "type_criminal_activity_1", "type_criminal_activity_2",
                     "type_criminal_activity_3", "type_weapon_force_involved_1",
                     "automatic_weapon_indicator_1", 
                     "type_weapon_force_involved_2", 
                     "automatic_weapon_indicator_2",
                     "type_weapon_force_involved_3",
                     "automatic_weapon_indicator_3",
                     "type_of_victim", "bias_motivation", "age_of_victim", 
                     "sex_of_victim", "race_of_victim", "ethnicity_of_victim"
  )
  
  nibrs_trimmed <- select(nibrs_full, all_of(selected_cols))
  
  saveRDS(nibrs_trimmed, "Objects/nibrs_trimmed.rds")
  
}


# Filter rows containing homicides and select necessary columns
homicides_data <- nibrs_trimmed %>%
  filter(grepl("murder", ucr_offense_code, ignore.case = TRUE)) %>%
  select(race_of_offender, race_of_victim)

# Count homicides for each combination of offender and victim race
homicides_count <- homicides_data %>%
  group_by(race_of_offender, race_of_victim) %>%
  summarise(total_homicides = n())

# Display the result
print(homicides_count, n = Inf)

unique(nibrs_trimmed$ucr_offense_code)
