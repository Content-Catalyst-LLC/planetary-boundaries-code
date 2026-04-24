# Boundary-aligned business strategy dashboard.
#
# This workflow models business units across boundary pressure,
# transition capability, overshoot dependency, supply-chain transparency,
# and revenue-weighted strategic fragility.

library(readr)
library(dplyr)
library(tidyr)

business_units <- tibble::tibble(
  business_unit = c(
    "Durable Products",
    "Disposable Goods",
    "Industrial Chemicals",
    "Circular Services",
    "Agricultural Inputs",
    "Digital Infrastructure"
  ),
  domain = c(
    "climate",
    "land",
    "novel_entities",
    "water",
    "nitrogen",
    "climate"
  ),
  absolute_impact = c(1.20, 1.45, 1.80, 0.75, 1.65, 1.10),
  allocated_budget = c(1, 1, 1, 1, 1, 1),
  transition_capability = c(0.62, 0.38, 0.30, 0.78, 0.42, 0.66),
  overshoot_dependency = c(0.45, 0.82, 0.90, 0.22, 0.76, 0.40),
  supply_chain_transparency = c(0.70, 0.46, 0.35, 0.72, 0.40, 0.68),
  revenue_share = c(0.18, 0.22, 0.16, 0.14, 0.20, 0.10)
)

boundary_weights <- tibble::tibble(
  domain = c(
    "climate",
    "water",
    "land",
    "biosphere",
    "nitrogen",
    "novel_entities"
  ),
  domain_weight = c(1.4, 1.1, 1.0, 1.3, 1.0, 1.2)
)

scored <- business_units %>%
  left_join(boundary_weights, by = "domain") %>%
  mutate(
    alignment_ratio = absolute_impact / allocated_budget,
    boundary_pressure = pmax(0, alignment_ratio - 1) * domain_weight,
    transparency_gap = 1 - supply_chain_transparency,
    strategic_fragility = boundary_pressure *
      (1 - transition_capability) *
      (1 + overshoot_dependency) *
      (1 + transparency_gap),
    revenue_weighted_fragility = revenue_share * strategic_fragility,
    strategic_class = case_when(
      strategic_fragility < 0.15 ~ "lower_fragility",
      strategic_fragility < 0.50 ~ "moderate_fragility",
      TRUE ~ "high_fragility"
    )
  ) %>%
  arrange(desc(revenue_weighted_fragility))

domain_summary <- scored %>%
  group_by(domain) %>%
  summarise(
    revenue_share = sum(revenue_share),
    boundary_pressure = sum(boundary_pressure),
    weighted_fragility = sum(revenue_weighted_fragility),
    mean_transition_capability = mean(transition_capability),
    mean_supply_chain_transparency = mean(supply_chain_transparency),
    .groups = "drop"
  ) %>%
  arrange(desc(weighted_fragility))

scenario_parameters <- tibble::tibble(
  scenario = c(
    "baseline",
    "governance_upgrade",
    "business_model_redesign",
    "deep_alignment"
  ),
  transition_gain = c(0.00, 0.10, 0.20, 0.30),
  dependency_reduction = c(0.00, 0.05, 0.25, 0.40),
  transparency_gain = c(0.00, 0.15, 0.20, 0.30)
)

scenario_scores <- scored %>%
  tidyr::crossing(scenario_parameters) %>%
  mutate(
    scenario_transition_capability = pmin(1, transition_capability + transition_gain),
    scenario_overshoot_dependency = pmax(0, overshoot_dependency - dependency_reduction),
    scenario_transparency = pmin(1, supply_chain_transparency + transparency_gain),
    scenario_transparency_gap = 1 - scenario_transparency,
    scenario_fragility = boundary_pressure *
      (1 - scenario_transition_capability) *
      (1 + scenario_overshoot_dependency) *
      (1 + scenario_transparency_gap),
    scenario_weighted_fragility = revenue_share * scenario_fragility
  )

dashboard_long <- scored %>%
  select(
    business_unit,
    domain,
    revenue_share,
    alignment_ratio,
    boundary_pressure,
    transition_capability,
    overshoot_dependency,
    supply_chain_transparency,
    revenue_weighted_fragility
  ) %>%
  pivot_longer(
    cols = c(
      alignment_ratio,
      boundary_pressure,
      transition_capability,
      overshoot_dependency,
      supply_chain_transparency,
      revenue_weighted_fragility
    ),
    names_to = "metric",
    values_to = "value"
  )

dir.create(
  "articles/business-strategy-within-planetary-boundaries/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/business-strategy-within-planetary-boundaries/outputs/r_business_unit_scores.csv"
)

write_csv(
  domain_summary,
  "articles/business-strategy-within-planetary-boundaries/outputs/r_domain_summary.csv"
)

write_csv(
  scenario_scores,
  "articles/business-strategy-within-planetary-boundaries/outputs/r_transition_scenarios.csv"
)

write_csv(
  dashboard_long,
  "articles/business-strategy-within-planetary-boundaries/outputs/r_dashboard_long.csv"
)

print(domain_summary)
