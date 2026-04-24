// Portfolio scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double boundary_pressure;
    double disclosure_adequacy;
    double transition_credibility;
    double uncertainty;
};

double risk_score(const Scenario& s) {
    double disclosure_gap = 1.0 - s.disclosure_adequacy;
    double transition_gap = 1.0 - s.transition_credibility;

    return s.boundary_pressure
        * (1.0 + disclosure_gap)
        * (1.0 + transition_gap)
        * (1.0 + s.uncertainty);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.35, 0.60, 0.48, 0.30},
        {"better_disclosure", 1.35, 0.82, 0.48, 0.25},
        {"credible_transition", 1.10, 0.82, 0.75, 0.22},
        {"stress_case", 1.65, 0.45, 0.35, 0.50}
    };

    for (const auto& s : scenarios) {
        std::cout << s.name
                  << " risk score: "
                  << std::fixed << std::setprecision(3)
                  << risk_score(s)
                  << std::endl;
    }

    return 0;
}
