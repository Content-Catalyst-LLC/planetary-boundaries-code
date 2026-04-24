// Holocene departure scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double standardized_departure;
    double boundary_pressure_ratio;
    double cross_system_amplification;
    double response_capacity;
    double development_exposure;
};

double departure_risk(const Scenario& s) {
    return std::max(0.0, s.standardized_departure)
        * s.boundary_pressure_ratio
        * (1.0 + 0.25 * s.cross_system_amplification)
        * (1.0 + 0.30 * s.development_exposure)
        * (1.0 - 0.50 * s.response_capacity);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"holocene_reference", 0.25, 0.70, 0.40, 0.75, 0.50},
        {"current_departure", 3.43, 1.20, 1.18, 0.54, 0.88},
        {"high_warming_future", 6.00, 1.80, 1.60, 0.45, 0.92}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " departure risk: "
                  << std::fixed << std::setprecision(3)
                  << departure_risk(scenario)
                  << std::endl;
    }

    return 0;
}
