"""
Planetary-boundary measurement workflow.

This workflow models how planetary boundaries are measured through:
- boundary processes
- control variables
- observed values
- proposed boundary values
- observation uncertainty
- boundary uncertainty
- monitoring capacity
- risk-zone classification

The values are illustrative. Replace them with documented control
variables, observed values, uncertainty estimates, and boundary values
before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskZone = Literal["safe_zone", "zone_of_increasing_risk", "high_risk_zone"]


@dataclass(frozen=True)
class BoundaryMeasurement:
    """Measurement specification for one planetary-boundary control variable."""

    boundary_process: str
    control_variable: str
    observed_value: float
    boundary_value: float
    high_risk_value: float
    observation_uncertainty: float
    boundary_uncertainty: float
    monitoring_capacity: float
    unit: str
    evidence_note: str


def build_sample_measurements() -> pd.DataFrame:
    """Create illustrative boundary-measurement data."""
    measurements = [
        BoundaryMeasurement(
            "climate_change",
            "atmospheric_co2_and_energy_imbalance_proxy",
            1.42,
            1.00,
            1.50,
            0.05,
            0.10,
            0.85,
            "scaled index",
            "high observational maturity but feedback uncertainty remains",
        ),
        BoundaryMeasurement(
            "biosphere_integrity",
            "functional_integrity_proxy",
            1.70,
            1.00,
            1.50,
            0.15,
            0.22,
            0.55,
            "scaled index",
            "multidimensional ecological process requiring proxies",
        ),
        BoundaryMeasurement(
            "freshwater_change",
            "streamflow_and_root_zone_soil_moisture_proxy",
            1.28,
            1.00,
            1.50,
            0.12,
            0.18,
            0.62,
            "scaled index",
            "regional hydrological deviations aggregated to planetary relevance",
        ),
        BoundaryMeasurement(
            "land_system_change",
            "forest_cover_and_biome_integrity_proxy",
            1.24,
            1.00,
            1.50,
            0.10,
            0.16,
            0.66,
            "scaled index",
            "land conversion differs by biome and ecological function",
        ),
        BoundaryMeasurement(
            "biogeochemical_flows",
            "nitrogen_and_phosphorus_perturbation_proxy",
            1.85,
            1.00,
            1.50,
            0.10,
            0.14,
            0.58,
            "scaled index",
            "nutrient disruption linked to agriculture, watersheds, and coasts",
        ),
        BoundaryMeasurement(
            "ocean_acidification",
            "carbonate_saturation_proxy",
            0.92,
            1.00,
            1.50,
            0.08,
            0.12,
            0.70,
            "scaled index",
            "ocean chemistry is measurable but biological response varies",
        ),
        BoundaryMeasurement(
            "novel_entities",
            "production_release_and_assessment_gap_proxy",
            1.65,
            1.00,
            1.50,
            0.25,
            0.30,
            0.38,
            "scaled index",
            "rapid chemical and material proliferation outpaces assessment",
        ),
        BoundaryMeasurement(
            "atmospheric_aerosol_loading",
            "regional_aerosol_optical_depth_proxy",
            0.95,
            1.00,
            1.50,
            0.22,
            0.28,
            0.48,
            "scaled index",
            "strong regional variation complicates global boundary setting",
        ),
        BoundaryMeasurement(
            "stratospheric_ozone_depletion",
            "stratospheric_ozone_concentration_proxy",
            0.72,
            1.00,
            1.50,
            0.05,
            0.08,
            0.82,
            "scaled index",
            "comparatively mature measurement system with long recovery lag",
        ),
    ]

    return pd.DataFrame([measurement.__dict__ for measurement in measurements])


def classify_risk_zone(ratio: float, high_risk_ratio: float) -> RiskZone:
    """Classify a control variable into a risk zone."""
    if ratio < 1.0:
        return "safe_zone"
    if ratio < high_risk_ratio:
        return "zone_of_increasing_risk"
    return "high_risk_zone"


def score_measurements(data: pd.DataFrame) -> pd.DataFrame:
    """Calculate pressure ratios, uncertainty-adjusted scores, and risk zones."""
    scored = data.copy()

    if (scored["boundary_value"] <= 0).any():
        raise ValueError("Boundary values must be positive.")

    scored["pressure_ratio"] = scored["observed_value"] / scored["boundary_value"]
    scored["high_risk_ratio"] = scored["high_risk_value"] / scored["boundary_value"]

    scored["combined_uncertainty"] = (
        scored["observation_uncertainty"] + scored["boundary_uncertainty"]
    )

    scored["uncertainty_adjusted_pressure"] = (
        scored["pressure_ratio"] * (1 + scored["combined_uncertainty"])
    )

    scored["monitoring_gap"] = 1 - scored["monitoring_capacity"]

    scored["measurement_risk_score"] = (
        scored["uncertainty_adjusted_pressure"] * (1 + scored["monitoring_gap"])
    )

    scored["risk_zone"] = scored.apply(
        lambda row: classify_risk_zone(
            ratio=float(row["pressure_ratio"]),
            high_risk_ratio=float(row["high_risk_ratio"]),
        ),
        axis=1,
    )

    scored["measurement_priority"] = np.select(
        [
            scored["risk_zone"] == "high_risk_zone",
            scored["combined_uncertainty"] >= 0.45,
            scored["monitoring_gap"] >= 0.50,
        ],
        [
            "high_pressure_priority",
            "uncertainty_priority",
            "monitoring_priority",
        ],
        default="standard_tracking",
    )

    return scored.sort_values("measurement_risk_score", ascending=False)


def summarize_by_zone(scored: pd.DataFrame) -> pd.DataFrame:
    """Summarize measurement status by risk zone."""
    return (
        scored.groupby("risk_zone")
        .agg(
            boundaries=("boundary_process", "count"),
            mean_pressure_ratio=("pressure_ratio", "mean"),
            mean_combined_uncertainty=("combined_uncertainty", "mean"),
            mean_monitoring_capacity=("monitoring_capacity", "mean"),
            mean_measurement_risk_score=("measurement_risk_score", "mean"),
        )
        .reset_index()
        .sort_values("mean_measurement_risk_score", ascending=False)
    )


def main() -> None:
    """Run the planetary-boundary measurement workflow."""
    output_dir = Path("articles/how-planetary-boundaries-are-measured/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_sample_measurements()
    scored = score_measurements(data)
    zone_summary = summarize_by_zone(scored)

    scored.to_csv(output_dir / "boundary_measurement_scores.csv", index=False)
    zone_summary.to_csv(output_dir / "risk_zone_summary.csv", index=False)

    print(scored)
    print(zone_summary)


if __name__ == "__main__":
    main()
