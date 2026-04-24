// Embedded-style CO2 and heat threshold alert scaffold.

#include <stdio.h>
#include <math.h>

typedef struct {
    const char *station;
    double co2_ppm;
    double co2_boundary_ppm;
    double co2_baseline_ppm;
    double heat_index_signal;
    double heat_index_watch_level;
} ClimateSignal;

double co2_boundary_pressure(ClimateSignal signal) {
    return signal.co2_ppm / signal.co2_boundary_ppm;
}

double co2_radiative_forcing(ClimateSignal signal) {
    return 5.35 * log(signal.co2_ppm / signal.co2_baseline_ppm);
}

int main(void) {
    ClimateSignal signal = {
        "climate_monitoring_station_01",
        429.8,
        350.0,
        280.0,
        0.82,
        0.75
    };

    double pressure = co2_boundary_pressure(signal);
    double forcing = co2_radiative_forcing(signal);

    printf("Station: %s\n", signal.station);
    printf("CO2 boundary pressure: %.3f\n", pressure);
    printf("CO2 radiative forcing: %.3f W/m2\n", forcing);

    if (pressure >= 1.0 && signal.heat_index_signal >= signal.heat_index_watch_level) {
        printf("Alert: CO2 boundary pressure and heat signal exceed watch levels.\n");
    } else if (pressure >= 1.0) {
        printf("Watch: CO2 boundary pressure exceeds reference.\n");
    } else {
        printf("Status: CO2 boundary pressure below reference.\n");
    }

    return 0;
}
