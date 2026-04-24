// Anthropocene 3-6-9 scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double warming_pressure;
    double biosphere_pressure;
    double development_demand;
    double boundary_transgression_pressure;
    double governance_resilience_capacity;
};

double core_369_pressure(const Scenario& s) {
    return 0.36 * s.warming_pressure
        + 0.34 * s.biosphere_pressure
        + 0.30 * s.development_demand;
}

double amplification(const Scenario& s) {
    return 0.35 * s.warming_pressure * s.biosphere_pressure
        + 0.25 * s.warming_pressure * s.development_demand
        + 0.25 * s.biosphere_pressure * s.development_demand
        + 0.15 * s.boundary_transgression_pressure;
}

double anthropocene_risk(const Scenario& s) {
    return core_369_pressure(s)
        * (1.0 + amplification(s))
        * (1.0 - 0.55 * s.governance_resilience_capacity)
        * (1.0 + 0.35 * s.boundary_transgression_pressure);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"current_fragmented_response", 0.82, 0.88, 0.76, 7.0 / 9.0, 0.42},
        {"planetary_boundary_aligned_development", 0.42, 0.46, 0.62, 4.0 / 9.0, 0.72},
        {"just_transition_and_ecological_restoration", 0.36, 0.38, 0.58, 3.0 / 9.0, 0.80}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " risk score: "
                  << std::fixed << std::setprecision(3)
                  << anthropocene_risk(scenario)
                  << std::endl;
    }

    return 0;
}
