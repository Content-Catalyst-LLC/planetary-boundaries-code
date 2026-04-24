// Embedded-style ozone and UV threshold alert scaffold.

#include <stdio.h>

typedef struct {
    const char *region;
    double ozone_du;
    double boundary_du;
    double uv_index_proxy;
} OzoneSignal;

double boundary_margin(OzoneSignal signal) {
    return (signal.ozone_du - signal.boundary_du) / signal.boundary_du;
}

int main(void) {
    OzoneSignal signal = {
        "global_mean_stratosphere",
        286.0,
        276.0,
        0.42
    };

    double margin = boundary_margin(signal);

    printf("Region: %s\n", signal.region);
    printf("Boundary margin: %.3f\n", margin);
    printf("UV proxy: %.3f\n", signal.uv_index_proxy);

    if (signal.ozone_du < signal.boundary_du) {
        printf("Alert: ozone value below boundary reference.\n");
    } else if (margin < 0.03) {
        printf("Watch: ozone value near boundary reference.\n");
    } else {
        printf("Status: ozone value above boundary reference.\n");
    }

    return 0;
}
