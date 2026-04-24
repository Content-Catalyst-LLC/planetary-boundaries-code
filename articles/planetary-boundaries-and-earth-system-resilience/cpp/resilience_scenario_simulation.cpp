// Earth system resilience scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double pressure_ratio;
    double resilience_capacity;
    double interaction_pressure;
    double structural_weight;
};

double resilience_adjusted_risk(const Scenario& scenario, double interaction_lambda) {
    double resilience_gap = 1.0 - scenario.resilience_capacity;

    return (
        scenario.pressure_ratio +
        interaction_lambda * scenario.interaction_pressure
    ) * resilience_gap * scenario.structural_weight;
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.25, 0.50, 0.40, 1.10},
        {"pressure_reduction", 0.95, 0.50, 0.30, 1.10},
        {"resilience_investment", 1.25, 0.70, 0.40, 1.10},
        {"interaction_amplification", 1.25, 0.50, 0.90, 1.10}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " resilience-adjusted risk: "
                  << std::fixed << std::setprecision(3)
                  << resilience_adjusted_risk(scenario, 0.60)
                  << std::endl;
    }

    return 0;
}
