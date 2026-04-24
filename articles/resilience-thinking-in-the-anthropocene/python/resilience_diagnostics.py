"""
Social-ecological resilience diagnostics for the Anthropocene.

This workflow models resilience using:
- boundary pressure
- disturbance exposure
- functional integrity
- diversity
- redundancy
- adaptive capacity
- learning capacity
- governance capacity
- justice capacity
- incumbent lock-in
- transformation feasibility

The values are illustrative. Replace them with documented ecological indicators,
social vulnerability data, monitoring records, governance assessments, and
transparent assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


ResilienceClass = Literal[
    "adaptive_resilience",
    "fragile_resilience",
    "transformation_needed",
    "maladaptive_resilience",
]


@dataclass(frozen=True)
class ResilienceProfile:
    """Social-ecological resilience profile."""

    system: str
    boundary_pressure: float
    disturbance_exposure: float
    functional_integrity: float
    diversity: float
    redundancy: float
    adaptive_capacity: float
    learning_capacity: float
    governance_capacity: float
    justice_capacity: float
    incumbent_lock_in: float
    transformation_feasibility: float


def build_resilience_profiles() -> pd.DataFrame:
    """Create illustrative social-ecological system profiles."""
    profiles = [
        ResilienceProfile("climate_exposed_coastal_city", 1.34, 0.86, 0.58, 0.52, 0.46, 0.56, 0.62, 0.50, 0.38, 0.62, 0.54),
        ResilienceProfile("industrial_monoculture_food_system", 1.52, 0.72, 0.50, 0.28, 0.34, 0.42, 0.46, 0.40, 0.36, 0.82, 0.48),
        ResilienceProfile("restored_wetland_watershed", 0.74, 0.54, 0.78, 0.82, 0.76, 0.72, 0.78, 0.70, 0.66, 0.24, 0.72),
        ResilienceProfile("fossil_fuel_dependent_region", 1.68, 0.78, 0.62, 0.36, 0.44, 0.38, 0.42, 0.36, 0.32, 0.90, 0.42),
        ResilienceProfile("polycentric_river_basin_governance", 0.92, 0.66, 0.70, 0.74, 0.68, 0.76, 0.80, 0.78, 0.62, 0.36, 0.70),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def logistic_risk(value: pd.Series, steepness: float = 8.0) -> pd.Series:
    """Convert boundary pressure into a smooth threshold-risk score."""
    return 1 / (1 + np.exp(-steepness * (value - 1)))


def classify_resilience(row: pd.Series) -> ResilienceClass:
    """Classify resilience condition."""
    if row["incumbent_lock_in"] >= 0.75 and row["boundary_pressure"] >= 1.0:
        return "maladaptive_resilience"

    if row["systemic_resilience_risk"] >= 1.40 and row["transformation_feasibility"] >= 0.45:
        return "transformation_needed"

    if row["resilience_capacity"] >= 0.65 and row["systemic_resilience_risk"] < 1.0:
        return "adaptive_resilience"

    return "fragile_resilience"


def score_resilience(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate social-ecological resilience diagnostics."""
    scored = data.copy()

    # Threshold risk rises when boundary pressure approaches or exceeds 1.0.
    scored["threshold_risk"] = logistic_risk(scored["boundary_pressure"])

    # Ecological buffering captures functional integrity, diversity, and redundancy.
    scored["ecological_buffering"] = (
        0.40 * scored["functional_integrity"]
        + 0.35 * scored["diversity"]
        + 0.25 * scored["redundancy"]
    )

    # Institutional adaptive capacity combines adaptation, learning, governance, and justice.
    scored["institutional_capacity"] = (
        0.30 * scored["adaptive_capacity"]
        + 0.25 * scored["learning_capacity"]
        + 0.25 * scored["governance_capacity"]
        + 0.20 * scored["justice_capacity"]
    )

    # Overall resilience capacity combines ecological and institutional dimensions.
    scored["resilience_capacity"] = (
        0.52 * scored["ecological_buffering"]
        + 0.48 * scored["institutional_capacity"]
    )

    # Lock-in pressure identifies systems that persist despite boundary stress.
    scored["lock_in_pressure"] = (
        scored["incumbent_lock_in"] * scored["boundary_pressure"]
    )

    # Systemic resilience risk rises with threshold risk, disturbance, and lock-in,
    # and falls with resilience capacity.
    scored["systemic_resilience_risk"] = (
        scored["threshold_risk"]
        * (1 + scored["disturbance_exposure"])
        * (1 + 0.50 * scored["lock_in_pressure"])
        * (1 - scored["resilience_capacity"])
    )

    # Transformation need is highest when risk and lock-in are high but feasible pathways exist.
    scored["transformation_need"] = (
        scored["systemic_resilience_risk"]
        * scored["transformation_feasibility"]
        * (1 + scored["incumbent_lock_in"])
    )

    scored["resilience_class"] = scored.apply(classify_resilience, axis=1)

    # Priority labels make the output easier to interpret.
    scored["priority"] = np.select(
        [
            scored["resilience_class"] == "maladaptive_resilience",
            scored["transformation_need"] >= 0.75,
            scored["justice_capacity"] < 0.45,
            scored["learning_capacity"] < 0.50,
            scored["ecological_buffering"] < 0.50,
        ],
        [
            "weaken_harmful_lock_in",
            "managed_transformation",
            "justice_centered_adaptation",
            "learning_system_investment",
            "restore_ecological_buffers",
        ],
        default="maintain_adaptive_capacity",
    )

    return scored.sort_values(
        "systemic_resilience_risk",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run resilience diagnostics."""
    output_dir = Path("articles/resilience-thinking-in-the-anthropocene/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_resilience_profiles()
    scored = score_resilience(data)

    scored.to_csv(output_dir / "resilience_diagnostics.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
