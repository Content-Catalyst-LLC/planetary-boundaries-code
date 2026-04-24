"""
PYNQ boundary scoring pipeline scaffold.

This file shows how a PYNQ-oriented workflow could separate software
orchestration from hardware-accelerated preprocessing.

Actual execution requires a PYNQ board, a hardware overlay, and a
configured data path. This scaffold is intentionally safe to read and
adapt without requiring hardware.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class SensorBatch:
    indicator: str
    readings: list[float]
    threshold: float
    direction: str


def software_preprocess(readings: list[float]) -> float:
    """Software fallback for reducing a batch to a representative value."""
    if not readings:
        raise ValueError("readings cannot be empty")
    return sum(readings) / len(readings)


def boundary_penalty(observed: float, threshold: float, direction: str) -> float:
    """Compute overshoot or shortfall after preprocessing."""
    if direction == "ceiling":
        return max(0.0, (observed - threshold) / threshold)

    if direction == "floor":
        return max(0.0, (threshold - observed) / threshold)

    raise ValueError("direction must be 'ceiling' or 'floor'")


def run_pipeline(batch: SensorBatch) -> dict[str, float | str]:
    """
    Run a software version of the pipeline.

    In a PYNQ implementation, software_preprocess could be replaced
    with an overlay call for accelerated filtering or aggregation.
    """
    observed = software_preprocess(batch.readings)
    penalty = boundary_penalty(observed, batch.threshold, batch.direction)

    return {
        "indicator": batch.indicator,
        "observed": observed,
        "threshold": batch.threshold,
        "penalty": penalty,
    }


if __name__ == "__main__":
    batch = SensorBatch(
        indicator="water_quality_proxy",
        readings=[0.92, 0.94, 0.91, 0.89, 0.88],
        threshold=0.90,
        direction="floor",
    )

    print(run_pipeline(batch))
