library(readr)
library(dplyr)

input_file <- "planetary_stewardship_country_panel.csv"
output_file <- "multilevel_stewardship_readiness_summary.csv"

ps_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "territory_name",
  "country_or_region",
  "territory_type",
  "governance_coherence_index",
  "justice_legitimacy_index",
  "restoration_regeneration_index",
  "boundary_pressure_index",
  "urban_transformation_index",
  "community_stewardship_index"
)

missing_cols <- setdiff(required_cols, names(ps_df))
if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

ps_df <- ps_df %>%
  mutate(
    stewardship_readiness_proxy = (
      governance_coherence_index +
      justice_legitimacy_index +
      restoration_regeneration_index +
      urban_transformation_index +
      community_stewardship_index
    ) / 5,
    stewardship_gap = boundary_pressure_index - stewardship_readiness_proxy
  )

summary_df <- ps_df %>%
  group_by(country_or_region, territory_type) %>%
  summarise(
    avg_stewardship_readiness = mean(stewardship_readiness_proxy, na.rm = TRUE),
    avg_boundary_pressure = mean(boundary_pressure_index, na.rm = TRUE),
    avg_stewardship_gap = mean(stewardship_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_stewardship_gap))

write_csv(summary_df, output_file)
cat("Exported:", output_file, "\n")
print(summary_df)
