"""
PYNQ-oriented planetary justice monitoring scaffold.

This file shows how a PYNQ-style workflow could separate software
orchestration from accelerated preprocessing of environmental or
social-access signals. Actual deployment requires a configured PYNQ
board and hardware overlay.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class JusticeSignalBatch:
    signal_name: str
    readings: list[float]
    threshold: float
    direction: str


def software_preprocess(readings: list[float]) -> float:
    """Software fallback for reducing a signal batch."""
    if not readings:
        raise ValueError("readings cannot be empty")
    return sum(readings) / len(readings)


def score_gap(observed: float, threshold: float, direction: str) -> float:
    """Calculate overuse or shortfall."""
    if direction == "ceiling":
        return max(0.0, (observed - threshold) / threshold)

    if direction == "floor":
        return max(0.0, (threshold - observed) / threshold)

    raise ValueError("direction must be 'ceiling' or 'floor'")


def run_pipeline(batch: JusticeSignalBatch) -> dict[str, float | str]:
    """Run a software version of a PYNQ-style monitoring pipeline."""
    observed = software_preprocess(batch.readings)
    gap = score_gap(observed, batch.threshold, batch.direction)

    return {
        "signal": batch.signal_name,
        "observed": observed,
        "threshold": batch.threshold,
        "gap": gap,
    }


if __name__ == "__main__":
    batch = JusticeSignalBatch(
        signal_name="clean_energy_access_proxy",
        readings=[0.48, 0.51, 0.49, 0.53, 0.52],
        threshold=0.85,
        direction="floor",
    )

    print(run_pipeline(batch))
