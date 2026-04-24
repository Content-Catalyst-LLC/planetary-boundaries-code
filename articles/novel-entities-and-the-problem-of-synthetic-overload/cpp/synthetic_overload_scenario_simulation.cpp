// Synthetic overload scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double production_index;
    double release_fraction;
    double intrinsic_risk;
    double assessment_gap;
    double monitoring_gap;
};

double overload_score(const Scenario& scenario) {
    double release_index = scenario.production_index * scenario.release_fraction;
    double governance_gap = 0.55 * scenario.assessment_gap + 0.45 * scenario.monitoring_gap;

    return release_index * scenario.intrinsic_risk * (1.0 + governance_gap);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.00, 0.32, 0.207, 0.35, 0.54},
        {"improved_monitoring", 1.00, 0.32, 0.207, 0.35, 0.30},
        {"release_reduction", 1.00, 0.18, 0.207, 0.35, 0.54},
        {"combined_precaution", 0.80, 0.15, 0.207, 0.20, 0.25}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " overload score: "
                  << std::fixed << std::setprecision(4)
                  << overload_score(scenario)
                  << std::endl;
    }

    return 0;
}
