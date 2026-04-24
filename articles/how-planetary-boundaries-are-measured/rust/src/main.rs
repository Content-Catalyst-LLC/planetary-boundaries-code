// Planetary-boundary measurement scoring engine in Rust.

#[derive(Debug)]
struct BoundaryMeasurement {
    boundary_process: &'static str,
    observed_value: f64,
    boundary_value: f64,
    high_risk_value: f64,
    observation_uncertainty: f64,
    boundary_uncertainty: f64,
    monitoring_capacity: f64,
}

impl BoundaryMeasurement {
    fn pressure_ratio(&self) -> f64 {
        self.observed_value / self.boundary_value
    }

    fn combined_uncertainty(&self) -> f64 {
        self.observation_uncertainty + self.boundary_uncertainty
    }

    fn uncertainty_adjusted_pressure(&self) -> f64 {
        self.pressure_ratio() * (1.0 + self.combined_uncertainty())
    }

    fn measurement_risk_score(&self) -> f64 {
        let monitoring_gap = 1.0 - self.monitoring_capacity;
        self.uncertainty_adjusted_pressure() * (1.0 + monitoring_gap)
    }

    fn risk_zone(&self) -> &'static str {
        let ratio = self.pressure_ratio();
        let high_risk_ratio = self.high_risk_value / self.boundary_value;

        if ratio < 1.0 {
            "safe_zone"
        } else if ratio < high_risk_ratio {
            "zone_of_increasing_risk"
        } else {
            "high_risk_zone"
        }
    }
}

fn main() {
    let measurement = BoundaryMeasurement {
        boundary_process: "novel_entities",
        observed_value: 1.65,
        boundary_value: 1.00,
        high_risk_value: 1.50,
        observation_uncertainty: 0.25,
        boundary_uncertainty: 0.30,
        monitoring_capacity: 0.38,
    };

    println!("Boundary process: {}", measurement.boundary_process);
    println!("Pressure ratio: {:.4}", measurement.pressure_ratio());
    println!("Risk zone: {}", measurement.risk_zone());
    println!(
        "Measurement risk score: {:.4}",
        measurement.measurement_risk_score()
    );
}
