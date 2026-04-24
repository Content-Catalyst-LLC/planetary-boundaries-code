"""
Tipping-risk and cascading ecological change workflow.

This workflow models:
- direct pressure on Earth system components
- precautionary thresholds under uncertainty
- feedback amplification
- cascade pressure through a weighted interaction network
- tipping probability
- scenario sensitivity

The values are illustrative. Replace them with documented Earth system
data, expert elicitation, model outputs, monitoring systems, and
transparent assumptions before applied use.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd


@dataclass(frozen=True)
class TippingElement:
    """Representation of an Earth system tipping element."""

    element: str
    pressure: float
    threshold: float
    threshold_uncertainty: float
    precaution_factor: float
    feedback_strength: float
    resilience_capacity: float
    monitoring_capacity: float


def build_tipping_elements() -> pd.DataFrame:
    """Create illustrative tipping-element data."""
    elements = [
        TippingElement("greenland_ice_sheet", 1.18, 1.00, 0.12, 1.0, 0.70, 0.42, 0.74),
        TippingElement("west_antarctic_ice_sheet", 1.12, 1.00, 0.14, 1.0, 0.68, 0.38, 0.66),
        TippingElement("amoc", 0.92, 1.00, 0.20, 1.1, 0.52, 0.48, 0.58),
        TippingElement("amazon_rainforest", 1.24, 1.00, 0.18, 1.1, 0.76, 0.36, 0.56),
        TippingElement("boreal_forest", 1.05, 1.00, 0.16, 1.0, 0.62, 0.44, 0.52),
        TippingElement("permafrost_carbon", 1.15, 1.00, 0.15, 1.0, 0.82, 0.34, 0.50),
        TippingElement("warm_water_coral_reefs", 1.40, 1.00, 0.10, 1.0, 0.74, 0.28, 0.62),
    ]

    return pd.DataFrame([element.__dict__ for element in elements])


def build_interaction_matrix(elements: list[str]) -> pd.DataFrame:
    """Create an illustrative directed interaction matrix."""
    matrix = pd.DataFrame(0.0, index=elements, columns=elements)

    matrix.loc["greenland_ice_sheet", "amoc"] = 0.30
    matrix.loc["west_antarctic_ice_sheet", "amoc"] = 0.18
    matrix.loc["amoc", "amazon_rainforest"] = 0.22
    matrix.loc["amazon_rainforest", "boreal_forest"] = 0.16
    matrix.loc["boreal_forest", "permafrost_carbon"] = 0.20
    matrix.loc["permafrost_carbon", "greenland_ice_sheet"] = 0.24
    matrix.loc["permafrost_carbon", "west_antarctic_ice_sheet"] = 0.20
    matrix.loc["warm_water_coral_reefs", "amazon_rainforest"] = 0.08
    matrix.loc["amazon_rainforest", "amoc"] = 0.10

    return matrix


def logistic(value: float) -> float:
    """Numerically stable logistic transform."""
    return float(1 / (1 + np.exp(-value)))


def score_tipping_risk(data: pd.DataFrame, interactions: pd.DataFrame) -> pd.DataFrame:
    """Score tipping probability and cascade-adjusted risk."""
    scored = data.copy()

    scored["precautionary_threshold"] = (
        scored["threshold"] - scored["precaution_factor"] * scored["threshold_uncertainty"]
    )

    if (scored["precautionary_threshold"] <= 0).any():
        raise ValueError("Precautionary thresholds must remain positive.")

    scored["pressure_ratio"] = scored["pressure"] / scored["precautionary_threshold"]
    scored["resilience_gap"] = 1 - scored["resilience_capacity"]
    scored["monitoring_gap"] = 1 - scored["monitoring_capacity"]

    scored["direct_risk_signal"] = (
        scored["pressure_ratio"]
        + scored["feedback_strength"]
        + scored["resilience_gap"]
        + 0.5 * scored["monitoring_gap"]
    )

    scored["initial_tipped_state"] = (scored["pressure_ratio"] >= 1.0).astype(float)

    tipped_state = scored.set_index("element")["initial_tipped_state"]
    cascade_pressure = interactions.T.dot(tipped_state)

    scored["cascade_pressure"] = scored["element"].map(cascade_pressure)

    scored["tipping_probability"] = scored.apply(
        lambda row: logistic(
            1.8 * (row["pressure_ratio"] - 1.0)
            + 1.2 * row["cascade_pressure"]
            + 0.8 * row["feedback_strength"]
            - 0.9 * row["resilience_capacity"]
        ),
        axis=1,
    )

    scored["cascade_adjusted_risk"] = (
        scored["tipping_probability"]
        * (1 + scored["cascade_pressure"])
        * (1 + scored["monitoring_gap"])
    )

    scored["risk_class"] = pd.cut(
        scored["cascade_adjusted_risk"],
        bins=[-np.inf, 0.35, 0.75, np.inf],
        labels=["lower_risk", "moderate_risk", "high_risk"],
    )

    return scored.sort_values("cascade_adjusted_risk", ascending=False)


def run_warming_scenarios(data: pd.DataFrame, interactions: pd.DataFrame) -> pd.DataFrame:
    """Run scenario multipliers for increased Earth system pressure."""
    scenarios = {
        "baseline": 1.00,
        "moderate_pressure_increase": 1.10,
        "high_pressure_increase": 1.25,
        "extreme_pressure_increase": 1.40,
    }

    frames = []

    for scenario_name, pressure_multiplier in scenarios.items():
        scenario_data = data.copy()
        scenario_data["pressure"] = scenario_data["pressure"] * pressure_multiplier
        scenario = score_tipping_risk(scenario_data, interactions)
        scenario["scenario"] = scenario_name
        scenario["pressure_multiplier"] = pressure_multiplier
        scenario["rank"] = scenario["cascade_adjusted_risk"].rank(
            ascending=False,
            method="dense",
        )
        frames.append(scenario)

    return pd.concat(frames, ignore_index=True)


def main() -> None:
    """Run tipping-risk and cascade simulation workflow."""
    output_dir = Path(
        "articles/tipping-points-feedback-loops-and-cascading-ecological-change/outputs"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    elements = build_tipping_elements()
    interactions = build_interaction_matrix(elements["element"].tolist())

    scored = score_tipping_risk(elements, interactions)
    scenarios = run_warming_scenarios(elements, interactions)

    scored.to_csv(output_dir / "tipping_risk_scores.csv", index=False)
    interactions.to_csv(output_dir / "interaction_matrix.csv")
    scenarios.to_csv(output_dir / "tipping_scenarios.csv", index=False)

    print(scored)


if __name__ == "__main__":
    main()
