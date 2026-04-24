// Planetary justice scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double ecological_overuse;
    double access_shortfall;
    double vulnerability;
    double historical_contribution;
    double capacity;
};

double justice_gap(const Scenario& s) {
    return (s.ecological_overuse + s.access_shortfall + s.vulnerability) / 3.0;
}

double responsibility_adjusted_gap(const Scenario& s) {
    return justice_gap(s) * (1.0 + s.historical_contribution) * (1.0 + s.capacity);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 1.40, 0.00, 0.22, 0.88, 0.86},
        {"access_expansion", 1.20, 0.00, 0.20, 0.88, 0.86},
        {"deep_reduction", 0.50, 0.00, 0.18, 0.88, 0.86},
        {"vulnerability_reduction", 0.50, 0.00, 0.08, 0.88, 0.86}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " responsibility-adjusted gap: "
                  << std::fixed << std::setprecision(3)
                  << responsibility_adjusted_gap(scenario)
                  << std::endl;
    }

    return 0;
}
