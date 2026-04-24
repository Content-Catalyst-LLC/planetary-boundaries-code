// Planetary boundary risk scoring engine in Rust.

#[derive(Debug)]
struct BoundaryState {
    boundary: &'static str,
    observed_value: f64,
    boundary_value: f64,
    uncertainty_band: f64,
    annual_pressure_trend: f64,
    monitoring_capacity: f64,
    governance_capacity: f64,
    reversibility_capacity: f64,
    interaction_weight: f64,
    social_exposure: f64,
}

impl BoundaryState {
    fn boundary_pressure_ratio(&self) -> f64 {
        self.observed_value / self.boundary_value
    }

    fn uncertainty_margin(&self) -> f64 {
        (self.boundary_value - self.observed_value) / self.uncertainty_band
    }

    fn threshold_risk_score(&self) -> f64 {
        let steepness = 8.0;
        1.0 / (1.0 + (-steepness * (self.boundary_pressure_ratio() - 1.0)).exp())
    }

    fn systemic_boundary_risk(&self, mean_other_risk: f64) -> f64 {
        let monitoring_gap = 1.0 - self.monitoring_capacity;
        let governance_gap = 1.0 - self.governance_capacity;
        let reversibility_gap = 1.0 - self.reversibility_capacity;
        let trend_pressure = self.annual_pressure_trend.max(0.0);
        let amplification = self.interaction_weight * mean_other_risk;

        self.threshold_risk_score()
            * (1.0 + amplification)
            * (1.0 + 0.30 * self.social_exposure)
            * (
                1.0
                    + 0.20 * monitoring_gap
                    + 0.30 * governance_gap
                    + 0.20 * reversibility_gap
                    + 0.10 * trend_pressure
            )
    }
}

fn main() {
    let boundary = BoundaryState {
        boundary: "biosphere_integrity",
        observed_value: 1.75,
        boundary_value: 1.00,
        uncertainty_band: 0.18,
        annual_pressure_trend: 0.030,
        monitoring_capacity: 0.62,
        governance_capacity: 0.44,
        reversibility_capacity: 0.30,
        interaction_weight: 0.96,
        social_exposure: 0.82,
    };

    let mean_other_risk = 0.72;

    println!("Boundary: {}", boundary.boundary);
    println!(
        "Boundary pressure ratio: {:.4}",
        boundary.boundary_pressure_ratio()
    );
    println!("Uncertainty margin: {:.4}", boundary.uncertainty_margin());
    println!("Threshold risk score: {:.4}", boundary.threshold_risk_score());
    println!(
        "Systemic boundary risk: {:.4}",
        boundary.systemic_boundary_risk(mean_other_risk)
    );
}
