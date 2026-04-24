"""
Earth system governance-fit scoring workflow.

This workflow models governance risk as a relationship between:
- boundary pressure
- monitoring capacity
- legal and institutional fit
- justice and legitimacy
- adaptive capacity
- cross-scale coordination

The data are illustrative. Replace them with documented indicators,
expert elicitation, stakeholder assessment, institutional data, treaty
tracking, legal analysis, or governance-performance metrics before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd


@dataclass(frozen=True)
class GovernanceWeight:
    """Weight assigned to a governance-capacity dimension."""

    dimension: str
    weight: float


def normalize_weights(weights: list[GovernanceWeight]) -> dict[str, float]:
    """Normalize governance-capacity weights so they sum to one."""
    total = sum(item.weight for item in weights)

    if total <= 0:
        raise ValueError("Total weight must be positive.")

    return {item.dimension: item.weight / total for item in weights}


def build_governance_cases() -> pd.DataFrame:
    """Create illustrative governance case data."""
    return pd.DataFrame(
        {
            "case": [
                "Global climate coordination",
                "Transboundary freshwater basin",
                "National land-use transition",
                "Chemical pollution governance",
                "Urban adaptation network",
                "Regional biodiversity compact",
            ],
            "domain": [
                "climate",
                "freshwater",
                "land",
                "novel_entities",
                "climate",
                "biosphere",
            ],
            "boundary_pressure": [1.45, 1.30, 1.25, 1.70, 1.10, 1.20],
            "boundary_level": [1.00, 1.00, 1.00, 1.00, 1.00, 1.00],
            "monitoring_capacity": [0.78, 0.62, 0.55, 0.38, 0.70, 0.58],
            "legal_institutional_fit": [0.60, 0.54, 0.48, 0.35, 0.50, 0.52],
            "justice_legitimacy": [0.52, 0.46, 0.40, 0.42, 0.62, 0.50],
            "adaptive_capacity": [0.66, 0.50, 0.45, 0.32, 0.72, 0.56],
            "cross_scale_coordination": [0.58, 0.52, 0.44, 0.30, 0.60, 0.48],
            "domain_weight": [1.4, 1.1, 1.0, 1.2, 1.0, 1.3],
        }
    )


def score_governance_fit(
    data: pd.DataFrame,
    weights: dict[str, float],
) -> pd.DataFrame:
    """Score governance fit and adjusted fragility."""
    scored = data.copy()

    scored["boundary_transgression"] = np.maximum(
        0,
        (scored["boundary_pressure"] - scored["boundary_level"])
        / scored["boundary_level"],
    )

    scored["governance_capacity"] = (
        scored["monitoring_capacity"] * weights["monitoring_capacity"]
        + scored["legal_institutional_fit"] * weights["legal_institutional_fit"]
        + scored["justice_legitimacy"] * weights["justice_legitimacy"]
        + scored["adaptive_capacity"] * weights["adaptive_capacity"]
        + scored["cross_scale_coordination"] * weights["cross_scale_coordination"]
    )

    scored["governance_gap"] = 1 - scored["governance_capacity"]

    scored["governance_adjusted_fragility"] = (
        scored["boundary_transgression"]
        * scored["governance_gap"]
        * scored["domain_weight"]
    )

    scored["fragility_class"] = pd.cut(
        scored["governance_adjusted_fragility"],
        bins=[-np.inf, 0.10, 0.30, np.inf],
        labels=["lower_fragility", "moderate_fragility", "high_fragility"],
    )

    return scored.sort_values(
        "governance_adjusted_fragility",
        ascending=False,
    ).reset_index(drop=True)


def main() -> None:
    """Run the Earth system governance-fit workflow."""
    output_dir = Path(
        "articles/earth-system-governance-in-an-age-of-limits/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_governance_cases()

    weights = normalize_weights(
        [
            GovernanceWeight("monitoring_capacity", 1),
            GovernanceWeight("legal_institutional_fit", 1),
            GovernanceWeight("justice_legitimacy", 1),
            GovernanceWeight("adaptive_capacity", 1),
            GovernanceWeight("cross_scale_coordination", 1),
        ]
    )

    scored = score_governance_fit(data, weights)

    scored.to_csv(output_dir / "governance_fit_scores.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
