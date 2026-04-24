"""
Stratospheric ozone depletion and governance diagnostics.

This workflow models ozone boundary status using:
- ozone concentration relative to a boundary reference
- ozone-depleting-substance loading
- emissions pressure
- treaty compliance
- industrial substitution
- monitoring capacity
- implementation support
- illegal-emissions risk
- recovery status and scenario sensitivity

The values are illustrative. Replace them with documented atmospheric
measurements, assessment data, emissions inventories, compliance records,
and transparent assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RecoveryStatus = Literal[
    "safe_zone",
    "watch_zone",
    "boundary_pressure_zone",
    "depletion_zone",
]


@dataclass(frozen=True)
class OzoneRegionProfile:
    """Atmospheric and governance profile for an ozone-monitoring region."""

    region: str
    ozone_du: float
    boundary_du: float
    preindustrial_reference_du: float
    ods_loading_index: float
    emissions_pressure: float
    treaty_compliance: float
    substitution_progress: float
    monitoring_capacity: float
    implementation_support: float
    illegal_emissions_risk: float
    atmospheric_lifetime_pressure: float


def build_ozone_profiles() -> pd.DataFrame:
    """Create illustrative ozone-region profiles."""
    profiles = [
        OzoneRegionProfile("global_mean_stratosphere", 286, 276, 290, 0.42, 0.18, 0.92, 0.88, 0.86, 0.82, 0.08, 0.46),
        OzoneRegionProfile("antarctic_spring", 238, 220, 290, 0.58, 0.16, 0.90, 0.86, 0.88, 0.80, 0.09, 0.62),
        OzoneRegionProfile("arctic_spring", 292, 276, 300, 0.44, 0.15, 0.91, 0.87, 0.84, 0.78, 0.07, 0.50),
        OzoneRegionProfile("mid_latutudes_northern", 302, 276, 305, 0.36, 0.12, 0.94, 0.91, 0.88, 0.82, 0.05, 0.40),
        OzoneRegionProfile("tropical_stratosphere", 278, 260, 280, 0.34, 0.10, 0.93, 0.89, 0.80, 0.76, 0.06, 0.38),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def classify_recovery(row: pd.Series) -> RecoveryStatus:
    """Classify ozone status relative to boundary and recovery margin."""
    if row["ozone_du"] < row["boundary_du"]:
        return "depletion_zone"
    if row["boundary_margin"] < 0.03:
        return "boundary_pressure_zone"
    if row["recovery_gap"] > 0.10:
        return "watch_zone"
    return "safe_zone"


def score_ozone_recovery(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate atmospheric and governance diagnostics for ozone recovery."""
    scored = data.copy()

    if (scored["boundary_du"] <= 0).any():
        raise ValueError("Boundary Dobson-unit values must be positive.")

    scored["boundary_margin"] = (
        (scored["ozone_du"] - scored["boundary_du"]) / scored["boundary_du"]
    )

    scored["recovery_gap"] = np.maximum(
        0.0,
        (scored["preindustrial_reference_du"] - scored["ozone_du"])
        / scored["preindustrial_reference_du"],
    )

    scored["governance_effectiveness"] = (
        0.30 * scored["treaty_compliance"]
        + 0.25 * scored["substitution_progress"]
        + 0.25 * scored["monitoring_capacity"]
        + 0.20 * scored["implementation_support"]
    )

    scored["residual_pressure"] = (
        0.35 * scored["ods_loading_index"]
        + 0.20 * scored["emissions_pressure"]
        + 0.25 * scored["atmospheric_lifetime_pressure"]
        + 0.20 * scored["illegal_emissions_risk"]
    )

    scored["recovery_resilience_score"] = (
        scored["boundary_margin"]
        + scored["governance_effectiveness"]
        - scored["residual_pressure"]
        - scored["recovery_gap"]
    )

    scored["status"] = scored.apply(classify_recovery, axis=1)

    scored["priority"] = np.select(
        [
            scored["status"] == "depletion_zone",
            scored["recovery_gap"] >= 0.10,
            scored["illegal_emissions_risk"] >= 0.08,
            scored["monitoring_capacity"] < 0.80,
        ],
        [
            "urgent_atmospheric_recovery_priority",
            "recovery_gap_priority",
            "emissions_integrity_priority",
            "monitoring_capacity_priority",
        ],
        default="maintain_governance_and_monitoring",
    )

    return scored.sort_values("recovery_resilience_score").reset_index(drop=True)


def run_governance_scenarios(data: pd.DataFrame) -> pd.DataFrame:
    """Test how ozone recovery diagnostics respond to governance scenarios."""
    scenarios = {
        "baseline": {
            "compliance_delta": 0.00,
            "monitoring_delta": 0.00,
            "substitution_delta": 0.00,
            "illegal_emissions_multiplier": 1.00,
        },
        "weakened_compliance": {
            "compliance_delta": -0.12,
            "monitoring_delta": -0.05,
            "substitution_delta": -0.05,
            "illegal_emissions_multiplier": 1.80,
        },
        "stronger_monitoring": {
            "compliance_delta": 0.02,
            "monitoring_delta": 0.10,
            "substitution_delta": 0.02,
            "illegal_emissions_multiplier": 0.70,
        },
        "accelerated_substitution": {
            "compliance_delta": 0.04,
            "monitoring_delta": 0.04,
            "substitution_delta": 0.10,
            "illegal_emissions_multiplier": 0.60,
        },
        "full_integrity_governance": {
            "compliance_delta": 0.06,
            "monitoring_delta": 0.12,
            "substitution_delta": 0.12,
            "illegal_emissions_multiplier": 0.40,
        },
    }

    frames = []

    for scenario_name, params in scenarios.items():
        scenario = data.copy()
        scenario["treaty_compliance"] = np.clip(
            scenario["treaty_compliance"] + params["compliance_delta"],
            0,
            1,
        )
        scenario["monitoring_capacity"] = np.clip(
            scenario["monitoring_capacity"] + params["monitoring_delta"],
            0,
            1,
        )
        scenario["substitution_progress"] = np.clip(
            scenario["substitution_progress"] + params["substitution_delta"],
            0,
            1,
        )
        scenario["illegal_emissions_risk"] = np.clip(
            scenario["illegal_emissions_risk"] * params["illegal_emissions_multiplier"],
            0,
            1,
        )

        scored = score_ozone_recovery(scenario)
        scored["scenario"] = scenario_name
        scored["rank"] = scored["recovery_resilience_score"].rank(
            ascending=True,
            method="dense",
        )
        frames.append(scored)

    return pd.concat(frames, ignore_index=True)


def main() -> None:
    """Run the ozone recovery and governance workflow."""
    output_dir = Path(
        "articles/stratospheric-ozone-depletion-and-global-environmental-governance/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_ozone_profiles()
    scored = score_ozone_recovery(data)
    scenarios = run_governance_scenarios(data)

    scored.to_csv(output_dir / "ozone_recovery_scores.csv", index=False)
    scenarios.to_csv(output_dir / "ozone_governance_scenarios.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
