// Boundary uncertainty scoring engine in Rust.

#[derive(Debug)]
struct BoundaryRisk {
    boundary: &'static str,
    observed_pressure: f64,
    estimated_threshold: f64,
    threshold_uncertainty: f64,
    precaution_factor: f64,
    governance_capacity: f64,
    weight: f64,
}

impl BoundaryRisk {
    fn precautionary_boundary(&self) -> f64 {
        self.estimated_threshold - self.precaution_factor * self.threshold_uncertainty
    }

    fn pressure_ratio(&self) -> f64 {
        self.observed_pressure / self.precautionary_boundary()
    }

    fn uncertainty_adjusted_pressure(&self) -> f64 {
        self.pressure_ratio() * (1.0 + self.threshold_uncertainty)
    }

    fn governance_adjusted_risk(&self) -> f64 {
        let governance_gap = 1.0 - self.governance_capacity;
        self.uncertainty_adjusted_pressure() * governance_gap * self.weight
    }

    fn risk_zone(&self) -> &'static str {
        let ratio = self.pressure_ratio();

        if ratio < 1.0 {
            "safe_zone"
        } else if ratio < 1.5 {
            "zone_of_increasing_risk"
        } else {
            "high_risk_zone"
        }
    }
}

fn main() {
    let boundary = BoundaryRisk {
        boundary: "novel_entities",
        observed_pressure: 1.60,
        estimated_threshold: 1.05,
        threshold_uncertainty: 0.30,
        precaution_factor: 1.30,
        governance_capacity: 0.34,
        weight: 1.30,
    };

    println!("Boundary: {}", boundary.boundary);
    println!("Precautionary boundary: {:.4}", boundary.precautionary_boundary());
    println!("Pressure ratio: {:.4}", boundary.pressure_ratio());
    println!("Risk zone: {}", boundary.risk_zone());
    println!("Governance-adjusted risk: {:.4}", boundary.governance_adjusted_risk());
}
