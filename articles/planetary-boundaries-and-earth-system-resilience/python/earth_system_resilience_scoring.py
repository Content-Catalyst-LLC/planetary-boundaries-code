"""
Earth system resilience and planetary-boundary interaction workflow.

This workflow models:
- boundary pressure
- resilience capacity
- resilience gaps
- cross-boundary interaction pressure
- resilience-adjusted risk
- scenario sensitivity

The values are illustrative. Replace them with documented boundary data,
resilience indicators, monitoring systems, expert elicitation, and
transparent assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import pandas as pd


@dataclass(frozen=True)
class BoundaryResilienceProfile:
    """Resilience profile for a planetary-boundary process."""

    boundary: str
    observed_pressure: float
    boundary_value: float
    diversity: float
    redundancy: float
    adaptive_capacity: float
    monitoring_capacity: float
    structural_weight: float


@dataclass(frozen=True)
class CapacityWeight:
    """Weight assigned to a resilience-capacity dimension."""

    dimension: str
    weight: float


def normalize_weights(weights: list[CapacityWeight]) -> dict[str, float]:
    """Normalize resilience-capacity weights so they sum to one."""
    total = sum(item.weight for item in weights)

    if total <= 0:
        raise ValueError("Total weight must be positive.")

    return {item.dimension: item.weight / total for item in weights}


def build_boundary_profiles() -> pd.DataFrame:
    """Create illustrative resilience profiles for planetary boundaries."""
    profiles = [
        BoundaryResilienceProfile("climate_change", 1.42, 1.00, 0.42, 0.38, 0.54, 0.76, 1.50),
        BoundaryResilienceProfile("biosphere_integrity", 1.70, 1.00, 0.28, 0.30, 0.40, 0.52, 1.55),
        BoundaryResilienceProfile("freshwater_change", 1.25, 1.00, 0.46, 0.42, 0.48, 0.60, 1.10),
        BoundaryResilienceProfile("land_system_change", 1.22, 1.00, 0.40, 0.36, 0.46, 0.62, 1.05),
        BoundaryResilienceProfile("biogeochemical_flows", 1.80, 1.00, 0.38, 0.34, 0.42, 0.56, 1.20),
        BoundaryResilienceProfile("ocean_acidification", 0.92, 1.00, 0.52, 0.48, 0.50, 0.68, 1.00),
        BoundaryResilienceProfile("novel_entities", 1.65, 1.00, 0.34, 0.30, 0.36, 0.40, 1.25),
        BoundaryResilienceProfile("atmospheric_aerosol_loading", 0.95, 1.00, 0.44, 0.40, 0.44, 0.46, 0.95),
        BoundaryResilienceProfile("stratospheric_ozone_depletion", 0.72, 1.00, 0.70, 0.68, 0.72, 0.82, 0.80),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def build_interaction_matrix(boundaries: list[str]) -> pd.DataFrame:
    """Create an illustrative directed interaction matrix."""
    matrix = pd.DataFrame(0.0, index=boundaries, columns=boundaries)

    matrix.loc["climate_change", "biosphere_integrity"] = 0.35
    matrix.loc["climate_change", "freshwater_change"] = 0.28
    matrix.loc["climate_change", "land_system_change"] = 0.18
    matrix.loc["climate_change", "ocean_acidification"] = 0.25

    matrix.loc["biosphere_integrity", "climate_change"] = 0.24
    matrix.loc["biosphere_integrity", "freshwater_change"] = 0.18
    matrix.loc["biosphere_integrity", "land_system_change"] = 0.20

    matrix.loc["land_system_change", "biosphere_integrity"] = 0.30
    matrix.loc["land_system_change", "freshwater_change"] = 0.22
    matrix.loc["land_system_change", "climate_change"] = 0.20

    matrix.loc["freshwater_change", "biosphere_integrity"] = 0.20
    matrix.loc["freshwater_change", "biogeochemical_flows"] = 0.12

    matrix.loc["biogeochemical_flows", "freshwater_change"] = 0.26
    matrix.loc["biogeochemical_flows", "biosphere_integrity"] = 0.22
    matrix.loc["biogeochemical_flows", "ocean_acidification"] = 0.10

    matrix.loc["novel_entities", "biosphere_integrity"] = 0.18
    matrix.loc["novel_entities", "freshwater_change"] = 0.12

    matrix.loc["atmospheric_aerosol_loading", "climate_change"] = 0.12
    matrix.loc["atmospheric_aerosol_loading", "freshwater_change"] = 0.15

    return matrix


def score_resilience(
    data: pd.DataFrame,
    interactions: pd.DataFrame,
    weights: dict[str, float],
    interaction_lambda: float = 0.60,
) -> pd.DataFrame:
    """Score resilience capacity and interaction-adjusted boundary risk."""
    scored = data.copy()

    if (scored["boundary_value"] <= 0).any():
        raise ValueError("Boundary values must be positive.")

    scored["pressure_ratio"] = scored["observed_pressure"] / scored["boundary_value"]

    scored["resilience_capacity"] = (
        scored["diversity"] * weights["diversity"]
        + scored["redundancy"] * weights["redundancy"]
        + scored["adaptive_capacity"] * weights["adaptive_capacity"]
        + scored["monitoring_capacity"] * weights["monitoring_capacity"]
    )

    scored["resilience_gap"] = 1 - scored["resilience_capacity"]

    pressure_vector = scored.set_index("boundary")["pressure_ratio"]
    interaction_pressure = interactions.T.dot(pressure_vector)

    scored["interaction_pressure"] = scored["boundary"].map(interaction_pressure)

    scored["resilience_adjusted_risk"] = (
        (scored["pressure_ratio"] + interaction_lambda * scored["interaction_pressure"])
        * scored["resilience_gap"]
        * scored["structural_weight"]
    )

    scored["risk_class"] = pd.cut(
        scored["resilience_adjusted_risk"],
        bins=[-float("inf"), 0.45, 0.90, float("inf")],
        labels=["lower_risk", "moderate_risk", "high_risk"],
    )

    scored["dominant_resilience_gap"] = scored[
        ["diversity", "redundancy", "adaptive_capacity", "monitoring_capacity"]
    ].idxmin(axis=1)

    return scored.sort_values("resilience_adjusted_risk", ascending=False)


def main() -> None:
    """Run the Earth system resilience workflow."""
    output_dir = Path("articles/planetary-boundaries-and-earth-system-resilience/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_boundary_profiles()
    interactions = build_interaction_matrix(data["boundary"].tolist())

    weights = normalize_weights(
        [
            CapacityWeight("diversity", 1.25),
            CapacityWeight("redundancy", 1.10),
            CapacityWeight("adaptive_capacity", 1.00),
            CapacityWeight("monitoring_capacity", 0.90),
        ]
    )

    scored = score_resilience(data, interactions, weights)

    scored.to_csv(output_dir / "earth_system_resilience_scores.csv", index=False)
    interactions.to_csv(output_dir / "boundary_interaction_matrix.csv")

    print(scored)


if __name__ == "__main__":
    main()
