# Critique-aware planetary boundaries dashboard workflow
#
# This script models major critiques of the planetary boundaries framework
# as explicit risk dimensions. The goal is transparent interpretation,
# not false precision.

library(readr)
library(dplyr)
library(tidyr)

critique_data <- tibble::tibble(
  case = c(
    "Global aggregate dashboard",
    "National climate allocation",
    "Corporate science-based target",
    "City-level boundary dashboard",
    "Community-led watershed transition"
  ),
  biophysical = c(0.85, 0.70, 0.62, 0.55, 0.38),
  justice = c(0.72, 0.80, 0.66, 0.52, 0.30),
  legitimacy = c(0.76, 0.68, 0.72, 0.44, 0.22),
  political_economy = c(0.82, 0.76, 0.88, 0.58, 0.35),
  operationalization = c(0.60, 0.65, 0.48, 0.42, 0.36)
)

weights <- tibble::tibble(
  domain = c(
    "biophysical",
    "justice",
    "legitimacy",
    "political_economy",
    "operationalization"
  ),
  weight = c(1, 1, 1, 1, 1)
) %>%
  mutate(weight = weight / sum(weight))

critique_long <- critique_data %>%
  pivot_longer(
    cols = -case,
    names_to = "domain",
    values_to = "risk_score"
  ) %>%
  left_join(weights, by = "domain") %>%
  mutate(weighted_risk = risk_score * weight)

case_scores <- critique_long %>%
  group_by(case) %>%
  summarise(
    total_critique_risk = sum(weighted_risk),
    dominant_risk_domain = domain[which.max(risk_score)],
    dominant_risk_value = max(risk_score),
    .groups = "drop"
  ) %>%
  mutate(
    risk_class = case_when(
      total_critique_risk < 0.33 ~ "low",
      total_critique_risk < 0.66 ~ "moderate",
      TRUE ~ "high"
    )
  ) %>%
  arrange(desc(total_critique_risk))

scenario_weights <- tibble::tibble(
  scenario = c(
    "equal_weight",
    "justice_priority",
    "implementation_priority",
    "political_economy_priority"
  ),
  biophysical = c(1, 1, 1, 1),
  justice = c(1, 2, 1, 1.2),
  legitimacy = c(1, 1.5, 1, 1),
  political_economy = c(1, 1, 1, 2),
  operationalization = c(1, 1, 2, 1)
) %>%
  pivot_longer(
    cols = -scenario,
    names_to = "domain",
    values_to = "raw_weight"
  ) %>%
  group_by(scenario) %>%
  mutate(weight = raw_weight / sum(raw_weight)) %>%
  ungroup()

sensitivity <- critique_data %>%
  pivot_longer(
    cols = -case,
    names_to = "domain",
    values_to = "risk_score"
  ) %>%
  left_join(scenario_weights, by = "domain") %>%
  mutate(weighted_risk = risk_score * weight) %>%
  group_by(scenario, case) %>%
  summarise(
    total_critique_risk = sum(weighted_risk),
    .groups = "drop"
  ) %>%
  group_by(scenario) %>%
  mutate(rank = dense_rank(desc(total_critique_risk))) %>%
  ungroup()

dir.create(
  "articles/critiques-of-the-planetary-boundaries-framework/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  critique_long,
  "articles/critiques-of-the-planetary-boundaries-framework/outputs/r_critique_risk_long.csv"
)

write_csv(
  case_scores,
  "articles/critiques-of-the-planetary-boundaries-framework/outputs/r_case_scores.csv"
)

write_csv(
  sensitivity,
  "articles/critiques-of-the-planetary-boundaries-framework/outputs/r_sensitivity.csv"
)

print(case_scores)
