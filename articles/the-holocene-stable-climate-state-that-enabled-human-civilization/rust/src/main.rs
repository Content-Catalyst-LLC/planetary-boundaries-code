// Holocene stability baseline scoring engine in Rust.

#[derive(Debug)]
struct HoloceneIndicator {
    indicator: &'static str,
    holocene_reference: f64,
    observed_value: f64,
    holocene_variability: f64,
    boundary_value: f64,
    interaction_weight: f64,
    governance_capacity: f64,
    adaptive_capacity: f64,
    development_exposure: f64,
}

impl HoloceneIndicator {
    fn anomaly(&self) -> f64 {
        self.observed_value - self.holocene_reference
    }

    fn standardized_departure(&self) -> f64 {
        self.anomaly() / self.holocene_variability
    }

    fn boundary_pressure_ratio(&self) -> f64 {
        self.observed_value / self.boundary_value
    }

    fn response_capacity(&self) -> f64 {
        0.55 * self.governance_capacity + 0.45 * self.adaptive_capacity
    }

    fn departure_risk(&self, mean_boundary_pressure: f64) -> f64 {
        let amplification = self.interaction_weight * mean_boundary_pressure;

        self.standardized_departure().max(0.0)
            * self.boundary_pressure_ratio()
            * (1.0 + 0.25 * amplification)
            * (1.0 + 0.30 * self.development_exposure)
            * (1.0 - 0.50 * self.response_capacity())
    }
}

fn main() {
    let indicator = HoloceneIndicator {
        indicator: "global_temperature",
        holocene_reference: 0.0,
        observed_value: 1.2,
        holocene_variability: 0.35,
        boundary_value: 1.0,
        interaction_weight: 0.92,
        governance_capacity: 0.56,
        adaptive_capacity: 0.52,
        development_exposure: 0.88,
    };

    let mean_boundary_pressure = 1.28;

    println!("Indicator: {}", indicator.indicator);
    println!("Anomaly: {:.4}", indicator.anomaly());
    println!("Standardized departure: {:.4}", indicator.standardized_departure());
    println!("Boundary pressure ratio: {:.4}", indicator.boundary_pressure_ratio());
    println!("Departure risk: {:.4}", indicator.departure_risk(mean_boundary_pressure));
}
