// Embedded-style tipping threshold alert scaffold.

#include <stdio.h>

typedef struct {
    const char *element;
    double pressure;
    double threshold;
    double threshold_uncertainty;
    double precaution_factor;
} TippingSignal;

double precautionary_threshold(TippingSignal signal) {
    return signal.threshold - signal.precaution_factor * signal.threshold_uncertainty;
}

double pressure_ratio(TippingSignal signal) {
    return signal.pressure / precautionary_threshold(signal);
}

int main(void) {
    TippingSignal signal = {
        "amazon_rainforest",
        1.24,
        1.00,
        0.18,
        1.10
    };

    double ratio = pressure_ratio(signal);

    printf("Element: %s\n", signal.element);
    printf("Pressure ratio: %.3f\n", ratio);

    if (ratio >= 1.5) {
        printf("Alert: high tipping-risk zone.\n");
    } else if (ratio >= 1.0) {
        printf("Alert: zone of increasing tipping risk.\n");
    } else {
        printf("Status: below precautionary threshold.\n");
    }

    return 0;
}
