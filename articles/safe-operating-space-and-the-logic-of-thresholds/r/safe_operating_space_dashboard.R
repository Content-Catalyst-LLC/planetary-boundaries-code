# Safe operating space and threshold-risk dashboard
#
# This workflow scores planetary-boundary risk across observed pressure,
# boundary values, uncertainty margins, pressure ratios, risk zones,
# cross-boundary amplification, monitoring capacity, governance capacity,
# and reversibility capacity.
#
# Values are illustrative and should be replaced with documented control
# variables, boundary estimates, uncertainty ranges, monitoring records,
# and transparent assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

boundary_profiles <- tibble::tibble(
  boundary = c(
    "climate_change",
    "biosphere_integrity",
    "land_system_change",
    "freshwater_change",
    "biogeochemical_flows",
    "ocean_acidification",
    "novel_entities",
    "atmospheric_aerosols",
    "stratospheric_ozone"
  ),
  observed_value = c(1.28, 1.75, 1.22, 1.36, 1.62, 1.08, 1.80, 0.74, 0.42),
  boundary_value = c(1, 1, 1, 1, 1, 1, 1, 1, 1),
  uncertainty_band = c(0.10, 0.18, 0.14, 0.16, 0.20, 0.12, 0.28, 0.22, 0.12),
  annual_pressure_trend = c(0.020, 0.030, 0.018, 0.022, 0.026, 0.016, 0.032, 0.006, -0.004),
  monitoring_capacity = c(0.82, 0.60, 0.72, 0.66, 0.70, 0.76, 0.48, 0.54, 0.88),
  governance_capacity = c(0.56, 0.44, 0.52, 0.46, 0.42, 0.50, 0.34, 0.40, 0.82),
  reversibility_capacity = c(0.42, 0.30, 0.44, 0.38, 0.36, 0.34, 0.22, 0.46, 0.76),
  interaction_weight = c(0.92, 0.96, 0.78, 0.82, 0.84, 0.66, 0.74, 0.58, 0.36)
)

logistic_risk <- function(pressure_ratio, steepness = 8) {
  # Convert a pressure ratio into a smooth risk score.
  1 / (1 + exp(-steepness * (pressure_ratio - 1)))
}

scored <- boundary_profiles %>%
  mutate(
    # Boundary pressure ratio shows distance from the boundary.
    boundary_pressure_ratio = observed_value / boundary_value,

    # Uncertainty margin shows how much buffer remains relative to uncertainty.
    uncertainty_margin = (boundary_value - observed_value) / uncertainty_band,

    # Risk score rises smoothly near and beyond the boundary.
    threshold_risk_score = logistic_risk(boundary_pressure_ratio, steepness = 8),

    # Risk zones use explicit categorical logic for interpretation.
    risk_zone = case_when(
      boundary_pressure_ratio < 0.80 ~ "safe_zone",
      boundary_pressure_ratio < 1.00 ~ "increasing_risk_zone",
      TRUE ~ "high_risk_zone"
    ),

    # Trend pressure rises when pressure is worsening.
    trend_pressure = pmax(0, annual_pressure_trend),

    # Weak monitoring, governance, and reversibility increase practical risk.
    monitoring_gap = 1 - monitoring_capacity,
    governance_gap = 1 - governance_capacity,
    reversibility_gap = 1 - reversibility_capacity,

    # Cross-boundary amplification approximates interaction with other stressed systems.
    cross_boundary_amplification =
      interaction_weight * mean(threshold_risk_score),

    # Composite systemic threshold risk combines proximity, amplification, trend, and capacity gaps.
    systemic_threshold_risk =
      threshold_risk_score *
      (1 + cross_boundary_amplification) *
      (
        1 +
        0.25 * monitoring_gap +
        0.35 * governance_gap +
        0.25 * reversibility_gap +
        0.15 * trend_pressure
      ),

    response_urgency = case_when(
      boundary_pressure_ratio >= 1.50 ~ "immediate_systemic_response",
      boundary_pressure_ratio >= 1.00 ~ "boundary_transgression_response",
      boundary_pressure_ratio >= 0.80 ~ "precautionary_buffer_response",
      annual_pressure_trend > 0.01 ~ "trend_reversal_response",
      TRUE ~ "maintain_monitoring_and_resilience"
    )
  ) %>%
  arrange(desc(systemic_threshold_risk))

dashboard_long <- scored %>%
  select(
    boundary,
    boundary_pressure_ratio,
    uncertainty_margin,
    threshold_risk_score,
    cross_boundary_amplification,
    systemic_threshold_risk
  ) %>%
  pivot_longer(
    cols = -boundary,
    names_to = "metric",
    values_to = "value"
  )

risk_summary <- scored %>%
  group_by(risk_zone) %>%
  summarise(
    boundaries = n(),
    mean_boundary_pressure_ratio = mean(boundary_pressure_ratio),
    mean_threshold_risk_score = mean(threshold_risk_score),
    mean_systemic_threshold_risk = mean(systemic_threshold_risk),
    .groups = "drop"
  )

dir.create(
  "articles/safe-operating-space-and-the-logic-of-thresholds/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/safe-operating-space-and-the-logic-of-thresholds/outputs/r_safe_operating_space_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/safe-operating-space-and-the-logic-of-thresholds/outputs/r_dashboard_long.csv"
)

write_csv(
  risk_summary,
  "articles/safe-operating-space-and-the-logic-of-thresholds/outputs/r_risk_summary.csv"
)

print(scored)
print(risk_summary)
