// Embedded-style precautionary threshold alert scaffold.

#include <stdio.h>
#include <stdbool.h>

typedef struct {
    const char *boundary;
    double observed_pressure;
    double estimated_threshold;
    double threshold_uncertainty;
    double precaution_factor;
} BoundarySignal;

double precautionary_boundary(BoundarySignal signal) {
    return signal.estimated_threshold -
           signal.precaution_factor * signal.threshold_uncertainty;
}

double pressure_ratio(BoundarySignal signal) {
    return signal.observed_pressure / precautionary_boundary(signal);
}

int main(void) {
    BoundarySignal signal = {
        "freshwater_change",
        1.22,
        1.10,
        0.18,
        1.10
    };

    double boundary_value = precautionary_boundary(signal);
    double ratio = pressure_ratio(signal);

    printf("Boundary: %s\n", signal.boundary);
    printf("Precautionary boundary: %.3f\n", boundary_value);
    printf("Pressure ratio: %.3f\n", ratio);

    if (ratio >= 1.0) {
        printf("Alert: pressure has entered the zone of increasing risk.\n");
    }

    return 0;
}
