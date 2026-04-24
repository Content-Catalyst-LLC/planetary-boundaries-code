// Aerosol policy scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double aod_pressure_ratio;
    double health_exposure_score;
    double climate_hydrology_score;
    double governance_capacity;
};

double regional_planetary_risk_score(const Scenario& scenario) {
    double governance_gap = 1.0 - scenario.governance_capacity;

    return (
        0.35 * scenario.aod_pressure_ratio +
        0.35 * scenario.health_exposure_score +
        0.30 * scenario.climate_hydrology_score
    ) * (1.0 + governance_gap);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.68, 0.62, 2.55, 0.42},
        {"clean_energy_and_industry", 1.31, 0.46, 1.86, 0.52},
        {"clean_cooking_and_transport", 1.38, 0.43, 1.70, 0.54},
        {"integrated_regional_policy", 1.09, 0.37, 1.32, 0.64}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " regional risk score: "
                  << std::fixed << std::setprecision(3)
                  << regional_planetary_risk_score(scenario)
                  << std::endl;
    }

    return 0;
}
