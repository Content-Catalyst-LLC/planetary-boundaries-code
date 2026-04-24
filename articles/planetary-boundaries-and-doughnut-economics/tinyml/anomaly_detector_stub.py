"""
TinyML-oriented anomaly detection scaffold.

This is not a deployed TinyML model. It demonstrates the basic logic
that could later be compressed, converted, or implemented on an edge
device using a TinyML toolchain.
"""

from __future__ import annotations

import numpy as np


def z_score_anomaly(values: np.ndarray, threshold: float = 2.5) -> np.ndarray:
    """Return True for values whose z-score exceeds the threshold."""
    mean = values.mean()
    std = values.std()

    if std == 0:
        return np.zeros_like(values, dtype=bool)

    z_scores = np.abs((values - mean) / std)
    return z_scores > threshold


sensor_values = np.array([1.01, 1.03, 1.02, 1.04, 1.05, 1.95, 1.02])
anomalies = z_score_anomaly(sensor_values)

for value, is_anomaly in zip(sensor_values, anomalies):
    print({"value": float(value), "anomaly": bool(is_anomaly)})
