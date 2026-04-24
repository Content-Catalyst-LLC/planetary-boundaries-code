// Framework diffusion scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double scientific_maturity;
    double governance_influence;
    double systems_depth;
    double operational_readiness;
    double justice_integration;
};

double framework_influence_score(const Scenario& s) {
    return 0.30 * s.scientific_maturity
        + 0.28 * s.governance_influence
        + 0.22 * s.systems_depth
        + 0.12 * s.operational_readiness
        + 0.08 * s.justice_integration;
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 0.84, 0.80, 0.86, 0.82, 0.48},
        {"measurement_led_operationalization", 0.88, 0.82, 0.88, 0.88, 0.50},
        {"justice_centered_interpretation", 0.86, 0.84, 0.88, 0.84, 0.70},
        {"integrated_research_policy_architecture", 0.90, 0.90, 0.94, 0.92, 0.76}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " framework influence score: "
                  << std::fixed << std::setprecision(3)
                  << framework_influence_score(scenario)
                  << std::endl;
    }

    return 0;
}
