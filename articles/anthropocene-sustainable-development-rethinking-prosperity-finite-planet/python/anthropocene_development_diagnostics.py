"""
Anthropocene sustainable development diagnostics.

This workflow models prosperity on a finite planet using:
- social foundation achievement
- wellbeing
- ecological pressure
- planetary-boundary pressure
- governance capacity
- justice capacity
- resilience capacity
- material efficiency
- transition urgency

The values are illustrative. Replace them with documented development indicators,
planetary-boundary data, ecological pressure metrics, governance indicators,
justice metrics, resilience assessments, and transparent assumptions before
applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


DevelopmentClass = Literal[
    "safe_and_just_development",
    "social_shortfall",
    "ecological_overshoot",
    "double_challenge",
    "transformation_urgent",
]


@dataclass(frozen=True)
class DevelopmentScenario:
    """Anthropocene sustainable development scenario profile."""

    scenario: str
    wellbeing: float
    social_foundation: float
    ecological_pressure: float
    boundary_pressure: float
    governance_capacity: float
    justice_capacity: float
    resilience_capacity: float
    material_efficiency: float
    mitigation_capacity: float
    restoration_capacity: float


def build_development_scenarios() -> pd.DataFrame:
    """Create illustrative Anthropocene development scenarios."""
    scenarios = [
        DevelopmentScenario("high_growth_high_overshoot", 0.78, 0.72, 0.88, 7 / 9, 0.48, 0.38, 0.44, 0.42, 0.46, 0.36),
        DevelopmentScenario("poverty_reduction_with_fossil_lock_in", 0.62, 0.58, 0.74, 6 / 9, 0.46, 0.44, 0.42, 0.40, 0.38, 0.34),
        DevelopmentScenario("green_growth_with_material_pressure", 0.76, 0.74, 0.70, 6 / 9, 0.60, 0.50, 0.56, 0.62, 0.68, 0.50),
        DevelopmentScenario("planetary_boundary_aligned_development", 0.78, 0.80, 0.48, 4 / 9, 0.72, 0.68, 0.70, 0.74, 0.76, 0.72),
        DevelopmentScenario("safe_and_just_prosperity", 0.84, 0.86, 0.36, 3 / 9, 0.82, 0.80, 0.78, 0.82, 0.84, 0.82),
    ]

    return pd.DataFrame([scenario.__dict__ for scenario in scenarios])


def classify_development(row: pd.Series) -> DevelopmentClass:
    """Classify Anthropocene development condition."""
    social_shortfall = row["social_foundation"] < 0.70
    overshoot = row["boundary_adjusted_pressure"] > 0.70
    urgent = row["transition_urgency"] > 0.55

    if urgent and social_shortfall and overshoot:
        return "transformation_urgent"
    if social_shortfall and overshoot:
        return "double_challenge"
    if overshoot:
        return "ecological_overshoot"
    if social_shortfall:
        return "social_shortfall"
    return "safe_and_just_development"


def score_anthropocene_development(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate Anthropocene sustainable development diagnostics."""
    scored = data.copy()

    # Response capacity combines institutions, justice, resilience, efficiency,
    # mitigation, and restoration.
    scored["response_capacity"] = (
        0.18 * scored["governance_capacity"]
        + 0.18 * scored["justice_capacity"]
        + 0.18 * scored["resilience_capacity"]
        + 0.16 * scored["material_efficiency"]
        + 0.16 * scored["mitigation_capacity"]
        + 0.14 * scored["restoration_capacity"]
    )

    # Boundary-adjusted pressure combines ecological pressure and boundary status.
    scored["boundary_adjusted_pressure"] = (
        0.55 * scored["ecological_pressure"]
        + 0.45 * scored["boundary_pressure"]
    )

    # Sustainable prosperity rises with wellbeing and social foundation achievement,
    # and falls with boundary-adjusted pressure.
    scored["sustainable_prosperity_score"] = (
        scored["wellbeing"]
        * scored["social_foundation"]
        * (1 - 0.65 * scored["boundary_adjusted_pressure"])
        * (1 + 0.45 * scored["response_capacity"])
    )

    # Social foundation gap highlights deprivation or underdevelopment risk.
    scored["social_foundation_gap"] = np.maximum(
        0,
        0.70 - scored["social_foundation"],
    )

    # Overshoot gap highlights ecological pressure beyond a safer reference range.
    scored["overshoot_gap"] = np.maximum(
        0,
        scored["boundary_adjusted_pressure"] - 0.55,
    )

    # Transition urgency rises when overshoot, deprivation, and weak capacity coincide.
    scored["transition_urgency"] = (
        (scored["social_foundation_gap"] + scored["overshoot_gap"])
        * (1 - scored["response_capacity"])
        * (1 + scored["boundary_pressure"])
    )

    scored["development_class"] = scored.apply(classify_development, axis=1)

    scored["priority"] = np.select(
        [
            scored["development_class"] == "transformation_urgent",
            scored["development_class"] == "double_challenge",
            scored["development_class"] == "ecological_overshoot",
            scored["development_class"] == "social_shortfall",
            scored["justice_capacity"] < 0.50,
        ],
        [
            "system_transformation",
            "meet_needs_while_reducing_overshoot",
            "reduce_ecological_pressure",
            "strengthen_social_foundations",
            "justice_centered_development",
        ],
        default="maintain_safe_and_just_development",
    )

    return scored.sort_values(
        "transition_urgency",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run Anthropocene sustainable development diagnostics."""
    output_dir = Path(
        "articles/anthropocene-sustainable-development-rethinking-prosperity-finite-planet/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    scenarios = build_development_scenarios()
    scored = score_anthropocene_development(scenarios)

    scored.to_csv(output_dir / "anthropocene_development_diagnostics.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
