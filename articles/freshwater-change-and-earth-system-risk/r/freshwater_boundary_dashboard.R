# Freshwater change and hydrological risk dashboard
#
# This workflow scores freshwater change across blue-water streamflow deviation,
# green-water soil-moisture deviation, groundwater stress, wetland buffering,
# ecological sensitivity, exposure, monitoring capacity, governance capacity,
# and adaptive capacity.

library(readr)
library(dplyr)
library(tidyr)

freshwater_profiles <- tibble::tibble(
  region = c(
    "semi_arid_irrigation_basin",
    "deforested_tropical_watershed",
    "groundwater_depletion_plain",
    "urban_flood_hardscape_region",
    "wetland_restoration_landscape",
    "snowmelt_dependent_mountain_basin",
    "monsoon_variability_delta"
  ),
  streamflow_current = c(0.68, 1.24, 0.72, 1.38, 0.96, 0.84, 1.30),
  streamflow_baseline = c(1, 1, 1, 1, 1, 1, 1),
  soil_moisture_current = c(0.62, 0.70, 0.76, 0.82, 0.94, 0.78, 0.74),
  soil_moisture_baseline = c(1, 1, 1, 1, 1, 1, 1),
  groundwater_stress = c(0.82, 0.42, 0.90, 0.38, 0.28, 0.46, 0.58),
  wetland_buffer_capacity = c(0.28, 0.34, 0.22, 0.18, 0.76, 0.44, 0.30),
  ecological_sensitivity = c(0.78, 0.84, 0.70, 0.66, 0.48, 0.76, 0.82),
  exposed_population_index = c(0.72, 0.68, 0.82, 0.88, 0.42, 0.64, 0.90),
  food_system_dependence = c(0.86, 0.72, 0.88, 0.54, 0.46, 0.80, 0.84),
  monitoring_capacity = c(0.52, 0.48, 0.56, 0.60, 0.72, 0.58, 0.50),
  governance_capacity = c(0.40, 0.36, 0.34, 0.42, 0.66, 0.46, 0.38),
  adaptive_capacity = c(0.38, 0.34, 0.32, 0.40, 0.68, 0.42, 0.36)
)

scored <- freshwater_profiles %>%
  mutate(
    # Blue-water deviation measures streamflow departure from baseline.
    blue_water_deviation =
      (streamflow_current - streamflow_baseline) / streamflow_baseline,

    # Green-water deviation measures root-zone soil-moisture departure from baseline.
    green_water_deviation =
      (soil_moisture_current - soil_moisture_baseline) / soil_moisture_baseline,

    # Both wet and dry deviations can destabilize systems.
    absolute_blue_pressure = abs(blue_water_deviation),
    absolute_green_pressure = abs(green_water_deviation),

    # Boundary pressure combines flow deviation, soil-moisture deviation, and groundwater stress.
    hydrological_boundary_pressure =
      0.38 * absolute_blue_pressure +
      0.42 * absolute_green_pressure +
      0.20 * groundwater_stress,

    # Exposure combines people and food-system dependence.
    social_ecological_exposure =
      0.50 * exposed_population_index +
      0.50 * food_system_dependence,

    # Natural buffers, monitoring, governance, and adaptation reduce risk.
    buffer_gap = 1 - wetland_buffer_capacity,
    monitoring_gap = 1 - monitoring_capacity,
    governance_gap = 1 - governance_capacity,
    adaptive_capacity_gap = 1 - adaptive_capacity,

    freshwater_system_risk_score =
      hydrological_boundary_pressure *
      ecological_sensitivity *
      social_ecological_exposure *
      (
        1 +
        0.25 * buffer_gap +
        0.25 * monitoring_gap +
        0.30 * governance_gap +
        0.20 * adaptive_capacity_gap
      ),

    risk_class = case_when(
      freshwater_system_risk_score < 0.55 ~ "lower_risk",
      freshwater_system_risk_score < 1.10 ~ "moderate_risk",
      freshwater_system_risk_score < 1.80 ~ "high_risk",
      TRUE ~ "severe_risk"
    ),

    priority = case_when(
      groundwater_stress >= 0.80 ~ "groundwater_depletion_priority",
      absolute_green_pressure >= 0.30 ~ "green_water_soil_moisture_priority",
      absolute_blue_pressure >= 0.30 ~ "blue_water_flow_regime_priority",
      wetland_buffer_capacity <= 0.30 ~ "wetland_and_natural_buffer_priority",
      governance_capacity < 0.40 ~ "governance_capacity_priority",
      TRUE ~ "integrated_hydrological_resilience_priority"
    )
  ) %>%
  arrange(desc(freshwater_system_risk_score))

dashboard_long <- scored %>%
  select(
    region,
    blue_water_deviation,
    green_water_deviation,
    groundwater_stress,
    hydrological_boundary_pressure,
    freshwater_system_risk_score
  ) %>%
  pivot_longer(
    cols = -region,
    names_to = "metric",
    values_to = "value"
  )

risk_summary <- scored %>%
  group_by(risk_class) %>%
  summarise(
    regions = n(),
    mean_blue_water_deviation = mean(blue_water_deviation),
    mean_green_water_deviation = mean(green_water_deviation),
    mean_groundwater_stress = mean(groundwater_stress),
    mean_freshwater_system_risk_score = mean(freshwater_system_risk_score),
    .groups = "drop"
  )

dir.create(
  "articles/freshwater-change-and-earth-system-risk/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/freshwater-change-and-earth-system-risk/outputs/r_freshwater_change_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/freshwater-change-and-earth-system-risk/outputs/r_dashboard_long.csv"
)

write_csv(
  risk_summary,
  "articles/freshwater-change-and-earth-system-risk/outputs/r_risk_summary.csv"
)

print(scored)
print(risk_summary)
