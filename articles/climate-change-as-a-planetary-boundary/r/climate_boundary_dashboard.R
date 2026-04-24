# Climate change planetary-boundary dashboard
#
# This workflow scores climate-boundary risk across:
# - atmospheric CO2 concentration
# - CO2 boundary pressure
# - radiative forcing approximation
# - emissions pressure
# - mitigation capacity
# - carbon sink resilience
# - biosphere, land, freshwater, and ocean stress
# - heat and infrastructure exposure
# - adaptive, monitoring, and governance capacity
#
# Values are illustrative and should be replaced with documented atmospheric
# records, emissions inventories, climate-risk indicators, carbon-cycle data,
# and transparent assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

climate_profiles <- tibble::tibble(
  region = c(
    "high_emissions_industrial_system",
    "rapid_transition_clean_energy_system",
    "climate_vulnerable_coastal_delta",
    "forest_carbon_sink_transition_zone",
    "arid_heat_and_water_stress_region",
    "resilient_low_carbon_region"
  ),
  co2_concentration_ppm = c(429.8, 429.8, 429.8, 429.8, 429.8, 429.8),
  co2_boundary_ppm = c(350, 350, 350, 350, 350, 350),
  co2_baseline_ppm = c(280, 280, 280, 280, 280, 280),
  forcing_boundary_wm2 = c(1, 1, 1, 1, 1, 1),
  gross_emissions_pressure = c(0.92, 0.52, 0.38, 0.46, 0.44, 0.28),
  mitigation_capacity = c(0.42, 0.76, 0.36, 0.58, 0.40, 0.82),
  carbon_sink_resilience = c(0.48, 0.66, 0.42, 0.38, 0.36, 0.78),
  biosphere_stress = c(0.66, 0.48, 0.72, 0.82, 0.64, 0.36),
  land_system_pressure = c(0.58, 0.42, 0.60, 0.76, 0.52, 0.30),
  freshwater_stress = c(0.54, 0.46, 0.82, 0.58, 0.88, 0.34),
  ocean_stress = c(0.62, 0.54, 0.78, 0.42, 0.30, 0.40),
  heat_extreme_exposure = c(0.72, 0.56, 0.86, 0.70, 0.92, 0.42),
  infrastructure_exposure = c(0.78, 0.50, 0.88, 0.46, 0.72, 0.38),
  adaptive_capacity = c(0.58, 0.70, 0.34, 0.48, 0.32, 0.78),
  monitoring_capacity = c(0.74, 0.82, 0.52, 0.66, 0.50, 0.84),
  governance_capacity = c(0.52, 0.74, 0.38, 0.44, 0.36, 0.80)
)

scored <- climate_profiles %>%
  mutate(
    # CO2 pressure compares current concentration with the boundary reference.
    co2_boundary_pressure = co2_concentration_ppm / co2_boundary_ppm,

    # Radiative forcing is approximated from CO2 concentration and baseline.
    co2_radiative_forcing_wm2 =
      5.35 * log(co2_concentration_ppm / co2_baseline_ppm),

    # Forcing pressure compares calculated forcing with the boundary reference.
    forcing_boundary_pressure =
      co2_radiative_forcing_wm2 / forcing_boundary_wm2,

    # Cross-boundary stress captures climate interactions with Earth-system processes.
    cross_boundary_stress =
      0.26 * biosphere_stress +
      0.24 * land_system_pressure +
      0.22 * freshwater_stress +
      0.18 * ocean_stress +
      0.10 * (1 - carbon_sink_resilience),

    # Exposure combines heat and infrastructure vulnerability.
    exposure_pressure =
      0.55 * heat_extreme_exposure +
      0.45 * infrastructure_exposure,

    # Transition gap rises when emissions pressure is high and mitigation capacity is low.
    transition_gap =
      gross_emissions_pressure * (1 - mitigation_capacity),

    # Governance and monitoring gaps affect capacity to respond.
    adaptive_capacity_gap = 1 - adaptive_capacity,
    monitoring_gap = 1 - monitoring_capacity,
    governance_gap = 1 - governance_capacity,

    # Composite score emphasizes planetary forcing and regional/systemic vulnerability.
    climate_boundary_risk_score =
      0.24 * co2_boundary_pressure +
      0.24 * forcing_boundary_pressure +
      0.18 * cross_boundary_stress +
      0.14 * exposure_pressure +
      0.12 * transition_gap +
      0.08 * (
        0.40 * adaptive_capacity_gap +
        0.25 * monitoring_gap +
        0.35 * governance_gap
      ),

    risk_class = case_when(
      climate_boundary_risk_score < 0.95 ~ "lower_risk",
      climate_boundary_risk_score < 1.75 ~ "moderate_risk",
      climate_boundary_risk_score < 2.75 ~ "high_risk",
      TRUE ~ "severe_risk"
    ),

    priority = case_when(
      transition_gap >= 0.45 ~ "rapid_mitigation_priority",
      carbon_sink_resilience <= 0.45 ~ "carbon_sink_protection_priority",
      freshwater_stress >= 0.80 ~ "water_climate_resilience_priority",
      heat_extreme_exposure >= 0.80 ~ "heat_adaptation_priority",
      governance_capacity < 0.45 ~ "governance_capacity_priority",
      mitigation_capacity >= 0.75 ~ "transition_acceleration_priority",
      TRUE ~ "integrated_climate_resilience_priority"
    )
  ) %>%
  arrange(desc(climate_boundary_risk_score))

dashboard_long <- scored %>%
  select(
    region,
    co2_boundary_pressure,
    forcing_boundary_pressure,
    cross_boundary_stress,
    exposure_pressure,
    transition_gap,
    climate_boundary_risk_score
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
    mean_co2_boundary_pressure = mean(co2_boundary_pressure),
    mean_forcing_boundary_pressure = mean(forcing_boundary_pressure),
    mean_cross_boundary_stress = mean(cross_boundary_stress),
    mean_climate_boundary_risk_score = mean(climate_boundary_risk_score),
    .groups = "drop"
  )

dir.create(
  "articles/climate-change-as-a-planetary-boundary/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/climate-change-as-a-planetary-boundary/outputs/r_climate_boundary_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/climate-change-as-a-planetary-boundary/outputs/r_dashboard_long.csv"
)

write_csv(
  risk_summary,
  "articles/climate-change-as-a-planetary-boundary/outputs/r_risk_summary.csv"
)

print(scored)
print(risk_summary)
