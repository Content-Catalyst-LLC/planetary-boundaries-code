"""
PYNQ-oriented SDG-boundary monitoring scaffold.

This file shows how a PYNQ-style workflow could separate software
orchestration from accelerated preprocessing of environmental or
development indicator streams. Actual deployment requires a configured
PYNQ board and hardware overlay.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class SignalBatch:
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
    """Calculate shortfall or overshoot."""
    if direction == "floor":
        return max(0.0, (threshold - observed) / threshold)

    if direction == "ceiling":
        return max(0.0, (observed - threshold) / threshold)

    raise ValueError("direction must be 'floor' or 'ceiling'")


def run_pipeline(batch: SignalBatch) -> dict[str, float | str]:
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
    batch = SignalBatch(
        signal_name="clean_energy_access",
        readings=[0.60, 0.62, 0.63, 0.61, 0.64],
        threshold=0.90,
        direction="floor",
    )

    print(run_pipeline(batch))
