# Anthropocene sustainable development dashboard
#
# This workflow scores prosperity within planetary limits across:
# wellbeing, social foundation achievement, ecological pressure,
# planetary-boundary pressure, governance capacity, justice capacity,
# resilience capacity, material efficiency, mitigation capacity, and restoration capacity.
#
# Values are illustrative and should be replaced with documented development
# indicators, planetary-boundary data, ecological pressure metrics, governance
# indicators, justice metrics, resilience assessments, and transparent assumptions
# before applied use.

library(readr)
library(dplyr)
library(tidyr)

development_scenarios <- tibble::tibble(
  scenario = c(
    "high_growth_high_overshoot",
    "poverty_reduction_with_fossil_lock_in",
    "green_growth_with_material_pressure",
    "planetary_boundary_aligned_development",
    "safe_and_just_prosperity"
  ),
  wellbeing = c(0.78, 0.62, 0.76, 0.78, 0.84),
  social_foundation = c(0.72, 0.58, 0.74, 0.80, 0.86),
  ecological_pressure = c(0.88, 0.74, 0.70, 0.48, 0.36),
  boundary_pressure = c(7 / 9, 6 / 9, 6 / 9, 4 / 9, 3 / 9),
  governance_capacity = c(0.48, 0.46, 0.60, 0.72, 0.82),
  justice_capacity = c(0.38, 0.44, 0.50, 0.68, 0.80),
  resilience_capacity = c(0.44, 0.42, 0.56, 0.70, 0.78),
  material_efficiency = c(0.42, 0.40, 0.62, 0.74, 0.82),
  mitigation_capacity = c(0.46, 0.38, 0.68, 0.76, 0.84),
  restoration_capacity = c(0.36, 0.34, 0.50, 0.72, 0.82)
)

scored <- development_scenarios %>%
  mutate(
    # Response capacity combines institutions, justice, resilience, efficiency,
    # mitigation, and restoration.
    response_capacity =
      0.18 * governance_capacity +
      0.18 * justice_capacity +
      0.18 * resilience_capacity +
      0.16 * material_efficiency +
      0.16 * mitigation_capacity +
      0.14 * restoration_capacity,

    # Boundary-adjusted pressure combines ecological pressure and boundary status.
    boundary_adjusted_pressure =
      0.55 * ecological_pressure +
      0.45 * boundary_pressure,

    # Sustainable prosperity rises with wellbeing and social foundation achievement,
    # and falls with boundary-adjusted pressure.
    sustainable_prosperity_score =
      wellbeing *
      social_foundation *
      (1 - 0.65 * boundary_adjusted_pressure) *
      (1 + 0.45 * response_capacity),

    # Social foundation gap highlights deprivation or underdevelopment risk.
    social_foundation_gap = pmax(0, 0.70 - social_foundation),

    # Overshoot gap highlights ecological pressure beyond a safer reference range.
    overshoot_gap = pmax(0, boundary_adjusted_pressure - 0.55),

    # Transition urgency rises when overshoot, deprivation, and weak capacity coincide.
    transition_urgency =
      (social_foundation_gap + overshoot_gap) *
      (1 - response_capacity) *
      (1 + boundary_pressure),

    development_class = case_when(
      transition_urgency > 0.55 & social_foundation < 0.70 & boundary_adjusted_pressure > 0.70 ~ "transformation_urgent",
      social_foundation < 0.70 & boundary_adjusted_pressure > 0.70 ~ "double_challenge",
      boundary_adjusted_pressure > 0.70 ~ "ecological_overshoot",
      social_foundation < 0.70 ~ "social_shortfall",
      TRUE ~ "safe_and_just_development"
    ),

    priority = case_when(
      development_class == "transformation_urgent" ~ "system_transformation",
      development_class == "double_challenge" ~ "meet_needs_while_reducing_overshoot",
      development_class == "ecological_overshoot" ~ "reduce_ecological_pressure",
      development_class == "social_shortfall" ~ "strengthen_social_foundations",
      justice_capacity < 0.50 ~ "justice_centered_development",
      TRUE ~ "maintain_safe_and_just_development"
    )
  ) %>%
  arrange(desc(transition_urgency))

dashboard_long <- scored %>%
  select(
    scenario,
    wellbeing,
    social_foundation,
    ecological_pressure,
    boundary_pressure,
    response_capacity,
    boundary_adjusted_pressure,
    sustainable_prosperity_score,
    transition_urgency
  ) %>%
  pivot_longer(
    cols = -scenario,
    names_to = "metric",
    values_to = "value"
  )

summary_by_class <- scored %>%
  group_by(development_class) %>%
  summarise(
    scenarios = n(),
    mean_social_foundation = mean(social_foundation),
    mean_boundary_adjusted_pressure = mean(boundary_adjusted_pressure),
    mean_sustainable_prosperity = mean(sustainable_prosperity_score),
    mean_transition_urgency = mean(transition_urgency),
    .groups = "drop"
  )

dir.create(
  "articles/anthropocene-sustainable-development-rethinking-prosperity-finite-planet/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(scored, "articles/anthropocene-sustainable-development-rethinking-prosperity-finite-planet/outputs/r_anthropocene_development_scores.csv")
write_csv(dashboard_long, "articles/anthropocene-sustainable-development-rethinking-prosperity-finite-planet/outputs/r_anthropocene_development_dashboard_long.csv")
write_csv(summary_by_class, "articles/anthropocene-sustainable-development-rethinking-prosperity-finite-planet/outputs/r_anthropocene_development_summary.csv")

print(scored)
print(summary_by_class)
