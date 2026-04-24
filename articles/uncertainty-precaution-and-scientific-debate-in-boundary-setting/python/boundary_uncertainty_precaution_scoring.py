"""
Boundary uncertainty and precautionary risk scoring workflow.

This workflow models planetary-boundary risk using:
- observed Earth system pressure
- estimated thresholds
- threshold uncertainty
- precautionary safety margins
- governance capacity
- risk-zone classification

The values are illustrative. Replace them with documented boundary data,
control variables, uncertainty estimates, expert elicitation, monitoring
systems, and transparent precautionary assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskZone = Literal["safe_zone", "zone_of_increasing_risk", "high_risk_zone"]


@dataclass(frozen=True)
class BoundarySpec:
    """Specification for a boundary process under uncertainty."""

    boundary: str
    observed_pressure: float
    estimated_threshold: float
    threshold_uncertainty: float
    precaution_factor: float
    governance_capacity: float
    weight: float


def build_boundary_specs() -> pd.DataFrame:
    """Create illustrative planetary-boundary uncertainty data."""
    specs = [
        BoundarySpec("climate_change", 1.42, 1.20, 0.12, 1.0, 0.68, 1.4),
        BoundarySpec("biosphere_integrity", 1.80, 1.15, 0.20, 1.2, 0.46, 1.5),
        BoundarySpec("freshwater_change", 1.22, 1.10, 0.18, 1.1, 0.52, 1.1),
        BoundarySpec("land_system_change", 1.28, 1.10, 0.15, 1.0, 0.50, 1.0),
        BoundarySpec("biogeochemical_flows", 1.70, 1.20, 0.16, 1.1, 0.42, 1.2),
        BoundarySpec("ocean_acidification", 0.92, 1.10, 0.10, 1.0, 0.60, 1.0),
        BoundarySpec("novel_entities", 1.60, 1.05, 0.30, 1.3, 0.34, 1.3),
        BoundarySpec("atmospheric_aerosols", 0.88, 1.00, 0.28, 1.2, 0.38, 0.9),
        BoundarySpec("stratospheric_ozone", 0.72, 1.10, 0.08, 1.0, 0.74, 0.8),
    ]

    return pd.DataFrame([spec.__dict__ for spec in specs])


def classify_risk_zone(pressure_ratio: float) -> RiskZone:
    """Classify pressure relative to the precautionary boundary."""
    if pressure_ratio < 1.0:
        return "safe_zone"
    if pressure_ratio < 1.5:
        return "zone_of_increasing_risk"
    return "high_risk_zone"


def score_uncertainty_risk(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate precautionary boundary, pressure ratio, and risk scores."""
    scored = data.copy()

    scored["precautionary_boundary"] = (
        scored["estimated_threshold"]
        - scored["precaution_factor"] * scored["threshold_uncertainty"]
    )

    if (scored["precautionary_boundary"] <= 0).any():
        raise ValueError("Precautionary boundary must remain positive.")

    scored["pressure_ratio"] = (
        scored["observed_pressure"] / scored["precautionary_boundary"]
    )

    scored["uncertainty_adjusted_pressure"] = (
        scored["pressure_ratio"] * (1 + scored["threshold_uncertainty"])
    )

    scored["governance_gap"] = 1 - scored["governance_capacity"]

    scored["governance_adjusted_risk"] = (
        scored["uncertainty_adjusted_pressure"]
        * scored["governance_gap"]
        * scored["weight"]
    )

    scored["risk_zone"] = scored["pressure_ratio"].apply(classify_risk_zone)

    scored["dominant_issue"] = np.select(
        [
            scored["pressure_ratio"] >= 1.5,
            scored["threshold_uncertainty"] >= 0.25,
            scored["governance_gap"] >= 0.60,
        ],
        [
            "high_pressure",
            "high_uncertainty",
            "low_governance_capacity",
        ],
        default="mixed_or_moderate_risk",
    )

    return scored.sort_values(
        "governance_adjusted_risk",
        ascending=False,
    ).reset_index(drop=True)


def run_precaution_sensitivity(data: pd.DataFrame) -> pd.DataFrame:
    """Test how conclusions change under different precautionary factors."""
    scenarios = {
        "lower_precaution": 0.75,
        "baseline_precaution": 1.00,
        "higher_precaution": 1.25,
        "strong_precaution": 1.50,
    }

    frames = []

    for scenario_name, multiplier in scenarios.items():
        scenario = data.copy()
        scenario["precaution_factor"] = scenario["precaution_factor"] * multiplier
        scenario = score_uncertainty_risk(scenario)
        scenario["scenario"] = scenario_name
        scenario["rank"] = scenario["governance_adjusted_risk"].rank(
            ascending=False,
            method="dense",
        )
        frames.append(scenario)

    return pd.concat(frames, ignore_index=True)


def main() -> None:
    """Run the uncertainty and precaution workflow."""
    output_dir = Path(
        "articles/uncertainty-precaution-and-scientific-debate-in-boundary-setting/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_boundary_specs()
    scored = score_uncertainty_risk(data)
    sensitivity = run_precaution_sensitivity(data)

    scored.to_csv(output_dir / "boundary_uncertainty_scores.csv", index=False)
    sensitivity.to_csv(output_dir / "precaution_sensitivity.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
