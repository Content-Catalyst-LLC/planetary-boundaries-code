// Embedded-style planetary-boundary threshold alert scaffold.

#include <stdio.h>

typedef struct {
    const char *boundary;
    double observed_value;
    double boundary_value;
    double uncertainty_band;
} BoundarySignal;

double pressure_ratio(BoundarySignal signal) {
    return signal.observed_value / signal.boundary_value;
}

double uncertainty_margin(BoundarySignal signal) {
    return (signal.boundary_value - signal.observed_value) / signal.uncertainty_band;
}

int main(void) {
    BoundarySignal signal = {
        "freshwater_change",
        1.36,
        1.00,
        0.16
    };

    double ratio = pressure_ratio(signal);
    double margin = uncertainty_margin(signal);

    printf("Boundary: %s\n", signal.boundary);
    printf("Boundary pressure ratio: %.3f\n", ratio);
    printf("Uncertainty margin: %.3f\n", margin);

    if (ratio >= 1.0) {
        printf("Alert: boundary is transgressed.\n");
    } else if (ratio >= 0.80) {
        printf("Watch: system is in the increasing-risk zone.\n");
    } else {
        printf("Status: system remains in the safer zone.\n");
    }

    return 0;
}
