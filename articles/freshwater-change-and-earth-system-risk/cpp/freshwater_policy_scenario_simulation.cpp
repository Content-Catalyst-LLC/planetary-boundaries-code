// Freshwater policy scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include <cmath>

struct Scenario {
    std::string name;
    double blue_water_deviation;
    double green_water_deviation;
    double groundwater_stress;
    double wetland_buffer_capacity;
    double ecological_sensitivity;
    double social_ecological_exposure;
    double monitoring_capacity;
    double governance_capacity;
    double adaptive_capacity;
};

double hydrological_boundary_pressure(const Scenario& s) {
    return 0.38 * std::abs(s.blue_water_deviation)
        + 0.42 * std::abs(s.green_water_deviation)
        + 0.20 * s.groundwater_stress;
}

double freshwater_system_risk_score(const Scenario& s) {
    double buffer_gap = 1.0 - s.wetland_buffer_capacity;
    double monitoring_gap = 1.0 - s.monitoring_capacity;
    double governance_gap = 1.0 - s.governance_capacity;
    double adaptive_gap = 1.0 - s.adaptive_capacity;

    return hydrological_boundary_pressure(s)
        * s.ecological_sensitivity
        * s.social_ecological_exposure
        * (1.0 + 0.25 * buffer_gap + 0.25 * monitoring_gap + 0.30 * governance_gap + 0.20 * adaptive_gap);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", -0.32, -0.38, 0.82, 0.28, 0.78, 0.79, 0.52, 0.40, 0.38},
        {"improved_monitoring", -0.31, -0.36, 0.78, 0.32, 0.78, 0.79, 0.61, 0.52, 0.44},
        {"groundwater_demand_reduction", -0.29, -0.34, 0.57, 0.34, 0.78, 0.79, 0.63, 0.54, 0.45},
        {"integrated_hydrological_resilience", -0.28, -0.26, 0.51, 0.54, 0.78, 0.79, 0.70, 0.64, 0.50}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " freshwater system risk score: "
                  << std::fixed << std::setprecision(3)
                  << freshwater_system_risk_score(scenario)
                  << std::endl;
    }

    return 0;
}
