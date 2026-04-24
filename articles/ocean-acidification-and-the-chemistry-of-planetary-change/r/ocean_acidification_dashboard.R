# Ocean acidification and marine chemistry risk dashboard
#
# This workflow scores regional ocean acidification risk across pH,
# carbonate ion availability, aragonite saturation state, boundary pressure,
# ecosystem vulnerability, multi-stressor pressure, monitoring capacity,
# and governance capacity.
#
# Values are illustrative and should be replaced with documented
# ocean chemistry observations, carbonate-system calculations,
# ecological sensitivity data, and transparent assumptions.

library(readr)
library(dplyr)
library(tidyr)

ocean_profiles <- tibble::tibble(
  region = c(
    "global_surface_ocean",
    "tropical_coral_reef_belt",
    "arctic_surface_waters",
    "southern_ocean",
    "eastern_boundary_upwelling_systems",
    "temperate_shellfish_coasts"
  ),
  current_ph = c(8.10, 8.06, 8.03, 8.04, 7.94, 7.98),
  preindustrial_ph = c(8.20, 8.18, 8.16, 8.17, 8.08, 8.10),
  carbonate_ion_index = c(0.82, 0.74, 0.66, 0.70, 0.62, 0.68),
  aragonite_saturation_state = c(2.90, 2.65, 1.65, 1.82, 1.48, 1.72),
  preindustrial_aragonite_state = c(3.44, 3.65, 2.25, 2.45, 2.10, 2.30),
  boundary_aragonite_state = c(2.75, 3.00, 1.70, 1.90, 1.60, 1.75),
  ecological_sensitivity = c(0.58, 0.90, 0.76, 0.72, 0.70, 0.78),
  exposure = c(0.72, 0.86, 0.82, 0.78, 0.88, 0.80),
  adaptive_capacity = c(0.52, 0.34, 0.30, 0.32, 0.42, 0.48),
  warming_stress = c(0.62, 0.88, 0.82, 0.58, 0.54, 0.48),
  deoxygenation_stress = c(0.42, 0.40, 0.36, 0.44, 0.72, 0.50),
  nutrient_stress = c(0.38, 0.54, 0.24, 0.26, 0.66, 0.60),
  monitoring_capacity = c(0.70, 0.58, 0.52, 0.56, 0.54, 0.62),
  governance_capacity = c(0.46, 0.38, 0.34, 0.36, 0.40, 0.50)
)

scored <- ocean_profiles %>%
  mutate(
    ph_decline = preindustrial_ph - current_ph,
    hydrogen_ion_increase_index =
      (10^(-current_ph)) / (10^(-preindustrial_ph)),
    aragonite_boundary_pressure =
      (preindustrial_aragonite_state - aragonite_saturation_state) /
      (preindustrial_aragonite_state - boundary_aragonite_state),
    aragonite_boundary_pressure = pmax(0, aragonite_boundary_pressure),
    carbonate_deficit = 1 - carbonate_ion_index,
    ecosystem_vulnerability =
      aragonite_boundary_pressure *
      ecological_sensitivity *
      exposure *
      (1 - adaptive_capacity),
    multi_stressor_pressure =
      0.40 * aragonite_boundary_pressure +
      0.25 * warming_stress +
      0.20 * deoxygenation_stress +
      0.15 * nutrient_stress,
    monitoring_gap = 1 - monitoring_capacity,
    governance_gap = 1 - governance_capacity,
    marine_chemistry_risk_score =
      (
        0.45 * ecosystem_vulnerability +
        0.35 * multi_stressor_pressure +
        0.20 * carbonate_deficit
      ) *
      (1 + 0.5 * monitoring_gap + 0.5 * governance_gap),
    risk_class = case_when(
      marine_chemistry_risk_score < 0.65 ~ "lower_risk",
      marine_chemistry_risk_score < 1.25 ~ "moderate_risk",
      marine_chemistry_risk_score < 2.00 ~ "high_risk",
      TRUE ~ "severe_risk"
    ),
    priority = case_when(
      aragonite_boundary_pressure >= 1.0 ~ "boundary_transgression_priority",
      ecosystem_vulnerability >= 0.60 ~ "ecosystem_resilience_priority",
      monitoring_capacity < 0.55 ~ "monitoring_capacity_priority",
      nutrient_stress >= 0.60 ~ "coastal_pollution_and_nutrient_priority",
      TRUE ~ "carbon_mitigation_and_monitoring"
    )
  ) %>%
  arrange(desc(marine_chemistry_risk_score))

dashboard_long <- scored %>%
  select(
    region,
    ph_decline,
    hydrogen_ion_increase_index,
    aragonite_boundary_pressure,
    ecosystem_vulnerability,
    multi_stressor_pressure,
    marine_chemistry_risk_score
  ) %>%
  pivot_longer(
    cols = -region,
    names_to = "metric",
    values_to = "value"
  )

scenario_grid <- tibble::tibble(
  scenario = c(
    "baseline",
    "improved_monitoring",
    "coastal_pollution_reduction",
    "strong_carbon_mitigation",
    "integrated_ocean_resilience"
  ),
  aragonite_gain = c(0.00, 0.00, 0.00, 0.18, 0.24),
  nutrient_multiplier = c(1.00, 1.00, 0.65, 0.85, 0.55),
  monitoring_gain = c(0.00, 0.18, 0.08, 0.10, 0.22),
  governance_gain = c(0.00, 0.08, 0.12, 0.18, 0.25)
)

scenario_scores <- ocean_profiles %>%
  crossing(scenario_grid) %>%
  mutate(
    aragonite_saturation_state = aragonite_saturation_state + aragonite_gain,
    nutrient_stress = nutrient_stress * nutrient_multiplier,
    monitoring_capacity = pmin(1, monitoring_capacity + monitoring_gain),
    governance_capacity = pmin(1, governance_capacity + governance_gain),
    ph_decline = preindustrial_ph - current_ph,
    hydrogen_ion_increase_index =
      (10^(-current_ph)) / (10^(-preindustrial_ph)),
    aragonite_boundary_pressure =
      (preindustrial_aragonite_state - aragonite_saturation_state) /
      (preindustrial_aragonite_state - boundary_aragonite_state),
    aragonite_boundary_pressure = pmax(0, aragonite_boundary_pressure),
    carbonate_deficit = 1 - carbonate_ion_index,
    ecosystem_vulnerability =
      aragonite_boundary_pressure *
      ecological_sensitivity *
      exposure *
      (1 - adaptive_capacity),
    multi_stressor_pressure =
      0.40 * aragonite_boundary_pressure +
      0.25 * warming_stress +
      0.20 * deoxygenation_stress +
      0.15 * nutrient_stress,
    monitoring_gap = 1 - monitoring_capacity,
    governance_gap = 1 - governance_capacity,
    marine_chemistry_risk_score =
      (
        0.45 * ecosystem_vulnerability +
        0.35 * multi_stressor_pressure +
        0.20 * carbonate_deficit
      ) *
      (1 + 0.5 * monitoring_gap + 0.5 * governance_gap),
    risk_class = case_when(
      marine_chemistry_risk_score < 0.65 ~ "lower_risk",
      marine_chemistry_risk_score < 1.25 ~ "moderate_risk",
      marine_chemistry_risk_score < 2.00 ~ "high_risk",
      TRUE ~ "severe_risk"
    )
  ) %>%
  group_by(scenario) %>%
  mutate(rank = dense_rank(desc(marine_chemistry_risk_score))) %>%
  ungroup()

risk_summary <- scored %>%
  group_by(risk_class) %>%
  summarise(
    regions = n(),
    mean_ph_decline = mean(ph_decline),
    mean_aragonite_boundary_pressure = mean(aragonite_boundary_pressure),
    mean_ecosystem_vulnerability = mean(ecosystem_vulnerability),
    mean_marine_chemistry_risk_score = mean(marine_chemistry_risk_score),
    .groups = "drop"
  )

dir.create(
  "articles/ocean-acidification-and-the-chemistry-of-planetary-change/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/ocean-acidification-and-the-chemistry-of-planetary-change/outputs/r_ocean_acidification_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/ocean-acidification-and-the-chemistry-of-planetary-change/outputs/r_dashboard_long.csv"
)

write_csv(
  scenario_scores,
  "articles/ocean-acidification-and-the-chemistry-of-planetary-change/outputs/r_policy_scenarios.csv"
)

write_csv(
  risk_summary,
  "articles/ocean-acidification-and-the-chemistry-of-planetary-change/outputs/r_risk_summary.csv"
)

print(scored)
print(risk_summary)
