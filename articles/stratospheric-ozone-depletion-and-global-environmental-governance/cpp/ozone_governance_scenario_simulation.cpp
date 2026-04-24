// Ozone governance scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double boundary_margin;
    double recovery_gap;
    double treaty_compliance;
    double substitution_progress;
    double monitoring_capacity;
    double implementation_support;
    double residual_pressure;
};

double governance_effectiveness(const Scenario& scenario) {
    return 0.30 * scenario.treaty_compliance
        + 0.25 * scenario.substitution_progress
        + 0.25 * scenario.monitoring_capacity
        + 0.20 * scenario.implementation_support;
}

double recovery_resilience_score(const Scenario& scenario) {
    return scenario.boundary_margin
        + governance_effectiveness(scenario)
        - scenario.residual_pressure
        - scenario.recovery_gap;
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 0.036, 0.014, 0.92, 0.88, 0.86, 0.82, 0.314},
        {"weakened_compliance", 0.036, 0.014, 0.80, 0.83, 0.81, 0.82, 0.340},
        {"stronger_monitoring", 0.036, 0.014, 0.94, 0.90, 0.96, 0.82, 0.300},
        {"full_integrity_governance", 0.036, 0.014, 0.98, 1.00, 0.98, 0.88, 0.280}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " governance effectiveness: "
                  << std::fixed << std::setprecision(3)
                  << governance_effectiveness(scenario)
                  << " recovery resilience score: "
                  << recovery_resilience_score(scenario)
                  << std::endl;
    }

    return 0;
}
