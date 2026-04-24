"""
Land-system change and biome-risk diagnostics.

This workflow models land-system change using:
- remaining forest-cover ratio
- biome-specific boundary thresholds
- fragmentation risk
- ecological quality
- land-conversion pressure
- climate stress
- hydrological disruption
- carbon-storage importance
- moisture-recycling importance
- biodiversity sensitivity
- restoration potential
- monitoring and governance capacity

The values are illustrative. Replace them with documented forest-cover data,
remote-sensing products, land-cover classifications, biodiversity data,
carbon estimates, hydrological indicators, and transparent assumptions
before applied use.
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
class LandBiomeProfile:
    """Biome-level land-system profile."""

    biome: str
    remaining_forest_ratio: float
    biome_boundary_threshold: float
    fragmentation_risk: float
    ecological_quality: float
    land_conversion_pressure: float
    climate_stress: float
    hydrological_disruption: float
    carbon_storage_importance: float
    moisture_recycling_importance: float
    biodiversity_sensitivity: float
    restoration_potential: float
    monitoring_capacity: float
    governance_capacity: float


def build_land_profiles() -> pd.DataFrame:
    """Create illustrative biome and landscape profiles."""
    profiles = [
        LandBiomeProfile("tropical_forest_frontier", 0.72, 0.85, 0.68, 0.58, 0.82, 0.66, 0.72, 0.92, 0.94, 0.96, 0.62, 0.60, 0.42),
        LandBiomeProfile("boreal_forest_fire_transition_zone", 0.80, 0.85, 0.42, 0.66, 0.38, 0.86, 0.54, 0.88, 0.68, 0.72, 0.48, 0.68, 0.54),
        LandBiomeProfile("temperate_forest_agricultural_mosaic", 0.46, 0.50, 0.72, 0.52, 0.58, 0.48, 0.56, 0.62, 0.58, 0.68, 0.76, 0.74, 0.62),
        LandBiomeProfile("wetland_peatland_conversion_zone", 0.62, 0.75, 0.66, 0.44, 0.70, 0.62, 0.88, 0.96, 0.82, 0.84, 0.70, 0.56, 0.40),
        LandBiomeProfile("savanna_woodland_agricultural_expansion", 0.68, 0.75, 0.58, 0.60, 0.74, 0.64, 0.60, 0.58, 0.64, 0.78, 0.66, 0.52, 0.38),
        LandBiomeProfile("restored_forest_corridor_landscape", 0.82, 0.75, 0.30, 0.78, 0.28, 0.42, 0.32, 0.70, 0.68, 0.72, 0.82, 0.80, 0.72),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def classify_risk(score: float) -> RiskClass:
    """Classify land-system risk."""
    if score < 0.65:
        return "lower_risk"
    if score < 1.25:
        return "moderate_risk"
    if score < 2.00:
        return "high_risk"
    return "severe_risk"


def score_land_system_change(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate land-system boundary and biome-risk diagnostics."""
    scored = data.copy()

    # Validate ratio fields before calculating boundary pressure.
    for column in ["remaining_forest_ratio", "biome_boundary_threshold"]:
        if (scored[column] <= 0).any():
            raise ValueError(f"{column} must contain only positive values.")

    # Boundary pressure exceeds 1 when forest cover falls below the biome threshold.
    scored["forest_boundary_pressure"] = (
        scored["biome_boundary_threshold"] / scored["remaining_forest_ratio"]
    )

    # Boundary deficit measures how far a biome is below its threshold.
    scored["forest_boundary_deficit"] = np.maximum(
        0,
        scored["biome_boundary_threshold"] - scored["remaining_forest_ratio"],
    )

    # Biome integrity combines cover, fragmentation, and ecological quality.
    scored["biome_integrity_index"] = (
        scored["remaining_forest_ratio"]
        * (1 - scored["fragmentation_risk"])
        * scored["ecological_quality"]
    )

    # Regulatory importance captures carbon, moisture, and biodiversity functions.
    scored["regulatory_importance"] = (
        0.34 * scored["carbon_storage_importance"]
        + 0.33 * scored["moisture_recycling_importance"]
        + 0.33 * scored["biodiversity_sensitivity"]
    )

    # Systemic pressure combines boundary pressure with land, climate, and hydrological stress.
    scored["land_system_pressure"] = (
        0.35 * scored["forest_boundary_pressure"]
        + 0.20 * scored["land_conversion_pressure"]
        + 0.18 * scored["climate_stress"]
        + 0.17 * scored["hydrological_disruption"]
        + 0.10 * scored["fragmentation_risk"]
    )

    # Governance and monitoring gaps increase risk because land-system change is difficult to manage invisibly.
    scored["monitoring_gap"] = 1 - scored["monitoring_capacity"]
    scored["governance_gap"] = 1 - scored["governance_capacity"]

    # Restoration potential reduces long-term risk only when governance capacity exists.
    scored["restoration_credit"] = (
        scored["restoration_potential"]
        * scored["governance_capacity"]
        * 0.30
    )

    scored["land_system_risk_score"] = (
        scored["land_system_pressure"]
        * scored["regulatory_importance"]
        * (1 + 0.35 * scored["monitoring_gap"] + 0.45 * scored["governance_gap"])
        - scored["restoration_credit"]
    )

    scored["risk_class"] = scored["land_system_risk_score"].apply(classify_risk)

    # Priority labels make the workflow more useful for planning and interpretation.
    scored["priority"] = np.select(
        [
            scored["forest_boundary_pressure"] >= 1.0,
            scored["land_conversion_pressure"] >= 0.70,
            scored["fragmentation_risk"] >= 0.65,
            scored["hydrological_disruption"] >= 0.70,
            scored["climate_stress"] >= 0.75,
            scored["governance_capacity"] < 0.45,
        ],
        [
            "forest_boundary_recovery_priority",
            "conversion_pressure_reduction_priority",
            "fragmentation_and_corridor_priority",
            "hydrological_function_restoration_priority",
            "climate_resilience_priority",
            "governance_capacity_priority",
        ],
        default="integrated_land_system_resilience_priority",
    )

    return scored.sort_values(
        "land_system_risk_score",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run the land-system change workflow."""
    output_dir = Path("articles/land-system-change-and-ecological-transformation/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_land_profiles()
    scored = score_land_system_change(data)

    scored.to_csv(output_dir / "land_system_risk_scores.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
