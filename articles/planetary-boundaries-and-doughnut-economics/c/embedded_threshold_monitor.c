// Embedded-style threshold monitor.
//
// This example demonstrates low-resource threshold scoring logic that
// could be adapted for microcontroller-based environmental monitoring.

#include <stdio.h>
#include <stdbool.h>

typedef struct {
    const char *name;
    double observed;
    double threshold;
    bool ceiling;
} SensorIndicator;

double penalty(SensorIndicator indicator) {
    if (indicator.ceiling && indicator.observed > indicator.threshold) {
        return (indicator.observed - indicator.threshold) / indicator.threshold;
    }

    if (!indicator.ceiling && indicator.observed < indicator.threshold) {
        return (indicator.threshold - indicator.observed) / indicator.threshold;
    }

    return 0.0;
}

int main(void) {
    SensorIndicator indicators[] = {
        {"co2_per_capita_proxy", 9.8, 3.0, true},
        {"clean_energy_access_proxy", 0.70, 0.90, false}
    };

    int count = sizeof(indicators) / sizeof(indicators[0]);

    for (int i = 0; i < count; i++) {
        double score = penalty(indicators[i]);

        if (score > 0.0) {
            printf("%s threshold alert: %.3f\n", indicators[i].name, score);
        } else {
            printf("%s within target range\n", indicators[i].name);
        }
    }

    return 0;
}
