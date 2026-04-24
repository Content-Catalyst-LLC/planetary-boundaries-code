// Embedded-style forest-cover and fragmentation threshold alert scaffold.

#include <stdio.h>

typedef struct {
    const char *station;
    double remaining_forest_ratio;
    double biome_boundary_threshold;
    double fragmentation_risk;
} LandSignal;

double forest_boundary_pressure(LandSignal signal) {
    return signal.biome_boundary_threshold / signal.remaining_forest_ratio;
}

int main(void) {
    LandSignal signal = {
        "forest_monitoring_tile_01",
        0.72,
        0.85,
        0.68
    };

    double pressure = forest_boundary_pressure(signal);

    printf("Station: %s\n", signal.station);
    printf("Forest boundary pressure: %.3f\n", pressure);
    printf("Fragmentation risk: %.3f\n", signal.fragmentation_risk);

    if (pressure >= 1.0 && signal.fragmentation_risk >= 0.65) {
        printf("Alert: forest cover below threshold and fragmentation risk high.\n");
    } else if (pressure >= 1.0) {
        printf("Watch: forest cover below biome threshold.\n");
    } else {
        printf("Status: forest cover above biome threshold.\n");
    }

    return 0;
}
