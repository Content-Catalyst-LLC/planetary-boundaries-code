"""
TinyML-oriented source-triage anomaly scaffold.

This lightweight example illustrates how automated document workflows might
flag unusual metadata, missing provenance, or atypical source patterns before
human review. It is included as an optional engineering extension for knowledge
architecture rather than as a required method for the article.
"""

from __future__ import annotations

import numpy as np


class RollingAnomalyDetector:
    """Small rolling-window anomaly detector."""

    def __init__(self, window_size: int = 8, z_threshold: float = 2.5) -> None:
        self.window_size = window_size
        self.z_threshold = z_threshold
        self.values: list[float] = []

    def update(self, value: float) -> bool:
        self.values.append(value)

        if len(self.values) > self.window_size:
            self.values.pop(0)

        if len(self.values) < 3:
            return False

        arr = np.array(self.values, dtype=float)
        std = arr.std()

        if std == 0:
            return False

        z_score = abs((value - arr.mean()) / std)
        return bool(z_score > self.z_threshold)


if __name__ == "__main__":
    detector = RollingAnomalyDetector(window_size=6, z_threshold=2.0)

    # Example source-quality score stream from a hypothetical document pipeline.
    stream = [0.82, 0.84, 0.81, 0.83, 0.85, 0.82, 0.44, 0.83]

    for score in stream:
        print({"source_quality_score": score, "anomaly": detector.update(score)})
