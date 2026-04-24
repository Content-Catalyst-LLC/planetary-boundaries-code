# Planetary boundaries and Earth system resilience dashboard
#
# This workflow scores planetary-boundary processes across direct pressure,
# diversity, redundancy, adaptive capacity, monitoring capacity,
# cross-boundary interaction pressure, and resilience-adjusted risk.

library(readr)
library(dplyr)
library(tidyr)
library(tibble)

boundary_profiles <- tibble::tibble(
  boundary = c(
    "climate_change",
    "biosphere_integrity",
    "freshwater_change",
    "land_system_change",
    "biogeochemical_flows",
    "ocean_acidification",
    "novel_entities",
    "atmospheric_aerosol_loading",
    "stratospheric_ozone_depletion"
  ),
  observed_pressure = c(1.42, 1.70, 1.25, 1.22, 1.80, 0.92, 1.65, 0.95, 0.72),
  boundary_value = c(1, 1, 1, 1, 1, 1, 1, 1, 1),
  diversity = c(0.42, 0.28, 0.46, 0.40, 0.38, 0.52, 0.34, 0.44, 0.70),
  redundancy = c(0.38, 0.30, 0.42, 0.36, 0.34, 0.48, 0.30, 0.40, 0.68),
  adaptive_capacity = c(0.54, 0.40, 0.48, 0.46, 0.42, 0.50, 0.36, 0.44, 0.72),
  monitoring_capacity = c(0.76, 0.52, 0.60, 0.62, 0.56, 0.68, 0.40, 0.46, 0.82),
  structural_weight = c(1.50, 1.55, 1.10, 1.05, 1.20, 1.00, 1.25, 0.95, 0.80)
)

capacity_weights <- tibble::tibble(
  dimension = c(
    "diversity",
    "redundancy",
    "adaptive_capacity",
    "monitoring_capacity"
  ),
  weight = c(1.25, 1.10, 1.00, 0.90)
) %>%
  mutate(weight = weight / sum(weight))

interaction_edges <- tibble::tibble(
  source = c(
    "climate_change",
    "climate_change",
    "climate_change",
    "climate_change",
    "biosphere_integrity",
    "biosphere_integrity",
    "biosphere_integrity",
    "land_system_change",
    "land_system_change",
    "land_system_change",
    "freshwater_change",
    "freshwater_change",
    "biogeochemical_flows",
    "biogeochemical_flows",
    "biogeochemical_flows",
    "novel_entities",
    "novel_entities",
    "atmospheric_aerosol_loading",
    "atmospheric_aerosol_loading"
  ),
  target = c(
    "biosphere_integrity",
    "freshwater_change",
    "land_system_change",
    "ocean_acidification",
    "climate_change",
    "freshwater_change",
    "land_system_change",
    "biosphere_integrity",
    "freshwater_change",
    "climate_change",
    "biosphere_integrity",
    "biogeochemical_flows",
    "freshwater_change",
    "biosphere_integrity",
    "ocean_acidification",
    "biosphere_integrity",
    "freshwater_change",
    "climate_change",
    "freshwater_change"
  ),
  interaction_weight = c(
    0.35, 0.28, 0.18, 0.25,
    0.24, 0.18, 0.20,
    0.30, 0.22, 0.20,
    0.20, 0.12,
    0.26, 0.22, 0.10,
    0.18, 0.12,
    0.12, 0.15
  )
)

capacity_long <- boundary_profiles %>%
  select(
    boundary,
    diversity,
    redundancy,
    adaptive_capacity,
    monitoring_capacity
  ) %>%
  pivot_longer(
    cols = -boundary,
    names_to = "dimension",
    values_to = "dimension_score"
  ) %>%
  left_join(capacity_weights, by = "dimension") %>%
  mutate(weighted_score = dimension_score * weight)

capacity_scores <- capacity_long %>%
  group_by(boundary) %>%
  summarise(
    resilience_capacity = sum(weighted_score),
    dominant_resilience_gap = dimension[which.min(dimension_score)],
    weakest_dimension_score = min(dimension_score),
    .groups = "drop"
  )

base_scores <- boundary_profiles %>%
  mutate(
    pressure_ratio = observed_pressure / boundary_value
  ) %>%
  left_join(capacity_scores, by = "boundary") %>%
  mutate(
    resilience_gap = 1 - resilience_capacity
  )

interaction_pressure <- interaction_edges %>%
  left_join(
    base_scores %>%
      select(source = boundary, pressure_ratio),
    by = "source"
  ) %>%
  mutate(
    interaction_contribution = interaction_weight * pressure_ratio
  ) %>%
  group_by(target) %>%
  summarise(
    interaction_pressure = sum(interaction_contribution),
    .groups = "drop"
  )

interaction_lambda <- 0.60

scored <- base_scores %>%
  left_join(
    interaction_pressure,
    by = c("boundary" = "target")
  ) %>%
  mutate(
    interaction_pressure = replace_na(interaction_pressure, 0),
    resilience_adjusted_risk = (
      pressure_ratio + interaction_lambda * interaction_pressure
    ) *
      resilience_gap *
      structural_weight,
    risk_class = case_when(
      resilience_adjusted_risk < 0.45 ~ "lower_risk",
      resilience_adjusted_risk < 0.90 ~ "moderate_risk",
      TRUE ~ "high_risk"
    )
  ) %>%
  arrange(desc(resilience_adjusted_risk))

dashboard_long <- scored %>%
  select(
    boundary,
    pressure_ratio,
    resilience_capacity,
    resilience_gap,
    interaction_pressure,
    resilience_adjusted_risk
  ) %>%
  pivot_longer(
    cols = -boundary,
    names_to = "metric",
    values_to = "value"
  )

dir.create(
  "articles/planetary-boundaries-and-earth-system-resilience/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/planetary-boundaries-and-earth-system-resilience/outputs/r_resilience_scores.csv"
)

write_csv(
  interaction_edges,
  "articles/planetary-boundaries-and-earth-system-resilience/outputs/r_interaction_edges.csv"
)

write_csv(
  capacity_long,
  "articles/planetary-boundaries-and-earth-system-resilience/outputs/r_capacity_long.csv"
)

write_csv(
  dashboard_long,
  "articles/planetary-boundaries-and-earth-system-resilience/outputs/r_dashboard_long.csv"
)

print(scored)
