# Stratospheric ozone depletion and global governance dashboard
#
# This workflow scores ozone boundary status across atmospheric and
# governance variables. Values are illustrative and should be replaced
# with documented measurements and treaty-monitoring records.

library(readr)
library(dplyr)
library(tidyr)

ozone_profiles <- tibble::tibble(
  region = c(
    "global_mean_stratosphere",
    "antarctic_spring",
    "arctic_spring",
    "mid_latutudes_northern",
    "tropical_stratosphere"
  ),
  ozone_du = c(286, 238, 292, 302, 278),
  boundary_du = c(276, 220, 276, 276, 260),
  preindustrial_reference_du = c(290, 290, 300, 305, 280),
  ods_loading_index = c(0.42, 0.58, 0.44, 0.36, 0.34),
  emissions_pressure = c(0.18, 0.16, 0.15, 0.12, 0.10),
  treaty_compliance = c(0.92, 0.90, 0.91, 0.94, 0.93),
  substitution_progress = c(0.88, 0.86, 0.87, 0.91, 0.89),
  monitoring_capacity = c(0.86, 0.88, 0.84, 0.88, 0.80),
  implementation_support = c(0.82, 0.80, 0.78, 0.82, 0.76),
  illegal_emissions_risk = c(0.08, 0.09, 0.07, 0.05, 0.06),
  atmospheric_lifetime_pressure = c(0.46, 0.62, 0.50, 0.40, 0.38)
)

scored <- ozone_profiles %>%
  mutate(
    boundary_margin = (ozone_du - boundary_du) / boundary_du,
    recovery_gap = pmax(
      0,
      (preindustrial_reference_du - ozone_du) / preindustrial_reference_du
    ),
    governance_effectiveness =
      0.30 * treaty_compliance +
      0.25 * substitution_progress +
      0.25 * monitoring_capacity +
      0.20 * implementation_support,
    residual_pressure =
      0.35 * ods_loading_index +
      0.20 * emissions_pressure +
      0.25 * atmospheric_lifetime_pressure +
      0.20 * illegal_emissions_risk,
    recovery_resilience_score =
      boundary_margin +
      governance_effectiveness -
      residual_pressure -
      recovery_gap,
    status = case_when(
      ozone_du < boundary_du ~ "depletion_zone",
      boundary_margin < 0.03 ~ "boundary_pressure_zone",
      recovery_gap > 0.10 ~ "watch_zone",
      TRUE ~ "safe_zone"
    ),
    priority = case_when(
      status == "depletion_zone" ~ "urgent_atmospheric_recovery_priority",
      recovery_gap >= 0.10 ~ "recovery_gap_priority",
      illegal_emissions_risk >= 0.08 ~ "emissions_integrity_priority",
      monitoring_capacity < 0.80 ~ "monitoring_capacity_priority",
      TRUE ~ "maintain_governance_and_monitoring"
    )
  ) %>%
  arrange(recovery_resilience_score)

dashboard_long <- scored %>%
  select(
    region,
    boundary_margin,
    recovery_gap,
    governance_effectiveness,
    residual_pressure,
    recovery_resilience_score
  ) %>%
  pivot_longer(
    cols = -region,
    names_to = "metric",
    values_to = "value"
  )

scenario_grid <- tibble::tibble(
  scenario = c(
    "baseline",
    "weakened_compliance",
    "stronger_monitoring",
    "accelerated_substitution",
    "full_integrity_governance"
  ),
  compliance_delta = c(0.00, -0.12, 0.02, 0.04, 0.06),
  monitoring_delta = c(0.00, -0.05, 0.10, 0.04, 0.12),
  substitution_delta = c(0.00, -0.05, 0.02, 0.10, 0.12),
  illegal_emissions_multiplier = c(1.00, 1.80, 0.70, 0.60, 0.40)
)

scenario_scores <- ozone_profiles %>%
  crossing(scenario_grid) %>%
  mutate(
    treaty_compliance = pmin(1, pmax(0, treaty_compliance + compliance_delta)),
    monitoring_capacity = pmin(1, pmax(0, monitoring_capacity + monitoring_delta)),
    substitution_progress = pmin(1, pmax(0, substitution_progress + substitution_delta)),
    illegal_emissions_risk = pmin(1, illegal_emissions_risk * illegal_emissions_multiplier),
    boundary_margin = (ozone_du - boundary_du) / boundary_du,
    recovery_gap = pmax(
      0,
      (preindustrial_reference_du - ozone_du) / preindustrial_reference_du
    ),
    governance_effectiveness =
      0.30 * treaty_compliance +
      0.25 * substitution_progress +
      0.25 * monitoring_capacity +
      0.20 * implementation_support,
    residual_pressure =
      0.35 * ods_loading_index +
      0.20 * emissions_pressure +
      0.25 * atmospheric_lifetime_pressure +
      0.20 * illegal_emissions_risk,
    recovery_resilience_score =
      boundary_margin +
      governance_effectiveness -
      residual_pressure -
      recovery_gap,
    status = case_when(
      ozone_du < boundary_du ~ "depletion_zone",
      boundary_margin < 0.03 ~ "boundary_pressure_zone",
      recovery_gap > 0.10 ~ "watch_zone",
      TRUE ~ "safe_zone"
    )
  ) %>%
  group_by(scenario) %>%
  mutate(rank = dense_rank(recovery_resilience_score)) %>%
  ungroup()

status_summary <- scored %>%
  group_by(status) %>%
  summarise(
    regions = n(),
    mean_boundary_margin = mean(boundary_margin),
    mean_recovery_gap = mean(recovery_gap),
    mean_governance_effectiveness = mean(governance_effectiveness),
    mean_residual_pressure = mean(residual_pressure),
    .groups = "drop"
  )

dir.create(
  "articles/stratospheric-ozone-depletion-and-global-environmental-governance/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/stratospheric-ozone-depletion-and-global-environmental-governance/outputs/r_ozone_recovery_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/stratospheric-ozone-depletion-and-global-environmental-governance/outputs/r_dashboard_long.csv"
)

write_csv(
  scenario_scores,
  "articles/stratospheric-ozone-depletion-and-global-environmental-governance/outputs/r_governance_scenarios.csv"
)

write_csv(
  status_summary,
  "articles/stratospheric-ozone-depletion-and-global-environmental-governance/outputs/r_status_summary.csv"
)

print(scored)
print(status_summary)
