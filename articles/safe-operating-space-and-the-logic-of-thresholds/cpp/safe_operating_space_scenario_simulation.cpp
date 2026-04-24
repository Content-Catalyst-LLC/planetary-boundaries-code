// Safe operating space scenario simulation scaffold in C++.

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
};

double logistic_risk(double pressure_ratio, double steepness = 8.0) {
    return 1.0 / (1.0 + std::exp(-steepness * (pressure_ratio - 1.0)));
}

double systemic_threshold_risk(const Scenario& s) {
    double monitoring_gap = 1.0 - s.monitoring_capacity;
    double governance_gap = 1.0 - s.governance_capacity;
    double reversibility_gap = 1.0 - s.reversibility_capacity;
    double trend_pressure = std::max(0.0, s.annual_pressure_trend);
    double amplification = s.interaction_weight * s.mean_other_risk;

    return logistic_risk(s.pressure_ratio)
        * (1.0 + amplification)
        * (
            1.0
            + 0.25 * monitoring_gap
            + 0.35 * governance_gap
            + 0.25 * reversibility_gap
            + 0.15 * trend_pressure
        );
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.75, 0.96, 0.72, 0.030, 0.60, 0.44, 0.30},
        {"improved_monitoring", 1.68, 0.96, 0.68, 0.027, 0.76, 0.52, 0.34},
        {"precautionary_buffer_restoration", 1.54, 0.96, 0.58, 0.021, 0.72, 0.58, 0.42},
        {"integrated_safe_operating_space_strategy", 1.26, 0.96, 0.42, 0.011, 0.82, 0.72, 0.52}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " systemic threshold risk: "
                  << std::fixed << std::setprecision(3)
                  << systemic_threshold_risk(scenario)
                  << std::endl;
    }

    return 0;
}
