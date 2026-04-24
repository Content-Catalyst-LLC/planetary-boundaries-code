# Doughnut diagnostic workflow in R.
#
# This script calculates ecological overshoot, social shortfall,
# and a combined safe-and-just score using illustrative data.

library(readr)
library(dplyr)
library(tidyr)

ecological_data <- tibble::tibble(
  entity = c("Region A", "Region B", "Region C", "Region D"),
  co2_per_capita = c(4.2, 9.8, 2.1, 13.5),
  material_footprint_per_capita = c(8.5, 18.0, 5.2, 24.0),
  nitrogen_surplus_index = c(0.85, 1.45, 0.60, 1.90),
  land_conversion_index = c(0.75, 1.20, 0.55, 1.35)
)

ecological_boundaries <- tibble::tibble(
  indicator = c(
    "co2_per_capita",
    "material_footprint_per_capita",
    "nitrogen_surplus_index",
    "land_conversion_index"
  ),
  boundary = c(3.0, 8.0, 1.0, 1.0)
)

social_data <- tibble::tibble(
  entity = c("Region A", "Region B", "Region C", "Region D"),
  basic_health_access = c(0.82, 0.96, 0.55, 0.91),
  education_access = c(0.78, 0.94, 0.48, 0.88),
  clean_energy_access = c(0.70, 0.98, 0.42, 0.95),
  political_voice_index = c(0.62, 0.80, 0.35, 0.66)
)

social_foundations <- tibble::tibble(
  indicator = c(
    "basic_health_access",
    "education_access",
    "clean_energy_access",
    "political_voice_index"
  ),
  foundation = c(0.90, 0.90, 0.90, 0.75)
)

ecological_scores <- ecological_data %>%
  pivot_longer(
    cols = -entity,
    names_to = "indicator",
    values_to = "observed_value"
  ) %>%
  left_join(ecological_boundaries, by = "indicator") %>%
  mutate(
    overshoot = pmax(0, (observed_value - boundary) / boundary)
  ) %>%
  group_by(entity) %>%
  summarise(
    mean_ecological_overshoot = mean(overshoot),
    max_ecological_overshoot = max(overshoot),
    .groups = "drop"
  )

social_scores <- social_data %>%
  pivot_longer(
    cols = -entity,
    names_to = "indicator",
    values_to = "observed_value"
  ) %>%
  left_join(social_foundations, by = "indicator") %>%
  mutate(
    shortfall = pmax(0, (foundation - observed_value) / foundation)
  ) %>%
  group_by(entity) %>%
  summarise(
    mean_social_shortfall = mean(shortfall),
    max_social_shortfall = max(shortfall),
    .groups = "drop"
  )

alpha <- 0.5
beta <- 0.5

diagnostic <- ecological_scores %>%
  left_join(social_scores, by = "entity") %>%
  mutate(
    safe_and_just_score = 1 - (
      alpha * mean_ecological_overshoot +
        beta * mean_social_shortfall
    ),
    doughnut_position = case_when(
      mean_ecological_overshoot == 0 & mean_social_shortfall == 0 ~
        "Inside the safe-and-just space",
      mean_ecological_overshoot > 0 & mean_social_shortfall == 0 ~
        "Social foundation met, ecological ceiling exceeded",
      mean_ecological_overshoot == 0 & mean_social_shortfall > 0 ~
        "Ecological ceiling respected, social foundation unmet",
      TRUE ~
        "Both ecological overshoot and social shortfall"
    )
  ) %>%
  arrange(desc(safe_and_just_score))

diagnostic_long <- diagnostic %>%
  select(
    entity,
    mean_ecological_overshoot,
    mean_social_shortfall,
    safe_and_just_score
  ) %>%
  pivot_longer(
    cols = -entity,
    names_to = "metric",
    values_to = "value"
  )

write_csv(
  diagnostic,
  "articles/planetary-boundaries-and-doughnut-economics/outputs/doughnut_diagnostic_scores_r.csv"
)

write_csv(
  diagnostic_long,
  "articles/planetary-boundaries-and-doughnut-economics/outputs/doughnut_diagnostic_dashboard_long.csv"
)

print(diagnostic)
