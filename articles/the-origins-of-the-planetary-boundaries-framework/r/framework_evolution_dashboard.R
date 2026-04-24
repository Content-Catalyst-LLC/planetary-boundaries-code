# Planetary boundaries framework evolution dashboard
#
# This workflow scores the framework's historical evolution across conceptual
# integration, measurement refinement, governance relevance, policy visibility,
# public legibility, justice integration, uncertainty treatment, and cross-boundary logic.
#
# Values are illustrative and should be replaced with bibliometric records,
# policy documents, citation data, structured literature reviews, and
# transparent coding assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

framework_milestones <- tibble::tibble(
  year = c(2000, 2005, 2009, 2015, 2023, 2024, 2025),
  milestone = c(
    "anthropocene_and_global_change_context",
    "resilience_and_social_ecological_systems_influence",
    "safe_operating_space_formalization",
    "science_refinement_and_core_boundaries",
    "all_nine_boundaries_quantified",
    "fifteen_year_framework_review",
    "planetary_health_check_seven_boundaries_breached"
  ),
  domain = c(
    "earth_system_science",
    "resilience_science",
    "planetary_boundaries",
    "framework_refinement",
    "earth_system_assessment",
    "knowledge_diffusion",
    "assessment_and_governance"
  ),
  conceptual_integration = c(0.58, 0.66, 0.88, 0.92, 0.94, 0.92, 0.94),
  measurement_refinement = c(0.42, 0.46, 0.62, 0.78, 0.88, 0.84, 0.90),
  governance_relevance = c(0.36, 0.44, 0.72, 0.78, 0.84, 0.88, 0.90),
  policy_visibility = c(0.28, 0.34, 0.64, 0.72, 0.80, 0.86, 0.88),
  public_legibility = c(0.34, 0.38, 0.82, 0.84, 0.86, 0.88, 0.90),
  justice_integration = c(0.20, 0.24, 0.32, 0.38, 0.48, 0.56, 0.60),
  uncertainty_treatment = c(0.44, 0.58, 0.68, 0.76, 0.82, 0.84, 0.86),
  cross_boundary_logic = c(0.46, 0.54, 0.78, 0.86, 0.90, 0.88, 0.92)
)

scored <- framework_milestones %>%
  mutate(
    # Scientific maturity combines conceptual, measurement, and uncertainty dimensions.
    scientific_maturity =
      0.45 * conceptual_integration +
      0.35 * measurement_refinement +
      0.20 * uncertainty_treatment,

    # Governance influence combines institutional and communication dimensions.
    governance_influence =
      0.40 * governance_relevance +
      0.35 * policy_visibility +
      0.25 * public_legibility,

    # Systems depth captures whether boundaries are treated as interacting processes.
    systems_depth =
      0.60 * cross_boundary_logic +
      0.25 * uncertainty_treatment +
      0.15 * conceptual_integration,

    # Justice gap helps flag where a technically strong framework needs social interpretation.
    justice_gap = 1 - justice_integration,

    # Operational readiness indicates suitability for dashboards and decision support.
    operational_readiness =
      0.35 * measurement_refinement +
      0.25 * governance_relevance +
      0.20 * uncertainty_treatment +
      0.20 * cross_boundary_logic,

    # Composite influence score balances science, governance, systems logic, and justice.
    framework_influence_score =
      0.30 * scientific_maturity +
      0.28 * governance_influence +
      0.22 * systems_depth +
      0.12 * operational_readiness +
      0.08 * justice_integration,

    influence_class = case_when(
      framework_influence_score < 0.45 ~ "emerging",
      framework_influence_score < 0.65 ~ "consolidating",
      framework_influence_score < 0.82 ~ "institutionalizing",
      TRUE ~ "mainstreaming"
    ),

    interpretive_priority = case_when(
      measurement_refinement < 0.50 ~ "conceptual_foundation_priority",
      justice_integration < 0.40 ~ "justice_and_distribution_priority",
      governance_relevance >= 0.80 ~ "governance_translation_priority",
      cross_boundary_logic >= 0.85 ~ "systems_interaction_priority",
      operational_readiness >= 0.82 ~ "operationalization_priority",
      TRUE ~ "framework_integration_priority"
    )
  ) %>%
  arrange(year)

dashboard_long <- scored %>%
  select(
    year,
    milestone,
    scientific_maturity,
    governance_influence,
    systems_depth,
    justice_gap,
    operational_readiness,
    framework_influence_score
  ) %>%
  pivot_longer(
    cols = -c(year, milestone),
    names_to = "metric",
    values_to = "value"
  )

summary_by_period <- scored %>%
  mutate(
    period = case_when(
      year < 2009 ~ "pre_formalization",
      year == 2009 ~ "formalization",
      year <= 2015 ~ "refinement",
      TRUE ~ "assessment_and_diffusion"
    )
  ) %>%
  group_by(period) %>%
  summarise(
    milestones = n(),
    mean_scientific_maturity = mean(scientific_maturity),
    mean_governance_influence = mean(governance_influence),
    mean_systems_depth = mean(systems_depth),
    mean_framework_influence_score = mean(framework_influence_score),
    .groups = "drop"
  )

dir.create(
  "articles/the-origins-of-the-planetary-boundaries-framework/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/the-origins-of-the-planetary-boundaries-framework/outputs/r_framework_evolution_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/the-origins-of-the-planetary-boundaries-framework/outputs/r_dashboard_long.csv"
)

write_csv(
  summary_by_period,
  "articles/the-origins-of-the-planetary-boundaries-framework/outputs/r_period_summary.csv"
)

print(scored)
print(summary_by_period)
