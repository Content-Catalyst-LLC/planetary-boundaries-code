"""
Planetary squeeze diagnostics for planetary-boundary analysis.

This workflow models the planetary squeeze using:
- population pressure
- affluence or consumption pressure
- climate stress
- ecosystem degradation
- planetary-boundary pressure
- interaction amplification
- governance capacity
- adaptive capacity
- justice capacity
- transformation urgency

The values are illustrative. Replace them with documented demographic data,
consumption indicators, climate metrics, ecosystem indicators, boundary data,
governance assessments, and transparent assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskClass = Literal[
    "managed_transition",
    "rising_squeeze_pressure",
    "high_planetary_squeeze",
    "system_transformation_urgent",
]


@dataclass(frozen=True)
class SqueezeScenario:
    """Planetary squeeze scenario profile."""

    scenario: str
    population_pressure: float
    affluence_pressure: float
    climate_stress: float
    ecosystem_degradation: float
    boundary_pressure: float
    governance_capacity: float
    adaptive_capacity: float
    justice_capacity: float
    mitigation_capacity: float
    restoration_capacity: float
    material_efficiency: float


def build_squeeze_scenarios() -> pd.DataFrame:
    """Create illustrative planetary squeeze scenarios."""
    scenarios = [
        SqueezeScenario("current_fragmented_response", 0.78, 0.84, 0.86, 0.88, 7 / 9, 0.42, 0.46, 0.34, 0.42, 0.36, 0.38),
        SqueezeScenario("growth_with_relative_efficiency", 0.80, 0.88, 0.72, 0.78, 6 / 9, 0.50, 0.52, 0.42, 0.58, 0.44, 0.56),
        SqueezeScenario("climate_policy_without_ecosystem_repair", 0.78, 0.76, 0.58, 0.84, 6 / 9, 0.56, 0.58, 0.46, 0.66, 0.40, 0.54),
        SqueezeScenario("planetary_boundary_aligned_development", 0.70, 0.58, 0.46, 0.48, 4 / 9, 0.72, 0.70, 0.66, 0.76, 0.72, 0.74),
        SqueezeScenario("just_transition_and_restoration", 0.66, 0.52, 0.38, 0.36, 3 / 9, 0.82, 0.78, 0.80, 0.84, 0.82, 0.80),
    ]

    return pd.DataFrame([scenario.__dict__ for scenario in scenarios])


def classify_squeeze_risk(score: float, urgency: float) -> RiskClass:
    """Classify planetary squeeze risk condition."""
    if score >= 1.25 and urgency >= 0.70:
        return "system_transformation_urgent"
    if score >= 0.95:
        return "high_planetary_squeeze"
    if score >= 0.65:
        return "rising_squeeze_pressure"
    return "managed_transition"


def score_planetary_squeeze(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate planetary squeeze diagnostics."""
    scored = data.copy()

    # Core squeeze pressure combines the four major structural forces.
    scored["core_squeeze_pressure"] = (
        0.24 * scored["population_pressure"]
        + 0.26 * scored["affluence_pressure"]
        + 0.26 * scored["climate_stress"]
        + 0.24 * scored["ecosystem_degradation"]
    )

    # Interaction amplification captures the fact that the four forces multiply risk.
    scored["interaction_amplification"] = (
        0.22 * scored["population_pressure"] * scored["affluence_pressure"]
        + 0.18 * scored["population_pressure"] * scored["climate_stress"]
        + 0.18 * scored["population_pressure"] * scored["ecosystem_degradation"]
        + 0.18 * scored["affluence_pressure"] * scored["climate_stress"]
        + 0.18 * scored["affluence_pressure"] * scored["ecosystem_degradation"]
        + 0.20 * scored["climate_stress"] * scored["ecosystem_degradation"]
    )

    # Governance-response capacity combines institutional, justice, mitigation,
    # restoration, adaptation, and material-efficiency dimensions.
    scored["response_capacity"] = (
        0.18 * scored["governance_capacity"]
        + 0.16 * scored["adaptive_capacity"]
        + 0.18 * scored["justice_capacity"]
        + 0.18 * scored["mitigation_capacity"]
        + 0.16 * scored["restoration_capacity"]
        + 0.14 * scored["material_efficiency"]
    )

    # Boundary-adjusted squeeze risk rises with core pressure, amplification,
    # and current planetary-boundary transgression.
    scored["planetary_squeeze_risk"] = (
        scored["core_squeeze_pressure"]
        * (1 + scored["interaction_amplification"])
        * (1 + 0.45 * scored["boundary_pressure"])
        * (1 - 0.55 * scored["response_capacity"])
    )

    # Transformation urgency rises when risk is high and response capacity is weak.
    scored["transformation_urgency"] = (
        scored["planetary_squeeze_risk"]
        * (1 - scored["response_capacity"])
        * (1 + scored["boundary_pressure"])
    )

    scored["risk_class"] = [
        classify_squeeze_risk(score, urgency)
        for score, urgency in zip(
            scored["planetary_squeeze_risk"],
            scored["transformation_urgency"],
        )
    ]

    scored["priority"] = np.select(
        [
            scored["risk_class"] == "system_transformation_urgent",
            scored["climate_stress"] >= 0.75,
            scored["ecosystem_degradation"] >= 0.75,
            scored["affluence_pressure"] >= 0.80,
            scored["justice_capacity"] < 0.45,
        ],
        [
            "system_transformation",
            "accelerated_climate_mitigation",
            "ecosystem_restoration",
            "resource_demand_reduction",
            "justice_centered_development",
        ],
        default="integrated_boundary_governance",
    )

    return scored.sort_values(
        "planetary_squeeze_risk",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run planetary squeeze diagnostics."""
    output_dir = Path(
        "articles/the-planetary-squeeze-four-forces-driving-the-sustainability-crisis/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    scenarios = build_squeeze_scenarios()
    scored = score_planetary_squeeze(scenarios)

    scored.to_csv(output_dir / "planetary_squeeze_diagnostics.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
