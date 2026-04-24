// Embedded-style justice threshold alert scaffold.

#include <stdio.h>

double shortfall(double observed, double minimum) {
    if (observed < minimum) {
        return (minimum - observed) / minimum;
    }

    return 0.0;
}

int main(void) {
    const char *indicator = "clean_energy_access_proxy";
    double observed = 0.52;
    double minimum = 0.85;

    double gap = shortfall(observed, minimum);

    printf("Indicator: %s\n", indicator);
    printf("Access shortfall: %.3f\n", gap);

    if (gap > 0.25) {
        printf("Alert: severe minimum-access shortfall.\n");
    }

    return 0;
}
