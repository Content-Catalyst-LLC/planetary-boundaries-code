"""
SDG-boundary alignment scoring workflow.

This workflow models sustainable development as a relationship between:
- SDG achievement
- minimum development thresholds
- ecological pressure
- planetary-boundary-compatible thresholds
- vulnerability
- capacity to act

The data are illustrative. Replace placeholder values with documented
SDG indicators, environmental accounts, vulnerability metrics, and
transparent boundary-allocation assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


IndicatorDomain = Literal["social", "ecological"]


@dataclass(frozen=True)
class IndicatorSpec:
    """Metadata for an SDG-boundary indicator."""

    name: str
    domain: IndicatorDomain
    threshold: float
    direction: Literal["floor", "ceiling"]
    weight: float
    unit: str


def build_indicator_specs() -> list[IndicatorSpec]:
    """Create illustrative indicator specifications."""
    return [
        IndicatorSpec("poverty_reduction", "social", 0.90, "floor", 1.3, "0-1 index"),
        IndicatorSpec("health_access", "social", 0.90, "floor", 1.2, "0-1 index"),
        IndicatorSpec("education_access", "social", 0.90, "floor", 1.1, "0-1 index"),
        IndicatorSpec("clean_energy_access", "social", 0.90, "floor", 1.1, "0-1 index"),
        IndicatorSpec("climate_pressure", "ecological", 1.00, "ceiling", 1.4, "pressure ratio"),
        IndicatorSpec("freshwater_pressure", "ecological", 1.00, "ceiling", 1.1, "pressure ratio"),
        IndicatorSpec("land_pressure", "ecological", 1.00, "ceiling", 1.0, "pressure ratio"),
        IndicatorSpec("nutrient_pressure", "ecological", 1.00, "ceiling", 1.0, "pressure ratio"),
        IndicatorSpec("biosphere_pressure", "ecological", 1.00, "ceiling", 1.2, "pressure ratio"),
    ]


def build_sample_data() -> pd.DataFrame:
    """Create illustrative region-level SDG and boundary data."""
    return pd.DataFrame(
        {
            "region": ["Region A", "Region B", "Region C", "Region D", "Region E"],
            "poverty_reduction": [0.82, 0.95, 0.54, 0.76, 0.88],
            "health_access": [0.78, 0.96, 0.58, 0.72, 0.84],
            "education_access": [0.80, 0.94, 0.52, 0.75, 0.86],
            "clean_energy_access": [0.70, 0.98, 0.46, 0.62, 0.82],
            "climate_pressure": [1.10, 1.85, 0.52, 0.78, 1.20],
            "freshwater_pressure": [0.95, 1.30, 0.72, 1.18, 0.88],
            "land_pressure": [1.05, 1.22, 0.64, 1.35, 0.92],
            "nutrient_pressure": [1.28, 1.55, 0.70, 1.48, 1.05],
            "biosphere_pressure": [1.12, 1.42, 0.66, 1.30, 0.98],
            "vulnerability": [0.54, 0.28, 0.84, 0.72, 0.46],
            "capacity_to_act": [0.52, 0.82, 0.24, 0.38, 0.60],
        }
    )


def score_indicators(
    data: pd.DataFrame,
    specs: list[IndicatorSpec],
) -> pd.DataFrame:
    """Score SDG shortfalls and ecological overshoot in long format."""
    records: list[dict[str, object]] = []

    for _, row in data.iterrows():
        for spec in specs:
            observed = float(row[spec.name])

            if spec.direction == "floor":
                penalty = max(0.0, (spec.threshold - observed) / spec.threshold)
            else:
                penalty = max(0.0, (observed - spec.threshold) / spec.threshold)

            records.append(
                {
                    "region": row["region"],
                    "indicator": spec.name,
                    "domain": spec.domain,
                    "observed": observed,
                    "threshold": spec.threshold,
                    "direction": spec.direction,
                    "weight": spec.weight,
                    "unit": spec.unit,
                    "penalty": penalty,
                }
            )

    return pd.DataFrame.from_records(records)


def weighted_mean(values: pd.Series, weights: pd.Series) -> float:
    """Calculate weighted mean with validation."""
    total_weight = weights.sum()

    if total_weight <= 0:
        raise ValueError("Total weight must be positive.")

    return float((values * weights).sum() / total_weight)


def aggregate_alignment(
    scored: pd.DataFrame,
    region_data: pd.DataFrame,
    alpha: float = 0.5,
    beta: float = 0.5,
) -> pd.DataFrame:
    """Aggregate social shortfall, ecological overshoot, and alignment."""
    social = (
        scored.query("domain == 'social'")
        .groupby("region")
        .apply(lambda g: weighted_mean(g["penalty"], g["weight"]))
        .rename("weighted_sdg_shortfall")
        .reset_index()
    )

    ecological = (
        scored.query("domain == 'ecological'")
        .groupby("region")
        .apply(lambda g: weighted_mean(g["penalty"], g["weight"]))
        .rename("weighted_boundary_overshoot")
        .reset_index()
    )

    result = social.merge(ecological, on="region").merge(
        region_data[["region", "vulnerability", "capacity_to_act"]],
        on="region",
    )

    result["sdg_boundary_alignment_score"] = 1 - (
        alpha * result["weighted_sdg_shortfall"]
        + beta * result["weighted_boundary_overshoot"]
    )

    result["justice_adjusted_risk"] = (
        result["weighted_sdg_shortfall"]
        + result["weighted_boundary_overshoot"]
        + result["vulnerability"]
    ) * (1 + (1 - result["capacity_to_act"]))

    result["diagnostic_class"] = np.select(
        [
            (result["weighted_sdg_shortfall"] == 0)
            & (result["weighted_boundary_overshoot"] == 0),
            (result["weighted_sdg_shortfall"] > 0)
            & (result["weighted_boundary_overshoot"] == 0),
            (result["weighted_sdg_shortfall"] == 0)
            & (result["weighted_boundary_overshoot"] > 0),
        ],
        [
            "within_social_and_ecological_targets",
            "social_shortfall_without_boundary_overshoot",
            "boundary_overshoot_without_social_shortfall",
        ],
        default="combined_social_shortfall_and_boundary_overshoot",
    )

    return result.sort_values(
        "justice_adjusted_risk",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run the SDG-boundary alignment workflow."""
    output_dir = Path(
        "articles/sustainable-development-goals-within-planetary-boundaries/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    specs = build_indicator_specs()
    data = build_sample_data()
    scored = score_indicators(data, specs)
    alignment = aggregate_alignment(scored, data)

    scored.to_csv(output_dir / "indicator_level_scores.csv", index=False)
    alignment.to_csv(output_dir / "sdg_boundary_alignment_scores.csv", index=False)

    print(alignment)


if __name__ == "__main__":
    main()
