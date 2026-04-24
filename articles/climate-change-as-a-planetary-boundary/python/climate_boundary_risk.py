"""
Climate change planetary-boundary diagnostics.

This workflow models climate boundary pressure using:
- atmospheric CO2 concentration
- CO2 boundary reference
- radiative forcing approximation
- forcing boundary reference
- gross emissions pressure
- mitigation capacity
- carbon sink resilience
- biosphere, land, freshwater, and ocean stress
- monitoring and governance capacity
- scenario testing

The values are illustrative. Replace them with documented atmospheric records,
emissions inventories, radiative forcing datasets, carbon-cycle estimates,
climate-risk indicators, and transparent assumptions before applied use.
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
class ClimateRegionProfile:
    """Regional or portfolio-level climate-boundary profile."""

    region: str
    co2_concentration_ppm: float
    co2_boundary_ppm: float
    co2_baseline_ppm: float
    forcing_boundary_wm2: float
    gross_emissions_pressure: float
    mitigation_capacity: float
    carbon_sink_resilience: float
    biosphere_stress: float
    land_system_pressure: float
    freshwater_stress: float
    ocean_stress: float
    heat_extreme_exposure: float
    infrastructure_exposure: float
    adaptive_capacity: float
    monitoring_capacity: float
    governance_capacity: float


def build_climate_profiles() -> pd.DataFrame:
    """Create illustrative climate-boundary profiles."""
    profiles = [
        ClimateRegionProfile("high_emissions_industrial_system", 429.8, 350.0, 280.0, 1.0, 0.92, 0.42, 0.48, 0.66, 0.58, 0.54, 0.62, 0.72, 0.78, 0.58, 0.74, 0.52),
        ClimateRegionProfile("rapid_transition_clean_energy_system", 429.8, 350.0, 280.0, 1.0, 0.52, 0.76, 0.66, 0.48, 0.42, 0.46, 0.54, 0.56, 0.50, 0.70, 0.82, 0.74),
        ClimateRegionProfile("climate_vulnerable_coastal_delta", 429.8, 350.0, 280.0, 1.0, 0.38, 0.36, 0.42, 0.72, 0.60, 0.82, 0.78, 0.86, 0.88, 0.34, 0.52, 0.38),
        ClimateRegionProfile("forest_carbon_sink_transition_zone", 429.8, 350.0, 280.0, 1.0, 0.46, 0.58, 0.38, 0.82, 0.76, 0.58, 0.42, 0.70, 0.46, 0.48, 0.66, 0.44),
        ClimateRegionProfile("arid_heat_and_water_stress_region", 429.8, 350.0, 280.0, 1.0, 0.44, 0.40, 0.36, 0.64, 0.52, 0.88, 0.30, 0.92, 0.72, 0.32, 0.50, 0.36),
        ClimateRegionProfile("resilient_low_carbon_region", 429.8, 350.0, 280.0, 1.0, 0.28, 0.82, 0.78, 0.36, 0.30, 0.34, 0.40, 0.42, 0.38, 0.78, 0.84, 0.80),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def classify_risk(score: float) -> RiskClass:
    """Classify climate-boundary risk."""
    if score < 0.95:
        return "lower_risk"
    if score < 1.75:
        return "moderate_risk"
    if score < 2.75:
        return "high_risk"
    return "severe_risk"


def calculate_co2_forcing(co2_ppm: pd.Series, baseline_ppm: pd.Series) -> pd.Series:
    """Approximate radiative forcing from CO2 concentration."""
    return 5.35 * np.log(co2_ppm / baseline_ppm)


def score_climate_boundary(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate climate-boundary and systems-risk diagnostics."""
    scored = data.copy()

    # Validate denominator fields before calculating ratios.
    required_positive = [
        "co2_boundary_ppm",
        "co2_baseline_ppm",
        "forcing_boundary_wm2",
    ]

    for column in required_positive:
        if (scored[column] <= 0).any():
            raise ValueError(f"{column} must contain only positive values.")

    # CO2 pressure compares current concentration with the boundary reference.
    scored["co2_boundary_pressure"] = (
        scored["co2_concentration_ppm"] / scored["co2_boundary_ppm"]
    )

    # Radiative forcing is approximated from CO2 concentration and baseline.
    scored["co2_radiative_forcing_wm2"] = calculate_co2_forcing(
        scored["co2_concentration_ppm"],
        scored["co2_baseline_ppm"],
    )

    # Forcing pressure compares calculated forcing with the boundary reference.
    scored["forcing_boundary_pressure"] = (
        scored["co2_radiative_forcing_wm2"] / scored["forcing_boundary_wm2"]
    )

    # Cross-boundary stress captures climate interactions with Earth-system processes.
    scored["cross_boundary_stress"] = (
        0.26 * scored["biosphere_stress"]
        + 0.24 * scored["land_system_pressure"]
        + 0.22 * scored["freshwater_stress"]
        + 0.18 * scored["ocean_stress"]
        + 0.10 * (1 - scored["carbon_sink_resilience"])
    )

    # Exposure combines heat and infrastructure vulnerability.
    scored["exposure_pressure"] = (
        0.55 * scored["heat_extreme_exposure"]
        + 0.45 * scored["infrastructure_exposure"]
    )

    # Transition gap rises when emissions pressure is high and mitigation capacity is low.
    scored["transition_gap"] = (
        scored["gross_emissions_pressure"] * (1 - scored["mitigation_capacity"])
    )

    # Governance and monitoring gaps affect capacity to respond.
    scored["adaptive_capacity_gap"] = 1 - scored["adaptive_capacity"]
    scored["monitoring_gap"] = 1 - scored["monitoring_capacity"]
    scored["governance_gap"] = 1 - scored["governance_capacity"]

    # Composite score emphasizes planetary forcing and regional/systemic vulnerability.
    scored["climate_boundary_risk_score"] = (
        0.24 * scored["co2_boundary_pressure"]
        + 0.24 * scored["forcing_boundary_pressure"]
        + 0.18 * scored["cross_boundary_stress"]
        + 0.14 * scored["exposure_pressure"]
        + 0.12 * scored["transition_gap"]
        + 0.08 * (
            0.40 * scored["adaptive_capacity_gap"]
            + 0.25 * scored["monitoring_gap"]
            + 0.35 * scored["governance_gap"]
        )
    )

    scored["risk_class"] = scored["climate_boundary_risk_score"].apply(classify_risk)

    # Priority labels make the output useful for interpretation and planning.
    scored["priority"] = np.select(
        [
            scored["transition_gap"] >= 0.45,
            scored["carbon_sink_resilience"] <= 0.45,
            scored["freshwater_stress"] >= 0.80,
            scored["heat_extreme_exposure"] >= 0.80,
            scored["governance_capacity"] < 0.45,
            scored["mitigation_capacity"] >= 0.75,
        ],
        [
            "rapid_mitigation_priority",
            "carbon_sink_protection_priority",
            "water_climate_resilience_priority",
            "heat_adaptation_priority",
            "governance_capacity_priority",
            "transition_acceleration_priority",
        ],
        default="integrated_climate_resilience_priority",
    )

    return scored.sort_values(
        "climate_boundary_risk_score",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run the climate boundary workflow."""
    output_dir = Path("articles/climate-change-as-a-planetary-boundary/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_climate_profiles()
    scored = score_climate_boundary(data)

    scored.to_csv(output_dir / "climate_boundary_risk_scores.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
