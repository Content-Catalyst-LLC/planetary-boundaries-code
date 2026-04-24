# Social-ecological resilience dashboard
#
# This workflow scores resilience across boundary pressure, disturbance exposure,
# functional integrity, diversity, redundancy, adaptive capacity, learning capacity,
# governance capacity, justice capacity, incumbent lock-in, and transformation feasibility.
#
# Values are illustrative and should be replaced with documented ecological
# indicators, social vulnerability data, monitoring records, governance
# assessments, and transparent assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

resilience_profiles <- tibble::tibble(
  system = c(
    "climate_exposed_coastal_city",
    "industrial_monoculture_food_system",
    "restored_wetland_watershed",
    "fossil_fuel_dependent_region",
    "polycentric_river_basin_governance"
  ),
  boundary_pressure = c(1.34, 1.52, 0.74, 1.68, 0.92),
  disturbance_exposure = c(0.86, 0.72, 0.54, 0.78, 0.66),
  functional_integrity = c(0.58, 0.50, 0.78, 0.62, 0.70),
  diversity = c(0.52, 0.28, 0.82, 0.36, 0.74),
  redundancy = c(0.46, 0.34, 0.76, 0.44, 0.68),
  adaptive_capacity = c(0.56, 0.42, 0.72, 0.38, 0.76),
  learning_capacity = c(0.62, 0.46, 0.78, 0.42, 0.80),
  governance_capacity = c(0.50, 0.40, 0.70, 0.36, 0.78),
  justice_capacity = c(0.38, 0.36, 0.66, 0.32, 0.62),
  incumbent_lock_in = c(0.62, 0.82, 0.24, 0.90, 0.36),
  transformation_feasibility = c(0.54, 0.48, 0.72, 0.42, 0.70)
)

logistic_risk <- function(value, steepness = 8) {
  1 / (1 + exp(-steepness * (value - 1)))
}

scored <- resilience_profiles %>%
  mutate(
    threshold_risk = logistic_risk(boundary_pressure),
    ecological_buffering =
      0.40 * functional_integrity +
      0.35 * diversity +
      0.25 * redundancy,
    institutional_capacity =
      0.30 * adaptive_capacity +
      0.25 * learning_capacity +
      0.25 * governance_capacity +
      0.20 * justice_capacity,
    resilience_capacity =
      0.52 * ecological_buffering +
      0.48 * institutional_capacity,
    lock_in_pressure =
      incumbent_lock_in * boundary_pressure,
    systemic_resilience_risk =
      threshold_risk *
      (1 + disturbance_exposure) *
      (1 + 0.50 * lock_in_pressure) *
      (1 - resilience_capacity),
    transformation_need =
      systemic_resilience_risk *
      transformation_feasibility *
      (1 + incumbent_lock_in),
    resilience_class = case_when(
      incumbent_lock_in >= 0.75 & boundary_pressure >= 1.0 ~ "maladaptive_resilience",
      systemic_resilience_risk >= 1.40 & transformation_feasibility >= 0.45 ~ "transformation_needed",
      resilience_capacity >= 0.65 & systemic_resilience_risk < 1.0 ~ "adaptive_resilience",
      TRUE ~ "fragile_resilience"
    ),
    priority = case_when(
      resilience_class == "maladaptive_resilience" ~ "weaken_harmful_lock_in",
      transformation_need >= 0.75 ~ "managed_transformation",
      justice_capacity < 0.45 ~ "justice_centered_adaptation",
      learning_capacity < 0.50 ~ "learning_system_investment",
      ecological_buffering < 0.50 ~ "restore_ecological_buffers",
      TRUE ~ "maintain_adaptive_capacity"
    )
  ) %>%
  arrange(desc(systemic_resilience_risk))

dashboard_long <- scored %>%
  select(
    system,
    threshold_risk,
    ecological_buffering,
    institutional_capacity,
    resilience_capacity,
    lock_in_pressure,
    systemic_resilience_risk,
    transformation_need
  ) %>%
  pivot_longer(
    cols = -system,
    names_to = "metric",
    values_to = "value"
  )

summary_by_class <- scored %>%
  group_by(resilience_class) %>%
  summarise(
    systems = n(),
    mean_boundary_pressure = mean(boundary_pressure),
    mean_resilience_capacity = mean(resilience_capacity),
    mean_systemic_resilience_risk = mean(systemic_resilience_risk),
    mean_transformation_need = mean(transformation_need),
    .groups = "drop"
  )

dir.create(
  "articles/resilience-thinking-in-the-anthropocene/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/resilience-thinking-in-the-anthropocene/outputs/r_resilience_diagnostics.csv"
)

write_csv(
  dashboard_long,
  "articles/resilience-thinking-in-the-anthropocene/outputs/r_resilience_dashboard_long.csv"
)

write_csv(
  summary_by_class,
  "articles/resilience-thinking-in-the-anthropocene/outputs/r_resilience_summary.csv"
)

print(scored)
print(summary_by_class)
