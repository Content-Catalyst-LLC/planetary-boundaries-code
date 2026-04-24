// Embedded-style nitrate/phosphate threshold alert scaffold.

#include <stdio.h>

typedef struct {
    const char *station;
    double nitrate_signal;
    double nitrate_reference;
    double phosphate_signal;
    double phosphate_reference;
} NutrientSignal;

double nitrate_ratio(NutrientSignal signal) {
    return signal.nitrate_signal / signal.nitrate_reference;
}

double phosphate_ratio(NutrientSignal signal) {
    return signal.phosphate_signal / signal.phosphate_reference;
}

int main(void) {
    NutrientSignal signal = {
        "watershed_station_01",
        1.42,
        1.00,
        1.28,
        1.00
    };

    double n_ratio = nitrate_ratio(signal);
    double p_ratio = phosphate_ratio(signal);

    printf("Station: %s\n", signal.station);
    printf("Nitrate ratio: %.3f\n", n_ratio);
    printf("Phosphate ratio: %.3f\n", p_ratio);

    if (n_ratio >= 1.0 && p_ratio >= 1.0) {
        printf("Alert: nitrogen and phosphorus exceed reference levels.\n");
    } else if (n_ratio >= 1.0 || p_ratio >= 1.0) {
        printf("Watch: one nutrient exceeds reference level.\n");
    } else {
        printf("Status: nutrient signals below reference levels.\n");
    }

    return 0;
}
