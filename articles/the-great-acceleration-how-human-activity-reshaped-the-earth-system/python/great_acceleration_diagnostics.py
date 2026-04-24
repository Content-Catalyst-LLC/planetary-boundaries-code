"""
Great Acceleration diagnostics for planetary-boundary analysis.

This workflow models the Great Acceleration using:
- socio-economic indicators
- Earth-system indicators
- growth rates
- acceleration rates
- socio-ecological coupling
- boundary pressure
- governance capacity
- justice capacity
- transformation urgency

The values are illustrative. Replace them with documented Great Acceleration
datasets, planetary-boundary estimates, emissions data, material-flow data,
land-system data, governance indicators, and transparent assumptions before
applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskClass = Literal[
    "managed_transition",
    "rising_acceleration_risk",
    "high_boundary_pressure",
    "system_transformation_urgent",
]


@dataclass(frozen=True)
class AccelerationProfile:
    """Great Acceleration profile for one coupled indicator pair."""

    indicator_pair: str
    socioeconomic_growth: float
    earth_system_pressure: float
    acceleration_rate: float
    coupling_strength: float
    boundary_pressure_ratio: float
    governance_capacity: float
    justice_capacity: float
    mitigation_capacity: float
    restoration_capacity: float
    lock_in_pressure: float


def build_acceleration_profiles() -> pd.DataFrame:
    """Create illustrative Great Acceleration indicator profiles."""
    profiles = [
        AccelerationProfile("energy_use_and_climate_change", 0.92, 0.88, 0.86, 0.90, 1.28, 0.52, 0.40, 0.48, 0.38, 0.82),
        AccelerationProfile("fertilizer_use_and_biogeochemical_flows", 0.84, 0.90, 0.82, 0.88, 1.62, 0.42, 0.38, 0.44, 0.46, 0.76),
        AccelerationProfile("land_conversion_and_biosphere_integrity", 0.78, 0.92, 0.74, 0.86, 1.75, 0.44, 0.36, 0.42, 0.52, 0.80),
        AccelerationProfile("water_use_and_freshwater_change", 0.76, 0.80, 0.70, 0.78, 1.36, 0.46, 0.42, 0.44, 0.48, 0.66),
        AccelerationProfile("petrochemicals_and_novel_entities", 0.88, 0.94, 0.88, 0.82, 1.80, 0.34, 0.34, 0.36, 0.28, 0.86),
        AccelerationProfile("transport_growth_and_aerosol_loading", 0.72, 0.58, 0.62, 0.60, 0.74, 0.40, 0.36, 0.50, 0.42, 0.62),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def classify_acceleration_risk(score: float, boundary_pressure: float) -> RiskClass:
    """Classify Great Acceleration risk condition."""
    if score >= 1.40 and boundary_pressure >= 1.50:
        return "system_transformation_urgent"
    if boundary_pressure >= 1.00:
        return "high_boundary_pressure"
    if score >= 0.70:
        return "rising_acceleration_risk"
    return "managed_transition"


def score_great_acceleration(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate Great Acceleration diagnostics."""
    scored = data.copy()

    # Human activity pressure combines growth, acceleration, and lock-in.
    scored["human_activity_pressure"] = (
        0.40 * scored["socioeconomic_growth"]
        + 0.35 * scored["acceleration_rate"]
        + 0.25 * scored["lock_in_pressure"]
    )

    # Earth-system stress combines pressure and boundary status.
    scored["earth_system_stress"] = (
        0.55 * scored["earth_system_pressure"]
        + 0.45 * scored["boundary_pressure_ratio"]
    )

    # Governance-response capacity includes governance, justice, mitigation, and restoration.
    scored["response_capacity"] = (
        0.30 * scored["governance_capacity"]
        + 0.25 * scored["justice_capacity"]
        + 0.25 * scored["mitigation_capacity"]
        + 0.20 * scored["restoration_capacity"]
    )

    # Coupled acceleration risk rises when human activity and Earth-system stress move together.
    scored["coupled_acceleration_risk"] = (
        scored["human_activity_pressure"]
        * scored["earth_system_stress"]
        * (1 + scored["coupling_strength"])
        * (1 - 0.50 * scored["response_capacity"])
    )

    # Transformation urgency rises when risk, lock-in, and weak justice capacity coincide.
    scored["transformation_urgency"] = (
        scored["coupled_acceleration_risk"]
        * (1 + scored["lock_in_pressure"])
        * (1 - scored["justice_capacity"])
    )

    scored["risk_class"] = [
        classify_acceleration_risk(score, pressure)
        for score, pressure in zip(
            scored["coupled_acceleration_risk"],
            scored["boundary_pressure_ratio"],
        )
    ]

    scored["priority"] = np.select(
        [
            scored["indicator_pair"].str.contains("climate", regex=False),
            scored["indicator_pair"].str.contains("biogeochemical", regex=False),
            scored["indicator_pair"].str.contains("biosphere", regex=False),
            scored["indicator_pair"].str.contains("freshwater", regex=False),
            scored["indicator_pair"].str.contains("novel_entities", regex=False),
        ],
        [
            "decarbonize_energy_systems",
            "reduce_nutrient_overload",
            "restore_biosphere_integrity",
            "build_freshwater_resilience",
            "control_synthetic_overload",
        ],
        default="integrated_transition_strategy",
    )

    return scored.sort_values(
        "coupled_acceleration_risk",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run Great Acceleration diagnostics."""
    output_dir = Path(
        "articles/the-great-acceleration-how-human-activity-reshaped-the-earth-system/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    profiles = build_acceleration_profiles()
    scored = score_great_acceleration(profiles)

    scored.to_csv(output_dir / "great_acceleration_diagnostics.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
