// Embedded-style chemical risk threshold alert scaffold.

#include <stdio.h>

typedef struct {
    const char *entity_class;
    double production_index;
    double release_fraction;
    double persistence;
    double mobility;
    double hazard;
    double exposure;
} EntitySignal;

double release_index(EntitySignal signal) {
    return signal.production_index * signal.release_fraction;
}

double intrinsic_risk(EntitySignal signal) {
    return signal.persistence * signal.mobility * signal.hazard * signal.exposure;
}

int main(void) {
    EntitySignal signal = {
        "pesticides_and_biocides",
        0.68,
        0.40,
        0.54,
        0.48,
        0.76,
        0.70
    };

    double release = release_index(signal);
    double risk = intrinsic_risk(signal);
    double score = release * risk;

    printf("Entity class: %s\n", signal.entity_class);
    printf("Release index: %.3f\n", release);
    printf("Intrinsic risk: %.3f\n", risk);
    printf("Preliminary overload score: %.3f\n", score);

    if (score >= 0.10) {
        printf("Alert: elevated synthetic overload signal.\n");
    } else {
        printf("Status: standard monitoring priority.\n");
    }

    return 0;
}
