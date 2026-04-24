// Biosphere policy scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double genetic_diversity_pressure;
    double functional_integrity_deficit;
    double habitat_loss_pressure;
    double fragmentation_risk;
    double appropriation_pressure;
    double cross_boundary_stress;
    double ecological_sensitivity;
    double restoration_potential;
    double monitoring_capacity;
    double governance_capacity;
};

double biosphere_pressure(const Scenario& s) {
    return 0.26 * s.genetic_diversity_pressure
        + 0.22 * s.functional_integrity_deficit
        + 0.16 * s.habitat_loss_pressure
        + 0.14 * s.fragmentation_risk
        + 0.12 * s.appropriation_pressure
        + 0.10 * s.cross_boundary_stress;
}

double biosphere_integrity_risk_score(const Scenario& s) {
    double monitoring_gap = 1.0 - s.monitoring_capacity;
    double governance_gap = 1.0 - s.governance_capacity;
    double restoration_credit = 0.35 * s.restoration_potential * s.governance_capacity;

    return biosphere_pressure(s)
        * s.ecological_sensitivity
        * (1.0 + 0.30 * monitoring_gap + 0.45 * governance_gap)
        - restoration_credit;
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 9.20, 0.28, 0.42, 0.72, 0.76, 0.61, 0.94, 0.68, 0.58, 0.40},
        {"habitat_protection_and_connectivity", 7.91, 0.23, 0.34, 0.50, 0.67, 0.61, 0.94, 0.68, 0.69, 0.55},
        {"restoration_and_reduced_appropriation", 7.54, 0.20, 0.36, 0.59, 0.50, 0.61, 0.94, 0.68, 0.72, 0.58},
        {"integrated_biosphere_resilience", 6.44, 0.16, 0.30, 0.42, 0.42, 0.61, 0.94, 0.68, 0.78, 0.66}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " biosphere integrity risk score: "
                  << std::fixed << std::setprecision(3)
                  << biosphere_integrity_risk_score(scenario)
                  << std::endl;
    }

    return 0;
}
