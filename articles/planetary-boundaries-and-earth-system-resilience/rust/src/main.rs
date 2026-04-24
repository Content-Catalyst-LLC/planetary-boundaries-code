// Earth system resilience scoring engine in Rust.

#[derive(Debug)]
struct BoundaryResilience {
    boundary: &'static str,
    observed_pressure: f64,
    boundary_value: f64,
    diversity: f64,
    redundancy: f64,
    adaptive_capacity: f64,
    monitoring_capacity: f64,
    interaction_pressure: f64,
    structural_weight: f64,
}

impl BoundaryResilience {
    fn pressure_ratio(&self) -> f64 {
        self.observed_pressure / self.boundary_value
    }

    fn resilience_capacity(&self) -> f64 {
        let diversity_weight = 1.25;
        let redundancy_weight = 1.10;
        let adaptive_weight = 1.00;
        let monitoring_weight = 0.90;
        let total = diversity_weight + redundancy_weight + adaptive_weight + monitoring_weight;

        (
            self.diversity * diversity_weight
                + self.redundancy * redundancy_weight
                + self.adaptive_capacity * adaptive_weight
                + self.monitoring_capacity * monitoring_weight
        ) / total
    }

    fn resilience_gap(&self) -> f64 {
        1.0 - self.resilience_capacity()
    }

    fn resilience_adjusted_risk(&self, interaction_lambda: f64) -> f64 {
        (
            self.pressure_ratio()
                + interaction_lambda * self.interaction_pressure
        ) * self.resilience_gap()
            * self.structural_weight
    }
}

fn main() {
    let boundary = BoundaryResilience {
        boundary: "biosphere_integrity",
        observed_pressure: 1.70,
        boundary_value: 1.00,
        diversity: 0.28,
        redundancy: 0.30,
        adaptive_capacity: 0.40,
        monitoring_capacity: 0.52,
        interaction_pressure: 1.20,
        structural_weight: 1.55,
    };

    println!("Boundary: {}", boundary.boundary);
    println!("Pressure ratio: {:.4}", boundary.pressure_ratio());
    println!("Resilience capacity: {:.4}", boundary.resilience_capacity());
    println!("Resilience gap: {:.4}", boundary.resilience_gap());
    println!(
        "Resilience-adjusted risk: {:.4}",
        boundary.resilience_adjusted_risk(0.60)
    );
}
