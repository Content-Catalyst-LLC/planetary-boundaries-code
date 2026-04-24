from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "planetary_stewardship_panel.csv"
OUTPUT_FILE = "planetary_stewardship_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    df = pd.read_csv(path)

    required_columns = [
        "territory_name",
        "country_or_region",
        "territory_type",
        "governance_coherence_index",
        "justice_legitimacy_index",
        "restoration_regeneration_index",
        "boundary_pressure_index",
        "urban_transformation_index",
        "community_stewardship_index",
    ]

    missing = [col for col in required_columns if col not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    return df


def validate_indices(df: pd.DataFrame) -> pd.DataFrame:
    index_columns = [col for col in df.columns if col.endswith("_index")]
    for col in index_columns:
        if ((df[col] < 0) | (df[col] > 1)).any():
            raise ValueError(f"Column '{col}' contains values outside [0, 1].")
    return df


def compute_scores(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()

    df["stewardship_capacity_score"] = (
        0.26 * df["governance_coherence_index"] +
        0.22 * df["justice_legitimacy_index"] +
        0.20 * df["restoration_regeneration_index"] +
        0.16 * df["urban_transformation_index"] +
        0.16 * df["community_stewardship_index"]
    ).clip(lower=0, upper=1)

    df["boundary_response_gap"] = (
        df["boundary_pressure_index"] - df["stewardship_capacity_score"]
    )

    df["risk_band"] = np.select(
        [
            df["boundary_response_gap"] >= 0.30,
            df["boundary_response_gap"] >= 0.15,
            df["boundary_response_gap"] >= 0.05,
        ],
        [
            "Severe stewardship gap",
            "High stewardship gap",
            "Moderate stewardship gap",
        ],
        default="Lower stewardship gap",
    )

    return df


def main() -> None:
    df = load_data(INPUT_FILE)
    df = validate_indices(df)
    scored = compute_scores(df)
    scored.to_csv(OUTPUT_FILE, index=False)
    print("Planetary stewardship scoring complete.")
    print(scored.to_string(index=False))


if __name__ == "__main__":
    main()
