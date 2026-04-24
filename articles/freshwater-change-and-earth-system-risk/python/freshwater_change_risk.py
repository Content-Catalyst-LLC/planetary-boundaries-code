"""
Freshwater change and hydrological risk diagnostics.

This workflow models freshwater change using:
- blue-water streamflow deviation
- green-water root-zone soil moisture deviation
- groundwater depletion pressure
- wetland and natural-buffer capacity
- ecological sensitivity
- exposure
- adaptive capacity
- monitoring capacity
- governance capacity
- scenario testing

The values are illustrative. Replace them with documented streamflow data,
soil-moisture observations, groundwater records, remote-sensing products,
hydrological models, and transparent assumptions before applied use.
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
class FreshwaterRegionProfile:
    """Regional freshwater-change profile."""

    region: str
    streamflow_current: float
    streamflow_baseline: float
    soil_moisture_current: float
    soil_moisture_baseline: float
    groundwater_stress: float
    wetland_buffer_capacity: float
    ecological_sensitivity: float
    exposed_population_index: float
    food_system_dependence: float
    monitoring_capacity: float
    governance_capacity: float
    adaptive_capacity: float


def build_freshwater_profiles() -> pd.DataFrame:
    """Create illustrative freshwater-change profiles."""
    profiles = [
        FreshwaterRegionProfile("semi_arid_irrigation_basin", 0.68, 1.00, 0.62, 1.00, 0.82, 0.28, 0.78, 0.72, 0.86, 0.52, 0.40, 0.38),
        FreshwaterRegionProfile("deforested_tropical_watershed", 1.24, 1.00, 0.70, 1.00, 0.42, 0.34, 0.84, 0.68, 0.72, 0.48, 0.36, 0.34),
        FreshwaterRegionProfile("groundwater_depletion_plain", 0.72, 1.00, 0.76, 1.00, 0.90, 0.22, 0.70, 0.82, 0.88, 0.56, 0.34, 0.32),
        FreshwaterRegionProfile("urban_flood_hardscape_region", 1.38, 1.00, 0.82, 1.00, 0.38, 0.18, 0.66, 0.88, 0.54, 0.60, 0.42, 0.40),
        FreshwaterRegionProfile("wetland_restoration_landscape", 0.96, 1.00, 0.94, 1.00, 0.28, 0.76, 0.48, 0.42, 0.46, 0.72, 0.66, 0.68),
        FreshwaterRegionProfile("snowmelt_dependent_mountain_basin", 0.84, 1.00, 0.78, 1.00, 0.46, 0.44, 0.76, 0.64, 0.80, 0.58, 0.46, 0.42),
        FreshwaterRegionProfile("monsoon_variability_delta", 1.30, 1.00, 0.74, 1.00, 0.58, 0.30, 0.82, 0.90, 0.84, 0.50, 0.38, 0.36),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def classify_risk(score: float) -> RiskClass:
    """Classify freshwater-change risk."""
    if score < 0.55:
        return "lower_risk"
    if score < 1.10:
        return "moderate_risk"
    if score < 1.80:
        return "high_risk"
    return "severe_risk"


def score_freshwater_change(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate freshwater-change boundary and systems-risk diagnostics."""
    scored = data.copy()

    # Validate denominators before calculating deviations.
    for column in ["streamflow_baseline", "soil_moisture_baseline"]:
        if (scored[column] <= 0).any():
            raise ValueError(f"{column} must contain only positive values.")

    # Blue-water deviation measures streamflow departure from baseline.
    scored["blue_water_deviation"] = (
        (scored["streamflow_current"] - scored["streamflow_baseline"])
        / scored["streamflow_baseline"]
    )

    # Green-water deviation measures root-zone soil-moisture departure from baseline.
    scored["green_water_deviation"] = (
        (scored["soil_moisture_current"] - scored["soil_moisture_baseline"])
        / scored["soil_moisture_baseline"]
    )

    # Both unusually wet and unusually dry deviations can destabilize systems.
    scored["absolute_blue_pressure"] = scored["blue_water_deviation"].abs()
    scored["absolute_green_pressure"] = scored["green_water_deviation"].abs()

    # Boundary pressure combines blue-water, green-water, and groundwater stress.
    scored["hydrological_boundary_pressure"] = (
        0.38 * scored["absolute_blue_pressure"]
        + 0.42 * scored["absolute_green_pressure"]
        + 0.20 * scored["groundwater_stress"]
    )

    # Exposure combines population exposure and food-system dependence.
    scored["social_ecological_exposure"] = (
        0.50 * scored["exposed_population_index"]
        + 0.50 * scored["food_system_dependence"]
    )

    # Natural buffers reduce risk by absorbing floods, supporting recharge, and preserving ecological function.
    scored["buffer_gap"] = 1 - scored["wetland_buffer_capacity"]

    # Weak monitoring and governance make hydrological risk harder to detect and manage.
    scored["monitoring_gap"] = 1 - scored["monitoring_capacity"]
    scored["governance_gap"] = 1 - scored["governance_capacity"]
    scored["adaptive_capacity_gap"] = 1 - scored["adaptive_capacity"]

    scored["freshwater_system_risk_score"] = (
        scored["hydrological_boundary_pressure"]
        * scored["ecological_sensitivity"]
        * scored["social_ecological_exposure"]
        * (
            1
            + 0.25 * scored["buffer_gap"]
            + 0.25 * scored["monitoring_gap"]
            + 0.30 * scored["governance_gap"]
            + 0.20 * scored["adaptive_capacity_gap"]
        )
    )

    scored["risk_class"] = scored["freshwater_system_risk_score"].apply(classify_risk)

    # Priority labels make the workflow more useful for planning and interpretation.
    scored["priority"] = np.select(
        [
            scored["groundwater_stress"] >= 0.80,
            scored["absolute_green_pressure"] >= 0.30,
            scored["absolute_blue_pressure"] >= 0.30,
            scored["wetland_buffer_capacity"] <= 0.30,
            scored["governance_capacity"] < 0.40,
        ],
        [
            "groundwater_depletion_priority",
            "green_water_soil_moisture_priority",
            "blue_water_flow_regime_priority",
            "wetland_and_natural_buffer_priority",
            "governance_capacity_priority",
        ],
        default="integrated_hydrological_resilience_priority",
    )

    return scored.sort_values(
        "freshwater_system_risk_score",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run the freshwater change workflow."""
    output_dir = Path("articles/freshwater-change-and-earth-system-risk/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_freshwater_profiles()
    scored = score_freshwater_change(data)

    scored.to_csv(output_dir / "freshwater_change_risk_scores.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
