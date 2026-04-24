// Nutrient policy scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double nitrogen_boundary_pressure;
    double phosphorus_boundary_pressure;
    double nutrient_loss_pressure;
    double ecosystem_sensitivity;
    double legacy_nutrient_pressure;
    double monitoring_capacity;
    double governance_capacity;
};

double eutrophication_pressure(const Scenario& s) {
    return (
        0.35 * s.nitrogen_boundary_pressure +
        0.35 * s.phosphorus_boundary_pressure +
        0.30 * s.nutrient_loss_pressure
    ) * s.ecosystem_sensitivity;
}

double planetary_nutrient_risk_score(const Scenario& s) {
    double legacy_adjusted_pressure =
        eutrophication_pressure(s) * (1.0 + s.legacy_nutrient_pressure);

    double monitoring_gap = 1.0 - s.monitoring_capacity;
    double governance_gap = 1.0 - s.governance_capacity;

    return legacy_adjusted_pressure * (1.0 + 0.45 * monitoring_gap + 0.55 * governance_gap);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.56, 1.40, 0.63, 0.84, 0.68, 0.66, 0.44},
        {"precision_nutrient_management", 1.34, 1.20, 0.48, 0.84, 0.68, 0.72, 0.52},
        {"wetland_and_buffer_restoration", 1.44, 1.29, 0.32, 0.84, 0.61, 0.74, 0.54},
        {"integrated_food_system_transition", 1.15, 1.04, 0.22, 0.84, 0.48, 0.82, 0.66}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " planetary nutrient risk score: "
                  << std::fixed << std::setprecision(3)
                  << planetary_nutrient_risk_score(scenario)
                  << std::endl;
    }

    return 0;
}
