// Embedded-style streamflow and soil-moisture threshold alert scaffold.

#include <stdio.h>
#include <math.h>

typedef struct {
    const char *station;
    double streamflow_current;
    double streamflow_baseline;
    double soil_moisture_current;
    double soil_moisture_baseline;
} FreshwaterSignal;

double blue_water_deviation(FreshwaterSignal signal) {
    return (signal.streamflow_current - signal.streamflow_baseline) / signal.streamflow_baseline;
}

double green_water_deviation(FreshwaterSignal signal) {
    return (signal.soil_moisture_current - signal.soil_moisture_baseline) / signal.soil_moisture_baseline;
}

int main(void) {
    FreshwaterSignal signal = {
        "watershed_station_01",
        0.72,
        1.00,
        0.76,
        1.00
    };

    double blue_dev = blue_water_deviation(signal);
    double green_dev = green_water_deviation(signal);

    printf("Station: %s\n", signal.station);
    printf("Blue-water deviation: %.3f\n", blue_dev);
    printf("Green-water deviation: %.3f\n", green_dev);

    if (fabs(blue_dev) >= 0.25 && fabs(green_dev) >= 0.25) {
        printf("Alert: blue-water and green-water deviations exceed watch levels.\n");
    } else if (fabs(blue_dev) >= 0.25 || fabs(green_dev) >= 0.25) {
        printf("Watch: one freshwater component exceeds watch level.\n");
    } else {
        printf("Status: freshwater deviations below watch levels.\n");
    }

    return 0;
}
