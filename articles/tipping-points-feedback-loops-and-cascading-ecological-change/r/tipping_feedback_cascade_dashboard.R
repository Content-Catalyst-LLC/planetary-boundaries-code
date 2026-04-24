# Tipping points, feedback loops, and cascading ecological change dashboard
#
# This workflow scores Earth system components across pressure,
# precautionary thresholds, feedback strength, resilience capacity,
# monitoring capacity, cascade pressure, and tipping probability.

library(readr)
library(dplyr)
library(tidyr)
library(tibble)

logistic <- function(x) {
  1 / (1 + exp(-x))
}

elements <- tibble::tibble(
  element = c(
    "greenland_ice_sheet",
    "west_antarctic_ice_sheet",
    "amoc",
    "amazon_rainforest",
    "boreal_forest",
    "permafrost_carbon",
    "warm_water_coral_reefs"
  ),
  pressure = c(1.18, 1.12, 0.92, 1.24, 1.05, 1.15, 1.40),
  threshold = c(1, 1, 1, 1, 1, 1, 1),
  threshold_uncertainty = c(0.12, 0.14, 0.20, 0.18, 0.16, 0.15, 0.10),
  precaution_factor = c(1.0, 1.0, 1.1, 1.1, 1.0, 1.0, 1.0),
  feedback_strength = c(0.70, 0.68, 0.52, 0.76, 0.62, 0.82, 0.74),
  resilience_capacity = c(0.42, 0.38, 0.48, 0.36, 0.44, 0.34, 0.28),
  monitoring_capacity = c(0.74, 0.66, 0.58, 0.56, 0.52, 0.50, 0.62)
)

interaction_edges <- tibble::tibble(
  source = c(
    "greenland_ice_sheet",
    "west_antarctic_ice_sheet",
    "amoc",
    "amazon_rainforest",
    "boreal_forest",
    "permafrost_carbon",
    "permafrost_carbon",
    "warm_water_coral_reefs",
    "amazon_rainforest"
  ),
  target = c(
    "amoc",
    "amoc",
    "amazon_rainforest",
    "boreal_forest",
    "permafrost_carbon",
    "greenland_ice_sheet",
    "west_antarctic_ice_sheet",
    "amazon_rainforest",
    "amoc"
  ),
  interaction_weight = c(0.30, 0.18, 0.22, 0.16, 0.20, 0.24, 0.20, 0.08, 0.10)
)

base_scores <- elements %>%
  mutate(
    precautionary_threshold = threshold -
      precaution_factor * threshold_uncertainty,
    pressure_ratio = pressure / precautionary_threshold,
    resilience_gap = 1 - resilience_capacity,
    monitoring_gap = 1 - monitoring_capacity,
    initial_tipped_state = if_else(pressure_ratio >= 1, 1, 0)
  )

cascade_pressure <- interaction_edges %>%
  left_join(
    base_scores %>%
      select(source = element, initial_tipped_state),
    by = "source"
  ) %>%
  mutate(cascade_contribution = interaction_weight * initial_tipped_state) %>%
  group_by(target) %>%
  summarise(
    cascade_pressure = sum(cascade_contribution),
    .groups = "drop"
  )

scored <- base_scores %>%
  left_join(
    cascade_pressure,
    by = c("element" = "target")
  ) %>%
  mutate(
    cascade_pressure = replace_na(cascade_pressure, 0),
    tipping_probability = logistic(
      1.8 * (pressure_ratio - 1) +
        1.2 * cascade_pressure +
        0.8 * feedback_strength -
        0.9 * resilience_capacity
    ),
    cascade_adjusted_risk = tipping_probability *
      (1 + cascade_pressure) *
      (1 + monitoring_gap),
    risk_class = case_when(
      cascade_adjusted_risk < 0.35 ~ "lower_risk",
      cascade_adjusted_risk < 0.75 ~ "moderate_risk",
      TRUE ~ "high_risk"
    )
  ) %>%
  arrange(desc(cascade_adjusted_risk))

dashboard_long <- scored %>%
  select(
    element,
    pressure_ratio,
    feedback_strength,
    resilience_gap,
    cascade_pressure,
    tipping_probability,
    cascade_adjusted_risk
  ) %>%
  pivot_longer(
    cols = -element,
    names_to = "metric",
    values_to = "value"
  )

dir.create(
  "articles/tipping-points-feedback-loops-and-cascading-ecological-change/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/tipping-points-feedback-loops-and-cascading-ecological-change/outputs/r_tipping_scores.csv"
)

write_csv(
  interaction_edges,
  "articles/tipping-points-feedback-loops-and-cascading-ecological-change/outputs/r_interaction_edges.csv"
)

write_csv(
  dashboard_long,
  "articles/tipping-points-feedback-loops-and-cascading-ecological-change/outputs/r_dashboard_long.csv"
)

print(scored)
