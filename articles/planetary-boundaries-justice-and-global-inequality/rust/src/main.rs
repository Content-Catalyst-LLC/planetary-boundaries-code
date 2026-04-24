// Planetary justice scoring engine in Rust.

#[derive(Debug)]
struct JusticeCase {
    group: &'static str,
    ecological_use: f64,
    fair_allocation: f64,
    social_access: f64,
    minimum_access: f64,
    vulnerability: f64,
    historical_contribution: f64,
    capacity_to_act: f64,
}

fn ecological_overuse(use_value: f64, allocation: f64) -> f64 {
    if use_value > allocation {
        (use_value - allocation) / allocation
    } else {
        0.0
    }
}

fn access_shortfall(access: f64, minimum: f64) -> f64 {
    if access < minimum {
        (minimum - access) / minimum
    } else {
        0.0
    }
}

fn main() {
    let case = JusticeCase {
        group: "High-income high-consuming",
        ecological_use: 2.40,
        fair_allocation: 1.00,
        social_access: 0.96,
        minimum_access: 0.85,
        vulnerability: 0.22,
        historical_contribution: 0.88,
        capacity_to_act: 0.86,
    };

    let overuse = ecological_overuse(case.ecological_use, case.fair_allocation);
    let shortfall = access_shortfall(case.social_access, case.minimum_access);
    let justice_gap = (overuse + shortfall + case.vulnerability) / 3.0;
    let responsibility_adjusted =
        justice_gap * (1.0 + case.historical_contribution) * (1.0 + case.capacity_to_act);

    println!("Group: {}", case.group);
    println!("Ecological overuse: {:.4}", overuse);
    println!("Minimum access shortfall: {:.4}", shortfall);
    println!("Planetary justice gap: {:.4}", justice_gap);
    println!("Responsibility-adjusted gap: {:.4}", responsibility_adjusted);
}
