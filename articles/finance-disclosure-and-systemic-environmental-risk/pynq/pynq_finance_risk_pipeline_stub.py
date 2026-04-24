"""
PYNQ-oriented finance risk monitoring scaffold.

This file shows how a PYNQ-style workflow could separate software
orchestration from hardware-accelerated preprocessing of environmental
signals or portfolio-risk streams.

Actual deployment requires a configured PYNQ board and hardware overlay.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class SignalBatch:
    domain: str
    readings: list[float]
    threshold: float


def software_preprocess(readings: list[float]) -> float:
    """Software fallback for reducing a signal batch."""
    if not readings:
        raise ValueError("readings cannot be empty")
    return sum(readings) / len(readings)


def pressure_ratio(observed: float, threshold: float) -> float:
    """Calculate pressure ratio."""
    return observed / threshold


def run_pipeline(batch: SignalBatch) -> dict[str, float | str]:
    """Run a software version of a PYNQ-style monitoring pipeline."""
    observed = software_preprocess(batch.readings)
    ratio = pressure_ratio(observed, batch.threshold)

    return {
        "domain": batch.domain,
        "observed": observed,
        "threshold": batch.threshold,
        "pressure_ratio": ratio,
    }


if __name__ == "__main__":
    batch = SignalBatch(
        domain="water",
        readings=[1.08, 1.12, 1.18, 1.09, 1.20],
        threshold=1.00,
    )

    print(run_pipeline(batch))
