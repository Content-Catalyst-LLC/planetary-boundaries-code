"""
Advanced Doughnut diagnostic reference pipeline.

Purpose
-------
This script provides an engineering-oriented Python workflow for modeling
ecological overshoot, social shortfall, composite safe-and-just performance,
and sensitivity to weighting assumptions.

The sample data are illustrative. In production, replace them with documented
indicators from authoritative sources such as UN datasets, national statistical
offices, environmental accounts, peer-reviewed planetary-boundary datasets,
or audited institutional reporting systems.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


Domain = Literal["ecological", "social"]


@dataclass(frozen=True)
class IndicatorSpec:
    """Metadata for a Doughnut diagnostic indicator."""

    name: str
    domain: Domain
    threshold: float
    direction: Literal["ceiling", "floor"]
    weight: float = 1.0
    unit: str = "index"
    source: str = "illustrative"


def overshoot(observed: float, ceiling: float) -> float:
    """Return proportional ecological overshoot above a ceiling."""
    if ceiling <= 0:
        raise ValueError("Ceiling must be positive.")
    return max(0.0, (observed - ceiling) / ceiling)


def shortfall(observed: float, floor: float) -> float:
    """Return proportional social shortfall below a floor."""
    if floor <= 0:
        raise ValueError("Floor must be positive.")
    return max(0.0, (floor - observed) / floor)


def weighted_mean(values: pd.Series, weights: pd.Series) -> float:
    """Return a weighted mean with validation."""
    total_weight = weights.sum()
    if total_weight <= 0:
        raise ValueError("Total weight must be positive.")
    return float((values * weights).sum() / total_weight)


def build_indicator_specs() -> list[IndicatorSpec]:
    """Create illustrative indicator metadata."""
    return [
        IndicatorSpec("co2_per_capita", "ecological", 3.0, "ceiling", 1.4, "tCO2/person"),
        IndicatorSpec("material_footprint_per_capita", "ecological", 8.0, "ceiling", 1.2, "tonnes/person"),
        IndicatorSpec("nitrogen_surplus_index", "ecological", 1.0, "ceiling", 1.1, "index"),
        IndicatorSpec("land_conversion_index", "ecological", 1.0, "ceiling", 1.0, "index"),
        IndicatorSpec("basic_health_access", "social", 0.90, "floor", 1.3, "0-1 index"),
        IndicatorSpec("education_access", "social", 0.90, "floor", 1.2, "0-1 index"),
        IndicatorSpec("clean_energy_access", "social", 0.90, "floor", 1.1, "0-1 index"),
        IndicatorSpec("political_voice_index", "social", 0.75, "floor", 1.0, "0-1 index"),
    ]


def build_observations() -> pd.DataFrame:
    """Create illustrative entity-level observations."""
    return pd.DataFrame(
        {
            "entity": ["Region A", "Region B", "Region C", "Region D"],
            "co2_per_capita": [4.2, 9.8, 2.1, 13.5],
            "material_footprint_per_capita": [8.5, 18.0, 5.2, 24.0],
            "nitrogen_surplus_index": [0.85, 1.45, 0.60, 1.90],
            "land_conversion_index": [0.75, 1.20, 0.55, 1.35],
            "basic_health_access": [0.82, 0.96, 0.55, 0.91],
            "education_access": [0.78, 0.94, 0.48, 0.88],
            "clean_energy_access": [0.70, 0.98, 0.42, 0.95],
            "political_voice_index": [0.62, 0.80, 0.35, 0.66],
        }
    )


def score_indicators(observations: pd.DataFrame, specs: list[IndicatorSpec]) -> pd.DataFrame:
    """Convert wide observations into scored long-format diagnostics."""
    records: list[dict[str, object]] = []

    for _, row in observations.iterrows():
        entity = row["entity"]

        for spec in specs:
            observed = float(row[spec.name])

            if spec.direction == "ceiling":
                penalty = overshoot(observed, spec.threshold)
            else:
                penalty = shortfall(observed, spec.threshold)

            records.append(
                {
                    "entity": entity,
                    "indicator": spec.name,
                    "domain": spec.domain,
                    "observed": observed,
                    "threshold": spec.threshold,
                    "direction": spec.direction,
                    "weight": spec.weight,
                    "unit": spec.unit,
                    "source": spec.source,
                    "penalty": penalty,
                }
            )

    return pd.DataFrame.from_records(records)


def aggregate_scores(scored: pd.DataFrame, alpha: float = 0.5, beta: float = 0.5) -> pd.DataFrame:
    """
    Aggregate indicator scores into entity-level diagnostics.

    alpha weights ecological overshoot.
    beta weights social shortfall.
    """
    if alpha < 0 or beta < 0:
        raise ValueError("alpha and beta must be non-negative.")

    ecological = (
        scored.query("domain == 'ecological'")
        .groupby("entity")
        .apply(lambda g: weighted_mean(g["penalty"], g["weight"]))
        .rename("weighted_ecological_overshoot")
        .reset_index()
    )

    social = (
        scored.query("domain == 'social'")
        .groupby("entity")
        .apply(lambda g: weighted_mean(g["penalty"], g["weight"]))
        .rename("weighted_social_shortfall")
        .reset_index()
    )

    result = ecological.merge(social, on="entity")

    result["safe_and_just_score"] = 1 - (
        alpha * result["weighted_ecological_overshoot"]
        + beta * result["weighted_social_shortfall"]
    )

    result["diagnostic_class"] = np.select(
        [
            (result["weighted_ecological_overshoot"] == 0)
            & (result["weighted_social_shortfall"] == 0),
            (result["weighted_ecological_overshoot"] > 0)
            & (result["weighted_social_shortfall"] == 0),
            (result["weighted_ecological_overshoot"] == 0)
            & (result["weighted_social_shortfall"] > 0),
        ],
        [
            "inside_safe_and_just_space",
            "social_foundation_met_ecological_ceiling_exceeded",
            "ecological_ceiling_respected_social_foundation_unmet",
        ],
        default="both_overshoot_and_shortfall",
    )

    return result.sort_values("safe_and_just_score", ascending=False).reset_index(drop=True)


def run_sensitivity(scored: pd.DataFrame) -> pd.DataFrame:
    """
    Evaluate how rankings change under different ecological/social weights.

    This is useful because different institutions may weight ecological risk
    and social shortfall differently. The goal is transparency, not false
    precision.
    """
    scenarios = [
        {"scenario": "equal_weight", "alpha": 0.5, "beta": 0.5},
        {"scenario": "ecological_priority", "alpha": 0.7, "beta": 0.3},
        {"scenario": "social_priority", "alpha": 0.3, "beta": 0.7},
        {"scenario": "strong_precaution", "alpha": 0.8, "beta": 0.2},
    ]

    frames = []

    for scenario in scenarios:
        result = aggregate_scores(
            scored,
            alpha=scenario["alpha"],
            beta=scenario["beta"],
        )
        result["scenario"] = scenario["scenario"]
        result["alpha"] = scenario["alpha"]
        result["beta"] = scenario["beta"]
        result["rank"] = result["safe_and_just_score"].rank(ascending=False, method="dense")
        frames.append(result)

    return pd.concat(frames, ignore_index=True)


def main() -> None:
    """Run the full reference pipeline."""
    output_dir = Path("articles/planetary-boundaries-and-doughnut-economics/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    specs = build_indicator_specs()
    observations = build_observations()

    scored = score_indicators(observations, specs)
    aggregate = aggregate_scores(scored)
    sensitivity = run_sensitivity(scored)

    scored.to_csv(output_dir / "indicator_level_scores.csv", index=False)
    aggregate.to_csv(output_dir / "entity_level_doughnut_scores.csv", index=False)
    sensitivity.to_csv(output_dir / "weight_sensitivity_analysis.csv", index=False)

    print("\nEntity-level Doughnut diagnostic:")
    print(aggregate)

    print("\nSensitivity analysis:")
    print(sensitivity[["scenario", "entity", "safe_and_just_score", "rank"]])


if __name__ == "__main__":
    main()
