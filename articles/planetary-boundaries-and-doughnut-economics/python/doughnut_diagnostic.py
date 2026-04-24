"""
Doughnut diagnostic scoring workflow.

This script calculates ecological overshoot, social shortfall,
and a combined safe-and-just performance score using illustrative data.

Replace sample values with documented indicators from authoritative
sources before using this workflow in applied analysis.
"""

from __future__ import annotations

import numpy as np
import pandas as pd


ecological_data = pd.DataFrame(
    {
        "entity": ["Region A", "Region B", "Region C", "Region D"],
        "co2_per_capita": [4.2, 9.8, 2.1, 13.5],
        "material_footprint_per_capita": [8.5, 18.0, 5.2, 24.0],
        "nitrogen_surplus_index": [0.85, 1.45, 0.60, 1.90],
        "land_conversion_index": [0.75, 1.20, 0.55, 1.35],
    }
)

ecological_boundaries = {
    "co2_per_capita": 3.0,
    "material_footprint_per_capita": 8.0,
    "nitrogen_surplus_index": 1.0,
    "land_conversion_index": 1.0,
}

social_data = pd.DataFrame(
    {
        "entity": ["Region A", "Region B", "Region C", "Region D"],
        "basic_health_access": [0.82, 0.96, 0.55, 0.91],
        "education_access": [0.78, 0.94, 0.48, 0.88],
        "clean_energy_access": [0.70, 0.98, 0.42, 0.95],
        "political_voice_index": [0.62, 0.80, 0.35, 0.66],
    }
)

social_foundations = {
    "basic_health_access": 0.90,
    "education_access": 0.90,
    "clean_energy_access": 0.90,
    "political_voice_index": 0.75,
}


def calculate_overshoot(
    df: pd.DataFrame,
    boundaries: dict[str, float],
    entity_col: str = "entity",
) -> pd.DataFrame:
    """Calculate proportional ecological overshoot."""
    result = df[[entity_col]].copy()

    for indicator, boundary in boundaries.items():
        result[f"{indicator}_overshoot"] = np.maximum(
            0,
            (df[indicator] - boundary) / boundary,
        )

    overshoot_cols = [col for col in result.columns if col.endswith("_overshoot")]
    result["mean_ecological_overshoot"] = result[overshoot_cols].mean(axis=1)

    return result


def calculate_shortfall(
    df: pd.DataFrame,
    foundations: dict[str, float],
    entity_col: str = "entity",
) -> pd.DataFrame:
    """Calculate proportional social shortfall."""
    result = df[[entity_col]].copy()

    for indicator, floor in foundations.items():
        result[f"{indicator}_shortfall"] = np.maximum(
            0,
            (floor - df[indicator]) / floor,
        )

    shortfall_cols = [col for col in result.columns if col.endswith("_shortfall")]
    result["mean_social_shortfall"] = result[shortfall_cols].mean(axis=1)

    return result


def classify_doughnut_position(row: pd.Series) -> str:
    """Classify an entity according to overshoot and shortfall."""
    overshoot = row["mean_ecological_overshoot"]
    shortfall = row["mean_social_shortfall"]

    if overshoot == 0 and shortfall == 0:
        return "Inside the safe-and-just space"
    if overshoot > 0 and shortfall == 0:
        return "Social foundation met, ecological ceiling exceeded"
    if overshoot == 0 and shortfall > 0:
        return "Ecological ceiling respected, social foundation unmet"
    return "Both ecological overshoot and social shortfall"


def main() -> None:
    """Run the diagnostic and export results."""
    overshoot_scores = calculate_overshoot(ecological_data, ecological_boundaries)
    shortfall_scores = calculate_shortfall(social_data, social_foundations)

    diagnostic = overshoot_scores.merge(shortfall_scores, on="entity")

    alpha = 0.5
    beta = 0.5

    diagnostic["safe_and_just_score"] = 1 - (
        alpha * diagnostic["mean_ecological_overshoot"]
        + beta * diagnostic["mean_social_shortfall"]
    )

    diagnostic["doughnut_position"] = diagnostic.apply(
        classify_doughnut_position,
        axis=1,
    )

    diagnostic = diagnostic.sort_values(
        by="safe_and_just_score",
        ascending=False,
    ).reset_index(drop=True)

    diagnostic.to_csv(
        "articles/planetary-boundaries-and-doughnut-economics/outputs/doughnut_diagnostic_scores.csv",
        index=False,
    )

    print(diagnostic)


if __name__ == "__main__":
    main()
