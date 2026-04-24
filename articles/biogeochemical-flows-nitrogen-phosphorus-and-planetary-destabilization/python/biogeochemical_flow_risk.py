"""
Biogeochemical flows boundary diagnostics.

This workflow models nitrogen and phosphorus risk using:
- nutrient inputs
- crop or biological uptake
- nutrient-use efficiency
- nutrient surplus
- runoff sensitivity
- hydrological connectivity
- ecosystem sensitivity
- governance capacity
- boundary pressure
- scenario testing

The values are illustrative. Replace them with documented fertilizer data,
manure estimates, crop uptake data, watershed monitoring, hydrological data,
and transparent assumptions before applied use.
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
class NutrientRegionProfile:
    """Regional nitrogen and phosphorus profile."""

    region: str
    nitrogen_input: float
    nitrogen_uptake: float
    phosphorus_input: float
    phosphorus_uptake: float
    nitrogen_boundary_reference: float
    phosphorus_boundary_reference: float
    runoff_sensitivity: float
    hydrological_connectivity: float
    ecosystem_sensitivity: float
    legacy_nutrient_pressure: float
    monitoring_capacity: float
    governance_capacity: float


def build_nutrient_profiles() -> pd.DataFrame:
    """Create illustrative regional nutrient profiles."""
    profiles = [
        NutrientRegionProfile("intensive_maize_soy_basin", 1.45, 0.82, 1.25, 0.58, 1.00, 1.00, 0.74, 0.82, 0.78, 0.62, 0.58, 0.46),
        NutrientRegionProfile("livestock_manure_concentration_zone", 1.32, 0.64, 1.48, 0.52, 1.00, 1.00, 0.70, 0.76, 0.72, 0.70, 0.50, 0.38),
        NutrientRegionProfile("eutrophic_lake_watershed", 1.10, 0.70, 1.35, 0.48, 1.00, 1.00, 0.82, 0.88, 0.86, 0.76, 0.62, 0.42),
        NutrientRegionProfile("coastal_dead_zone_drainage", 1.56, 0.86, 1.40, 0.62, 1.00, 1.00, 0.78, 0.92, 0.84, 0.68, 0.66, 0.44),
        NutrientRegionProfile("phosphorus_limited_smallholder_region", 0.62, 0.54, 0.48, 0.42, 1.00, 1.00, 0.34, 0.40, 0.52, 0.24, 0.36, 0.34),
        NutrientRegionProfile("urban_wastewater_nutrient_corridor", 0.92, 0.44, 1.05, 0.38, 1.00, 1.00, 0.68, 0.80, 0.76, 0.58, 0.54, 0.40),
        NutrientRegionProfile("restored_wetland_buffer_landscape", 0.82, 0.66, 0.78, 0.58, 1.00, 1.00, 0.36, 0.48, 0.46, 0.30, 0.74, 0.68),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def classify_risk(score: float) -> RiskClass:
    """Classify nutrient boundary risk."""
    if score < 0.55:
        return "lower_risk"
    if score < 1.10:
        return "moderate_risk"
    if score < 1.80:
        return "high_risk"
    return "severe_risk"


def score_biogeochemical_flows(data: pd.DataFrame) -> pd.DataFrame:
    """Score nitrogen and phosphorus surplus, boundary pressure, and ecosystem risk."""
    scored = data.copy()

    # Validate that denominator values are positive before calculating ratios.
    required_positive = [
        "nitrogen_input",
        "phosphorus_input",
        "nitrogen_boundary_reference",
        "phosphorus_boundary_reference",
    ]

    for column in required_positive:
        if (scored[column] <= 0).any():
            raise ValueError(f"{column} must contain only positive values.")

    # Surplus indicates nutrient input not taken up by crops or retained productively.
    scored["nitrogen_surplus"] = scored["nitrogen_input"] - scored["nitrogen_uptake"]
    scored["phosphorus_surplus"] = scored["phosphorus_input"] - scored["phosphorus_uptake"]

    # Nutrient-use efficiency helps distinguish productivity from leakage.
    scored["nitrogen_use_efficiency"] = scored["nitrogen_uptake"] / scored["nitrogen_input"]
    scored["phosphorus_use_efficiency"] = scored["phosphorus_uptake"] / scored["phosphorus_input"]

    # Boundary pressure compares nutrient input to an explicit reference level.
    scored["nitrogen_boundary_pressure"] = (
        scored["nitrogen_input"] / scored["nitrogen_boundary_reference"]
    )
    scored["phosphorus_boundary_pressure"] = (
        scored["phosphorus_input"] / scored["phosphorus_boundary_reference"]
    )

    # Surplus pressure combines surplus magnitude with runoff and hydrological connectivity.
    scored["nutrient_loss_pressure"] = (
        0.50 * scored["nitrogen_surplus"].clip(lower=0)
        + 0.50 * scored["phosphorus_surplus"].clip(lower=0)
    ) * (
        0.50 * scored["runoff_sensitivity"]
        + 0.50 * scored["hydrological_connectivity"]
    )

    # Eutrophication pressure reflects boundary pressure and ecosystem vulnerability.
    scored["eutrophication_pressure"] = (
        0.35 * scored["nitrogen_boundary_pressure"]
        + 0.35 * scored["phosphorus_boundary_pressure"]
        + 0.30 * scored["nutrient_loss_pressure"]
    ) * scored["ecosystem_sensitivity"]

    # Legacy pressure represents stored nutrients in soils, sediments, or watersheds.
    scored["legacy_adjusted_pressure"] = (
        scored["eutrophication_pressure"]
        * (1 + scored["legacy_nutrient_pressure"])
    )

    # Governance and monitoring gaps increase risk because nutrient systems require observability.
    scored["monitoring_gap"] = 1 - scored["monitoring_capacity"]
    scored["governance_gap"] = 1 - scored["governance_capacity"]

    scored["planetary_nutrient_risk_score"] = (
        scored["legacy_adjusted_pressure"]
        * (1 + 0.45 * scored["monitoring_gap"] + 0.55 * scored["governance_gap"])
    )

    scored["risk_class"] = scored["planetary_nutrient_risk_score"].apply(classify_risk)

    # Priority labels make the output useful for management interpretation.
    scored["priority"] = np.select(
        [
            scored["phosphorus_boundary_pressure"] >= 1.25,
            scored["nitrogen_boundary_pressure"] >= 1.25,
            scored["legacy_nutrient_pressure"] >= 0.65,
            scored["governance_capacity"] < 0.45,
            scored["nitrogen_input"] < 0.75,
        ],
        [
            "phosphorus_loss_and_recovery_priority",
            "nitrogen_surplus_reduction_priority",
            "legacy_nutrient_remediation_priority",
            "governance_capacity_priority",
            "nutrient_access_and_soil_fertility_priority",
        ],
        default="integrated_nutrient_management_priority",
    )

    return scored.sort_values(
        "planetary_nutrient_risk_score",
        ascending=False,
    ).reset_index(drop=True)


def run_policy_scenarios(data: pd.DataFrame) -> pd.DataFrame:
    """Test nutrient-risk changes under policy scenarios."""
    scenarios = {
        "baseline": {
            "input_multiplier": 1.00,
            "uptake_gain": 0.00,
            "runoff_multiplier": 1.00,
            "legacy_multiplier": 1.00,
            "governance_gain": 0.00,
        },
        "precision_nutrient_management": {
            "input_multiplier": 0.86,
            "uptake_gain": 0.08,
            "runoff_multiplier": 0.90,
            "legacy_multiplier": 1.00,
            "governance_gain": 0.08,
        },
        "wetland_and_buffer_restoration": {
            "input_multiplier": 0.92,
            "uptake_gain": 0.04,
            "runoff_multiplier": 0.65,
            "legacy_multiplier": 0.90,
            "governance_gain": 0.10,
        },
        "nutrient_recovery_and_circularity": {
            "input_multiplier": 0.82,
            "uptake_gain": 0.06,
            "runoff_multiplier": 0.78,
            "legacy_multiplier": 0.82,
            "governance_gain": 0.15,
        },
        "integrated_food_system_transition": {
            "input_multiplier": 0.74,
            "uptake_gain": 0.10,
            "runoff_multiplier": 0.58,
            "legacy_multiplier": 0.70,
            "governance_gain": 0.22,
        },
    }

    frames = []

    for scenario_name, params in scenarios.items():
        scenario = data.copy()

        # Reduce total inputs while preserving the possibility of nutrient access needs.
        scenario["nitrogen_input"] = scenario["nitrogen_input"] * params["input_multiplier"]
        scenario["phosphorus_input"] = scenario["phosphorus_input"] * params["input_multiplier"]

        # Improved practices increase uptake, capped below input to avoid impossible values.
        scenario["nitrogen_uptake"] = np.minimum(
            scenario["nitrogen_input"] * 0.98,
            scenario["nitrogen_uptake"] + params["uptake_gain"],
        )
        scenario["phosphorus_uptake"] = np.minimum(
            scenario["phosphorus_input"] * 0.98,
            scenario["phosphorus_uptake"] + params["uptake_gain"],
        )

        # Landscape restoration and improved management reduce runoff sensitivity.
        scenario["runoff_sensitivity"] = (
            scenario["runoff_sensitivity"] * params["runoff_multiplier"]
        )

        # Legacy nutrient pressure can decline slowly through remediation and reduced loading.
        scenario["legacy_nutrient_pressure"] = (
            scenario["legacy_nutrient_pressure"] * params["legacy_multiplier"]
        )

        # Governance improvements improve monitoring, enforcement, coordination, and capacity.
        scenario["governance_capacity"] = np.minimum(
            1.0,
            scenario["governance_capacity"] + params["governance_gain"],
        )
        scenario["monitoring_capacity"] = np.minimum(
            1.0,
            scenario["monitoring_capacity"] + params["governance_gain"] * 0.75,
        )

        scored = score_biogeochemical_flows(scenario)
        scored["scenario"] = scenario_name
        scored["rank"] = scored["planetary_nutrient_risk_score"].rank(
            ascending=False,
            method="dense",
        )
        frames.append(scored)

    return pd.concat(frames, ignore_index=True)


def main() -> None:
    """Run the biogeochemical flows workflow."""
    output_dir = Path(
        "articles/biogeochemical-flows-nitrogen-phosphorus-and-planetary-destabilization/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_nutrient_profiles()
    scored = score_biogeochemical_flows(data)
    scenarios = run_policy_scenarios(data)

    scored.to_csv(output_dir / "biogeochemical_flow_risk_scores.csv", index=False)
    scenarios.to_csv(output_dir / "nutrient_policy_scenarios.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
