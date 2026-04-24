# Novel entities boundary dashboard
#
# This workflow scores synthetic overload across entity classes using
# production, release, persistence, mobility, hazard, exposure,
# monitoring coverage, assessment status, substitution feasibility,
# and essentiality.

library(readr)
library(dplyr)
library(tidyr)

entity_profiles <- tibble::tibble(
  entity_class = c(
    "plastics_and_microplastics",
    "pfas_forever_chemicals",
    "pesticides_and_biocides",
    "industrial_additives",
    "pharmaceutical_residues",
    "flame_retardants",
    "engineered_nanomaterials",
    "radioactive_materials",
    "unknown_or_unregistered_entities"
  ),
  annual_production_index = c(1.00, 0.42, 0.68, 0.74, 0.38, 0.30, 0.24, 0.18, 0.55),
  environmental_release_fraction = c(0.32, 0.28, 0.40, 0.22, 0.36, 0.18, 0.20, 0.08, 0.30),
  persistence = c(0.86, 0.98, 0.54, 0.68, 0.42, 0.74, 0.60, 0.92, 0.70),
  mobility = c(0.62, 0.88, 0.48, 0.46, 0.58, 0.42, 0.64, 0.30, 0.65),
  hazard = c(0.54, 0.82, 0.76, 0.62, 0.52, 0.70, 0.50, 0.95, 0.60),
  exposure = c(0.72, 0.78, 0.70, 0.56, 0.64, 0.50, 0.46, 0.32, 0.62),
  monitoring_coverage = c(0.46, 0.34, 0.52, 0.38, 0.44, 0.40, 0.28, 0.68, 0.12),
  assessment_status = c(
    "partially_assessed",
    "poorly_assessed",
    "partially_assessed",
    "poorly_assessed",
    "partially_assessed",
    "partially_assessed",
    "poorly_assessed",
    "partially_assessed",
    "not_assessed"
  ),
  substitution_feasibility = c(0.58, 0.44, 0.50, 0.48, 0.36, 0.52, 0.42, 0.22, 0.30),
  essentiality = c(0.42, 0.36, 0.58, 0.50, 0.76, 0.46, 0.44, 0.70, 0.40)
)

assessment_weights <- tibble::tibble(
  assessment_status = c(
    "adequately_assessed",
    "partially_assessed",
    "poorly_assessed",
    "not_assessed"
  ),
  assessment_gap = c(0.00, 0.35, 0.70, 1.00)
)

scored <- entity_profiles %>%
  left_join(assessment_weights, by = "assessment_status") %>%
  mutate(
    release_index = annual_production_index * environmental_release_fraction,
    intrinsic_risk = persistence * mobility * hazard * exposure,
    monitoring_gap = 1 - monitoring_coverage,
    governance_gap = 0.55 * assessment_gap + 0.45 * monitoring_gap,
    essential_use_pressure = essentiality * (1 - substitution_feasibility),
    synthetic_overload_score = release_index *
      intrinsic_risk *
      (1 + governance_gap) *
      (1 + essential_use_pressure),
    priority_class = case_when(
      synthetic_overload_score >= 0.22 ~ "urgent_pressure_reduction",
      governance_gap >= 0.65 ~ "assessment_and_monitoring_priority",
      persistence >= 0.85 ~ "persistence_precaution_priority",
      TRUE ~ "standard_control_priority"
    )
  ) %>%
  arrange(desc(synthetic_overload_score))

dashboard_long <- scored %>%
  select(
    entity_class,
    release_index,
    intrinsic_risk,
    assessment_gap,
    monitoring_gap,
    governance_gap,
    synthetic_overload_score
  ) %>%
  pivot_longer(
    cols = -entity_class,
    names_to = "metric",
    values_to = "value"
  )

boundary_summary <- scored %>%
  summarise(
    total_production_index = sum(annual_production_index),
    total_release_index = sum(release_index),
    weighted_synthetic_overload_risk =
      sum(synthetic_overload_score * annual_production_index) /
      sum(annual_production_index),
    average_assessment_gap = mean(assessment_gap),
    average_monitoring_gap = mean(monitoring_gap),
    synthetic_overload_ratio =
      total_release_index * (1 + average_assessment_gap + average_monitoring_gap),
    diagnostic = if_else(
      synthetic_overload_ratio >= 1,
      "outside_safe_operating_space",
      "inside_or_near_safe_operating_space"
    )
  )

dir.create(
  "articles/novel-entities-and-the-problem-of-synthetic-overload/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/novel-entities-and-the-problem-of-synthetic-overload/outputs/r_novel_entities_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/novel-entities-and-the-problem-of-synthetic-overload/outputs/r_dashboard_long.csv"
)

write_csv(
  boundary_summary,
  "articles/novel-entities-and-the-problem-of-synthetic-overload/outputs/r_boundary_summary.csv"
)

print(scored)
print(boundary_summary)
