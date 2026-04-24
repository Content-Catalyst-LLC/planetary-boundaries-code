// Embedded-style habitat and functional-integrity threshold alert scaffold.

#include <stdio.h>

typedef struct {
    const char *station;
    double functional_integrity_index;
    double functional_integrity_threshold;
    double habitat_intactness;
    double fragmentation_risk;
} BiosphereSignal;

double functional_integrity_deficit(BiosphereSignal signal) {
    double deficit = signal.functional_integrity_threshold - signal.functional_integrity_index;
    return deficit > 0.0 ? deficit : 0.0;
}

int main(void) {
    BiosphereSignal signal = {
        "ecosystem_monitoring_tile_01",
        0.52,
        0.80,
        0.58,
        0.72
    };

    double deficit = functional_integrity_deficit(signal);

    printf("Station: %s\n", signal.station);
    printf("Functional integrity deficit: %.3f\n", deficit);
    printf("Habitat intactness: %.3f\n", signal.habitat_intactness);
    printf("Fragmentation risk: %.3f\n", signal.fragmentation_risk);

    if (deficit >= 0.25 && signal.fragmentation_risk >= 0.70) {
        printf("Alert: functional integrity deficit and fragmentation risk are high.\n");
    } else if (deficit >= 0.25) {
        printf("Watch: functional integrity below threshold.\n");
    } else {
        printf("Status: functional integrity above watch threshold.\n");
    }

    return 0;
}
