// Embedded-style environmental threshold alert.
//
// This example shows low-resource threshold monitoring logic that could
// be adapted for edge devices, facility monitoring, or sensor gateways.

#include <stdio.h>
#include <stdbool.h>

typedef struct {
    const char *indicator;
    double observed;
    double threshold;
    bool alert_enabled;
} EnvironmentalSignal;

double pressure_ratio(double observed, double threshold) {
    return observed / threshold;
}

int main(void) {
    EnvironmentalSignal signal = {
        "water_stress_proxy",
        1.24,
        1.00,
        true
    };

    double ratio = pressure_ratio(signal.observed, signal.threshold);

    printf("Indicator: %s\n", signal.indicator);
    printf("Pressure ratio: %.3f\n", ratio);

    if (signal.alert_enabled && ratio > 1.0) {
        printf("Alert: threshold pressure exceeded.\n");
    }

    return 0;
}
