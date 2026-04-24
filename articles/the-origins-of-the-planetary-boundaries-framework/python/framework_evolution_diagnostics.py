"""
Planetary boundaries framework origins and evolution diagnostics.

This workflow models the framework as a historical, scientific, and governance
architecture using:
- conceptual sources
- framework milestones
- research refinement
- policy influence
- boundary evolution
- governance uptake
- cross-boundary integration
- uncertainty treatment
- justice integration

The values are illustrative. Replace them with bibliometric records, policy
documents, citation data, structured literature reviews, and transparent
coding assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


InfluenceClass = Literal[
    "emerging",
    "consolidating",
    "institutionalizing",
    "mainstreaming",
]


@dataclass(frozen=True)
class FrameworkMilestone:
    """Historical milestone in the evolution of the planetary boundaries framework."""

    year: int
    milestone: str
    domain: str
    conceptual_integration: float
    measurement_refinement: float
    governance_relevance: float
    policy_visibility: float
    public_legibility: float
    justice_integration: float
    uncertainty_treatment: float
    cross_boundary_logic: float


def build_framework_milestones() -> pd.DataFrame:
    """Create illustrative milestones for framework-evolution analysis."""
    milestones = [
        FrameworkMilestone("2000", "anthropocene_and_global_change_context", "earth_system_science", 0.58, 0.42, 0.36, 0.28, 0.34, 0.20, 0.44, 0.46),
        FrameworkMilestone("2005", "resilience_and_social_ecological_systems_influence", "resilience_science", 0.66, 0.46, 0.44, 0.34, 0.38, 0.24, 0.58, 0.54),
        FrameworkMilestone("2009", "safe_operating_space_formalization", "planetary_boundaries", 0.88, 0.62, 0.72, 0.64, 0.82, 0.32, 0.68, 0.78),
        FrameworkMilestone("2015", "science_refinement_and_core_boundaries", "framework_refinement", 0.92, 0.78, 0.78, 0.72, 0.84, 0.38, 0.76, 0.86),
        FrameworkMilestone("2023", "all_nine_boundaries_quantified", "earth_system_assessment", 0.94, 0.88, 0.84, 0.80, 0.86, 0.48, 0.82, 0.90),
        FrameworkMilestone("2024", "fifteen_year_framework_review", "knowledge_diffusion", 0.92, 0.84, 0.88, 0.86, 0.88, 0.56, 0.84, 0.88),
        FrameworkMilestone("2025", "planetary_health_check_seven_boundaries_breached", "assessment_and_governance", 0.94, 0.90, 0.90, 0.88, 0.90, 0.60, 0.86, 0.92),
    ]

    return pd.DataFrame([milestone.__dict__ for milestone in milestones])


def classify_influence(score: float) -> InfluenceClass:
    """Classify framework influence and maturity."""
    if score < 0.45:
        return "emerging"
    if score < 0.65:
        return "consolidating"
    if score < 0.82:
        return "institutionalizing"
    return "mainstreaming"


def score_framework_evolution(data: pd.DataFrame) -> pd.DataFrame:
    """Score framework maturity, influence, and operational readiness."""
    scored = data.copy()

    # Scientific maturity combines conceptual and measurement dimensions.
    scored["scientific_maturity"] = (
        0.45 * scored["conceptual_integration"]
        + 0.35 * scored["measurement_refinement"]
        + 0.20 * scored["uncertainty_treatment"]
    )

    # Governance influence combines relevance, visibility, and public legibility.
    scored["governance_influence"] = (
        0.40 * scored["governance_relevance"]
        + 0.35 * scored["policy_visibility"]
        + 0.25 * scored["public_legibility"]
    )

    # Systems depth captures whether the framework treats boundaries as interacting processes.
    scored["systems_depth"] = (
        0.60 * scored["cross_boundary_logic"]
        + 0.25 * scored["uncertainty_treatment"]
        + 0.15 * scored["conceptual_integration"]
    )

    # Justice gap helps flag where a technically strong framework still needs social interpretation.
    scored["justice_gap"] = 1 - scored["justice_integration"]

    # Operational readiness indicates suitability for dashboards and decision support.
    scored["operational_readiness"] = (
        0.35 * scored["measurement_refinement"]
        + 0.25 * scored["governance_relevance"]
        + 0.20 * scored["uncertainty_treatment"]
        + 0.20 * scored["cross_boundary_logic"]
    )

    # Composite influence score balances science, governance, systems logic, and justice.
    scored["framework_influence_score"] = (
        0.30 * scored["scientific_maturity"]
        + 0.28 * scored["governance_influence"]
        + 0.22 * scored["systems_depth"]
        + 0.12 * scored["operational_readiness"]
        + 0.08 * scored["justice_integration"]
    )

    scored["influence_class"] = scored["framework_influence_score"].apply(
        classify_influence
    )

    # Priority interpretation helps identify what each historical stage contributed.
    scored["interpretive_priority"] = np.select(
        [
            scored["measurement_refinement"] < 0.50,
            scored["justice_integration"] < 0.40,
            scored["governance_relevance"] >= 0.80,
            scored["cross_boundary_logic"] >= 0.85,
            scored["operational_readiness"] >= 0.82,
        ],
        [
            "conceptual_foundation_priority",
            "justice_and_distribution_priority",
            "governance_translation_priority",
            "systems_interaction_priority",
            "operationalization_priority",
        ],
        default="framework_integration_priority",
    )

    return scored.sort_values("year", ascending=True).reset_index(drop=True)


def main() -> None:
    """Run planetary boundaries framework evolution diagnostics."""
    output_dir = Path("articles/the-origins-of-the-planetary-boundaries-framework/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_framework_milestones()
    scored = score_framework_evolution(data)

    scored.to_csv(output_dir / "framework_evolution_scores.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
