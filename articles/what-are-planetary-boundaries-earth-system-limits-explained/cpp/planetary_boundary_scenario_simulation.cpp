// Planetary-boundary scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include <cmath>

struct Scenario {
    std::string name;
    double pressure_ratio;
    double interaction_weight;
    double mean_other_risk;
    double annual_pressure_trend;
    double monitoring_capacity;
    double governance_capacity;
    double reversibility_capacity;
    double social_exposure;
};

double logistic_risk(double pressure_ratio, double steepness = 8.0) {
    return 1.0 / (1.0 + std::exp(-steepness * (pressure_ratio - 1.0)));
}

double systemic_boundary_risk(const Scenario& s) {
    double monitoring_gap = 1.0 - s.monitoring_capacity;
    double governance_gap = 1.0 - s.governance_capacity;
    double reversibility_gap = 1.0 - s.reversibility_capacity;
    double trend_pressure = std::max(0.0, s.annual_pressure_trend);
    double amplification = s.interaction_weight * s.mean_other_risk;

    return logistic_risk(s.pressure_ratio)
        * (1.0 + amplification)
        * (1.0 + 0.30 * s.social_exposure)
        * (
            1.0
            + 0.20 * monitoring_gap
            + 0.30 * governance_gap
            + 0.20 * reversibility_gap
            + 0.10 * trend_pressure
        );
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.75, 0.96, 0.72, 0.030, 0.62, 0.44, 0.30, 0.82},
        {"improved_monitoring", 1.68, 0.96, 0.68, 0.027, 0.78, 0.52, 0.34, 0.82},
        {"targeted_boundary_response", 1.54, 0.96, 0.58, 0.021, 0.74, 0.58, 0.42, 0.82},
        {"integrated_safe_operating_space_strategy", 1.26, 0.96, 0.42, 0.011, 0.84, 0.72, 0.52, 0.82}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " systemic boundary risk: "
                  << std::fixed << std::setprecision(3)
                  << systemic_boundary_risk(scenario)
                  << std::endl;
    }

    return 0;
}
