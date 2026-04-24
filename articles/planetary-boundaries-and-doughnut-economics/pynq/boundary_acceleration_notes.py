"""
PYNQ-oriented boundary acceleration notes.

This scaffold shows where a hardware-accelerated preprocessing
or scoring function could sit in a PYNQ workflow.

Actual deployment would require a configured PYNQ board, overlay,
and hardware-specific implementation.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class BoundaryReading:
    indicator: str
    observed: float
    threshold: float


def software_boundary_score(reading: BoundaryReading) -> float:
    """
    Software fallback for proportional overshoot.

    A PYNQ implementation could replace this with an accelerated
    hardware function for high-volume sensor streams.
    """
    if reading.observed > reading.threshold:
        return (reading.observed - reading.threshold) / reading.threshold
    return 0.0


example = BoundaryReading(
    indicator="material_footprint_per_capita",
    observed=18.0,
    threshold=8.0,
)

print(
    {
        "indicator": example.indicator,
        "overshoot": software_boundary_score(example),
    }
)
