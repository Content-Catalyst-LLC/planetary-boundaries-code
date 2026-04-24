// High-performance boundary simulation scaffold in C++.

#include <iostream>
#include <vector>
#include <string>
#include <iomanip>

double overshoot(double observed, double boundary) {
    if (observed > boundary) {
        return (observed - boundary) / boundary;
    }
    return 0.0;
}

int main() {
    std::vector<std::string> entities = {"Region A", "Region B", "Region C"};
    std::vector<double> observed = {4.2, 9.8, 2.1};
    double boundary = 3.0;

    for (size_t i = 0; i < entities.size(); ++i) {
        double score = overshoot(observed[i], boundary);
        std::cout << entities[i]
                  << " overshoot: "
                  << std::fixed << std::setprecision(3)
                  << score << std::endl;
    }

    return 0;
}
