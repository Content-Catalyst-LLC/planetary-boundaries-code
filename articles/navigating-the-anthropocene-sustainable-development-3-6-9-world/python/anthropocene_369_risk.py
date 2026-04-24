"""
Anthropocene 3-6-9 risk diagnostics.

This workflow models a simplified 3-6-9 world:
- 3: climate pressure under inadequate mitigation
- 6: biosphere pressure associated with biodiversity loss
- 9: demographic-development demand in a finite Earth system

The workflow also includes:
- planetary-boundary transgression
- cross-pressure amplification
- governance capacity
- adaptive capacity
- justice capacity
- transformation urgency

The values are illustrative. Replace them with documented indicators,
scenario data, population projections, climate pathway data, biodiversity
metrics, governance assessments, and transparent assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskClass = Literal[
    "managed_transition",
    "rising_systemic_risk",
    "high_anthropocene_risk",
    "transformation_urgent",
]


@dataclass(frozen=True)
class AnthropoceneScenario:
    """Scenario profile for Anthropocene 3-6-9 risk analysis."""

    scenario: str
    warming_pressure: float
    biosphere_pressure: float
    development_demand: float
    boundary_transgression_count: int
    governance_capacity: float
    adaptive_capacity: float
    justice_capacity: float
    mitigation_capacity: float
    restoration_capacity: float
    institutional_learning: float


def build_scenarios() -> pd.DataFrame:
    """Create illustrative Anthropocene scenario profiles."""
    scenarios = [
        AnthropoceneScenario("current_fragmented_response", 0.82, 0.88, 0.76, 7, 0.42, 0.48, 0.34, 0.44, 0.38, 0.46),
        AnthropoceneScenario("climate_policy_without_biosphere_repair", 0.62, 0.84, 0.74, 6, 0.50, 0.54, 0.42, 0.62, 0.40, 0.52),
        AnthropoceneScenario("green_growth_with_high_material_demand", 0.58, 0.72, 0.88, 6, 0.56, 0.58, 0.44, 0.68, 0.46, 0.56),
        AnthropoceneScenario("planetary_boundary_aligned_development", 0.42, 0.46, 0.62, 4, 0.72, 0.70, 0.66, 0.76, 0.72, 0.74),
        AnthropoceneScenario("just_transition_and_ecological_restoration", 0.36, 0.38, 0.58, 3, 0.80, 0.76, 0.78, 0.82, 0.80, 0.82),
    ]

    return pd.DataFrame([scenario.__dict__ for scenario in scenarios])


def classify_risk(score: float, transformation_urgency: float) -> RiskClass:
    """Classify Anthropocene risk condition."""
    if score >= 1.40 and transformation_urgency >= 0.75:
        return "transformation_urgent"
    if score >= 1.05:
        return "high_anthropocene_risk"
    if score >= 0.70:
        return "rising_systemic_risk"
    return "managed_transition"


def score_anthropocene_risk(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate 3-6-9 Anthropocene risk diagnostics."""
    scored = data.copy()

    # Normalize boundary transgression count to a 0-1 scale.
    scored["boundary_transgression_pressure"] = (
        scored["boundary_transgression_count"] / 9.0
    )

    # Core 3-6-9 pressure combines warming, biosphere decline, and development demand.
    scored["core_369_pressure"] = (
        0.36 * scored["warming_pressure"]
        + 0.34 * scored["biosphere_pressure"]
        + 0.30 * scored["development_demand"]
    )

    # Cross-pressure amplification captures interaction among the 3-6-9 components.
    scored["cross_pressure_amplification"] = (
        0.35 * scored["warming_pressure"] * scored["biosphere_pressure"]
        + 0.25 * scored["warming_pressure"] * scored["development_demand"]
        + 0.25 * scored["biosphere_pressure"] * scored["development_demand"]
        + 0.15 * scored["boundary_transgression_pressure"]
    )

    # Governance capacity combines institutional, adaptive, justice, mitigation,
    # restoration, and learning dimensions.
    scored["governance_resilience_capacity"] = (
        0.20 * scored["governance_capacity"]
        + 0.18 * scored["adaptive_capacity"]
        + 0.18 * scored["justice_capacity"]
        + 0.16 * scored["mitigation_capacity"]
        + 0.16 * scored["restoration_capacity"]
        + 0.12 * scored["institutional_learning"]
    )

    # Anthropocene risk rises with pressure and amplification,
    # and falls when governance-resilience capacity is high.
    scored["anthropocene_risk_score"] = (
        scored["core_369_pressure"]
        * (1 + scored["cross_pressure_amplification"])
        * (1 - 0.55 * scored["governance_resilience_capacity"])
        * (1 + 0.35 * scored["boundary_transgression_pressure"])
    )

    # Transformation urgency rises when risk is high and governance capacity is weak.
    scored["transformation_urgency"] = (
        scored["anthropocene_risk_score"]
        * (1 - scored["governance_resilience_capacity"])
        * (1 + scored["boundary_transgression_pressure"])
    )

    scored["risk_class"] = [
        classify_risk(score, urgency)
        for score, urgency in zip(
            scored["anthropocene_risk_score"],
            scored["transformation_urgency"],
        )
    ]

    scored["priority"] = np.select(
        [
            scored["risk_class"] == "transformation_urgent",
            scored["biosphere_pressure"] >= 0.75,
            scored["warming_pressure"] >= 0.75,
            scored["justice_capacity"] < 0.45,
            scored["development_demand"] >= 0.80,
        ],
        [
            "system_transformation",
            "biosphere_integrity_repair",
            "accelerated_climate_mitigation",
            "justice_centered_development",
            "resource_demand_reduction",
        ],
        default="integrated_boundary_governance",
    )

    return scored.sort_values(
        "anthropocene_risk_score",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run Anthropocene 3-6-9 risk diagnostics."""
    output_dir = Path(
        "articles/navigating-the-anthropocene-sustainable-development-3-6-9-world/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    scenarios = build_scenarios()
    scored = score_anthropocene_risk(scenarios)

    scored.to_csv(output_dir / "anthropocene_369_risk_scores.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
