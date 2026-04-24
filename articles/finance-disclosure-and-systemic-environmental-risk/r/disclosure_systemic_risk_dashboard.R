# Portfolio-level systemic environmental risk dashboard.
#
# This workflow combines boundary pressure, disclosure adequacy,
# transition credibility, uncertainty, and portfolio weight.

library(readr)
library(dplyr)
library(tidyr)

portfolio <- tibble::tibble(
  issuer = c(
    "Utility A",
    "Agribusiness B",
    "Chemicals C",
    "Infrastructure D",
    "Bank E",
    "Retail F"
  ),
  portfolio_weight = c(0.18, 0.16, 0.14, 0.20, 0.22, 0.10),
  domain = c(
    "climate",
    "land",
    "novel_entities",
    "water",
    "climate",
    "biosphere"
  ),
  exposure_pressure = c(1.45, 1.25, 1.70, 1.10, 1.35, 0.95),
  disclosure_adequacy = c(0.70, 0.42, 0.35, 0.62, 0.78, 0.50),
  transition_credibility = c(0.55, 0.38, 0.30, 0.58, 0.64, 0.45),
  uncertainty = c(0.25, 0.40, 0.50, 0.30, 0.20, 0.35)
)

boundary_specs <- tibble::tibble(
  domain = c(
    "climate",
    "water",
    "land",
    "biosphere",
    "nitrogen",
    "novel_entities"
  ),
  boundary_threshold = c(1, 1, 1, 1, 1, 1),
  domain_weight = c(1.5, 1.1, 1.0, 1.3, 0.9, 1.2)
)

scored <- portfolio %>%
  left_join(boundary_specs, by = "domain") %>%
  mutate(
    boundary_pressure_ratio = exposure_pressure / boundary_threshold,
    disclosure_gap = 1 - disclosure_adequacy,
    transition_gap = 1 - transition_credibility,
    risk_score = boundary_pressure_ratio *
      (1 + disclosure_gap) *
      (1 + transition_gap) *
      (1 + uncertainty) *
      domain_weight,
    portfolio_contribution = portfolio_weight * risk_score
  )

domain_summary <- scored %>%
  group_by(domain) %>%
  summarise(
    portfolio_weight = sum(portfolio_weight),
    weighted_risk = sum(portfolio_contribution),
    mean_disclosure_adequacy = mean(disclosure_adequacy),
    mean_transition_credibility = mean(transition_credibility),
    mean_uncertainty = mean(uncertainty),
    .groups = "drop"
  ) %>%
  arrange(desc(weighted_risk))

issuer_summary <- scored %>%
  arrange(desc(portfolio_contribution)) %>%
  mutate(
    risk_class = case_when(
      portfolio_contribution < 0.25 ~ "lower",
      portfolio_contribution < 0.50 ~ "moderate",
      TRUE ~ "elevated"
    )
  )

dashboard_long <- scored %>%
  select(
    issuer,
    domain,
    portfolio_weight,
    boundary_pressure_ratio,
    disclosure_adequacy,
    transition_credibility,
    uncertainty,
    portfolio_contribution
  ) %>%
  pivot_longer(
    cols = c(
      boundary_pressure_ratio,
      disclosure_adequacy,
      transition_credibility,
      uncertainty,
      portfolio_contribution
    ),
    names_to = "metric",
    values_to = "value"
  )

dir.create(
  "articles/finance-disclosure-and-systemic-environmental-risk/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/finance-disclosure-and-systemic-environmental-risk/outputs/r_issuer_scores.csv"
)

write_csv(
  domain_summary,
  "articles/finance-disclosure-and-systemic-environmental-risk/outputs/r_domain_summary.csv"
)

write_csv(
  issuer_summary,
  "articles/finance-disclosure-and-systemic-environmental-risk/outputs/r_issuer_summary.csv"
)

write_csv(
  dashboard_long,
  "articles/finance-disclosure-and-systemic-environmental-risk/outputs/r_dashboard_long.csv"
)

print(domain_summary)
