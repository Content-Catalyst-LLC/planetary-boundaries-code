# Planetary-boundary measurement dashboard
#
# This workflow models how boundary processes are measured through
# control variables, observed values, boundary values, uncertainty,
# monitoring capacity, and risk-zone classification.

library(readr)
library(dplyr)
library(tidyr)

boundary_measurements <- tibble::tibble(
  boundary_process = c(
    "climate_change",
    "biosphere_integrity",
    "freshwater_change",
    "land_system_change",
    "biogeochemical_flows",
    "ocean_acidification",
    "novel_entities",
    "atmospheric_aerosol_loading",
    "stratospheric_ozone_depletion"
  ),
  control_variable = c(
    "atmospheric_co2_and_energy_imbalance_proxy",
    "functional_integrity_proxy",
    "streamflow_and_root_zone_soil_moisture_proxy",
    "forest_cover_and_biome_integrity_proxy",
    "nitrogen_and_phosphorus_perturbation_proxy",
    "carbonate_saturation_proxy",
    "production_release_and_assessment_gap_proxy",
    "regional_aerosol_optical_depth_proxy",
    "stratospheric_ozone_concentration_proxy"
  ),
  observed_value = c(1.42, 1.70, 1.28, 1.24, 1.85, 0.92, 1.65, 0.95, 0.72),
  boundary_value = c(1, 1, 1, 1, 1, 1, 1, 1, 1),
  high_risk_value = c(1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5),
  observation_uncertainty = c(0.05, 0.15, 0.12, 0.10, 0.10, 0.08, 0.25, 0.22, 0.05),
  boundary_uncertainty = c(0.10, 0.22, 0.18, 0.16, 0.14, 0.12, 0.30, 0.28, 0.08),
  monitoring_capacity = c(0.85, 0.55, 0.62, 0.66, 0.58, 0.70, 0.38, 0.48, 0.82)
)

scored <- boundary_measurements %>%
  mutate(
    pressure_ratio = observed_value / boundary_value,
    high_risk_ratio = high_risk_value / boundary_value,
    combined_uncertainty = observation_uncertainty + boundary_uncertainty,
    uncertainty_adjusted_pressure = pressure_ratio * (1 + combined_uncertainty),
    monitoring_gap = 1 - monitoring_capacity,
    measurement_risk_score = uncertainty_adjusted_pressure * (1 + monitoring_gap),
    risk_zone = case_when(
      pressure_ratio < 1 ~ "safe_zone",
      pressure_ratio < high_risk_ratio ~ "zone_of_increasing_risk",
      TRUE ~ "high_risk_zone"
    ),
    measurement_priority = case_when(
      risk_zone == "high_risk_zone" ~ "high_pressure_priority",
      combined_uncertainty >= 0.45 ~ "uncertainty_priority",
      monitoring_gap >= 0.50 ~ "monitoring_priority",
      TRUE ~ "standard_tracking"
    )
  ) %>%
  arrange(desc(measurement_risk_score))

dashboard_long <- scored %>%
  select(
    boundary_process,
    pressure_ratio,
    combined_uncertainty,
    monitoring_capacity,
    measurement_risk_score
  ) %>%
  pivot_longer(
    cols = -boundary_process,
    names_to = "metric",
    values_to = "value"
  )

risk_zone_summary <- scored %>%
  group_by(risk_zone) %>%
  summarise(
    boundaries = n(),
    mean_pressure_ratio = mean(pressure_ratio),
    mean_combined_uncertainty = mean(combined_uncertainty),
    mean_monitoring_capacity = mean(monitoring_capacity),
    mean_measurement_risk_score = mean(measurement_risk_score),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_measurement_risk_score))

dir.create(
  "articles/how-planetary-boundaries-are-measured/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/how-planetary-boundaries-are-measured/outputs/r_boundary_measurement_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/how-planetary-boundaries-are-measured/outputs/r_dashboard_long.csv"
)

write_csv(
  risk_zone_summary,
  "articles/how-planetary-boundaries-are-measured/outputs/r_risk_zone_summary.csv"
)

print(scored)
