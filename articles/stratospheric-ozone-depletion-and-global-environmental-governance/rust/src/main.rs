// Ozone recovery scoring engine in Rust.

#[derive(Debug)]
struct OzoneRegion {
    region: &'static str,
    ozone_du: f64,
    boundary_du: f64,
    preindustrial_reference_du: f64,
    ods_loading_index: f64,
    emissions_pressure: f64,
    treaty_compliance: f64,
    substitution_progress: f64,
    monitoring_capacity: f64,
    implementation_support: f64,
    illegal_emissions_risk: f64,
    atmospheric_lifetime_pressure: f64,
}

impl OzoneRegion {
    fn boundary_margin(&self) -> f64 {
        (self.ozone_du - self.boundary_du) / self.boundary_du
    }

    fn recovery_gap(&self) -> f64 {
        let gap = (self.preindustrial_reference_du - self.ozone_du)
            / self.preindustrial_reference_du;
        gap.max(0.0)
    }

    fn governance_effectiveness(&self) -> f64 {
        0.30 * self.treaty_compliance
            + 0.25 * self.substitution_progress
            + 0.25 * self.monitoring_capacity
            + 0.20 * self.implementation_support
    }

    fn residual_pressure(&self) -> f64 {
        0.35 * self.ods_loading_index
            + 0.20 * self.emissions_pressure
            + 0.25 * self.atmospheric_lifetime_pressure
            + 0.20 * self.illegal_emissions_risk
    }

    fn recovery_resilience_score(&self) -> f64 {
        self.boundary_margin()
            + self.governance_effectiveness()
            - self.residual_pressure()
            - self.recovery_gap()
    }
}

fn main() {
    let region = OzoneRegion {
        region: "global_mean_stratosphere",
        ozone_du: 286.0,
        boundary_du: 276.0,
        preindustrial_reference_du: 290.0,
        ods_loading_index: 0.42,
        emissions_pressure: 0.18,
        treaty_compliance: 0.92,
        substitution_progress: 0.88,
        monitoring_capacity: 0.86,
        implementation_support: 0.82,
        illegal_emissions_risk: 0.08,
        atmospheric_lifetime_pressure: 0.46,
    };

    println!("Region: {}", region.region);
    println!("Boundary margin: {:.4}", region.boundary_margin());
    println!("Recovery gap: {:.4}", region.recovery_gap());
    println!(
        "Governance effectiveness: {:.4}",
        region.governance_effectiveness()
    );
    println!("Residual pressure: {:.4}", region.residual_pressure());
    println!(
        "Recovery resilience score: {:.4}",
        region.recovery_resilience_score()
    );
}
