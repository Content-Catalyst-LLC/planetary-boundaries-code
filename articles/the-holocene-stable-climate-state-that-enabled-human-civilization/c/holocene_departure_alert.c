// Embedded-style Holocene departure alert scaffold.

#include <stdio.h>

typedef struct {
    const char *indicator;
    double holocene_reference;
    double observed_value;
    double holocene_variability;
} HoloceneSignal;

double standardized_departure(HoloceneSignal signal) {
    return (signal.observed_value - signal.holocene_reference) / signal.holocene_variability;
}

int main(void) {
    HoloceneSignal signal = {
        "global_temperature",
        0.00,
        1.20,
        0.35
    };

    double departure = standardized_departure(signal);

    printf("Indicator: %s\n", signal.indicator);
    printf("Standardized departure: %.3f\n", departure);

    if (departure >= 3.0) {
        printf("Alert: major departure from Holocene reference range.\n");
    } else if (departure >= 1.5) {
        printf("Watch: emerging departure from Holocene reference range.\n");
    } else {
        printf("Status: within or near reference range.\n");
    }

    return 0;
}
