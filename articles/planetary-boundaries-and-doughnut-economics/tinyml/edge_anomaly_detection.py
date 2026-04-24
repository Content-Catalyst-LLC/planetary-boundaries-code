"""
TinyML-oriented edge anomaly detection scaffold.

This example uses a lightweight z-score method as a conceptual bridge.
In a real TinyML deployment, the model could be replaced by a quantized
classifier, anomaly detector, or sensor-fusion pipeline.
"""

from __future__ import annotations

import numpy as np


class RollingAnomalyDetector:
    """Small rolling-window anomaly detector suitable for edge translation."""

    def __init__(self, window_size: int = 8, z_threshold: float = 2.5) -> None:
        self.window_size = window_size
        self.z_threshold = z_threshold
        self.values: list[float] = []

    def update(self, value: float) -> bool:
        """Update the detector and return True if value is anomalous."""
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

    stream = [1.01, 1.02, 1.00, 1.03, 1.02, 1.01, 1.65, 1.04]

    for reading in stream:
        print(
            {
                "reading": reading,
                "anomaly": detector.update(reading),
            }
        )
