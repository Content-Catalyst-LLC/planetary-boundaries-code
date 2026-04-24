"""
TinyML-oriented synthetic overload anomaly detection scaffold.

This illustrates how low-power edge systems might flag unusual spikes
in water-quality, air-quality, or industrial-release signals before
they are integrated into novel-entities dashboards.
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

    stream = [0.12, 0.11, 0.13, 0.12, 0.14, 0.13, 0.31, 0.12]

    for reading in stream:
        print({"chemical_signal": reading, "anomaly": detector.update(reading)})
