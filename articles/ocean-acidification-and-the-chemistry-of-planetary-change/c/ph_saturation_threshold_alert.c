// Embedded-style pH and aragonite saturation threshold alert scaffold.

#include <stdio.h>
#include <math.h>

typedef struct {
    const char *region;
    double current_ph;
    double preindustrial_ph;
    double aragonite_saturation_state;
    double boundary_aragonite_state;
} OceanChemistrySignal;

double ph_decline(OceanChemistrySignal signal) {
    return signal.preindustrial_ph - signal.current_ph;
}

double hydrogen_ion_increase_index(OceanChemistrySignal signal) {
    return pow(10.0, -signal.current_ph) / pow(10.0, -signal.preindustrial_ph);
}

int main(void) {
    OceanChemistrySignal signal = {
        "temperate_shellfish_coasts",
        7.98,
        8.10,
        1.72,
        1.75
    };

    printf("Region: %s\n", signal.region);
    printf("pH decline: %.3f\n", ph_decline(signal));
    printf(
        "Hydrogen ion increase index: %.3f\n",
        hydrogen_ion_increase_index(signal)
    );

    if (signal.aragonite_saturation_state < signal.boundary_aragonite_state) {
        printf("Alert: aragonite saturation below boundary reference.\n");
    } else {
        printf("Status: aragonite saturation above boundary reference.\n");
    }

    return 0;
}
