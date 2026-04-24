// Ocean acidification scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double aragonite_boundary_pressure;
    double ecosystem_vulnerability;
    double warming_stress;
    double deoxygenation_stress;
    double nutrient_stress;
    double carbonate_deficit;
    double monitoring_capacity;
    double governance_capacity;
};

double multi_stressor_pressure(const Scenario& s) {
    return 0.40 * s.aragonite_boundary_pressure
        + 0.25 * s.warming_stress
        + 0.20 * s.deoxygenation_stress
        + 0.15 * s.nutrient_stress;
}

double marine_chemistry_risk_score(const Scenario& s) {
    double monitoring_gap = 1.0 - s.monitoring_capacity;
    double governance_gap = 1.0 - s.governance_capacity;

    return (
        0.45 * s.ecosystem_vulnerability
            + 0.35 * multi_stressor_pressure(s)
            + 0.20 * s.carbonate_deficit
    ) * (1.0 + 0.5 * monitoring_gap + 0.5 * governance_gap);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.54, 0.79, 0.88, 0.40, 0.54, 0.26, 0.58, 0.38},
        {"coastal_pollution_reduction", 1.54, 0.79, 0.88, 0.40, 0.35, 0.26, 0.66, 0.50},
        {"strong_carbon_mitigation", 1.26, 0.64, 0.80, 0.38, 0.46, 0.23, 0.68, 0.56},
        {"integrated_ocean_resilience", 1.17, 0.59, 0.76, 0.35, 0.30, 0.22, 0.80, 0.64}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " marine chemistry risk score: "
                  << std::fixed << std::setprecision(3)
                  << marine_chemistry_risk_score(scenario)
                  << std::endl;
    }

    return 0;
}
