# Land-system change and biome-risk dashboard
#
# This workflow scores land-system risk across remaining forest cover,
# biome-specific boundary thresholds, fragmentation risk, ecological quality,
# land-conversion pressure, climate stress, hydrological disruption,
# regulatory importance, restoration potential, monitoring capacity,
# and governance capacity.
#
# Values are illustrative and should be replaced with documented
# forest-cover data, remote-sensing products, land-cover classifications,
# biodiversity data, carbon estimates, hydrological indicators, and
# transparent assumptions before applied use.

library(readr)
library(dplyr)
library(tidyr)

land_profiles <- tibble::tibble(
  biome = c(
    "tropical_forest_frontier",
    "boreal_forest_fire_transition_zone",
    "temperate_forest_agricultural_mosaic",
    "wetland_peatland_conversion_zone",
    "savanna_woodland_agricultural_expansion",
    "restored_forest_corridor_landscape"
  ),
  remaining_forest_ratio = c(0.72, 0.80, 0.46, 0.62, 0.68, 0.82),
  biome_boundary_threshold = c(0.85, 0.85, 0.50, 0.75, 0.75, 0.75),
  fragmentation_risk = c(0.68, 0.42, 0.72, 0.66, 0.58, 0.30),
  ecological_quality = c(0.58, 0.66, 0.52, 0.44, 0.60, 0.78),
  land_conversion_pressure = c(0.82, 0.38, 0.58, 0.70, 0.74, 0.28),
  climate_stress = c(0.66, 0.86, 0.48, 0.62, 0.64, 0.42),
  hydrological_disruption = c(0.72, 0.54, 0.56, 0.88, 0.60, 0.32),
  carbon_storage_importance = c(0.92, 0.88, 0.62, 0.96, 0.58, 0.70),
  moisture_recycling_importance = c(0.94, 0.68, 0.58, 0.82, 0.64, 0.68),
  biodiversity_sensitivity = c(0.96, 0.72, 0.68, 0.84, 0.78, 0.72),
  restoration_potential = c(0.62, 0.48, 0.76, 0.70, 0.66, 0.82),
  monitoring_capacity = c(0.60, 0.68, 0.74, 0.56, 0.52, 0.80),
  governance_capacity = c(0.42, 0.54, 0.62, 0.40, 0.38, 0.72)
)

scored <- land_profiles %>%
  mutate(
    # Boundary pressure exceeds 1 when forest cover falls below the biome threshold.
    forest_boundary_pressure =
      biome_boundary_threshold / remaining_forest_ratio,

    # Boundary deficit shows how far a biome is below its forest-cover threshold.
    forest_boundary_deficit =
      pmax(0, biome_boundary_threshold - remaining_forest_ratio),

    # Biome integrity combines cover, fragmentation, and ecological quality.
    biome_integrity_index =
      remaining_forest_ratio * (1 - fragmentation_risk) * ecological_quality,

    # Regulatory importance combines carbon, water, and biodiversity functions.
    regulatory_importance =
      0.34 * carbon_storage_importance +
      0.33 * moisture_recycling_importance +
      0.33 * biodiversity_sensitivity,

    # Systemic land pressure combines boundary pressure, conversion, climate, water, and fragmentation.
    land_system_pressure =
      0.35 * forest_boundary_pressure +
      0.20 * land_conversion_pressure +
      0.18 * climate_stress +
      0.17 * hydrological_disruption +
      0.10 * fragmentation_risk,

    # Weak monitoring and governance increase land-system risk.
    monitoring_gap = 1 - monitoring_capacity,
    governance_gap = 1 - governance_capacity,

    # Restoration potential reduces risk only when governance capacity exists.
    restoration_credit =
      restoration_potential * governance_capacity * 0.30,

    land_system_risk_score =
      land_system_pressure *
      regulatory_importance *
      (1 + 0.35 * monitoring_gap + 0.45 * governance_gap) -
      restoration_credit,

    risk_class = case_when(
      land_system_risk_score < 0.65 ~ "lower_risk",
      land_system_risk_score < 1.25 ~ "moderate_risk",
      land_system_risk_score < 2.00 ~ "high_risk",
      TRUE ~ "severe_risk"
    ),

    priority = case_when(
      forest_boundary_pressure >= 1.0 ~ "forest_boundary_recovery_priority",
      land_conversion_pressure >= 0.70 ~ "conversion_pressure_reduction_priority",
      fragmentation_risk >= 0.65 ~ "fragmentation_and_corridor_priority",
      hydrological_disruption >= 0.70 ~ "hydrological_function_restoration_priority",
      climate_stress >= 0.75 ~ "climate_resilience_priority",
      governance_capacity < 0.45 ~ "governance_capacity_priority",
      TRUE ~ "integrated_land_system_resilience_priority"
    )
  ) %>%
  arrange(desc(land_system_risk_score))

dashboard_long <- scored %>%
  select(
    biome,
    forest_boundary_pressure,
    forest_boundary_deficit,
    biome_integrity_index,
    regulatory_importance,
    land_system_pressure,
    land_system_risk_score
  ) %>%
  pivot_longer(
    cols = -biome,
    names_to = "metric",
    values_to = "value"
  )

risk_summary <- scored %>%
  group_by(risk_class) %>%
  summarise(
    regions = n(),
    mean_forest_boundary_pressure = mean(forest_boundary_pressure),
    mean_biome_integrity_index = mean(biome_integrity_index),
    mean_regulatory_importance = mean(regulatory_importance),
    mean_land_system_risk_score = mean(land_system_risk_score),
    .groups = "drop"
  )

dir.create(
  "articles/land-system-change-and-ecological-transformation/outputs",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  scored,
  "articles/land-system-change-and-ecological-transformation/outputs/r_land_system_scores.csv"
)

write_csv(
  dashboard_long,
  "articles/land-system-change-and-ecological-transformation/outputs/r_dashboard_long.csv"
)

write_csv(
  risk_summary,
  "articles/land-system-change-and-ecological-transformation/outputs/r_risk_summary.csv"
)

print(scored)
print(risk_summary)
