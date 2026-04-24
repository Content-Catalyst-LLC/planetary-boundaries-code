# Anthropocene 3-6-9 risk dashboard
#
# This workflow scores scenario-level Anthropocene risk across climate pressure,
# biosphere pressure, development demand, planetary-boundary transgression,
# governance capacity, adaptive capacity, justice capacity, mitigation capacity,
# restoration capacity, and institutional learning.
#
# Values are illustrative and should be replaced with documented scenario data,
# climate pathway data, biodiversity metrics, population projections, governance
# assessments, and transparent assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

anthropocene_scenarios <- tibble::tibble(
  scenario = c(
    "current_fragmented_response",
    "climate_policy_without_biosphere_repair",
    "green_growth_with_high_material_demand",
    "planetary_boundary_aligned_development",
    "just_transition_and_ecological_restoration"
  ),
  warming_pressure = c(0.82, 0.62, 0.58, 0.42, 0.36),
  biosphere_pressure = c(0.88, 0.84, 0.72, 0.46, 0.38),
  development_demand = c(0.76, 0.74, 0.88, 0.62, 0.58),
  boundary_transgression_count = c(7, 6, 6, 4, 3),
  governance_capacity = c(0.42, 0.50, 0.56, 0.72, 0.80),
  adaptive_capacity = c(0.48, 0.54, 0.58, 0.70, 0.76),
  justice_capacity = c(0.34, 0.42, 0.44, 0.66, 0.78),
  mitigation_capacity = c(0.44, 0.62, 0.68, 0.76, 0.82),
  restoration_capacity = c(0.38, 0.40, 0.46, 0.72, 0.80),
  institutional_learning = c(0.46, 0.52, 0.56, 0.74, 0.82)
)

scored <- anthropocene_scenarios %>%
  mutate(
    boundary_transgression_pressure = boundary_transgression_count / 9,
    core_369_pressure =
      0.36 * warming_pressure +
      0.34 * biosphere_pressure +
      0.30 * development_demand,
    cross_pressure_amplification =
      0.35 * warming_pressure * biosphere_pressure +
      0.25 * warming_pressure * development_demand +
      0.25 * biosphere_pressure * development_demand +
      0.15 * boundary_transgression_pressure,
    governance_resilience_capacity =
      0.20 * governance_capacity +
      0.18 * adaptive_capacity +
      0.18 * justice_capacity +
      0.16 * mitigation_capacity +
      0.16 * restoration_capacity +
      0.12 * institutional_learning,
    anthropocene_risk_score =
      core_369_pressure *
      (1 + cross_pressure_amplification) *
      (1 - 0.55 * governance_resilience_capacity) *
      (1 + 0.35 * boundary_transgression_pressure),
    transformation_urgency =
      anthropocene_risk_score *
      (1 - governance_resilience_capacity) *
      (1 + boundary_transgression_pressure),
    risk_class = case_when(
      anthropocene_risk_score >= 1.40 & transformation_urgency >= 0.75 ~ "transformation_urgent",
      anthropocene_risk_score >= 1.05 ~ "high_anthropocene_risk",
      anthropocene_risk_score >= 0.70 ~ "rising_systemic_risk",
      TRUE ~ "managed_transition"
    ),
    priority = case_when(
      risk_class == "transformation_urgent" ~ "system_transformation",
      biosphere_pressure >= 0.75 ~ "biosphere_integrity_repair",
      warming_pressure >= 0.75 ~ "accelerated_climate_mitigation",
      justice_capacity < 0.45 ~ "justice_centered_development",
      development_demand >= 0.80 ~ "resource_demand_reduction",
      TRUE ~ "integrated_boundary_governance"
    )
  ) %>%
  arrange(desc(anthropocene_risk_score))

dashboard_long <- scored %>%
  select(
    scenario,
    warming_pressure,
    biosphere_pressure,
    development_demand,
    boundary_transgression_pressure,
    core_369_pressure,
    cross_pressure_amplification,
    governance_resilience_capacity,
    anthropocene_risk_score,
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
    mean_core_369_pressure = mean(core_369_pressure),
    mean_governance_resilience_capacity = mean(governance_resilience_capacity),
    mean_anthropocene_risk_score = mean(anthropocene_risk_score),
    mean_transformation_urgency = mean(transformation_urgency),
    .groups = "drop"
  )

dir.create(
  "articles/navigating-the-anthropocene-sustainable-development-3-6-9-world/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(scored, "articles/navigating-the-anthropocene-sustainable-development-3-6-9-world/outputs/r_anthropocene_369_scores.csv")
write_csv(dashboard_long, "articles/navigating-the-anthropocene-sustainable-development-3-6-9-world/outputs/r_anthropocene_369_dashboard_long.csv")
write_csv(summary_by_class, "articles/navigating-the-anthropocene-sustainable-development-3-6-9-world/outputs/r_anthropocene_369_summary.csv")

print(scored)
print(summary_by_class)
