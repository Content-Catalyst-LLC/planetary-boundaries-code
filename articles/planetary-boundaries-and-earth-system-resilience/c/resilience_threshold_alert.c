// Embedded-style resilience threshold alert scaffold.

#include <stdio.h>

typedef struct {
    const char *boundary;
    double observed_pressure;
    double boundary_value;
    double resilience_capacity;
} ResilienceSignal;

double pressure_ratio(ResilienceSignal signal) {
    return signal.observed_pressure / signal.boundary_value;
}

double resilience_gap(ResilienceSignal signal) {
    return 1.0 - signal.resilience_capacity;
}

int main(void) {
    ResilienceSignal signal = {
        "freshwater_change",
        1.25,
        1.00,
        0.49
    };

    double ratio = pressure_ratio(signal);
    double gap = resilience_gap(signal);

    printf("Boundary: %s\n", signal.boundary);
    printf("Pressure ratio: %.3f\n", ratio);
    printf("Resilience gap: %.3f\n", gap);

    if (ratio >= 1.0 && gap >= 0.5) {
        printf("Alert: high pressure with weak resilience capacity.\n");
    } else if (ratio >= 1.0) {
        printf("Alert: boundary pressure exceeds the guardrail.\n");
    } else {
        printf("Status: below boundary pressure guardrail.\n");
    }

    return 0;
}
