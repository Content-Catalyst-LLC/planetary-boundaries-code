"""
Ocean acidification and carbonate-risk diagnostics.

This workflow models ocean acidification using:
- pH change
- carbonate ion availability
- aragonite saturation state
- boundary pressure
- ecosystem vulnerability
- warming, deoxygenation, and nutrient stress
- monitoring and governance capacity

The values are illustrative. Replace them with documented ocean chemistry
measurements, observational networks, carbonate-system calculations,
ecosystem sensitivity data, and transparent assumptions before applied use.
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
class OceanRegionProfile:
    """Regional carbonate-chemistry and ecosystem-risk profile."""

    region: str
    current_ph: float
    preindustrial_ph: float
    carbonate_ion_index: float
    aragonite_saturation_state: float
    preindustrial_aragonite_state: float
    boundary_aragonite_state: float
    ecological_sensitivity: float
    exposure: float
    adaptive_capacity: float
    warming_stress: float
    deoxygenation_stress: float
    nutrient_stress: float
    monitoring_capacity: float
    governance_capacity: float


def build_ocean_profiles() -> pd.DataFrame:
    """Create illustrative regional ocean-acidification profiles."""
    profiles = [
        OceanRegionProfile("global_surface_ocean", 8.10, 8.20, 0.82, 2.90, 3.44, 2.75, 0.58, 0.72, 0.52, 0.62, 0.42, 0.38, 0.70, 0.46),
        OceanRegionProfile("tropical_coral_reef_belt", 8.06, 8.18, 0.74, 2.65, 3.65, 3.00, 0.90, 0.86, 0.34, 0.88, 0.40, 0.54, 0.58, 0.38),
        OceanRegionProfile("arctic_surface_waters", 8.03, 8.16, 0.66, 1.65, 2.25, 1.70, 0.76, 0.82, 0.30, 0.82, 0.36, 0.24, 0.52, 0.34),
        OceanRegionProfile("southern_ocean", 8.04, 8.17, 0.70, 1.82, 2.45, 1.90, 0.72, 0.78, 0.32, 0.58, 0.44, 0.26, 0.56, 0.36),
        OceanRegionProfile("eastern_boundary_upwelling_systems", 7.94, 8.08, 0.62, 1.48, 2.10, 1.60, 0.70, 0.88, 0.42, 0.54, 0.72, 0.66, 0.54, 0.40),
        OceanRegionProfile("temperate_shellfish_coasts", 7.98, 8.10, 0.68, 1.72, 2.30, 1.75, 0.78, 0.80, 0.48, 0.48, 0.50, 0.60, 0.62, 0.50),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def classify_risk(score: float) -> RiskClass:
    """Classify marine chemistry risk."""
    if score < 0.65:
        return "lower_risk"
    if score < 1.25:
        return "moderate_risk"
    if score < 2.00:
        return "high_risk"
    return "severe_risk"


def score_ocean_acidification(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate carbonate-chemistry and marine ecosystem risk diagnostics."""
    scored = data.copy()

    if (scored["preindustrial_aragonite_state"] <= scored["boundary_aragonite_state"]).any():
        raise ValueError("Preindustrial aragonite state must exceed boundary aragonite state.")

    scored["ph_decline"] = scored["preindustrial_ph"] - scored["current_ph"]

    scored["hydrogen_ion_increase_index"] = (
        10 ** (-scored["current_ph"])
    ) / (
        10 ** (-scored["preindustrial_ph"])
    )

    scored["aragonite_boundary_pressure"] = (
        (scored["preindustrial_aragonite_state"] - scored["aragonite_saturation_state"])
        / (scored["preindustrial_aragonite_state"] - scored["boundary_aragonite_state"])
    ).clip(lower=0)

    scored["carbonate_deficit"] = 1 - scored["carbonate_ion_index"]

    scored["ecosystem_vulnerability"] = (
        scored["aragonite_boundary_pressure"]
        * scored["ecological_sensitivity"]
        * scored["exposure"]
        * (1 - scored["adaptive_capacity"])
    )

    scored["multi_stressor_pressure"] = (
        0.40 * scored["aragonite_boundary_pressure"]
        + 0.25 * scored["warming_stress"]
        + 0.20 * scored["deoxygenation_stress"]
        + 0.15 * scored["nutrient_stress"]
    )

    scored["monitoring_gap"] = 1 - scored["monitoring_capacity"]
    scored["governance_gap"] = 1 - scored["governance_capacity"]

    scored["marine_chemistry_risk_score"] = (
        0.45 * scored["ecosystem_vulnerability"]
        + 0.35 * scored["multi_stressor_pressure"]
        + 0.20 * scored["carbonate_deficit"]
    ) * (1 + 0.5 * scored["monitoring_gap"] + 0.5 * scored["governance_gap"])

    scored["risk_class"] = scored["marine_chemistry_risk_score"].apply(classify_risk)

    scored["priority"] = np.select(
        [
            scored["aragonite_boundary_pressure"] >= 1.0,
            scored["ecosystem_vulnerability"] >= 0.60,
            scored["monitoring_capacity"] < 0.55,
            scored["nutrient_stress"] >= 0.60,
        ],
        [
            "boundary_transgression_priority",
            "ecosystem_resilience_priority",
            "monitoring_capacity_priority",
            "coastal_pollution_and_nutrient_priority",
        ],
        default="carbon_mitigation_and_monitoring",
    )

    return scored.sort_values("marine_chemistry_risk_score", ascending=False).reset_index(drop=True)


def run_policy_scenarios(data: pd.DataFrame) -> pd.DataFrame:
    """Test how carbonate risk changes under mitigation and local-stress scenarios."""
    scenarios = {
        "baseline": {
            "aragonite_gain": 0.00,
            "nutrient_multiplier": 1.00,
            "monitoring_gain": 0.00,
            "governance_gain": 0.00,
        },
        "improved_monitoring": {
            "aragonite_gain": 0.00,
            "nutrient_multiplier": 1.00,
            "monitoring_gain": 0.18,
            "governance_gain": 0.08,
        },
        "coastal_pollution_reduction": {
            "aragonite_gain": 0.00,
            "nutrient_multiplier": 0.65,
            "monitoring_gain": 0.08,
            "governance_gain": 0.12,
        },
        "strong_carbon_mitigation": {
            "aragonite_gain": 0.18,
            "nutrient_multiplier": 0.85,
            "monitoring_gain": 0.10,
            "governance_gain": 0.18,
        },
        "integrated_ocean_resilience": {
            "aragonite_gain": 0.24,
            "nutrient_multiplier": 0.55,
            "monitoring_gain": 0.22,
            "governance_gain": 0.25,
        },
    }

    frames = []

    for scenario_name, params in scenarios.items():
        scenario = data.copy()
        scenario["aragonite_saturation_state"] = (
            scenario["aragonite_saturation_state"] + params["aragonite_gain"]
        )
        scenario["nutrient_stress"] = (
            scenario["nutrient_stress"] * params["nutrient_multiplier"]
        )
        scenario["monitoring_capacity"] = np.minimum(
            1.0,
            scenario["monitoring_capacity"] + params["monitoring_gain"],
        )
        scenario["governance_capacity"] = np.minimum(
            1.0,
            scenario["governance_capacity"] + params["governance_gain"],
        )

        scored = score_ocean_acidification(scenario)
        scored["scenario"] = scenario_name
        scored["rank"] = scored["marine_chemistry_risk_score"].rank(
            ascending=False,
            method="dense",
        )
        frames.append(scored)

    return pd.concat(frames, ignore_index=True)


def main() -> None:
    """Run the ocean acidification workflow."""
    output_dir = Path(
        "articles/ocean-acidification-and-the-chemistry-of-planetary-change/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_ocean_profiles()
    scored = score_ocean_acidification(data)
    scenarios = run_policy_scenarios(data)

    scored.to_csv(output_dir / "ocean_acidification_risk_scores.csv", index=False)
    scenarios.to_csv(output_dir / "ocean_acidification_scenarios.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
