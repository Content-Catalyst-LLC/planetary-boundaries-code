// Embedded-style particulate threshold alert scaffold.

#include <stdio.h>

typedef struct {
    const char *region;
    double pm25_signal;
    double pm25_reference;
    double vulnerability_index;
} ParticulateSignal;

double exposure_ratio(ParticulateSignal signal) {
    return signal.pm25_signal / signal.pm25_reference;
}

double vulnerability_adjusted_signal(ParticulateSignal signal) {
    return exposure_ratio(signal) * (1.0 + signal.vulnerability_index);
}

int main(void) {
    ParticulateSignal signal = {
        "south_asia_monsoon_region",
        0.86,
        0.50,
        0.78
    };

    double ratio = exposure_ratio(signal);
    double adjusted = vulnerability_adjusted_signal(signal);

    printf("Region: %s\n", signal.region);
    printf("Exposure ratio: %.3f\n", ratio);
    printf("Vulnerability-adjusted signal: %.3f\n", adjusted);

    if (adjusted >= 2.0) {
        printf("Alert: elevated regional aerosol exposure signal.\n");
    } else {
        printf("Status: standard monitoring priority.\n");
    }

    return 0;
}
