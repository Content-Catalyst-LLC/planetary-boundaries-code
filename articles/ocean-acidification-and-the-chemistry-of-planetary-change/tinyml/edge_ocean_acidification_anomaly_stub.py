"""
TinyML-oriented ocean acidification anomaly detection scaffold.

This illustrates how low-power edge systems might flag unusual pH,
temperature, oxygen, or carbonate-proxy signals before they are integrated
into marine chemistry dashboards.
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

    # Example pH-like sensor stream.
    stream = [8.02, 8.01, 8.03, 8.00, 8.02, 8.01, 7.82, 8.01]

    for reading in stream:
        print({"ph_signal": reading, "anomaly": detector.update(reading)})
