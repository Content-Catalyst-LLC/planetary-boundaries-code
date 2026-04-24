# Atmospheric aerosol loading and regional planetary-risk dashboard
#
# This workflow scores aerosol loading across regions using aerosol optical depth,
# PM2.5 exposure, aerosol composition, exposed population, vulnerability,
# hydrological sensitivity, cloud uncertainty, and governance capacity.

library(readr)
library(dplyr)
library(tidyr)

aerosol_regions <- tibble::tibble(
  region = c(
    "south_asia_monsoon_region",
    "east_asia_industrial_corridor",
    "sub_saharan_biomass_burning_belt",
    "arctic_black_carbon_influence_zone",
    "middle_east_dust_corridor",
    "latin_america_fire_frontier",
    "europe_urban_industrial_region"
  ),
  aerosol_optical_depth = c(0.42, 0.36, 0.30, 0.18, 0.34, 0.24, 0.16),
  regional_boundary_reference = c(0.25, 0.25, 0.22, 0.16, 0.24, 0.22, 0.22),
  pm25_exposure = c(0.86, 0.72, 0.64, 0.26, 0.50, 0.46, 0.34),
  black_carbon_share = c(0.28, 0.22, 0.34, 0.46, 0.12, 0.32, 0.14),
  sulfate_share = c(0.34, 0.42, 0.18, 0.10, 0.16, 0.14, 0.32),
  dust_share = c(0.12, 0.10, 0.22, 0.18, 0.52, 0.20, 0.08),
  exposed_population_index = c(0.92, 0.86, 0.70, 0.18, 0.62, 0.54, 0.68),
  vulnerability_index = c(0.78, 0.58, 0.74, 0.52, 0.60, 0.56, 0.34),
  hydrological_sensitivity = c(0.88, 0.66, 0.62, 0.80, 0.48, 0.58, 0.34),
  cloud_uncertainty = c(0.32, 0.28, 0.35, 0.30, 0.26, 0.24, 0.18),
  governance_capacity = c(0.42, 0.56, 0.38, 0.50, 0.46, 0.48, 0.74)
)

scored <- aerosol_regions %>%
  mutate(
    aod_pressure_ratio = aerosol_optical_depth / regional_boundary_reference,
    composition_weight =
      1.30 * black_carbon_share +
      0.85 * sulfate_share +
      0.70 * dust_share,
    health_exposure_score =
      pm25_exposure * exposed_population_index * vulnerability_index,
    climate_hydrology_score =
      aod_pressure_ratio *
      (1 + cloud_uncertainty) *
      hydrological_sensitivity *
      (1 + composition_weight),
    governance_gap = 1 - governance_capacity,
    regional_planetary_risk_score =
      (
        0.35 * aod_pressure_ratio +
        0.35 * health_exposure_score +
        0.30 * climate_hydrology_score
      ) *
      (1 + governance_gap),
    risk_class = case_when(
      regional_planetary_risk_score < 1.0 ~ "lower_risk",
      regional_planetary_risk_score < 2.0 ~ "moderate_risk",
      TRUE ~ "high_risk"
    ),
    dominant_driver = case_when(
      health_exposure_score > climate_hydrology_score ~ "health_exposure",
      black_carbon_share >= 0.30 ~ "black_carbon_and_absorption",
      dust_share >= 0.40 ~ "dust_and_land_atmosphere_linkage",
      TRUE ~ "mixed_aerosol_climate_risk"
    )
  ) %>%
  arrange(desc(regional_planetary_risk_score))

dashboard_long <- scored %>%
  select(
    region,
    aod_pressure_ratio,
    health_exposure_score,
    climate_hydrology_score,
    governance_gap,
    regional_planetary_risk_score
  ) %>%
  pivot_longer(
    cols = -region,
    names_to = "metric",
    values_to = "value"
  )

scenario_grid <- tibble::tibble(
  scenario = c(
    "baseline",
    "clean_energy_and_industry",
    "clean_cooking_and_transport",
    "integrated_regional_policy"
  ),
  aod_multiplier = c(1.00, 0.78, 0.82, 0.65),
  pm25_multiplier = c(1.00, 0.75, 0.70, 0.60),
  black_carbon_multiplier = c(1.00, 0.82, 0.60, 0.55),
  governance_gain = c(0.00, 0.10, 0.12, 0.22)
)

scenario_scores <- aerosol_regions %>%
  crossing(scenario_grid) %>%
  mutate(
    aerosol_optical_depth = aerosol_optical_depth * aod_multiplier,
    pm25_exposure = pm25_exposure * pm25_multiplier,
    black_carbon_share = black_carbon_share * black_carbon_multiplier,
    governance_capacity = pmin(1, governance_capacity + governance_gain),
    aod_pressure_ratio = aerosol_optical_depth / regional_boundary_reference,
    composition_weight =
      1.30 * black_carbon_share +
      0.85 * sulfate_share +
      0.70 * dust_share,
    health_exposure_score =
      pm25_exposure * exposed_population_index * vulnerability_index,
    climate_hydrology_score =
      aod_pressure_ratio *
      (1 + cloud_uncertainty) *
      hydrological_sensitivity *
      (1 + composition_weight),
    governance_gap = 1 - governance_capacity,
    regional_planetary_risk_score =
      (
        0.35 * aod_pressure_ratio +
        0.35 * health_exposure_score +
        0.30 * climate_hydrology_score
      ) *
      (1 + governance_gap),
    risk_class = case_when(
      regional_planetary_risk_score < 1.0 ~ "lower_risk",
      regional_planetary_risk_score < 2.0 ~ "moderate_risk",
      TRUE ~ "high_risk"
    )
  ) %>%
  group_by(scenario) %>%
  mutate(rank = dense_rank(desc(regional_planetary_risk_score))) %>%
  ungroup()

regional_summary <- scored %>%
  group_by(risk_class) %>%
  summarise(
    regions = n(),
    mean_aod_pressure_ratio = mean(aod_pressure_ratio),
    mean_health_exposure_score = mean(health_exposure_score),
    mean_climate_hydrology_score = mean(climate_hydrology_score),
    mean_governance_gap = mean(governance_gap),
    .groups = "drop"
  )

dir.create(
  "articles/atmospheric-aerosol-loading-and-regional-planetary-risk/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/atmospheric-aerosol-loading-and-regional-planetary-risk/outputs/r_regional_aerosol_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/atmospheric-aerosol-loading-and-regional-planetary-risk/outputs/r_dashboard_long.csv"
)

write_csv(
  scenario_scores,
  "articles/atmospheric-aerosol-loading-and-regional-planetary-risk/outputs/r_policy_scenarios.csv"
)

write_csv(
  regional_summary,
  "articles/atmospheric-aerosol-loading-and-regional-planetary-risk/outputs/r_regional_summary.csv"
)

print(scored)
print(regional_summary)
