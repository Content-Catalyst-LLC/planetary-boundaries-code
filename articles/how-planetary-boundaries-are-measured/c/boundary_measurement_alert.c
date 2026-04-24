// Embedded-style planetary-boundary measurement alert scaffold.

#include <stdio.h>

typedef struct {
    const char *boundary_process;
    double observed_value;
    double boundary_value;
    double high_risk_value;
} BoundarySignal;

double pressure_ratio(BoundarySignal signal) {
    return signal.observed_value / signal.boundary_value;
}

int main(void) {
    BoundarySignal signal = {
        "freshwater_change",
        1.28,
        1.00,
        1.50
    };

    double ratio = pressure_ratio(signal);

    printf("Boundary process: %s\n", signal.boundary_process);
    printf("Pressure ratio: %.3f\n", ratio);

    if (ratio >= signal.high_risk_value / signal.boundary_value) {
        printf("Alert: high-risk zone.\n");
    } else if (ratio >= 1.0) {
        printf("Alert: zone of increasing risk.\n");
    } else {
        printf("Status: safe zone.\n");
    }

    return 0;
}
