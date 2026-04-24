// Embedded-style SDG threshold alert scaffold.

#include <stdio.h>

double floor_shortfall(double observed, double floor_value) {
    if (observed < floor_value) {
        return (floor_value - observed) / floor_value;
    }

    return 0.0;
}

double ceiling_overshoot(double observed, double ceiling_value) {
    if (observed > ceiling_value) {
        return (observed - ceiling_value) / ceiling_value;
    }

    return 0.0;
}

int main(void) {
    double clean_energy_access = 0.62;
    double clean_energy_floor = 0.90;

    double nutrient_pressure = 1.48;
    double nutrient_ceiling = 1.00;

    printf("Clean energy shortfall: %.3f\n",
           floor_shortfall(clean_energy_access, clean_energy_floor));

    printf("Nutrient pressure overshoot: %.3f\n",
           ceiling_overshoot(nutrient_pressure, nutrient_ceiling));

    return 0;
}
