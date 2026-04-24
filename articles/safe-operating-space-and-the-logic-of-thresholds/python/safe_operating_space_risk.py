"""
Safe operating space and threshold-risk diagnostics.

This workflow models planetary-boundary risk using:
- observed control-variable pressure
- boundary values
- uncertainty margins
- boundary pressure ratios
- risk-zone classification
- trend direction
- cross-boundary amplification
- monitoring capacity
- governance capacity
- response urgency

The values are illustrative. Replace them with documented control variables,
boundary estimates, uncertainty ranges, monitoring records, and transparent
assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskZone = Literal[
    "safe_zone",
    "increasing_risk_zone",
    "high_risk_zone",
]


@dataclass(frozen=True)
class BoundaryProfile:
    """Planetary-boundary profile for threshold-risk analysis."""

    boundary: str
    observed_value: float
    boundary_value: float
    uncertainty_band: float
    annual_pressure_trend: float
    monitoring_capacity: float
    governance_capacity: float
    reversibility_capacity: float
    interaction_weight: float


def build_boundary_profiles() -> pd.DataFrame:
    """Create illustrative planetary-boundary profiles."""
    profiles = [
        BoundaryProfile("climate_change", 1.28, 1.00, 0.10, 0.020, 0.82, 0.56, 0.42, 0.92),
        BoundaryProfile("biosphere_integrity", 1.75, 1.00, 0.18, 0.030, 0.60, 0.44, 0.30, 0.96),
        BoundaryProfile("land_system_change", 1.22, 1.00, 0.14, 0.018, 0.72, 0.52, 0.44, 0.78),
        BoundaryProfile("freshwater_change", 1.36, 1.00, 0.16, 0.022, 0.66, 0.46, 0.38, 0.82),
        BoundaryProfile("biogeochemical_flows", 1.62, 1.00, 0.20, 0.026, 0.70, 0.42, 0.36, 0.84),
        BoundaryProfile("ocean_acidification", 1.08, 1.00, 0.12, 0.016, 0.76, 0.50, 0.34, 0.66),
        BoundaryProfile("novel_entities", 1.80, 1.00, 0.28, 0.032, 0.48, 0.34, 0.22, 0.74),
        BoundaryProfile("atmospheric_aerosols", 0.74, 1.00, 0.22, 0.006, 0.54, 0.40, 0.46, 0.58),
        BoundaryProfile("stratospheric_ozone", 0.42, 1.00, 0.12, -0.004, 0.88, 0.82, 0.76, 0.36),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def logistic_risk(pressure_ratio: pd.Series, steepness: float = 8.0) -> pd.Series:
    """Convert a boundary pressure ratio into a smooth risk score."""
    return 1 / (1 + np.exp(-steepness * (pressure_ratio - 1)))


def classify_risk_zone(pressure_ratio: float) -> RiskZone:
    """Classify boundary status using simple risk-zone thresholds."""
    if pressure_ratio < 0.80:
        return "safe_zone"
    if pressure_ratio < 1.00:
        return "increasing_risk_zone"
    return "high_risk_zone"


def score_safe_operating_space(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate safe operating space diagnostics."""
    scored = data.copy()

    # Validate denominator fields before calculating ratios.
    for column in ["boundary_value", "uncertainty_band"]:
        if (scored[column] <= 0).any():
            raise ValueError(f"{column} must contain only positive values.")

    # Boundary pressure ratio shows distance from the boundary.
    scored["boundary_pressure_ratio"] = scored["observed_value"] / scored["boundary_value"]

    # Uncertainty margin shows how much buffer remains relative to uncertainty.
    scored["uncertainty_margin"] = (
        scored["boundary_value"] - scored["observed_value"]
    ) / scored["uncertainty_band"]

    # Risk score rises smoothly near and beyond the boundary.
    scored["threshold_risk_score"] = logistic_risk(
        scored["boundary_pressure_ratio"],
        steepness=8.0,
    )

    # Risk zone uses explicit categorical logic for interpretation.
    scored["risk_zone"] = scored["boundary_pressure_ratio"].apply(classify_risk_zone)

    # Trend pressure rises when observed pressure is moving in the wrong direction.
    scored["trend_pressure"] = np.maximum(0, scored["annual_pressure_trend"])

    # Weak monitoring and governance increase practical risk.
    scored["monitoring_gap"] = 1 - scored["monitoring_capacity"]
    scored["governance_gap"] = 1 - scored["governance_capacity"]
    scored["reversibility_gap"] = 1 - scored["reversibility_capacity"]

    # Cross-boundary amplification approximates interaction with other breached systems.
    mean_other_risk = scored["threshold_risk_score"].mean()
    scored["cross_boundary_amplification"] = scored["interaction_weight"] * mean_other_risk

    # Composite systemic risk combines threshold risk, amplification, trends, and capacity gaps.
    scored["systemic_threshold_risk"] = (
        scored["threshold_risk_score"]
        * (1 + scored["cross_boundary_amplification"])
        * (
            1
            + 0.25 * scored["monitoring_gap"]
            + 0.35 * scored["governance_gap"]
            + 0.25 * scored["reversibility_gap"]
            + 0.15 * scored["trend_pressure"]
        )
    )

    # Response urgency identifies what kind of governance attention is needed.
    scored["response_urgency"] = np.select(
        [
            scored["boundary_pressure_ratio"] >= 1.50,
            scored["boundary_pressure_ratio"] >= 1.00,
            scored["boundary_pressure_ratio"] >= 0.80,
            scored["annual_pressure_trend"] > 0.01,
        ],
        [
            "immediate_systemic_response",
            "boundary_transgression_response",
            "precautionary_buffer_response",
            "trend_reversal_response",
        ],
        default="maintain_monitoring_and_resilience",
    )

    return scored.sort_values("systemic_threshold_risk", ascending=False).reset_index(drop=True)


def main() -> None:
    """Run safe operating space diagnostics."""
    output_dir = Path("articles/safe-operating-space-and-the-logic-of-thresholds/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_boundary_profiles()
    scored = score_safe_operating_space(data)

    scored.to_csv(output_dir / "safe_operating_space_scores.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
