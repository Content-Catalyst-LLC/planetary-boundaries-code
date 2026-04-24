// Precaution scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double observed_pressure;
    double estimated_threshold;
    double threshold_uncertainty;
    double precaution_factor;
    double governance_capacity;
};

double precautionary_boundary(const Scenario& s) {
    return s.estimated_threshold - s.precaution_factor * s.threshold_uncertainty;
}

double pressure_ratio(const Scenario& s) {
    return s.observed_pressure / precautionary_boundary(s);
}

double governance_adjusted_risk(const Scenario& s) {
    double uncertainty_adjusted = pressure_ratio(s) * (1.0 + s.threshold_uncertainty);
    double governance_gap = 1.0 - s.governance_capacity;
    return uncertainty_adjusted * governance_gap;
}

int main() {
    std::vector<Scenario> scenarios = {
        {"lower_precaution", 1.60, 1.05, 0.30, 0.75, 0.34},
        {"baseline_precaution", 1.60, 1.05, 0.30, 1.00, 0.34},
        {"higher_precaution", 1.60, 1.05, 0.30, 1.25, 0.34},
        {"strong_precaution", 1.60, 1.05, 0.30, 1.50, 0.34}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " pressure ratio: "
                  << std::fixed << std::setprecision(3)
                  << pressure_ratio(scenario)
                  << " risk: "
                  << governance_adjusted_risk(scenario)
                  << std::endl;
    }

    return 0;
}
