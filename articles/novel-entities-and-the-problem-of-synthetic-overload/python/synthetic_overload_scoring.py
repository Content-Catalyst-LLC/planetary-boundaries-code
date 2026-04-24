"""
Novel entities synthetic overload workflow.

This workflow models the novel entities boundary using:
- production volume
- environmental release fraction
- persistence
- mobility
- hazard
- exposure
- monitoring coverage
- assessment status
- governance capacity

The values are illustrative. Replace them with documented chemical
inventories, production data, release estimates, monitoring records,
hazard data, and transparent assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


AssessmentStatus = Literal[
    "adequately_assessed",
    "partially_assessed",
    "poorly_assessed",
    "not_assessed",
]


@dataclass(frozen=True)
class NovelEntityClass:
    """Profile for a class of novel entities."""

    entity_class: str
    annual_production_index: float
    environmental_release_fraction: float
    persistence: float
    mobility: float
    hazard: float
    exposure: float
    monitoring_coverage: float
    assessment_status: AssessmentStatus
    substitution_feasibility: float
    essentiality: float


ASSESSMENT_GAP_WEIGHTS: dict[AssessmentStatus, float] = {
    "adequately_assessed": 0.00,
    "partially_assessed": 0.35,
    "poorly_assessed": 0.70,
    "not_assessed": 1.00,
}


def build_entity_profiles() -> pd.DataFrame:
    """Create illustrative novel-entity class data."""
    profiles = [
        NovelEntityClass("plastics_and_microplastics", 1.00, 0.32, 0.86, 0.62, 0.54, 0.72, 0.46, "partially_assessed", 0.58, 0.42),
        NovelEntityClass("pfas_forever_chemicals", 0.42, 0.28, 0.98, 0.88, 0.82, 0.78, 0.34, "poorly_assessed", 0.44, 0.36),
        NovelEntityClass("pesticides_and_biocides", 0.68, 0.40, 0.54, 0.48, 0.76, 0.70, 0.52, "partially_assessed", 0.50, 0.58),
        NovelEntityClass("industrial_additives", 0.74, 0.22, 0.68, 0.46, 0.62, 0.56, 0.38, "poorly_assessed", 0.48, 0.50),
        NovelEntityClass("pharmaceutical_residues", 0.38, 0.36, 0.42, 0.58, 0.52, 0.64, 0.44, "partially_assessed", 0.36, 0.76),
        NovelEntityClass("flame_retardants", 0.30, 0.18, 0.74, 0.42, 0.70, 0.50, 0.40, "partially_assessed", 0.52, 0.46),
        NovelEntityClass("engineered_nanomaterials", 0.24, 0.20, 0.60, 0.64, 0.50, 0.46, 0.28, "poorly_assessed", 0.42, 0.44),
        NovelEntityClass("radioactive_materials", 0.18, 0.08, 0.92, 0.30, 0.95, 0.32, 0.68, "partially_assessed", 0.22, 0.70),
        NovelEntityClass("unknown_or_unregistered_entities", 0.55, 0.30, 0.70, 0.65, 0.60, 0.62, 0.12, "not_assessed", 0.30, 0.40),
    ]

    return pd.DataFrame([profile.__dict__ for profile in profiles])


def score_synthetic_overload(data: pd.DataFrame) -> pd.DataFrame:
    """Score synthetic overload risk by entity class."""
    scored = data.copy()

    scored["release_index"] = (
        scored["annual_production_index"] * scored["environmental_release_fraction"]
    )

    scored["intrinsic_risk"] = (
        scored["persistence"]
        * scored["mobility"]
        * scored["hazard"]
        * scored["exposure"]
    )

    scored["assessment_gap"] = scored["assessment_status"].map(ASSESSMENT_GAP_WEIGHTS)
    scored["monitoring_gap"] = 1 - scored["monitoring_coverage"]

    scored["governance_gap"] = (
        0.55 * scored["assessment_gap"]
        + 0.45 * scored["monitoring_gap"]
    )

    scored["essential_use_pressure"] = scored["essentiality"] * (
        1 - scored["substitution_feasibility"]
    )

    scored["synthetic_overload_score"] = (
        scored["release_index"]
        * scored["intrinsic_risk"]
        * (1 + scored["governance_gap"])
        * (1 + scored["essential_use_pressure"])
    )

    scored["priority_class"] = np.select(
        [
            scored["synthetic_overload_score"] >= 0.22,
            scored["governance_gap"] >= 0.65,
            scored["persistence"] >= 0.85,
        ],
        [
            "urgent_pressure_reduction",
            "assessment_and_monitoring_priority",
            "persistence_precaution_priority",
        ],
        default="standard_control_priority",
    )

    return scored.sort_values(
        "synthetic_overload_score",
        ascending=False,
    ).reset_index(drop=True)


def summarize_boundary_status(scored: pd.DataFrame) -> pd.DataFrame:
    """Create boundary-level summary metrics."""
    total_production = scored["annual_production_index"].sum()
    total_release = scored["release_index"].sum()

    weighted_risk = (
        scored["synthetic_overload_score"] * scored["annual_production_index"]
    ).sum() / total_production

    average_assessment_gap = scored["assessment_gap"].mean()
    average_monitoring_gap = scored["monitoring_gap"].mean()

    overload_ratio = (
        total_release * (1 + average_assessment_gap + average_monitoring_gap)
    )

    return pd.DataFrame(
        {
            "total_production_index": [total_production],
            "total_release_index": [total_release],
            "weighted_synthetic_overload_risk": [weighted_risk],
            "average_assessment_gap": [average_assessment_gap],
            "average_monitoring_gap": [average_monitoring_gap],
            "synthetic_overload_ratio": [overload_ratio],
            "diagnostic": [
                "outside_safe_operating_space"
                if overload_ratio >= 1
                else "inside_or_near_safe_operating_space"
            ],
        }
    )


def main() -> None:
    """Run the novel entities synthetic overload workflow."""
    output_dir = Path("articles/novel-entities-and-the-problem-of-synthetic-overload/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_entity_profiles()
    scored = score_synthetic_overload(data)
    summary = summarize_boundary_status(scored)

    scored.to_csv(output_dir / "novel_entities_overload_scores.csv", index=False)
    summary.to_csv(output_dir / "boundary_status_summary.csv", index=False)

    print(scored)
    print(summary)


if __name__ == "__main__":
    main()
