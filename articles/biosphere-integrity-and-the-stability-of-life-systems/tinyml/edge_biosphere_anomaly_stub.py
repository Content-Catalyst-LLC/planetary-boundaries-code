"""
TinyML-oriented biosphere anomaly detection scaffold.

This illustrates how low-power or edge systems might flag unusual
vegetation-index, acoustic-diversity, camera-trap, soil-moisture,
habitat-disturbance, or ecological sensor signals before they are
integrated into biosphere integrity dashboards.
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

    # Example ecosystem-function-like signal from an edge monitoring device.
    stream = [0.76, 0.75, 0.77, 0.74, 0.76, 0.75, 0.51, 0.74]

    for reading in stream:
        print({"biosphere_signal": reading, "anomaly": detector.update(reading)})
