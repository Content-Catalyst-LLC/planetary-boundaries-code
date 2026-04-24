# Biosphere integrity and life-system risk dashboard
#
# This workflow scores biosphere-integrity risk across:
# - extinction pressure
# - genetic-diversity pressure
# - functional integrity
# - habitat intactness
# - fragmentation risk
# - human appropriation of net primary production
# - ecological sensitivity
# - climate, land, freshwater, nutrient, and novel-entity stress
# - restoration potential
# - monitoring and governance capacity
#
# Values are illustrative and should be replaced with documented biodiversity
# data, ecosystem-condition datasets, remote-sensing products, primary
# productivity estimates, habitat connectivity metrics, and transparent
# assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

biosphere_profiles <- tibble::tibble(
  region = c(
    "tropical_forest_biodiversity_frontier",
    "temperate_agricultural_mosaic",
    "freshwater_wetland_complex",
    "coral_reef_and_coastal_marine_system",
    "boreal_forest_fire_transition_zone",
    "restored_connected_landscape"
  ),
  observed_extinction_pressure = c(9.2, 5.8, 7.4, 8.6, 3.6, 1.8),
  genetic_boundary_reference = c(1, 1, 1, 1, 1, 1),
  functional_integrity_index = c(0.52, 0.56, 0.50, 0.44, 0.66, 0.76),
  functional_integrity_threshold = c(0.80, 0.78, 0.82, 0.80, 0.82, 0.80),
  habitat_intactness = c(0.58, 0.46, 0.54, 0.50, 0.72, 0.82),
  fragmentation_risk = c(0.72, 0.78, 0.66, 0.52, 0.42, 0.28),
  appropriation_pressure = c(0.76, 0.82, 0.58, 0.62, 0.44, 0.34),
  ecological_sensitivity = c(0.94, 0.70, 0.88, 0.96, 0.74, 0.58),
  climate_stress = c(0.62, 0.48, 0.56, 0.88, 0.86, 0.42),
  land_system_pressure = c(0.84, 0.68, 0.62, 0.40, 0.56, 0.32),
  freshwater_stress = c(0.60, 0.54, 0.86, 0.46, 0.42, 0.34),
  nutrient_pollution_pressure = c(0.44, 0.76, 0.70, 0.68, 0.28, 0.30),
  novel_entity_pressure = c(0.52, 0.64, 0.50, 0.72, 0.36, 0.34),
  restoration_potential = c(0.68, 0.78, 0.74, 0.52, 0.48, 0.84),
  monitoring_capacity = c(0.58, 0.72, 0.60, 0.64, 0.68, 0.80),
  governance_capacity = c(0.40, 0.58, 0.46, 0.42, 0.54, 0.72)
)

scored <- biosphere_profiles %>%
  mutate(
    # Genetic pressure compares observed extinction pressure to the boundary reference.
    genetic_diversity_pressure =
      observed_extinction_pressure / genetic_boundary_reference,

    # Functional deficit measures how far functional integrity falls below threshold.
    functional_integrity_deficit =
      pmax(0, functional_integrity_threshold - functional_integrity_index),

    # Habitat loss pressure rises as intactness declines.
    habitat_loss_pressure = 1 - habitat_intactness,

    # Cross-boundary stress captures interactions with other planetary pressures.
    cross_boundary_stress =
      0.24 * climate_stress +
      0.24 * land_system_pressure +
      0.18 * freshwater_stress +
      0.18 * nutrient_pollution_pressure +
      0.16 * novel_entity_pressure,

    # Biosphere pressure combines genetic, functional, habitat, fragmentation,
    # appropriation, and systemic stress.
    biosphere_pressure =
      0.26 * genetic_diversity_pressure +
      0.22 * functional_integrity_deficit +
      0.16 * habitat_loss_pressure +
      0.14 * fragmentation_risk +
      0.12 * appropriation_pressure +
      0.10 * cross_boundary_stress,

    # Weak monitoring and governance increase ecological risk.
    monitoring_gap = 1 - monitoring_capacity,
    governance_gap = 1 - governance_capacity,

    # Restoration potential reduces risk only when governance capacity exists.
    restoration_credit =
      0.35 * restoration_potential * governance_capacity,

    biosphere_integrity_risk_score =
      biosphere_pressure *
      ecological_sensitivity *
      (1 + 0.30 * monitoring_gap + 0.45 * governance_gap) -
      restoration_credit,

    risk_class = case_when(
      biosphere_integrity_risk_score < 0.85 ~ "lower_risk",
      biosphere_integrity_risk_score < 1.75 ~ "moderate_risk",
      biosphere_integrity_risk_score < 3.00 ~ "high_risk",
      TRUE ~ "severe_risk"
    ),

    priority = case_when(
      genetic_diversity_pressure >= 8.0 ~ "genetic_diversity_and_extinction_priority",
      functional_integrity_deficit >= 0.25 ~ "functional_integrity_recovery_priority",
      fragmentation_risk >= 0.70 ~ "habitat_connectivity_priority",
      appropriation_pressure >= 0.75 ~ "biomass_appropriation_reduction_priority",
      cross_boundary_stress >= 0.70 ~ "cross_boundary_stress_reduction_priority",
      governance_capacity < 0.45 ~ "governance_capacity_priority",
      TRUE ~ "integrated_biosphere_resilience_priority"
    )
  ) %>%
  arrange(desc(biosphere_integrity_risk_score))

dashboard_long <- scored %>%
  select(
    region,
    genetic_diversity_pressure,
    functional_integrity_deficit,
    habitat_loss_pressure,
    fragmentation_risk,
    appropriation_pressure,
    cross_boundary_stress,
    biosphere_integrity_risk_score
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
    mean_genetic_pressure = mean(genetic_diversity_pressure),
    mean_functional_deficit = mean(functional_integrity_deficit),
    mean_cross_boundary_stress = mean(cross_boundary_stress),
    mean_biosphere_integrity_risk_score = mean(biosphere_integrity_risk_score),
    .groups = "drop"
  )

dir.create(
  "articles/biosphere-integrity-and-the-stability-of-life-systems/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/biosphere-integrity-and-the-stability-of-life-systems/outputs/r_biosphere_integrity_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/biosphere-integrity-and-the-stability-of-life-systems/outputs/r_dashboard_long.csv"
)

write_csv(
  risk_summary,
  "articles/biosphere-integrity-and-the-stability-of-life-systems/outputs/r_risk_summary.csv"
)

print(scored)
print(risk_summary)
