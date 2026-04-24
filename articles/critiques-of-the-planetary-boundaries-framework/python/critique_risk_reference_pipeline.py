"""
Advanced critique-aware planetary boundaries diagnostic.

This workflow models several critiques of the planetary boundaries framework
as explicit risk dimensions:

- biophysical boundary pressure
- justice and distribution risk
- democratic legitimacy risk
- political-economy driver risk
- operationalization and downscaling risk

The values are illustrative. Replace them with documented data,
stakeholder-derived assessments, expert elicitation, or transparent
institutional scoring before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


RiskDomain = Literal[
    "biophysical",
    "justice",
    "legitimacy",
    "political_economy",
    "operationalization",
]


@dataclass(frozen=True)
class RiskWeight:
    """Weight for a critique-aware risk domain."""

    domain: RiskDomain
    weight: float


def normalize_weights(weights: list[RiskWeight]) -> dict[str, float]:
    """Normalize weights so they sum to one."""
    total = sum(item.weight for item in weights)

    if total <= 0:
        raise ValueError("Total weight must be positive.")

    return {item.domain: item.weight / total for item in weights}


def build_sample_data() -> pd.DataFrame:
    """
    Create illustrative critique-risk data.

    Scores are scaled from 0 to 1:
    - 0 means low risk or strong performance
    - 1 means high risk or weak performance
    """
    return pd.DataFrame(
        {
            "case": [
                "Global aggregate dashboard",
                "National climate allocation",
                "Corporate science-based target",
                "City-level boundary dashboard",
                "Community-led watershed transition",
            ],
            "biophysical": [0.85, 0.70, 0.62, 0.55, 0.38],
            "justice": [0.72, 0.80, 0.66, 0.52, 0.30],
            "legitimacy": [0.76, 0.68, 0.72, 0.44, 0.22],
            "political_economy": [0.82, 0.76, 0.88, 0.58, 0.35],
            "operationalization": [0.60, 0.65, 0.48, 0.42, 0.36],
        }
    )


def score_cases(data: pd.DataFrame, weights: dict[str, float]) -> pd.DataFrame:
    """Calculate critique-aware total risk for each case."""
    domain_cols = list(weights.keys())

    scored = data.copy()
    scored["total_critique_risk"] = 0.0

    for domain in domain_cols:
        scored["total_critique_risk"] += scored[domain] * weights[domain]

    scored["risk_class"] = pd.cut(
        scored["total_critique_risk"],
        bins=[-np.inf, 0.33, 0.66, np.inf],
        labels=["low", "moderate", "high"],
    )

    return scored.sort_values("total_critique_risk", ascending=False)


def run_sensitivity(data: pd.DataFrame) -> pd.DataFrame:
    """
    Run alternative weighting scenarios.

    This reveals whether conclusions depend heavily on one value judgment.
    """
    scenarios = {
        "equal_weight": [
            RiskWeight("biophysical", 1),
            RiskWeight("justice", 1),
            RiskWeight("legitimacy", 1),
            RiskWeight("political_economy", 1),
            RiskWeight("operationalization", 1),
        ],
        "justice_priority": [
            RiskWeight("biophysical", 1),
            RiskWeight("justice", 2),
            RiskWeight("legitimacy", 1.5),
            RiskWeight("political_economy", 1),
            RiskWeight("operationalization", 1),
        ],
        "implementation_priority": [
            RiskWeight("biophysical", 1),
            RiskWeight("justice", 1),
            RiskWeight("legitimacy", 1),
            RiskWeight("political_economy", 1),
            RiskWeight("operationalization", 2),
        ],
        "political_economy_priority": [
            RiskWeight("biophysical", 1),
            RiskWeight("justice", 1.2),
            RiskWeight("legitimacy", 1),
            RiskWeight("political_economy", 2),
            RiskWeight("operationalization", 1),
        ],
    }

    frames = []

    for scenario_name, scenario_weights in scenarios.items():
        normalized = normalize_weights(scenario_weights)
        scored = score_cases(data, normalized)
        scored["scenario"] = scenario_name
        scored["rank"] = scored["total_critique_risk"].rank(
            ascending=False,
            method="dense",
        )
        frames.append(scored)

    return pd.concat(frames, ignore_index=True)


def identify_dominant_risk(data: pd.DataFrame) -> pd.DataFrame:
    """Identify the highest risk domain for each case."""
    domain_cols = [
        "biophysical",
        "justice",
        "legitimacy",
        "political_economy",
        "operationalization",
    ]

    result = data.copy()
    result["dominant_risk_domain"] = result[domain_cols].idxmax(axis=1)
    result["dominant_risk_value"] = result[domain_cols].max(axis=1)

    return result[["case", "dominant_risk_domain", "dominant_risk_value"]]


def main() -> None:
    """Run the critique-aware diagnostic workflow."""
    output_dir = Path(
        "articles/critiques-of-the-planetary-boundaries-framework/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_sample_data()

    baseline_weights = normalize_weights(
        [
            RiskWeight("biophysical", 1),
            RiskWeight("justice", 1),
            RiskWeight("legitimacy", 1),
            RiskWeight("political_economy", 1),
            RiskWeight("operationalization", 1),
        ]
    )

    baseline = score_cases(data, baseline_weights)
    sensitivity = run_sensitivity(data)
    dominant = identify_dominant_risk(data)

    baseline.to_csv(output_dir / "critique_risk_baseline.csv", index=False)
    sensitivity.to_csv(output_dir / "critique_risk_sensitivity.csv", index=False)
    dominant.to_csv(output_dir / "dominant_risk_domains.csv", index=False)

    print("\nBaseline critique-risk diagnostic:")
    print(baseline)

    print("\nDominant risk domains:")
    print(dominant)


if __name__ == "__main__":
    main()
