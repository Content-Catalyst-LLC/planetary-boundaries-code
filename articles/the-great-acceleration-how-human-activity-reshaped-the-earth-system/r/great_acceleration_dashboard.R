# Great Acceleration dashboard
#
# This workflow scores coupled socio-economic and Earth-system acceleration across:
# socioeconomic growth, Earth-system pressure, acceleration rate, coupling strength,
# boundary pressure, governance capacity, justice capacity, mitigation capacity,
# restoration capacity, and lock-in pressure.
#
# Values are illustrative and should be replaced with documented Great Acceleration
# datasets, planetary-boundary estimates, emissions data, material-flow data,
# land-system data, governance indicators, and transparent assumptions before use.

library(readr)
library(dplyr)
library(tidyr)

acceleration_profiles <- tibble::tibble(
  indicator_pair = c(
    "energy_use_and_climate_change",
    "fertilizer_use_and_biogeochemical_flows",
    "land_conversion_and_biosphere_integrity",
    "water_use_and_freshwater_change",
    "petrochemicals_and_novel_entities",
    "transport_growth_and_aerosol_loading"
  ),
  socioeconomic_growth = c(0.92, 0.84, 0.78, 0.76, 0.88, 0.72),
  earth_system_pressure = c(0.88, 0.90, 0.92, 0.80, 0.94, 0.58),
  acceleration_rate = c(0.86, 0.82, 0.74, 0.70, 0.88, 0.62),
  coupling_strength = c(0.90, 0.88, 0.86, 0.78, 0.82, 0.60),
  boundary_pressure_ratio = c(1.28, 1.62, 1.75, 1.36, 1.80, 0.74),
  governance_capacity = c(0.52, 0.42, 0.44, 0.46, 0.34, 0.40),
  justice_capacity = c(0.40, 0.38, 0.36, 0.42, 0.34, 0.36),
  mitigation_capacity = c(0.48, 0.44, 0.42, 0.44, 0.36, 0.50),
  restoration_capacity = c(0.38, 0.46, 0.52, 0.48, 0.28, 0.42),
  lock_in_pressure = c(0.82, 0.76, 0.80, 0.66, 0.86, 0.62)
)

scored <- acceleration_profiles %>%
  mutate(
    # Human activity pressure combines growth, acceleration, and lock-in.
    human_activity_pressure =
      0.40 * socioeconomic_growth +
      0.35 * acceleration_rate +
      0.25 * lock_in_pressure,

    # Earth-system stress combines pressure and boundary status.
    earth_system_stress =
      0.55 * earth_system_pressure +
      0.45 * boundary_pressure_ratio,

    # Governance-response capacity includes governance, justice, mitigation, and restoration.
    response_capacity =
      0.30 * governance_capacity +
      0.25 * justice_capacity +
      0.25 * mitigation_capacity +
      0.20 * restoration_capacity,

    # Coupled acceleration risk rises when human activity and Earth-system stress move together.
    coupled_acceleration_risk =
      human_activity_pressure *
      earth_system_stress *
      (1 + coupling_strength) *
      (1 - 0.50 * response_capacity),

    # Transformation urgency rises when risk, lock-in, and weak justice capacity coincide.
    transformation_urgency =
      coupled_acceleration_risk *
      (1 + lock_in_pressure) *
      (1 - justice_capacity),

    risk_class = case_when(
      coupled_acceleration_risk >= 1.40 & boundary_pressure_ratio >= 1.50 ~ "system_transformation_urgent",
      boundary_pressure_ratio >= 1.00 ~ "high_boundary_pressure",
      coupled_acceleration_risk >= 0.70 ~ "rising_acceleration_risk",
      TRUE ~ "managed_transition"
    ),

    priority = case_when(
      grepl("climate", indicator_pair) ~ "decarbonize_energy_systems",
      grepl("biogeochemical", indicator_pair) ~ "reduce_nutrient_overload",
      grepl("biosphere", indicator_pair) ~ "restore_biosphere_integrity",
      grepl("freshwater", indicator_pair) ~ "build_freshwater_resilience",
      grepl("novel_entities", indicator_pair) ~ "control_synthetic_overload",
      TRUE ~ "integrated_transition_strategy"
    )
  ) %>%
  arrange(desc(coupled_acceleration_risk))

dashboard_long <- scored %>%
  select(
    indicator_pair,
    human_activity_pressure,
    earth_system_stress,
    response_capacity,
    coupled_acceleration_risk,
    transformation_urgency,
    boundary_pressure_ratio
  ) %>%
  pivot_longer(
    cols = -indicator_pair,
    names_to = "metric",
    values_to = "value"
  )

summary_by_class <- scored %>%
  group_by(risk_class) %>%
  summarise(
    indicator_pairs = n(),
    mean_human_activity_pressure = mean(human_activity_pressure),
    mean_earth_system_stress = mean(earth_system_stress),
    mean_response_capacity = mean(response_capacity),
    mean_coupled_acceleration_risk = mean(coupled_acceleration_risk),
    mean_transformation_urgency = mean(transformation_urgency),
    .groups = "drop"
  )

dir.create(
  "articles/the-great-acceleration-how-human-activity-reshaped-the-earth-system/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/the-great-acceleration-how-human-activity-reshaped-the-earth-system/outputs/r_great_acceleration_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/the-great-acceleration-how-human-activity-reshaped-the-earth-system/outputs/r_great_acceleration_dashboard_long.csv"
)

write_csv(
  summary_by_class,
  "articles/the-great-acceleration-how-human-activity-reshaped-the-earth-system/outputs/r_great_acceleration_summary.csv"
)

print(scored)
print(summary_by_class)
