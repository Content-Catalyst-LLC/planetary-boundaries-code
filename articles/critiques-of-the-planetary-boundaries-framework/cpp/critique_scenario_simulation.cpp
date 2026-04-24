// Critique-risk scenario simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

struct Scenario {
    std::string name;
    double biophysical;
    double justice;
    double legitimacy;
    double political_economy;
    double operationalization;
};

double total_risk(const Scenario& s) {
    return (
        s.biophysical +
        s.justice +
        s.legitimacy +
        s.political_economy +
        s.operationalization
    ) / 5.0;
}

int main() {
    std::vector<Scenario> scenarios = {
        {"global_dashboard", 0.85, 0.72, 0.76, 0.82, 0.60},
        {"city_dashboard", 0.55, 0.52, 0.44, 0.58, 0.42},
        {"community_transition", 0.38, 0.30, 0.22, 0.35, 0.36}
    };

    for (const auto& s : scenarios) {
        std::cout << s.name
                  << " total critique risk: "
                  << std::fixed << std::setprecision(3)
                  << total_risk(s)
                  << std::endl;
    }

    return 0;
}
