# Advanced Doughnut dashboard workflow
#
# This R workflow produces dashboard-ready summaries from the same logic
# used in the Python reference pipeline.

library(readr)
library(dplyr)
library(tidyr)

observations <- tibble::tibble(
  entity = c("Region A", "Region B", "Region C", "Region D"),
  co2_per_capita = c(4.2, 9.8, 2.1, 13.5),
  material_footprint_per_capita = c(8.5, 18.0, 5.2, 24.0),
  nitrogen_surplus_index = c(0.85, 1.45, 0.60, 1.90),
  land_conversion_index = c(0.75, 1.20, 0.55, 1.35),
  basic_health_access = c(0.82, 0.96, 0.55, 0.91),
  education_access = c(0.78, 0.94, 0.48, 0.88),
  clean_energy_access = c(0.70, 0.98, 0.42, 0.95),
  political_voice_index = c(0.62, 0.80, 0.35, 0.66)
)

indicator_specs <- tibble::tibble(
  indicator = c(
    "co2_per_capita",
    "material_footprint_per_capita",
    "nitrogen_surplus_index",
    "land_conversion_index",
    "basic_health_access",
    "education_access",
    "clean_energy_access",
    "political_voice_index"
  ),
  domain = c(
    "ecological",
    "ecological",
    "ecological",
    "ecological",
    "social",
    "social",
    "social",
    "social"
  ),
  threshold = c(3.0, 8.0, 1.0, 1.0, 0.90, 0.90, 0.90, 0.75),
  direction = c(
    "ceiling",
    "ceiling",
    "ceiling",
    "ceiling",
    "floor",
    "floor",
    "floor",
    "floor"
  ),
  weight = c(1.4, 1.2, 1.1, 1.0, 1.3, 1.2, 1.1, 1.0)
)

scored <- observations %>%
  pivot_longer(
    cols = -entity,
    names_to = "indicator",
    values_to = "observed"
  ) %>%
  left_join(indicator_specs, by = "indicator") %>%
  mutate(
    penalty = case_when(
      direction == "ceiling" ~ pmax(0, (observed - threshold) / threshold),
      direction == "floor" ~ pmax(0, (threshold - observed) / threshold),
      TRUE ~ NA_real_
    )
  )

entity_scores <- scored %>%
  group_by(entity, domain) %>%
  summarise(
    weighted_penalty = sum(penalty * weight) / sum(weight),
    max_penalty = max(penalty),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = domain,
    values_from = c(weighted_penalty, max_penalty)
  ) %>%
  mutate(
    safe_and_just_score = 1 - (
      0.5 * weighted_penalty_ecological +
        0.5 * weighted_penalty_social
    ),
    diagnostic_class = case_when(
      weighted_penalty_ecological == 0 & weighted_penalty_social == 0 ~
        "inside_safe_and_just_space",
      weighted_penalty_ecological > 0 & weighted_penalty_social == 0 ~
        "social_foundation_met_ecological_ceiling_exceeded",
      weighted_penalty_ecological == 0 & weighted_penalty_social > 0 ~
        "ecological_ceiling_respected_social_foundation_unmet",
      TRUE ~
        "both_overshoot_and_shortfall"
    )
  ) %>%
  arrange(desc(safe_and_just_score))

dashboard_long <- entity_scores %>%
  select(
    entity,
    weighted_penalty_ecological,
    weighted_penalty_social,
    safe_and_just_score
  ) %>%
  pivot_longer(
    cols = -entity,
    names_to = "metric",
    values_to = "value"
  )

dir.create(
  "articles/planetary-boundaries-and-doughnut-economics/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/planetary-boundaries-and-doughnut-economics/outputs/r_indicator_scores.csv"
)

write_csv(
  entity_scores,
  "articles/planetary-boundaries-and-doughnut-economics/outputs/r_entity_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/planetary-boundaries-and-doughnut-economics/outputs/r_dashboard_long.csv"
)

print(entity_scores)
