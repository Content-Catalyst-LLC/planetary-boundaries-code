"""
TinyML-oriented climate anomaly detection scaffold.

This illustrates how low-power edge systems might flag unusual CO2,
temperature, humidity, heat-index, wildfire-smoke, or infrastructure-stress
signals before they are integrated into climate boundary dashboards.
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

    # Example heat-index-like stream from a climate monitoring device.
    stream = [0.62, 0.64, 0.63, 0.65, 0.64, 0.66, 0.92, 0.67]

    for reading in stream:
        print({"climate_signal": reading, "anomaly": detector.update(reading)})
