// Tipping-risk scoring engine in Rust.

#[derive(Debug)]
struct TippingElement {
    element: &'static str,
    pressure: f64,
    threshold: f64,
    threshold_uncertainty: f64,
    precaution_factor: f64,
    feedback_strength: f64,
    resilience_capacity: f64,
    monitoring_capacity: f64,
    cascade_pressure: f64,
}

impl TippingElement {
    fn precautionary_threshold(&self) -> f64 {
        self.threshold - self.precaution_factor * self.threshold_uncertainty
    }

    fn pressure_ratio(&self) -> f64 {
        self.pressure / self.precautionary_threshold()
    }

    fn logistic(value: f64) -> f64 {
        1.0 / (1.0 + (-value).exp())
    }

    fn tipping_probability(&self) -> f64 {
        Self::logistic(
            1.8 * (self.pressure_ratio() - 1.0)
                + 1.2 * self.cascade_pressure
                + 0.8 * self.feedback_strength
                - 0.9 * self.resilience_capacity,
        )
    }

    fn cascade_adjusted_risk(&self) -> f64 {
        let monitoring_gap = 1.0 - self.monitoring_capacity;
        self.tipping_probability() * (1.0 + self.cascade_pressure) * (1.0 + monitoring_gap)
    }
}

fn main() {
    let element = TippingElement {
        element: "amazon_rainforest",
        pressure: 1.24,
        threshold: 1.00,
        threshold_uncertainty: 0.18,
        precaution_factor: 1.10,
        feedback_strength: 0.76,
        resilience_capacity: 0.36,
        monitoring_capacity: 0.56,
        cascade_pressure: 0.30,
    };

    println!("Element: {}", element.element);
    println!("Pressure ratio: {:.4}", element.pressure_ratio());
    println!("Tipping probability: {:.4}", element.tipping_probability());
    println!("Cascade-adjusted risk: {:.4}", element.cascade_adjusted_risk());
}
