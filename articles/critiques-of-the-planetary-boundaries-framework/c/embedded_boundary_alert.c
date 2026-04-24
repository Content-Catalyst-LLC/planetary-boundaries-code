// Embedded-style boundary alert scaffold.
//
// This example demonstrates low-resource alert logic that separates
// threshold pressure from uncertainty and legitimacy flags.

#include <stdio.h>
#include <stdbool.h>

typedef struct {
    const char *indicator;
    double observed;
    double threshold;
    double uncertainty;
    bool legitimacy_review_required;
} BoundarySignal;

double overshoot(double observed, double threshold) {
    if (observed > threshold) {
        return (observed - threshold) / threshold;
    }

    return 0.0;
}

int main(void) {
    BoundarySignal signal = {
        "freshwater_pressure_proxy",
        1.18,
        1.00,
        0.12,
        true
    };

    double score = overshoot(signal.observed, signal.threshold);

    printf("Indicator: %s\n", signal.indicator);
    printf("Overshoot: %.3f\n", score);
    printf("Uncertainty: %.3f\n", signal.uncertainty);

    if (signal.legitimacy_review_required) {
        printf("Governance review required before decision escalation.\n");
    }

    return 0;
}
