// Embedded-style threshold monitoring example in C.

#include <stdio.h>

double overshoot(double observed, double boundary) {
    if (observed > boundary) {
        return (observed - boundary) / boundary;
    }
    return 0.0;
}

int main(void) {
    double observed_co2 = 9.8;
    double co2_boundary = 3.0;

    double result = overshoot(observed_co2, co2_boundary);

    if (result > 0.0) {
        printf("Boundary exceeded. Overshoot: %.3f\n", result);
    } else {
        printf("Boundary respected.\n");
    }

    return 0;
}
