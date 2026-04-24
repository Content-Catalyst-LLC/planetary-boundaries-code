// Climate policy scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include <cmath>

struct Scenario {
    std::string name;
    double co2_ppm;
    double co2_boundary_ppm;
    double co2_baseline_ppm;
    double forcing_boundary_wm2;
    double cross_boundary_stress;
    double exposure_pressure;
    double transition_gap;
    double adaptive_gap;
    double monitoring_gap;
    double governance_gap;
};

double co2_boundary_pressure(const Scenario& s) {
    return s.co2_ppm / s.co2_boundary_ppm;
}

double radiative_forcing(const Scenario& s) {
    return 5.35 * std::log(s.co2_ppm / s.co2_baseline_ppm);
}

double climate_boundary_risk_score(const Scenario& s) {
    double forcing_pressure = radiative_forcing(s) / s.forcing_boundary_wm2;

    return 0.24 * co2_boundary_pressure(s)
        + 0.24 * forcing_pressure
        + 0.18 * s.cross_boundary_stress
        + 0.14 * s.exposure_pressure
        + 0.12 * s.transition_gap
        + 0.08 * (0.40 * s.adaptive_gap + 0.25 * s.monitoring_gap + 0.35 * s.governance_gap);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 429.8, 350.0, 280.0, 1.0, 0.58, 0.75, 0.53, 0.42, 0.26, 0.48},
        {"rapid_mitigation", 429.8, 350.0, 280.0, 1.0, 0.55, 0.72, 0.22, 0.36, 0.18, 0.34},
        {"sink_protection_and_restoration", 429.8, 350.0, 280.0, 1.0, 0.50, 0.70, 0.30, 0.34, 0.16, 0.32},
        {"integrated_climate_resilience", 429.8, 350.0, 280.0, 1.0, 0.46, 0.64, 0.14, 0.22, 0.08, 0.20}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " climate boundary risk score: "
                  << std::fixed << std::setprecision(3)
                  << climate_boundary_risk_score(scenario)
                  << std::endl;
    }

    return 0;
}
