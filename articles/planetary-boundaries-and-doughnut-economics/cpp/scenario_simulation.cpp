// C++ scenario simulation scaffold.
//
// This file demonstrates high-performance simulation logic for evaluating
// how changes in ecological pressure and social achievement affect a
// simplified safe-and-just score across scenarios.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double ecological_pressure;
    double ecological_ceiling;
    double social_achievement;
    double social_floor;
};

double overshoot(double observed, double ceiling) {
    if (observed > ceiling) {
        return (observed - ceiling) / ceiling;
    }
    return 0.0;
}

double shortfall(double observed, double floor) {
    if (observed < floor) {
        return (floor - observed) / floor;
    }
    return 0.0;
}

double safe_and_just_score(const Scenario& scenario) {
    double o = overshoot(scenario.ecological_pressure, scenario.ecological_ceiling);
    double q = shortfall(scenario.social_achievement, scenario.social_floor);
    return 1.0 - (0.5 * o + 0.5 * q);
}

int main() {
    std::vector<Scenario> scenarios = {
        {"baseline", 9.8, 3.0, 0.82, 0.90},
        {"efficiency_gain", 7.0, 3.0, 0.84, 0.90},
        {"social_investment", 9.0, 3.0, 0.91, 0.90},
        {"regenerative_transition", 3.2, 3.0, 0.93, 0.90}
    };

    for (const auto& scenario : scenarios) {
        std::cout << scenario.name
                  << " score: "
                  << std::fixed << std::setprecision(4)
                  << safe_and_just_score(scenario)
                  << std::endl;
    }

    return 0;
}
