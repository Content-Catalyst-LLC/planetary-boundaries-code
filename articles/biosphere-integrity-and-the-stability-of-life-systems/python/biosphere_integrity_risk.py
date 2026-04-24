"""
Biosphere integrity and life-system risk diagnostics.

This workflow models biosphere integrity using:
- extinction pressure
- genetic-diversity pressure
- functional integrity
- habitat intactness
- fragmentation risk
- human appropriation of net primary production
- ecological sensitivity
- restoration potential
- monitoring capacity
- governance capacity
- interactions with climate, land, freshwater, nutrients, and novel entities

The values are illustrative. Replace them with documented biodiversity data,
IUCN Red List data, ecosystem-condition datasets, remote-sensing products,
primary productivity estimates, habitat connectivity metrics, and transparent
assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskClass = Literal[
    "lower_risk",
    "moderate_risk",
    "high_risk",
    "severe_risk",
]


@dataclass(frozen=True)
class BiosphereRegionProfile:
    """Regional biosphere-integrity profile."""

    region: str
    observed_extinction_pressure: float
    genetic_boundary_reference: float
    functional_integrity_index: float
    functional_integrity_threshold: float
    habitat_intactness: float
    fragmentation_risk: float
    appropriation_pressure: float
    ecological_sensitivity: float
    climate_stress: float
    land_system_pressure: float
    freshwater_stress: float
    nutrient_pollution_pressure: float
    novel_entity_pressure: float
    restoration_potential: float
    monitoring_capacity: float
    governance_capacity: float


def build_biosphere_profiles() -> pd.DataFrame:
    """Create illustrative biosphere-integrity profiles."""
    profiles = [
        BiosphereRegionProfile("tropical_forest_biodiversity_frontier", 9.2, 1.0, 0.52, 0.80, 0.58, 0.72, 0.76, 0.94, 0.62, 0.84, 0.60, 0.44, 0.52, 0.68, 0.58, 0.40),
        BiosphereRegionProfile("temperate_agricultural_mosaic", 5.8, 1.0, 0.56, 0.78, 0.46, 0.78, 0.82, 0.70, 0.48, 0.68, 0.54, 0.76, 0.64, 0.78, 0.72, 0.58),
        BiosphereRegionProfile("freshwater_wetland_complex", 7.4, 1.0, 0.50, 0.82, 0.54, 0.66, 0.58, 0.88, 0.56, 0.62, 0.86, 0.70, 0.50, 0.74, 0.60, 0.46),
        BiosphereRegionProfile("coral_reef_and_coastal_marine_system", 8.6, 1.0, 0.44, 0.80, 0.50, 0.52, 0.62, 0.96, 0.88, 0.40, 0.46, 0.68, 0.72, 0.52, 0.64, 0.42),
        BiosphereRegionProfile("boreal_forest_fire_transition_zone", 3.6, 1.0, 0.66, 0.82, 0.72, 0.42, 0.44, 0.74, 0.86, 0.56, 0.42, 0.28, 0.36, 0.48, 0.68, 0.54),
        BiosphereRegionProfile("restored_connected_landscape", 1.8, 1.0, 0.76, 0.80, 0.82, 0.28, 0.34, 0.58, 0.42, 0.32, 0.34, 0.30, 0.34, 0.84, 0.80, 0.72),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def classify_risk(score: float) -> RiskClass:
    """Classify biosphere-integrity risk."""
    if score < 0.85:
        return "lower_risk"
    if score < 1.75:
        return "moderate_risk"
    if score < 3.00:
        return "high_risk"
    return "severe_risk"


def score_biosphere_integrity(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate genetic, functional, and systemic biosphere-risk diagnostics."""
    scored = data.copy()

    # Validate denominators and threshold fields before calculating ratios.
    for column in ["genetic_boundary_reference", "functional_integrity_threshold"]:
        if (scored[column] <= 0).any():
            raise ValueError(f"{column} must contain only positive values.")

    # Genetic pressure compares observed extinction pressure to the boundary reference.
    scored["genetic_diversity_pressure"] = (
        scored["observed_extinction_pressure"] / scored["genetic_boundary_reference"]
    )

    # Functional deficit measures how far functional integrity falls below the threshold.
    scored["functional_integrity_deficit"] = np.maximum(
        0,
        scored["functional_integrity_threshold"] - scored["functional_integrity_index"],
    )

    # Habitat loss pressure rises as intactness declines.
    scored["habitat_loss_pressure"] = 1 - scored["habitat_intactness"]

    # Cross-boundary stress captures how other planetary pressures interact with the biosphere.
    scored["cross_boundary_stress"] = (
        0.24 * scored["climate_stress"]
        + 0.24 * scored["land_system_pressure"]
        + 0.18 * scored["freshwater_stress"]
        + 0.18 * scored["nutrient_pollution_pressure"]
        + 0.16 * scored["novel_entity_pressure"]
    )

    # Biosphere pressure combines genetic, functional, habitat, fragmentation, appropriation, and systemic stress.
    scored["biosphere_pressure"] = (
        0.26 * scored["genetic_diversity_pressure"]
        + 0.22 * scored["functional_integrity_deficit"]
        + 0.16 * scored["habitat_loss_pressure"]
        + 0.14 * scored["fragmentation_risk"]
        + 0.12 * scored["appropriation_pressure"]
        + 0.10 * scored["cross_boundary_stress"]
    )

    # Governance and monitoring gaps increase risk because ecological decline is hard to reverse if unseen.
    scored["monitoring_gap"] = 1 - scored["monitoring_capacity"]
    scored["governance_gap"] = 1 - scored["governance_capacity"]

    # Restoration potential reduces long-term risk only when governance capacity exists.
    scored["restoration_credit"] = (
        0.35 * scored["restoration_potential"] * scored["governance_capacity"]
    )

    scored["biosphere_integrity_risk_score"] = (
        scored["biosphere_pressure"]
        * scored["ecological_sensitivity"]
        * (1 + 0.30 * scored["monitoring_gap"] + 0.45 * scored["governance_gap"])
        - scored["restoration_credit"]
    )

    scored["risk_class"] = scored["biosphere_integrity_risk_score"].apply(classify_risk)

    # Priority labels make the output useful for interpretation and planning.
    scored["priority"] = np.select(
        [
            scored["genetic_diversity_pressure"] >= 8.0,
            scored["functional_integrity_deficit"] >= 0.25,
            scored["fragmentation_risk"] >= 0.70,
            scored["appropriation_pressure"] >= 0.75,
            scored["cross_boundary_stress"] >= 0.70,
            scored["governance_capacity"] < 0.45,
        ],
        [
            "genetic_diversity_and_extinction_priority",
            "functional_integrity_recovery_priority",
            "habitat_connectivity_priority",
            "biomass_appropriation_reduction_priority",
            "cross_boundary_stress_reduction_priority",
            "governance_capacity_priority",
        ],
        default="integrated_biosphere_resilience_priority",
    )

    return scored.sort_values(
        "biosphere_integrity_risk_score",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run the biosphere integrity workflow."""
    output_dir = Path("articles/biosphere-integrity-and-the-stability-of-life-systems/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_biosphere_profiles()
    scored = score_biosphere_integrity(data)

    scored.to_csv(output_dir / "biosphere_integrity_risk_scores.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
