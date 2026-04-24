# Holocene stability dashboard
#
# This workflow scores departure from Holocene-like conditions across:
# Holocene reference values, observed values, Holocene variability,
# boundary pressure, cross-system amplification, governance capacity,
# adaptive capacity, and development exposure.
#
# Values are illustrative and should be replaced with documented paleoclimate
# datasets, boundary estimates, scenario data, monitoring records, and
# transparent assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

holocene_indicators <- tibble::tibble(
  indicator = c(
    "global_temperature",
    "biosphere_integrity",
    "land_system_change",
    "freshwater_change",
    "biogeochemical_flows",
    "ocean_acidification"
  ),
  holocene_reference = c(0.00, 0.20, 0.25, 0.18, 0.16, 0.10),
  observed_value = c(1.20, 1.55, 1.20, 1.32, 1.60, 1.06),
  holocene_variability = c(0.35, 0.28, 0.30, 0.26, 0.32, 0.22),
  boundary_value = c(1, 1, 1, 1, 1, 1),
  interaction_weight = c(0.92, 0.96, 0.78, 0.82, 0.84, 0.66),
  governance_capacity = c(0.56, 0.44, 0.52, 0.46, 0.42, 0.50),
  adaptive_capacity = c(0.52, 0.46, 0.50, 0.48, 0.44, 0.48),
  development_exposure = c(0.88, 0.82, 0.70, 0.86, 0.76, 0.68)
)

scored <- holocene_indicators %>%
  mutate(
    # Raw anomaly relative to the Holocene reference state.
    holocene_anomaly = observed_value - holocene_reference,

    # Standardized departure expresses anomaly relative to Holocene variability.
    standardized_departure = holocene_anomaly / holocene_variability,

    # Boundary pressure shows whether the indicator exceeds its boundary reference.
    boundary_pressure_ratio = observed_value / boundary_value,

    # Capacity combines governance and adaptive capacity.
    response_capacity =
      0.55 * governance_capacity +
      0.45 * adaptive_capacity,

    # Cross-system amplification increases when a process is strongly coupled to others.
    cross_system_amplification =
      interaction_weight * mean(boundary_pressure_ratio),

    # Departure risk combines standardized departure, boundary pressure,
    # amplification, exposure, and limited response capacity.
    holocene_departure_risk =
      pmax(0, standardized_departure) *
      boundary_pressure_ratio *
      (1 + 0.25 * cross_system_amplification) *
      (1 + 0.30 * development_exposure) *
      (1 - 0.50 * response_capacity),

    risk_class = case_when(
      holocene_departure_risk < 0.50 ~ "within_reference_range",
      holocene_departure_risk < 1.00 ~ "emerging_departure",
      holocene_departure_risk < 1.50 ~ "high_departure_risk",
      TRUE ~ "systemic_transformation_risk"
    ),

    priority = case_when(
      indicator == "global_temperature" ~ "accelerated_decarbonization",
      indicator == "biosphere_integrity" ~ "biosphere_integrity_repair",
      indicator == "freshwater_change" ~ "hydrological_resilience",
      indicator == "biogeochemical_flows" ~ "nutrient_flow_reduction",
      indicator == "land_system_change" ~ "land_system_restoration",
      TRUE ~ "integrated_monitoring"
    )
  ) %>%
  arrange(desc(holocene_departure_risk))

dashboard_long <- scored %>%
  select(
    indicator,
    holocene_anomaly,
    standardized_departure,
    boundary_pressure_ratio,
    response_capacity,
    cross_system_amplification,
    holocene_departure_risk
  ) %>%
  pivot_longer(
    cols = -indicator,
    names_to = "metric",
    values_to = "value"
  )

risk_summary <- scored %>%
  group_by(risk_class) %>%
  summarise(
    indicators = n(),
    mean_standardized_departure = mean(standardized_departure),
    mean_boundary_pressure_ratio = mean(boundary_pressure_ratio),
    mean_departure_risk = mean(holocene_departure_risk),
    .groups = "drop"
  )

dir.create(
  "articles/the-holocene-stable-climate-state-that-enabled-human-civilization/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/the-holocene-stable-climate-state-that-enabled-human-civilization/outputs/r_holocene_stability_diagnostics.csv"
)

write_csv(
  dashboard_long,
  "articles/the-holocene-stable-climate-state-that-enabled-human-civilization/outputs/r_holocene_dashboard_long.csv"
)

write_csv(
  risk_summary,
  "articles/the-holocene-stable-climate-state-that-enabled-human-civilization/outputs/r_holocene_risk_summary.csv"
)

print(scored)
print(risk_summary)
