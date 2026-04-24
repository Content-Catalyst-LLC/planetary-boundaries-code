// SDG-boundary scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double sdg_shortfall;
    double boundary_overshoot;
    double vulnerability;
    double capacity;
};

double alignment_score(const Scenario& s) {
    return 1.0 - (0.5 * s.sdg_shortfall + 0.5 * s.boundary_overshoot);
}

double justice_adjusted_risk(const Scenario& s) {
    return (s.sdg_shortfall + s.boundary_overshoot + s.vulnerability)
        * (1.0 + (1.0 - s.capacity));
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 0.22, 0.28, 0.72, 0.38},
        {"social_investment", 0.10, 0.30, 0.66, 0.42},
        {"ecological_transition", 0.18, 0.10, 0.62, 0.48},
        {"integrated_strategy", 0.08, 0.08, 0.45, 0.62}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " alignment: "
                  << std::fixed << std::setprecision(3)
                  << alignment_score(scenario)
                  << " risk: "
                  << justice_adjusted_risk(scenario)
                  << std::endl;
    }

    return 0;
}
