// Planetary-boundary measurement scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct MeasurementScenario {
    std::string name;
    double observed_value;
    double boundary_value;
    double observation_uncertainty;
    double boundary_uncertainty;
    double monitoring_capacity;
};

double pressure_ratio(const MeasurementScenario& s) {
    return s.observed_value / s.boundary_value;
}

double measurement_risk_score(const MeasurementScenario& s) {
    double combined_uncertainty = s.observation_uncertainty + s.boundary_uncertainty;
    double uncertainty_adjusted_pressure = pressure_ratio(s) * (1.0 + combined_uncertainty);
    double monitoring_gap = 1.0 - s.monitoring_capacity;

    return uncertainty_adjusted_pressure * (1.0 + monitoring_gap);
}

int main() {
    std::vector<MeasurementScenario> scenarios = {
        {"baseline", 1.28, 1.00, 0.12, 0.18, 0.62},
        {"better_monitoring", 1.28, 1.00, 0.08, 0.12, 0.82},
        {"higher_uncertainty", 1.28, 1.00, 0.18, 0.26, 0.62},
        {"higher_pressure", 1.55, 1.00, 0.12, 0.18, 0.62}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " pressure ratio: "
                  << std::fixed << std::setprecision(3)
                  << pressure_ratio(scenario)
                  << " risk score: "
                  << measurement_risk_score(scenario)
                  << std::endl;
    }

    return 0;
}
