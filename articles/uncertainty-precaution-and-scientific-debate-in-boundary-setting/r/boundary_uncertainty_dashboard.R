# Boundary uncertainty and precaution dashboard
#
# This workflow scores planetary-boundary processes across observed pressure,
# estimated thresholds, uncertainty, precautionary margins, governance capacity,
# and risk-zone classification.

library(readr)
library(dplyr)
library(tidyr)

boundary_data <- tibble::tibble(
  boundary = c(
    "climate_change",
    "biosphere_integrity",
    "freshwater_change",
    "land_system_change",
    "biogeochemical_flows",
    "ocean_acidification",
    "novel_entities",
    "atmospheric_aerosols",
    "stratospheric_ozone"
  ),
  observed_pressure = c(1.42, 1.80, 1.22, 1.28, 1.70, 0.92, 1.60, 0.88, 0.72),
  estimated_threshold = c(1.20, 1.15, 1.10, 1.10, 1.20, 1.10, 1.05, 1.00, 1.10),
  threshold_uncertainty = c(0.12, 0.20, 0.18, 0.15, 0.16, 0.10, 0.30, 0.28, 0.08),
  precaution_factor = c(1.0, 1.2, 1.1, 1.0, 1.1, 1.0, 1.3, 1.2, 1.0),
  governance_capacity = c(0.68, 0.46, 0.52, 0.50, 0.42, 0.60, 0.34, 0.38, 0.74),
  weight = c(1.4, 1.5, 1.1, 1.0, 1.2, 1.0, 1.3, 0.9, 0.8)
)

scored <- boundary_data %>%
  mutate(
    precautionary_boundary = estimated_threshold -
      precaution_factor * threshold_uncertainty,
    pressure_ratio = observed_pressure / precautionary_boundary,
    uncertainty_adjusted_pressure = pressure_ratio * (1 + threshold_uncertainty),
    governance_gap = 1 - governance_capacity,
    governance_adjusted_risk = uncertainty_adjusted_pressure *
      governance_gap *
      weight,
    risk_zone = case_when(
      pressure_ratio < 1.0 ~ "safe_zone",
      pressure_ratio < 1.5 ~ "zone_of_increasing_risk",
      TRUE ~ "high_risk_zone"
    ),
    dominant_issue = case_when(
      pressure_ratio >= 1.5 ~ "high_pressure",
      threshold_uncertainty >= 0.25 ~ "high_uncertainty",
      governance_gap >= 0.60 ~ "low_governance_capacity",
      TRUE ~ "mixed_or_moderate_risk"
    )
  ) %>%
  arrange(desc(governance_adjusted_risk))

dashboard_long <- scored %>%
  select(
    boundary,
    observed_pressure,
    estimated_threshold,
    threshold_uncertainty,
    precautionary_boundary,
    pressure_ratio,
    governance_capacity,
    governance_adjusted_risk
  ) %>%
  pivot_longer(
    cols = -boundary,
    names_to = "metric",
    values_to = "value"
  )

precaution_scenarios <- tibble::tibble(
  scenario = c(
    "lower_precaution",
    "baseline_precaution",
    "higher_precaution",
    "strong_precaution"
  ),
  precaution_multiplier = c(0.75, 1.00, 1.25, 1.50)
)

sensitivity <- boundary_data %>%
  crossing(precaution_scenarios) %>%
  mutate(
    scenario_precaution_factor = precaution_factor * precaution_multiplier,
    precautionary_boundary = estimated_threshold -
      scenario_precaution_factor * threshold_uncertainty,
    pressure_ratio = observed_pressure / precautionary_boundary,
    uncertainty_adjusted_pressure = pressure_ratio * (1 + threshold_uncertainty),
    governance_gap = 1 - governance_capacity,
    governance_adjusted_risk = uncertainty_adjusted_pressure *
      governance_gap *
      weight,
    risk_zone = case_when(
      pressure_ratio < 1.0 ~ "safe_zone",
      pressure_ratio < 1.5 ~ "zone_of_increasing_risk",
      TRUE ~ "high_risk_zone"
    )
  ) %>%
  group_by(scenario) %>%
  mutate(rank = dense_rank(desc(governance_adjusted_risk))) %>%
  ungroup()

risk_zone_summary <- scored %>%
  group_by(risk_zone) %>%
  summarise(
    count = n(),
    mean_governance_adjusted_risk = mean(governance_adjusted_risk),
    mean_threshold_uncertainty = mean(threshold_uncertainty),
    .groups = "drop"
  )

dir.create(
  "articles/uncertainty-precaution-and-scientific-debate-in-boundary-setting/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/uncertainty-precaution-and-scientific-debate-in-boundary-setting/outputs/r_boundary_uncertainty_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/uncertainty-precaution-and-scientific-debate-in-boundary-setting/outputs/r_dashboard_long.csv"
)

write_csv(
  sensitivity,
  "articles/uncertainty-precaution-and-scientific-debate-in-boundary-setting/outputs/r_precaution_sensitivity.csv"
)

write_csv(
  risk_zone_summary,
  "articles/uncertainty-precaution-and-scientific-debate-in-boundary-setting/outputs/r_risk_zone_summary.csv"
)

print(scored)
