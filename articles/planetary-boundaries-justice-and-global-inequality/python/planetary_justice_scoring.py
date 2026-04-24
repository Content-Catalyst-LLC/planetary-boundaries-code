"""
Planetary justice and inequality scoring workflow.

This workflow models justice gaps across:
- ecological overuse
- minimum-access shortfall
- vulnerability
- historical contribution
- present capacity to act

The data are illustrative. Replace sample values with documented
environmental accounts, social indicators, vulnerability metrics,
historical responsibility data, and transparent allocation methods
before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd


@dataclass(frozen=True)
class JusticeWeight:
    """Weight assigned to a planetary justice dimension."""

    dimension: str
    weight: float


def normalize_weights(weights: list[JusticeWeight]) -> dict[str, float]:
    """Normalize weights so they sum to one."""
    total = sum(item.weight for item in weights)

    if total <= 0:
        raise ValueError("Total weight must be positive.")

    return {item.dimension: item.weight / total for item in weights}


def build_sample_data() -> pd.DataFrame:
    """Create illustrative group-level planetary justice data."""
    return pd.DataFrame(
        {
            "group": [
                "High-income high-consuming",
                "Middle-income industrializing",
                "Low-income climate-vulnerable",
                "Small island vulnerable",
                "Resource-export dependent",
                "Urban low-income communities",
            ],
            "ecological_use": [2.40, 1.45, 0.55, 0.38, 1.20, 0.62],
            "fair_allocation": [1.00, 1.00, 1.00, 1.00, 1.00, 1.00],
            "social_access": [0.96, 0.78, 0.48, 0.68, 0.58, 0.52],
            "minimum_access": [0.85, 0.85, 0.85, 0.85, 0.85, 0.85],
            "vulnerability": [0.22, 0.45, 0.82, 0.90, 0.66, 0.74],
            "historical_contribution": [0.88, 0.48, 0.12, 0.08, 0.35, 0.18],
            "capacity_to_act": [0.86, 0.58, 0.24, 0.30, 0.42, 0.32],
        }
    )


def score_justice_gaps(
    data: pd.DataFrame,
    weights: dict[str, float],
) -> pd.DataFrame:
    """Calculate planetary justice gap and responsibility-adjusted score."""
    scored = data.copy()

    scored["ecological_overuse"] = np.maximum(
        0,
        (scored["ecological_use"] - scored["fair_allocation"])
        / scored["fair_allocation"],
    )

    scored["minimum_access_shortfall"] = np.maximum(
        0,
        (scored["minimum_access"] - scored["social_access"])
        / scored["minimum_access"],
    )

    scored["planetary_justice_gap"] = (
        scored["ecological_overuse"] * weights["ecological_overuse"]
        + scored["minimum_access_shortfall"] * weights["minimum_access_shortfall"]
        + scored["vulnerability"] * weights["vulnerability"]
    )

    scored["responsibility_adjusted_gap"] = (
        scored["planetary_justice_gap"]
        * (1 + scored["historical_contribution"])
        * (1 + scored["capacity_to_act"])
    )

    scored["dominant_dimension"] = scored[
        ["ecological_overuse", "minimum_access_shortfall", "vulnerability"]
    ].idxmax(axis=1)

    scored["justice_priority_class"] = pd.cut(
        scored["responsibility_adjusted_gap"],
        bins=[-np.inf, 0.40, 0.90, np.inf],
        labels=["lower_priority", "moderate_priority", "high_priority"],
    )

    return scored.sort_values(
        "responsibility_adjusted_gap",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run the planetary justice scoring workflow."""
    output_dir = Path(
        "articles/planetary-boundaries-justice-and-global-inequality/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_sample_data()

    weights = normalize_weights(
        [
            JusticeWeight("ecological_overuse", 1),
            JusticeWeight("minimum_access_shortfall", 1),
            JusticeWeight("vulnerability", 1),
        ]
    )

    scored = score_justice_gaps(data, weights)

    scored.to_csv(output_dir / "planetary_justice_scores.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
