# Planetary justice and inequality dashboard
#
# This workflow scores groups across ecological overuse,
# minimum-access shortfall, vulnerability, historical contribution,
# and present capacity to act.

library(readr)
library(dplyr)
library(tidyr)

justice_data <- tibble::tibble(
  group = c(
    "High-income high-consuming",
    "Middle-income industrializing",
    "Low-income climate-vulnerable",
    "Small island vulnerable",
    "Resource-export dependent",
    "Urban low-income communities"
  ),
  ecological_use = c(2.40, 1.45, 0.55, 0.38, 1.20, 0.62),
  fair_allocation = c(1, 1, 1, 1, 1, 1),
  social_access = c(0.96, 0.78, 0.48, 0.68, 0.58, 0.52),
  minimum_access = c(0.85, 0.85, 0.85, 0.85, 0.85, 0.85),
  vulnerability = c(0.22, 0.45, 0.82, 0.90, 0.66, 0.74),
  historical_contribution = c(0.88, 0.48, 0.12, 0.08, 0.35, 0.18),
  capacity_to_act = c(0.86, 0.58, 0.24, 0.30, 0.42, 0.32)
)

weights <- tibble::tibble(
  dimension = c(
    "ecological_overuse",
    "minimum_access_shortfall",
    "vulnerability"
  ),
  weight = c(1, 1, 1)
) %>%
  mutate(weight = weight / sum(weight))

scored <- justice_data %>%
  mutate(
    ecological_overuse = pmax(
      0,
      (ecological_use - fair_allocation) / fair_allocation
    ),
    minimum_access_shortfall = pmax(
      0,
      (minimum_access - social_access) / minimum_access
    )
  )

justice_long <- scored %>%
  select(
    group,
    ecological_overuse,
    minimum_access_shortfall,
    vulnerability
  ) %>%
  pivot_longer(
    cols = -group,
    names_to = "dimension",
    values_to = "dimension_score"
  ) %>%
  left_join(weights, by = "dimension") %>%
  mutate(weighted_score = dimension_score * weight)

justice_scores <- justice_long %>%
  group_by(group) %>%
  summarise(
    planetary_justice_gap = sum(weighted_score),
    dominant_dimension = dimension[which.max(dimension_score)],
    dominant_dimension_value = max(dimension_score),
    .groups = "drop"
  ) %>%
  left_join(
    scored %>%
      select(group, historical_contribution, capacity_to_act),
    by = "group"
  ) %>%
  mutate(
    responsibility_adjusted_gap = planetary_justice_gap *
      (1 + historical_contribution) *
      (1 + capacity_to_act),
    justice_priority_class = case_when(
      responsibility_adjusted_gap < 0.40 ~ "lower_priority",
      responsibility_adjusted_gap < 0.90 ~ "moderate_priority",
      TRUE ~ "high_priority"
    )
  ) %>%
  arrange(desc(responsibility_adjusted_gap))

dashboard_long <- justice_scores %>%
  select(
    group,
    planetary_justice_gap,
    responsibility_adjusted_gap,
    historical_contribution,
    capacity_to_act
  ) %>%
  pivot_longer(
    cols = -group,
    names_to = "metric",
    values_to = "value"
  )

dir.create(
  "articles/planetary-boundaries-justice-and-global-inequality/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/planetary-boundaries-justice-and-global-inequality/outputs/r_base_scores.csv"
)

write_csv(
  justice_long,
  "articles/planetary-boundaries-justice-and-global-inequality/outputs/r_justice_long.csv"
)

write_csv(
  justice_scores,
  "articles/planetary-boundaries-justice-and-global-inequality/outputs/r_justice_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/planetary-boundaries-justice-and-global-inequality/outputs/r_dashboard_long.csv"
)

print(justice_scores)
