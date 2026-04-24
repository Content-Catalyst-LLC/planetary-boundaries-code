# Planetary squeeze dashboard
#
# This workflow scores scenario-level sustainability pressure across:
# population pressure, affluence pressure, climate stress, ecosystem degradation,
# planetary-boundary pressure, governance capacity, adaptive capacity,
# justice capacity, mitigation capacity, restoration capacity, and material efficiency.
#
# Values are illustrative and should be replaced with documented demographic data,
# consumption indicators, climate metrics, ecosystem indicators, boundary data,
# governance assessments, and transparent assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

squeeze_scenarios <- tibble::tibble(
  scenario = c(
    "current_fragmented_response",
    "growth_with_relative_efficiency",
    "climate_policy_without_ecosystem_repair",
    "planetary_boundary_aligned_development",
    "just_transition_and_restoration"
  ),
  population_pressure = c(0.78, 0.80, 0.78, 0.70, 0.66),
  affluence_pressure = c(0.84, 0.88, 0.76, 0.58, 0.52),
  climate_stress = c(0.86, 0.72, 0.58, 0.46, 0.38),
  ecosystem_degradation = c(0.88, 0.78, 0.84, 0.48, 0.36),
  boundary_pressure = c(7 / 9, 6 / 9, 6 / 9, 4 / 9, 3 / 9),
  governance_capacity = c(0.42, 0.50, 0.56, 0.72, 0.82),
  adaptive_capacity = c(0.46, 0.52, 0.58, 0.70, 0.78),
  justice_capacity = c(0.34, 0.42, 0.46, 0.66, 0.80),
  mitigation_capacity = c(0.42, 0.58, 0.66, 0.76, 0.84),
  restoration_capacity = c(0.36, 0.44, 0.40, 0.72, 0.82),
  material_efficiency = c(0.38, 0.56, 0.54, 0.74, 0.80)
)

scored <- squeeze_scenarios %>%
  mutate(
    # Core squeeze pressure combines the four major structural forces.
    core_squeeze_pressure =
      0.24 * population_pressure +
      0.26 * affluence_pressure +
      0.26 * climate_stress +
      0.24 * ecosystem_degradation,

    # Interaction amplification captures the fact that the four forces multiply risk.
    interaction_amplification =
      0.22 * population_pressure * affluence_pressure +
      0.18 * population_pressure * climate_stress +
      0.18 * population_pressure * ecosystem_degradation +
      0.18 * affluence_pressure * climate_stress +
      0.18 * affluence_pressure * ecosystem_degradation +
      0.20 * climate_stress * ecosystem_degradation,

    # Governance-response capacity combines institutional, justice, mitigation,
    # restoration, adaptation, and material-efficiency dimensions.
    response_capacity =
      0.18 * governance_capacity +
      0.16 * adaptive_capacity +
      0.18 * justice_capacity +
      0.18 * mitigation_capacity +
      0.16 * restoration_capacity +
      0.14 * material_efficiency,

    # Boundary-adjusted squeeze risk rises with core pressure, amplification,
    # and current planetary-boundary transgression.
    planetary_squeeze_risk =
      core_squeeze_pressure *
      (1 + interaction_amplification) *
      (1 + 0.45 * boundary_pressure) *
      (1 - 0.55 * response_capacity),

    # Transformation urgency rises when risk is high and response capacity is weak.
    transformation_urgency =
      planetary_squeeze_risk *
      (1 - response_capacity) *
      (1 + boundary_pressure),

    risk_class = case_when(
      planetary_squeeze_risk >= 1.25 & transformation_urgency >= 0.70 ~ "system_transformation_urgent",
      planetary_squeeze_risk >= 0.95 ~ "high_planetary_squeeze",
      planetary_squeeze_risk >= 0.65 ~ "rising_squeeze_pressure",
      TRUE ~ "managed_transition"
    ),

    priority = case_when(
      risk_class == "system_transformation_urgent" ~ "system_transformation",
      climate_stress >= 0.75 ~ "accelerated_climate_mitigation",
      ecosystem_degradation >= 0.75 ~ "ecosystem_restoration",
      affluence_pressure >= 0.80 ~ "resource_demand_reduction",
      justice_capacity < 0.45 ~ "justice_centered_development",
      TRUE ~ "integrated_boundary_governance"
    )
  ) %>%
  arrange(desc(planetary_squeeze_risk))

dashboard_long <- scored %>%
  select(
    scenario,
    population_pressure,
    affluence_pressure,
    climate_stress,
    ecosystem_degradation,
    boundary_pressure,
    core_squeeze_pressure,
    interaction_amplification,
    response_capacity,
    planetary_squeeze_risk,
    transformation_urgency
  ) %>%
  pivot_longer(
    cols = -scenario,
    names_to = "metric",
    values_to = "value"
  )

summary_by_class <- scored %>%
  group_by(risk_class) %>%
  summarise(
    scenarios = n(),
    mean_core_squeeze_pressure = mean(core_squeeze_pressure),
    mean_interaction_amplification = mean(interaction_amplification),
    mean_response_capacity = mean(response_capacity),
    mean_planetary_squeeze_risk = mean(planetary_squeeze_risk),
    mean_transformation_urgency = mean(transformation_urgency),
    .groups = "drop"
  )

dir.create(
  "articles/the-planetary-squeeze-four-forces-driving-the-sustainability-crisis/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(scored, "articles/the-planetary-squeeze-four-forces-driving-the-sustainability-crisis/outputs/r_planetary_squeeze_scores.csv")
write_csv(dashboard_long, "articles/the-planetary-squeeze-four-forces-driving-the-sustainability-crisis/outputs/r_planetary_squeeze_dashboard_long.csv")
write_csv(summary_by_class, "articles/the-planetary-squeeze-four-forces-driving-the-sustainability-crisis/outputs/r_planetary_squeeze_summary.csv")

print(scored)
print(summary_by_class)
