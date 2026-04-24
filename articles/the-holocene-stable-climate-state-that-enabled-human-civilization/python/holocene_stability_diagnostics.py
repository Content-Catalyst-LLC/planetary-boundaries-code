"""
Holocene stability diagnostics for planetary-boundary analysis.

This workflow models the Holocene as a baseline condition using:
- Holocene reference values
- current or scenario values
- anomaly scores
- standardized departure scores
- boundary pressure ratios
- cross-system amplification
- governance capacity
- adaptive capacity
- development exposure

The values are illustrative. Replace them with documented paleoclimate
datasets, boundary estimates, scenario data, monitoring records, and
transparent assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskClass = Literal[
    "within_reference_range",
    "emerging_departure",
    "high_departure_risk",
    "systemic_transformation_risk",
]


@dataclass(frozen=True)
class HoloceneIndicator:
    """Earth-system indicator compared with a Holocene reference state."""

    indicator: str
    holocene_reference: float
    observed_value: float
    holocene_variability: float
    boundary_value: float
    interaction_weight: float
    governance_capacity: float
    adaptive_capacity: float
    development_exposure: float


def build_holocene_indicators() -> pd.DataFrame:
    """Create illustrative indicators for Holocene departure analysis."""
    indicators = [
        HoloceneIndicator("global_temperature", 0.00, 1.20, 0.35, 1.00, 0.92, 0.56, 0.52, 0.88),
        HoloceneIndicator("biosphere_integrity", 0.20, 1.55, 0.28, 1.00, 0.96, 0.44, 0.46, 0.82),
        HoloceneIndicator("land_system_change", 0.25, 1.20, 0.30, 1.00, 0.78, 0.52, 0.50, 0.70),
        HoloceneIndicator("freshwater_change", 0.18, 1.32, 0.26, 1.00, 0.82, 0.46, 0.48, 0.86),
        HoloceneIndicator("biogeochemical_flows", 0.16, 1.60, 0.32, 1.00, 0.84, 0.42, 0.44, 0.76),
        HoloceneIndicator("ocean_acidification", 0.10, 1.06, 0.22, 1.00, 0.66, 0.50, 0.48, 0.68),
    ]

    return pd.DataFrame([indicator.__dict__ for indicator in indicators])


def classify_departure(score: float) -> RiskClass:
    """Classify departure from Holocene-like conditions."""
    if score < 0.50:
        return "within_reference_range"
    if score < 1.00:
        return "emerging_departure"
    if score < 1.50:
        return "high_departure_risk"
    return "systemic_transformation_risk"


def score_holocene_departure(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate Holocene departure diagnostics."""
    scored = data.copy()

    # Validate denominators before calculating ratios.
    for column in ["holocene_variability", "boundary_value"]:
        if (scored[column] <= 0).any():
            raise ValueError(f"{column} must contain only positive values.")

    # Raw anomaly relative to the Holocene reference state.
    scored["holocene_anomaly"] = scored["observed_value"] - scored["holocene_reference"]

    # Standardized departure expresses anomaly relative to Holocene variability.
    scored["standardized_departure"] = (
        scored["holocene_anomaly"] / scored["holocene_variability"]
    )

    # Boundary pressure shows whether the indicator exceeds its boundary reference.
    scored["boundary_pressure_ratio"] = scored["observed_value"] / scored["boundary_value"]

    # Capacity combines governance and adaptive capacity.
    scored["response_capacity"] = (
        0.55 * scored["governance_capacity"] + 0.45 * scored["adaptive_capacity"]
    )

    # Mean pressure is used as a simple proxy for cross-boundary context.
    mean_boundary_pressure = scored["boundary_pressure_ratio"].mean()

    # Cross-system amplification increases when a process is strongly coupled to others.
    scored["cross_system_amplification"] = (
        scored["interaction_weight"] * mean_boundary_pressure
    )

    # Departure risk combines standardized departure, boundary pressure,
    # amplification, exposure, and limited response capacity.
    scored["holocene_departure_risk"] = (
        np.maximum(0, scored["standardized_departure"])
        * scored["boundary_pressure_ratio"]
        * (1 + 0.25 * scored["cross_system_amplification"])
        * (1 + 0.30 * scored["development_exposure"])
        * (1 - 0.50 * scored["response_capacity"])
    )

    scored["risk_class"] = scored["holocene_departure_risk"].apply(classify_departure)

    scored["priority"] = np.select(
        [
            scored["indicator"] == "global_temperature",
            scored["indicator"] == "biosphere_integrity",
            scored["indicator"] == "freshwater_change",
            scored["indicator"] == "biogeochemical_flows",
            scored["indicator"] == "land_system_change",
        ],
        [
            "accelerated_decarbonization",
            "biosphere_integrity_repair",
            "hydrological_resilience",
            "nutrient_flow_reduction",
            "land_system_restoration",
        ],
        default="integrated_monitoring",
    )

    return scored.sort_values(
        "holocene_departure_risk",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run Holocene stability diagnostics."""
    output_dir = Path(
        "articles/the-holocene-stable-climate-state-that-enabled-human-civilization/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    indicators = build_holocene_indicators()
    scored = score_holocene_departure(indicators)

    scored.to_csv(output_dir / "holocene_stability_diagnostics.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
