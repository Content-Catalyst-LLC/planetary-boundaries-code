# SDG-boundary alignment dashboard
#
# This workflow scores regions across SDG achievement,
# planetary-boundary pressure, vulnerability, and capacity to act.

library(readr)
library(dplyr)
library(tidyr)

region_data <- tibble::tibble(
  region = c("Region A", "Region B", "Region C", "Region D", "Region E"),
  poverty_reduction = c(0.82, 0.95, 0.54, 0.76, 0.88),
  health_access = c(0.78, 0.96, 0.58, 0.72, 0.84),
  education_access = c(0.80, 0.94, 0.52, 0.75, 0.86),
  clean_energy_access = c(0.70, 0.98, 0.46, 0.62, 0.82),
  climate_pressure = c(1.10, 1.85, 0.52, 0.78, 1.20),
  freshwater_pressure = c(0.95, 1.30, 0.72, 1.18, 0.88),
  land_pressure = c(1.05, 1.22, 0.64, 1.35, 0.92),
  nutrient_pressure = c(1.28, 1.55, 0.70, 1.48, 1.05),
  biosphere_pressure = c(1.12, 1.42, 0.66, 1.30, 0.98),
  vulnerability = c(0.54, 0.28, 0.84, 0.72, 0.46),
  capacity_to_act = c(0.52, 0.82, 0.24, 0.38, 0.60)
)

indicator_specs <- tibble::tibble(
  indicator = c(
    "poverty_reduction",
    "health_access",
    "education_access",
    "clean_energy_access",
    "climate_pressure",
    "freshwater_pressure",
    "land_pressure",
    "nutrient_pressure",
    "biosphere_pressure"
  ),
  domain = c(
    "social",
    "social",
    "social",
    "social",
    "ecological",
    "ecological",
    "ecological",
    "ecological",
    "ecological"
  ),
  threshold = c(0.90, 0.90, 0.90, 0.90, 1.00, 1.00, 1.00, 1.00, 1.00),
  direction = c(
    "floor",
    "floor",
    "floor",
    "floor",
    "ceiling",
    "ceiling",
    "ceiling",
    "ceiling",
    "ceiling"
  ),
  weight = c(1.3, 1.2, 1.1, 1.1, 1.4, 1.1, 1.0, 1.0, 1.2)
)

indicator_scores <- region_data %>%
  pivot_longer(
    cols = -c(region, vulnerability, capacity_to_act),
    names_to = "indicator",
    values_to = "observed"
  ) %>%
  left_join(indicator_specs, by = "indicator") %>%
  mutate(
    penalty = case_when(
      direction == "floor" ~ pmax(0, (threshold - observed) / threshold),
      direction == "ceiling" ~ pmax(0, (observed - threshold) / threshold),
      TRUE ~ NA_real_
    ),
    weighted_penalty = penalty * weight
  )

domain_scores <- indicator_scores %>%
  group_by(region, domain) %>%
  summarise(
    weighted_penalty = sum(weighted_penalty) / sum(weight),
    max_penalty = max(penalty),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = domain,
    values_from = c(weighted_penalty, max_penalty)
  )

alignment_scores <- domain_scores %>%
  left_join(
    region_data %>%
      select(region, vulnerability, capacity_to_act),
    by = "region"
  ) %>%
  mutate(
    sdg_boundary_alignment_score = 1 - (
      0.5 * weighted_penalty_social +
        0.5 * weighted_penalty_ecological
    ),
    justice_adjusted_risk = (
      weighted_penalty_social +
        weighted_penalty_ecological +
        vulnerability
    ) * (1 + (1 - capacity_to_act)),
    diagnostic_class = case_when(
      weighted_penalty_social == 0 & weighted_penalty_ecological == 0 ~
        "within_social_and_ecological_targets",
      weighted_penalty_social > 0 & weighted_penalty_ecological == 0 ~
        "social_shortfall_without_boundary_overshoot",
      weighted_penalty_social == 0 & weighted_penalty_ecological > 0 ~
        "boundary_overshoot_without_social_shortfall",
      TRUE ~
        "combined_social_shortfall_and_boundary_overshoot"
    )
  ) %>%
  arrange(desc(justice_adjusted_risk))

dashboard_long <- alignment_scores %>%
  select(
    region,
    weighted_penalty_social,
    weighted_penalty_ecological,
    sdg_boundary_alignment_score,
    vulnerability,
    capacity_to_act,
    justice_adjusted_risk
  ) %>%
  pivot_longer(
    cols = -region,
    names_to = "metric",
    values_to = "value"
  )

dir.create(
  "articles/sustainable-development-goals-within-planetary-boundaries/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  indicator_scores,
  "articles/sustainable-development-goals-within-planetary-boundaries/outputs/r_indicator_scores.csv"
)

write_csv(
  alignment_scores,
  "articles/sustainable-development-goals-within-planetary-boundaries/outputs/r_alignment_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/sustainable-development-goals-within-planetary-boundaries/outputs/r_dashboard_long.csv"
)

print(alignment_scores)
