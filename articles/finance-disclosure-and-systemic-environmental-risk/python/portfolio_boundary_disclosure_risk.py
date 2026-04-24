"""
Portfolio-level boundary and disclosure risk scoring.

This workflow models systemic environmental risk by combining:
- portfolio exposure
- boundary-relevant thresholds
- disclosure adequacy
- transition credibility
- uncertainty penalties

The data are illustrative. Replace them with documented issuer data,
portfolio holdings, emissions data, nature-related metrics, audited
disclosures, and institution-specific thresholds before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd


BoundaryDomain = Literal[
    "climate",
    "water",
    "land",
    "biosphere",
    "nitrogen",
    "novel_entities",
]


@dataclass(frozen=True)
class BoundarySpec:
    """Metadata for a boundary-relevant risk domain."""

    domain: BoundaryDomain
    threshold: float
    weight: float
    unit: str
    rationale: str


def build_boundary_specs() -> dict[str, BoundarySpec]:
    """Create illustrative boundary-domain metadata."""
    specs = [
        BoundarySpec("climate", 1.0, 1.5, "portfolio pressure index", "Climate risk proxy"),
        BoundarySpec("water", 1.0, 1.1, "portfolio pressure index", "Water stress proxy"),
        BoundarySpec("land", 1.0, 1.0, "portfolio pressure index", "Land conversion proxy"),
        BoundarySpec("biosphere", 1.0, 1.3, "portfolio pressure index", "Biodiversity proxy"),
        BoundarySpec("nitrogen", 1.0, 0.9, "portfolio pressure index", "Nutrient pollution proxy"),
        BoundarySpec("novel_entities", 1.0, 1.2, "portfolio pressure index", "Chemical risk proxy"),
    ]

    return {spec.domain: spec for spec in specs}


def build_sample_portfolio() -> pd.DataFrame:
    """Create illustrative issuer-domain exposure data."""
    return pd.DataFrame(
        {
            "issuer": [
                "Utility A",
                "Agribusiness B",
                "Chemicals C",
                "Infrastructure D",
                "Bank E",
                "Retail F",
            ],
            "portfolio_weight": [0.18, 0.16, 0.14, 0.20, 0.22, 0.10],
            "domain": [
                "climate",
                "land",
                "novel_entities",
                "water",
                "climate",
                "biosphere",
            ],
            "exposure_pressure": [1.45, 1.25, 1.70, 1.10, 1.35, 0.95],
            "disclosure_adequacy": [0.70, 0.42, 0.35, 0.62, 0.78, 0.50],
            "transition_credibility": [0.55, 0.38, 0.30, 0.58, 0.64, 0.45],
            "uncertainty": [0.25, 0.40, 0.50, 0.30, 0.20, 0.35],
        }
    )


def score_issuer_domain_risk(
    portfolio: pd.DataFrame,
    specs: dict[str, BoundarySpec],
) -> pd.DataFrame:
    """Score issuer-level systemic environmental risk."""
    scored = portfolio.copy()

    scored["boundary_threshold"] = scored["domain"].map(
        lambda domain: specs[domain].threshold
    )
    scored["domain_weight"] = scored["domain"].map(
        lambda domain: specs[domain].weight
    )

    scored["boundary_pressure_ratio"] = (
        scored["exposure_pressure"] / scored["boundary_threshold"]
    )

    scored["disclosure_gap"] = 1 - scored["disclosure_adequacy"]
    scored["transition_gap"] = 1 - scored["transition_credibility"]

    scored["risk_score"] = (
        scored["boundary_pressure_ratio"]
        * (1 + scored["disclosure_gap"])
        * (1 + scored["transition_gap"])
        * (1 + scored["uncertainty"])
        * scored["domain_weight"]
    )

    scored["portfolio_contribution"] = (
        scored["portfolio_weight"] * scored["risk_score"]
    )

    return scored


def summarize_portfolio(scored: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Create portfolio-level and domain-level summaries."""
    domain_summary = (
        scored.groupby("domain")
        .agg(
            portfolio_weight=("portfolio_weight", "sum"),
            weighted_risk=("portfolio_contribution", "sum"),
            mean_disclosure_adequacy=("disclosure_adequacy", "mean"),
            mean_transition_credibility=("transition_credibility", "mean"),
            mean_uncertainty=("uncertainty", "mean"),
        )
        .reset_index()
        .sort_values("weighted_risk", ascending=False)
    )

    total_risk = scored["portfolio_contribution"].sum()
    weighted_disclosure = np.average(
        scored["disclosure_adequacy"],
        weights=scored["portfolio_weight"],
    )
    weighted_transition = np.average(
        scored["transition_credibility"],
        weights=scored["portfolio_weight"],
    )

    portfolio_summary = pd.DataFrame(
        {
            "portfolio_systemic_environmental_risk": [total_risk],
            "weighted_disclosure_adequacy": [weighted_disclosure],
            "weighted_transition_credibility": [weighted_transition],
        }
    )

    return portfolio_summary, domain_summary


def run_sensitivity(scored: pd.DataFrame) -> pd.DataFrame:
    """Test sensitivity to disclosure and transition assumptions."""
    scenarios = {
        "baseline": {"disclosure_multiplier": 1.0, "transition_multiplier": 1.0},
        "skeptical_disclosure": {"disclosure_multiplier": 0.8, "transition_multiplier": 1.0},
        "skeptical_transition": {"disclosure_multiplier": 1.0, "transition_multiplier": 0.8},
        "stress_case": {"disclosure_multiplier": 0.75, "transition_multiplier": 0.75},
    }

    frames = []

    for scenario_name, params in scenarios.items():
        scenario = scored.copy()
        scenario["adjusted_disclosure"] = (
            scenario["disclosure_adequacy"] * params["disclosure_multiplier"]
        ).clip(0, 1)
        scenario["adjusted_transition"] = (
            scenario["transition_credibility"] * params["transition_multiplier"]
        ).clip(0, 1)

        scenario["adjusted_risk_score"] = (
            scenario["boundary_pressure_ratio"]
            * (1 + (1 - scenario["adjusted_disclosure"]))
            * (1 + (1 - scenario["adjusted_transition"]))
            * (1 + scenario["uncertainty"])
            * scenario["domain_weight"]
        )

        scenario["adjusted_portfolio_contribution"] = (
            scenario["portfolio_weight"] * scenario["adjusted_risk_score"]
        )
        scenario["scenario"] = scenario_name

        frames.append(scenario)

    return pd.concat(frames, ignore_index=True)


def main() -> None:
    """Run the portfolio boundary-risk workflow."""
    output_dir = Path(
        "articles/finance-disclosure-and-systemic-environmental-risk/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    specs = build_boundary_specs()
    portfolio = build_sample_portfolio()

    scored = score_issuer_domain_risk(portfolio, specs)
    portfolio_summary, domain_summary = summarize_portfolio(scored)
    sensitivity = run_sensitivity(scored)

    scored.to_csv(output_dir / "issuer_domain_boundary_risk.csv", index=False)
    portfolio_summary.to_csv(output_dir / "portfolio_summary.csv", index=False)
    domain_summary.to_csv(output_dir / "domain_summary.csv", index=False)
    sensitivity.to_csv(output_dir / "sensitivity_analysis.csv", index=False)

    print("\nPortfolio summary:")
    print(portfolio_summary)

    print("\nDomain summary:")
    print(domain_summary)


if __name__ == "__main__":
    main()
