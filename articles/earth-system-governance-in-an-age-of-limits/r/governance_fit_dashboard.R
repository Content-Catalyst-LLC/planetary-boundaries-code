# Earth system governance-fit dashboard.
#
# This workflow scores governance cases across boundary pressure,
# monitoring capacity, legal and institutional fit, justice and legitimacy,
# adaptive capacity, and cross-scale coordination.

library(readr)
library(dplyr)
library(tidyr)

governance_cases <- tibble::tibble(
  case = c(
    "Global climate coordination",
    "Transboundary freshwater basin",
    "National land-use transition",
    "Chemical pollution governance",
    "Urban adaptation network",
    "Regional biodiversity compact"
  ),
  domain = c(
    "climate",
    "freshwater",
    "land",
    "novel_entities",
    "climate",
    "biosphere"
  ),
  boundary_pressure = c(1.45, 1.30, 1.25, 1.70, 1.10, 1.20),
  boundary_level = c(1, 1, 1, 1, 1, 1),
  monitoring_capacity = c(0.78, 0.62, 0.55, 0.38, 0.70, 0.58),
  legal_institutional_fit = c(0.60, 0.54, 0.48, 0.35, 0.50, 0.52),
  justice_legitimacy = c(0.52, 0.46, 0.40, 0.42, 0.62, 0.50),
  adaptive_capacity = c(0.66, 0.50, 0.45, 0.32, 0.72, 0.56),
  cross_scale_coordination = c(0.58, 0.52, 0.44, 0.30, 0.60, 0.48),
  domain_weight = c(1.4, 1.1, 1.0, 1.2, 1.0, 1.3)
)

capacity_weights <- tibble::tibble(
  dimension = c(
    "monitoring_capacity",
    "legal_institutional_fit",
    "justice_legitimacy",
    "adaptive_capacity",
    "cross_scale_coordination"
  ),
  weight = c(1, 1, 1, 1, 1)
) %>%
  mutate(weight = weight / sum(weight))

capacity_long <- governance_cases %>%
  select(
    case,
    monitoring_capacity,
    legal_institutional_fit,
    justice_legitimacy,
    adaptive_capacity,
    cross_scale_coordination
  ) %>%
  pivot_longer(
    cols = -case,
    names_to = "dimension",
    values_to = "capacity_score"
  ) %>%
  left_join(capacity_weights, by = "dimension") %>%
  mutate(weighted_capacity = capacity_score * weight)

capacity_scores <- capacity_long %>%
  group_by(case) %>%
  summarise(
    governance_capacity = sum(weighted_capacity),
    weakest_capacity_dimension = dimension[which.min(capacity_score)],
    weakest_capacity_value = min(capacity_score),
    .groups = "drop"
  )

governance_scores <- governance_cases %>%
  left_join(capacity_scores, by = "case") %>%
  mutate(
    boundary_transgression = pmax(
      0,
      (boundary_pressure - boundary_level) / boundary_level
    ),
    governance_gap = 1 - governance_capacity,
    governance_adjusted_fragility = boundary_transgression *
      governance_gap *
      domain_weight,
    fragility_class = case_when(
      governance_adjusted_fragility < 0.10 ~ "lower_fragility",
      governance_adjusted_fragility < 0.30 ~ "moderate_fragility",
      TRUE ~ "high_fragility"
    )
  ) %>%
  arrange(desc(governance_adjusted_fragility))

dashboard_long <- governance_scores %>%
  select(
    case,
    domain,
    boundary_transgression,
    governance_capacity,
    governance_gap,
    governance_adjusted_fragility,
    monitoring_capacity,
    legal_institutional_fit,
    justice_legitimacy,
    adaptive_capacity,
    cross_scale_coordination
  ) %>%
  pivot_longer(
    cols = -c(case, domain),
    names_to = "metric",
    values_to = "value"
  )

dir.create(
  "articles/earth-system-governance-in-an-age-of-limits/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  governance_scores,
  "articles/earth-system-governance-in-an-age-of-limits/outputs/r_governance_scores.csv"
)

write_csv(
  capacity_long,
  "articles/earth-system-governance-in-an-age-of-limits/outputs/r_capacity_long.csv"
)

write_csv(
  dashboard_long,
  "articles/earth-system-governance-in-an-age-of-limits/outputs/r_dashboard_long.csv"
)

print(governance_scores)
