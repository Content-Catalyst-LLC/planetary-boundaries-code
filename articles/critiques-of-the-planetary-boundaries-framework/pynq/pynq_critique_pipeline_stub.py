"""
PYNQ-oriented critique-aware monitoring scaffold.

This file shows how software orchestration could be separated from
hardware-accelerated preprocessing in a planetary-boundary monitoring
pipeline. Actual deployment requires a configured PYNQ board and overlay.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class MonitoringBatch:
    indicator: str
    readings: list[float]
    threshold: float
    uncertainty: float


def software_preprocess(readings: list[float]) -> float:
    """Software fallback for reducing a sensor batch."""
    if not readings:
        raise ValueError("readings cannot be empty")
    return sum(readings) / len(readings)


def overshoot(observed: float, threshold: float) -> float:
    """Calculate proportional overshoot."""
    return max(0.0, (observed - threshold) / threshold)


def run_pipeline(batch: MonitoringBatch) -> dict[str, float | str]:
    """Run a software version of a PYNQ-style monitoring pipeline."""
    observed = software_preprocess(batch.readings)
    pressure = overshoot(observed, batch.threshold)

    return {
        "indicator": batch.indicator,
        "observed": observed,
        "threshold": batch.threshold,
        "overshoot": pressure,
        "uncertainty": batch.uncertainty,
    }


if __name__ == "__main__":
    batch = MonitoringBatch(
        indicator="freshwater_pressure_proxy",
        readings=[1.08, 1.12, 1.18, 1.09, 1.20],
        threshold=1.00,
        uncertainty=0.12,
    )

    print(run_pipeline(batch))
