// Land-system policy scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double forest_boundary_pressure;
    double land_conversion_pressure;
    double climate_stress;
    double hydrological_disruption;
    double fragmentation_risk;
    double regulatory_importance;
    double restoration_potential;
    double monitoring_capacity;
    double governance_capacity;
};

double land_system_pressure(const Scenario& s) {
    return 0.35 * s.forest_boundary_pressure
        + 0.20 * s.land_conversion_pressure
        + 0.18 * s.climate_stress
        + 0.17 * s.hydrological_disruption
        + 0.10 * s.fragmentation_risk;
}

double land_system_risk_score(const Scenario& s) {
    double monitoring_gap = 1.0 - s.monitoring_capacity;
    double governance_gap = 1.0 - s.governance_capacity;
    double restoration_credit = s.restoration_potential * s.governance_capacity * 0.30;

    return land_system_pressure(s)
        * s.regulatory_importance
        * (1.0 + 0.35 * monitoring_gap + 0.45 * governance_gap)
        - restoration_credit;
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.181, 0.82, 0.66, 0.72, 0.68, 0.94, 0.62, 0.60, 0.42},
        {"conversion_reduction", 1.139, 0.59, 0.66, 0.72, 0.60, 0.94, 0.62, 0.70, 0.56},
        {"restoration_and_corridors", 1.075, 0.67, 0.66, 0.72, 0.46, 0.94, 0.62, 0.72, 0.58},
        {"integrated_land_system_resilience", 1.036, 0.49, 0.66, 0.72, 0.37, 0.94, 0.62, 0.78, 0.66}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " land-system risk score: "
                  << std::fixed << std::setprecision(3)
                  << land_system_risk_score(scenario)
                  << std::endl;
    }

    return 0;
}
