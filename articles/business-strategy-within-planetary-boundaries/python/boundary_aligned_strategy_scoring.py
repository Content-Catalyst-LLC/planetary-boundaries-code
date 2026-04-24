"""
Boundary-aligned business strategy scoring.

This workflow models business units across:
- absolute boundary pressure
- allocated ecological budget
- transition capability
- overshoot dependency
- supply-chain transparency
- strategic fragility

The data are illustrative. Replace them with firm-specific environmental
accounts, lifecycle data, supplier data, scenario analysis, and documented
allocation methods before applied use.
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
class BoundaryWeight:
    """Weight assigned to a boundary-relevant domain."""

    domain: BoundaryDomain
    weight: float


def build_business_unit_data() -> pd.DataFrame:
    """Create illustrative business-unit data."""
    return pd.DataFrame(
        {
            "business_unit": [
                "Durable Products",
                "Disposable Goods",
                "Industrial Chemicals",
                "Circular Services",
                "Agricultural Inputs",
                "Digital Infrastructure",
            ],
            "domain": [
                "climate",
                "land",
                "novel_entities",
                "water",
                "nitrogen",
                "climate",
            ],
            "absolute_impact": [1.20, 1.45, 1.80, 0.75, 1.65, 1.10],
            "allocated_budget": [1.00, 1.00, 1.00, 1.00, 1.00, 1.00],
            "transition_capability": [0.62, 0.38, 0.30, 0.78, 0.42, 0.66],
            "overshoot_dependency": [0.45, 0.82, 0.90, 0.22, 0.76, 0.40],
            "supply_chain_transparency": [0.70, 0.46, 0.35, 0.72, 0.40, 0.68],
            "revenue_share": [0.18, 0.22, 0.16, 0.14, 0.20, 0.10],
        }
    )


def build_boundary_weights() -> dict[str, float]:
    """Create illustrative boundary-domain weights."""
    weights = [
        BoundaryWeight("climate", 1.4),
        BoundaryWeight("water", 1.1),
        BoundaryWeight("land", 1.0),
        BoundaryWeight("biosphere", 1.3),
        BoundaryWeight("nitrogen", 1.0),
        BoundaryWeight("novel_entities", 1.2),
    ]

    return {item.domain: item.weight for item in weights}


def score_business_units(
    data: pd.DataFrame,
    weights: dict[str, float],
) -> pd.DataFrame:
    """Score business units for boundary alignment and strategic fragility."""
    scored = data.copy()

    scored["domain_weight"] = scored["domain"].map(weights)
    scored["alignment_ratio"] = (
        scored["absolute_impact"] / scored["allocated_budget"]
    )

    scored["boundary_pressure"] = np.maximum(
        0,
        scored["alignment_ratio"] - 1,
    ) * scored["domain_weight"]

    scored["transparency_gap"] = 1 - scored["supply_chain_transparency"]

    scored["strategic_fragility"] = (
        scored["boundary_pressure"]
        * (1 - scored["transition_capability"])
        * (1 + scored["overshoot_dependency"])
        * (1 + scored["transparency_gap"])
    )

    scored["portfolio_weighted_fragility"] = (
        scored["revenue_share"] * scored["strategic_fragility"]
    )

    scored["strategic_class"] = pd.cut(
        scored["strategic_fragility"],
        bins=[-np.inf, 0.15, 0.50, np.inf],
        labels=["lower_fragility", "moderate_fragility", "high_fragility"],
    )

    return scored.sort_values(
        "portfolio_weighted_fragility",
        ascending=False,
    ).reset_index(drop=True)


def summarize_strategy(scored: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Create portfolio and domain summaries."""
    portfolio_summary = pd.DataFrame(
        {
            "revenue_weighted_fragility": [
                scored["portfolio_weighted_fragility"].sum()
            ],
            "mean_transition_capability": [
                np.average(
                    scored["transition_capability"],
                    weights=scored["revenue_share"],
                )
            ],
            "mean_supply_chain_transparency": [
                np.average(
                    scored["supply_chain_transparency"],
                    weights=scored["revenue_share"],
                )
            ],
            "mean_overshoot_dependency": [
                np.average(
                    scored["overshoot_dependency"],
                    weights=scored["revenue_share"],
                )
            ],
        }
    )

    domain_summary = (
        scored.groupby("domain")
        .agg(
            revenue_share=("revenue_share", "sum"),
            boundary_pressure=("boundary_pressure", "sum"),
            weighted_fragility=("portfolio_weighted_fragility", "sum"),
            mean_transition_capability=("transition_capability", "mean"),
            mean_transparency=("supply_chain_transparency", "mean"),
        )
        .reset_index()
        .sort_values("weighted_fragility", ascending=False)
    )

    return portfolio_summary, domain_summary


def run_transition_scenarios(scored: pd.DataFrame) -> pd.DataFrame:
    """Evaluate how strategic fragility changes under transition scenarios."""
    scenarios = {
        "baseline": {
            "transition_gain": 0.00,
            "dependency_reduction": 0.00,
            "transparency_gain": 0.00,
        },
        "governance_upgrade": {
            "transition_gain": 0.10,
            "dependency_reduction": 0.05,
            "transparency_gain": 0.15,
        },
        "business_model_redesign": {
            "transition_gain": 0.20,
            "dependency_reduction": 0.25,
            "transparency_gain": 0.20,
        },
        "deep_alignment": {
            "transition_gain": 0.30,
            "dependency_reduction": 0.40,
            "transparency_gain": 0.30,
        },
    }

    frames = []

    for scenario_name, params in scenarios.items():
        scenario = scored.copy()
        scenario["scenario"] = scenario_name

        scenario["scenario_transition_capability"] = (
            scenario["transition_capability"] + params["transition_gain"]
        ).clip(0, 1)

        scenario["scenario_overshoot_dependency"] = (
            scenario["overshoot_dependency"] - params["dependency_reduction"]
        ).clip(0, 1)

        scenario["scenario_transparency"] = (
            scenario["supply_chain_transparency"] + params["transparency_gain"]
        ).clip(0, 1)

        scenario["scenario_transparency_gap"] = 1 - scenario["scenario_transparency"]

        scenario["scenario_fragility"] = (
            scenario["boundary_pressure"]
            * (1 - scenario["scenario_transition_capability"])
            * (1 + scenario["scenario_overshoot_dependency"])
            * (1 + scenario["scenario_transparency_gap"])
        )

        scenario["scenario_weighted_fragility"] = (
            scenario["revenue_share"] * scenario["scenario_fragility"]
        )

        frames.append(scenario)

    return pd.concat(frames, ignore_index=True)


def main() -> None:
    """Run the boundary-aligned strategy workflow."""
    output_dir = Path(
        "articles/business-strategy-within-planetary-boundaries/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    data = build_business_unit_data()
    weights = build_boundary_weights()

    scored = score_business_units(data, weights)
    portfolio_summary, domain_summary = summarize_strategy(scored)
    scenarios = run_transition_scenarios(scored)

    scored.to_csv(output_dir / "business_unit_strategy_scores.csv", index=False)
    portfolio_summary.to_csv(output_dir / "portfolio_strategy_summary.csv", index=False)
    domain_summary.to_csv(output_dir / "domain_strategy_summary.csv", index=False)
    scenarios.to_csv(output_dir / "transition_scenarios.csv", index=False)

    print("\nBusiness-unit strategy scores:")
    print(scored)

    print("\nPortfolio summary:")
    print(portfolio_summary)


if __name__ == "__main__":
    main()
