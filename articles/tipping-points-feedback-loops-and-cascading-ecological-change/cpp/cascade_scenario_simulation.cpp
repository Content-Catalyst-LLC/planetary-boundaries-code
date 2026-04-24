// Cascade scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include <cmath>

struct Scenario {
    std::string name;
    double pressure_ratio;
    double cascade_pressure;
    double feedback_strength;
    double resilience_capacity;
    double monitoring_capacity;
};

double logistic(double value) {
    return 1.0 / (1.0 + std::exp(-value));
}

double tipping_probability(const Scenario& s) {
    return logistic(
        1.8 * (s.pressure_ratio - 1.0) +
        1.2 * s.cascade_pressure +
        0.8 * s.feedback_strength -
        0.9 * s.resilience_capacity
    );
}

double cascade_adjusted_risk(const Scenario& s) {
    double monitoring_gap = 1.0 - s.monitoring_capacity;
    return tipping_probability(s) * (1.0 + s.cascade_pressure) * (1.0 + monitoring_gap);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.20, 0.10, 0.70, 0.42, 0.74},
        {"higher_pressure", 1.45, 0.10, 0.70, 0.42, 0.74},
        {"cascade_trigger", 1.45, 0.40, 0.70, 0.42, 0.74},
        {"weak_monitoring", 1.45, 0.40, 0.70, 0.42, 0.45}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " tipping probability: "
                  << std::fixed << std::setprecision(3)
                  << tipping_probability(scenario)
                  << " cascade-adjusted risk: "
                  << cascade_adjusted_risk(scenario)
                  << std::endl;
    }

    return 0;
}
