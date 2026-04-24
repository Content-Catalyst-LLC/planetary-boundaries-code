"""
Atmospheric aerosol loading regional planetary-risk workflow.

This workflow models aerosol loading using:
- aerosol optical depth
- PM2.5 exposure
- black carbon share
- sulfate share
- dust share
- exposed population index
- vulnerability
- hydrological sensitivity
- cloud interaction uncertainty
- governance capacity

The values are illustrative. Replace them with documented satellite
retrievals, ground monitoring, atmospheric chemistry model outputs,
public-health data, and transparent regional assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskClass = Literal["lower_risk", "moderate_risk", "high_risk"]


@dataclass(frozen=True)
class AerosolRegion:
    """Regional aerosol-risk profile."""

    region: str
    aerosol_optical_depth: float
    regional_boundary_reference: float
    pm25_exposure: float
    black_carbon_share: float
    sulfate_share: float
    dust_share: float
    exposed_population_index: float
    vulnerability_index: float
    hydrological_sensitivity: float
    cloud_uncertainty: float
    governance_capacity: float


def build_aerosol_regions() -> pd.DataFrame:
    """Create illustrative regional aerosol data."""
    regions = [
        AerosolRegion("south_asia_monsoon_region", 0.42, 0.25, 0.86, 0.28, 0.34, 0.12, 0.92, 0.78, 0.88, 0.32, 0.42),
        AerosolRegion("east_asia_industrial_corridor", 0.36, 0.25, 0.72, 0.22, 0.42, 0.10, 0.86, 0.58, 0.66, 0.28, 0.56),
        AerosolRegion("sub_saharan_biomass_burning_belt", 0.30, 0.22, 0.64, 0.34, 0.18, 0.22, 0.70, 0.74, 0.62, 0.35, 0.38),
        AerosolRegion("arctic_black_carbon_influence_zone", 0.18, 0.16, 0.26, 0.46, 0.10, 0.18, 0.18, 0.52, 0.80, 0.30, 0.50),
        AerosolRegion("middle_east_dust_corridor", 0.34, 0.24, 0.50, 0.12, 0.16, 0.52, 0.62, 0.60, 0.48, 0.26, 0.46),
        AerosolRegion("latin_america_fire_frontier", 0.24, 0.22, 0.46, 0.32, 0.14, 0.20, 0.54, 0.56, 0.58, 0.24, 0.48),
        AerosolRegion("europe_urban_industrial_region", 0.16, 0.22, 0.34, 0.14, 0.32, 0.08, 0.68, 0.34, 0.34, 0.18, 0.74),
    ]

    return pd.DataFrame([region.__dict__ for region in regions])


def classify_risk(score: float) -> RiskClass:
    """Classify regional aerosol risk."""
    if score < 1.0:
        return "lower_risk"
    if score < 2.0:
        return "moderate_risk"
    return "high_risk"


def score_aerosol_risk(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate regional aerosol-loading risk diagnostics."""
    scored = data.copy()

    if (scored["regional_boundary_reference"] <= 0).any():
        raise ValueError("Regional boundary reference values must be positive.")

    scored["aod_pressure_ratio"] = (
        scored["aerosol_optical_depth"] / scored["regional_boundary_reference"]
    )

    scored["composition_weight"] = (
        1.30 * scored["black_carbon_share"]
        + 0.85 * scored["sulfate_share"]
        + 0.70 * scored["dust_share"]
    )

    scored["health_exposure_score"] = (
        scored["pm25_exposure"]
        * scored["exposed_population_index"]
        * scored["vulnerability_index"]
    )

    scored["climate_hydrology_score"] = (
        scored["aod_pressure_ratio"]
        * (1 + scored["cloud_uncertainty"])
        * scored["hydrological_sensitivity"]
        * (1 + scored["composition_weight"])
    )

    scored["governance_gap"] = 1 - scored["governance_capacity"]

    scored["regional_planetary_risk_score"] = (
        0.35 * scored["aod_pressure_ratio"]
        + 0.35 * scored["health_exposure_score"]
        + 0.30 * scored["climate_hydrology_score"]
    ) * (1 + scored["governance_gap"])

    scored["risk_class"] = scored["regional_planetary_risk_score"].apply(classify_risk)

    scored["dominant_driver"] = np.select(
        [
            scored["health_exposure_score"] > scored["climate_hydrology_score"],
            scored["black_carbon_share"] >= 0.30,
            scored["dust_share"] >= 0.40,
        ],
        [
            "health_exposure",
            "black_carbon_and_absorption",
            "dust_and_land_atmosphere_linkage",
        ],
        default="mixed_aerosol_climate_risk",
    )

    return scored.sort_values(
        "regional_planetary_risk_score",
        ascending=False,
    ).reset_index(drop=True)


def run_policy_scenarios(data: pd.DataFrame) -> pd.DataFrame:
    """Test how risk changes under policy scenarios."""
    scenarios = {
        "baseline": {
            "aod_multiplier": 1.00,
            "pm25_multiplier": 1.00,
            "black_carbon_multiplier": 1.00,
            "governance_gain": 0.00,
        },
        "clean_energy_and_industry": {
            "aod_multiplier": 0.78,
            "pm25_multiplier": 0.75,
            "black_carbon_multiplier": 0.82,
            "governance_gain": 0.10,
        },
        "clean_cooking_and_transport": {
            "aod_multiplier": 0.82,
            "pm25_multiplier": 0.70,
            "black_carbon_multiplier": 0.60,
            "governance_gain": 0.12,
        },
        "integrated_regional_policy": {
            "aod_multiplier": 0.65,
            "pm25_multiplier": 0.60,
            "black_carbon_multiplier": 0.55,
            "governance_gain": 0.22,
        },
    }

    frames = []

    for scenario_name, params in scenarios.items():
        scenario = data.copy()
        scenario["aerosol_optical_depth"] = (
            scenario["aerosol_optical_depth"] * params["aod_multiplier"]
        )
        scenario["pm25_exposure"] = (
            scenario["pm25_exposure"] * params["pm25_multiplier"]
        )
        scenario["black_carbon_share"] = (
            scenario["black_carbon_share"] * params["black_carbon_multiplier"]
        )
        scenario["governance_capacity"] = np.minimum(
            1.0,
            scenario["governance_capacity"] + params["governance_gain"],
        )

        scored = score_aerosol_risk(scenario)
        scored["scenario"] = scenario_name
        scored["rank"] = scored["regional_planetary_risk_score"].rank(
            ascending=False,
            method="dense",
        )
        frames.append(scored)

    return pd.concat(frames, ignore_index=True)


def main() -> None:
    """Run the aerosol-loading regional-risk workflow."""
    output_dir = Path(
        "articles/atmospheric-aerosol-loading-and-regional-planetary-risk/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_aerosol_regions()
    scored = score_aerosol_risk(data)
    scenarios = run_policy_scenarios(data)

    scored.to_csv(output_dir / "regional_aerosol_risk_scores.csv", index=False)
    scenarios.to_csv(output_dir / "aerosol_policy_scenarios.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
