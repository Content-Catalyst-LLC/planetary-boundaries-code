# Biogeochemical flows boundary dashboard
#
# This workflow scores nitrogen and phosphorus risk across:
# - nutrient inputs
# - crop or biological uptake
# - nutrient-use efficiency
# - nutrient surplus
# - boundary pressure
# - runoff sensitivity
# - hydrological connectivity
# - ecosystem sensitivity
# - legacy nutrient pressure
# - monitoring and governance capacity
#
# Values are illustrative and should be replaced with documented
# fertilizer records, manure estimates, crop uptake data, watershed
# monitoring data, and transparent assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

nutrient_profiles <- tibble::tibble(
  region = c(
    "intensive_maize_soy_basin",
    "livestock_manure_concentration_zone",
    "eutrophic_lake_watershed",
    "coastal_dead_zone_drainage",
    "phosphorus_limited_smallholder_region",
    "urban_wastewater_nutrient_corridor",
    "restored_wetland_buffer_landscape"
  ),
  nitrogen_input = c(1.45, 1.32, 1.10, 1.56, 0.62, 0.92, 0.82),
  nitrogen_uptake = c(0.82, 0.64, 0.70, 0.86, 0.54, 0.44, 0.66),
  phosphorus_input = c(1.25, 1.48, 1.35, 1.40, 0.48, 1.05, 0.78),
  phosphorus_uptake = c(0.58, 0.52, 0.48, 0.62, 0.42, 0.38, 0.58),
  nitrogen_boundary_reference = c(1, 1, 1, 1, 1, 1, 1),
  phosphorus_boundary_reference = c(1, 1, 1, 1, 1, 1, 1),
  runoff_sensitivity = c(0.74, 0.70, 0.82, 0.78, 0.34, 0.68, 0.36),
  hydrological_connectivity = c(0.82, 0.76, 0.88, 0.92, 0.40, 0.80, 0.48),
  ecosystem_sensitivity = c(0.78, 0.72, 0.86, 0.84, 0.52, 0.76, 0.46),
  legacy_nutrient_pressure = c(0.62, 0.70, 0.76, 0.68, 0.24, 0.58, 0.30),
  monitoring_capacity = c(0.58, 0.50, 0.62, 0.66, 0.36, 0.54, 0.74),
  governance_capacity = c(0.46, 0.38, 0.42, 0.44, 0.34, 0.40, 0.68)
)

scored <- nutrient_profiles %>%
  mutate(
    # Surplus indicates nutrients not productively retained.
    nitrogen_surplus = nitrogen_input - nitrogen_uptake,
    phosphorus_surplus = phosphorus_input - phosphorus_uptake,

    # Nutrient-use efficiency distinguishes productive use from leakage.
    nitrogen_use_efficiency = nitrogen_uptake / nitrogen_input,
    phosphorus_use_efficiency = phosphorus_uptake / phosphorus_input,

    # Boundary pressure compares nutrient flow to the selected reference.
    nitrogen_boundary_pressure =
      nitrogen_input / nitrogen_boundary_reference,
    phosphorus_boundary_pressure =
      phosphorus_input / phosphorus_boundary_reference,

    # Loss pressure combines surplus with runoff and hydrological connectivity.
    nutrient_loss_pressure =
      (
        0.50 * pmax(0, nitrogen_surplus) +
        0.50 * pmax(0, phosphorus_surplus)
      ) *
      (
        0.50 * runoff_sensitivity +
        0.50 * hydrological_connectivity
      ),

    # Eutrophication pressure links boundary pressure to ecosystem sensitivity.
    eutrophication_pressure =
      (
        0.35 * nitrogen_boundary_pressure +
        0.35 * phosphorus_boundary_pressure +
        0.30 * nutrient_loss_pressure
      ) *
      ecosystem_sensitivity,

    # Legacy nutrients can continue to drive risk after application changes.
    legacy_adjusted_pressure =
      eutrophication_pressure * (1 + legacy_nutrient_pressure),

    # Weak monitoring and governance increase systemic risk.
    monitoring_gap = 1 - monitoring_capacity,
    governance_gap = 1 - governance_capacity,

    planetary_nutrient_risk_score =
      legacy_adjusted_pressure *
      (1 + 0.45 * monitoring_gap + 0.55 * governance_gap),

    risk_class = case_when(
      planetary_nutrient_risk_score < 0.55 ~ "lower_risk",
      planetary_nutrient_risk_score < 1.10 ~ "moderate_risk",
      planetary_nutrient_risk_score < 1.80 ~ "high_risk",
      TRUE ~ "severe_risk"
    ),

    priority = case_when(
      phosphorus_boundary_pressure >= 1.25 ~ "phosphorus_loss_and_recovery_priority",
      nitrogen_boundary_pressure >= 1.25 ~ "nitrogen_surplus_reduction_priority",
      legacy_nutrient_pressure >= 0.65 ~ "legacy_nutrient_remediation_priority",
      governance_capacity < 0.45 ~ "governance_capacity_priority",
      nitrogen_input < 0.75 ~ "nutrient_access_and_soil_fertility_priority",
      TRUE ~ "integrated_nutrient_management_priority"
    )
  ) %>%
  arrange(desc(planetary_nutrient_risk_score))

dashboard_long <- scored %>%
  select(
    region,
    nitrogen_use_efficiency,
    phosphorus_use_efficiency,
    nitrogen_boundary_pressure,
    phosphorus_boundary_pressure,
    nutrient_loss_pressure,
    eutrophication_pressure,
    planetary_nutrient_risk_score
  ) %>%
  pivot_longer(
    cols = -region,
    names_to = "metric",
    values_to = "value"
  )

scenario_grid <- tibble::tibble(
  scenario = c(
    "baseline",
    "precision_nutrient_management",
    "wetland_and_buffer_restoration",
    "nutrient_recovery_and_circularity",
    "integrated_food_system_transition"
  ),
  input_multiplier = c(1.00, 0.86, 0.92, 0.82, 0.74),
  uptake_gain = c(0.00, 0.08, 0.04, 0.06, 0.10),
  runoff_multiplier = c(1.00, 0.90, 0.65, 0.78, 0.58),
  legacy_multiplier = c(1.00, 1.00, 0.90, 0.82, 0.70),
  governance_gain = c(0.00, 0.08, 0.10, 0.15, 0.22)
)

scenario_scores <- nutrient_profiles %>%
  crossing(scenario_grid) %>%
  mutate(
    # Reduce total nutrient pressure according to scenario assumptions.
    nitrogen_input = nitrogen_input * input_multiplier,
    phosphorus_input = phosphorus_input * input_multiplier,

    # Uptake improves under better practices but cannot exceed input.
    nitrogen_uptake = pmin(nitrogen_input * 0.98, nitrogen_uptake + uptake_gain),
    phosphorus_uptake = pmin(phosphorus_input * 0.98, phosphorus_uptake + uptake_gain),

    # Landscape restoration reduces runoff sensitivity.
    runoff_sensitivity = runoff_sensitivity * runoff_multiplier,

    # Legacy nutrient pressure declines more slowly than direct input pressure.
    legacy_nutrient_pressure = legacy_nutrient_pressure * legacy_multiplier,

    # Monitoring and governance capacity improve together.
    governance_capacity = pmin(1, governance_capacity + governance_gain),
    monitoring_capacity = pmin(1, monitoring_capacity + governance_gain * 0.75),

    nitrogen_surplus = nitrogen_input - nitrogen_uptake,
    phosphorus_surplus = phosphorus_input - phosphorus_uptake,
    nitrogen_use_efficiency = nitrogen_uptake / nitrogen_input,
    phosphorus_use_efficiency = phosphorus_uptake / phosphorus_input,
    nitrogen_boundary_pressure =
      nitrogen_input / nitrogen_boundary_reference,
    phosphorus_boundary_pressure =
      phosphorus_input / phosphorus_boundary_reference,
    nutrient_loss_pressure =
      (
        0.50 * pmax(0, nitrogen_surplus) +
        0.50 * pmax(0, phosphorus_surplus)
      ) *
      (
        0.50 * runoff_sensitivity +
        0.50 * hydrological_connectivity
      ),
    eutrophication_pressure =
      (
        0.35 * nitrogen_boundary_pressure +
        0.35 * phosphorus_boundary_pressure +
        0.30 * nutrient_loss_pressure
      ) *
      ecosystem_sensitivity,
    legacy_adjusted_pressure =
      eutrophication_pressure * (1 + legacy_nutrient_pressure),
    monitoring_gap = 1 - monitoring_capacity,
    governance_gap = 1 - governance_capacity,
    planetary_nutrient_risk_score =
      legacy_adjusted_pressure *
      (1 + 0.45 * monitoring_gap + 0.55 * governance_gap),
    risk_class = case_when(
      planetary_nutrient_risk_score < 0.55 ~ "lower_risk",
      planetary_nutrient_risk_score < 1.10 ~ "moderate_risk",
      planetary_nutrient_risk_score < 1.80 ~ "high_risk",
      TRUE ~ "severe_risk"
    )
  ) %>%
  group_by(scenario) %>%
  mutate(rank = dense_rank(desc(planetary_nutrient_risk_score))) %>%
  ungroup()

risk_summary <- scored %>%
  group_by(risk_class) %>%
  summarise(
    regions = n(),
    mean_nitrogen_use_efficiency = mean(nitrogen_use_efficiency),
    mean_phosphorus_use_efficiency = mean(phosphorus_use_efficiency),
    mean_eutrophication_pressure = mean(eutrophication_pressure),
    mean_planetary_nutrient_risk_score = mean(planetary_nutrient_risk_score),
    .groups = "drop"
  )

dir.create(
  "articles/biogeochemical-flows-nitrogen-phosphorus-and-planetary-destabilization/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/biogeochemical-flows-nitrogen-phosphorus-and-planetary-destabilization/outputs/r_biogeochemical_flow_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/biogeochemical-flows-nitrogen-phosphorus-and-planetary-destabilization/outputs/r_dashboard_long.csv"
)

write_csv(
  scenario_scores,
  "articles/biogeochemical-flows-nitrogen-phosphorus-and-planetary-destabilization/outputs/r_policy_scenarios.csv"
)

write_csv(
  risk_summary,
  "articles/biogeochemical-flows-nitrogen-phosphorus-and-planetary-destabilization/outputs/r_risk_summary.csv"
)

print(scored)
print(risk_summary)
