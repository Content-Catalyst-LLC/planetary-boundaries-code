// Climate boundary risk scoring engine in Rust.

#[derive(Debug)]
struct ClimateSystem {
    name: &'static str,
    co2_concentration_ppm: f64,
    co2_boundary_ppm: f64,
    co2_baseline_ppm: f64,
    forcing_boundary_wm2: f64,
    gross_emissions_pressure: f64,
    mitigation_capacity: f64,
    carbon_sink_resilience: f64,
    biosphere_stress: f64,
    land_system_pressure: f64,
    freshwater_stress: f64,
    ocean_stress: f64,
    heat_extreme_exposure: f64,
    infrastructure_exposure: f64,
    adaptive_capacity: f64,
    monitoring_capacity: f64,
    governance_capacity: f64,
}

impl ClimateSystem {
    fn co2_boundary_pressure(&self) -> f64 {
        self.co2_concentration_ppm / self.co2_boundary_ppm
    }

    fn co2_radiative_forcing(&self) -> f64 {
        5.35 * (self.co2_concentration_ppm / self.co2_baseline_ppm).ln()
    }

    fn forcing_boundary_pressure(&self) -> f64 {
        self.co2_radiative_forcing() / self.forcing_boundary_wm2
    }

    fn cross_boundary_stress(&self) -> f64 {
        0.26 * self.biosphere_stress
            + 0.24 * self.land_system_pressure
            + 0.22 * self.freshwater_stress
            + 0.18 * self.ocean_stress
            + 0.10 * (1.0 - self.carbon_sink_resilience)
    }

    fn exposure_pressure(&self) -> f64 {
        0.55 * self.heat_extreme_exposure + 0.45 * self.infrastructure_exposure
    }

    fn transition_gap(&self) -> f64 {
        self.gross_emissions_pressure * (1.0 - self.mitigation_capacity)
    }

    fn climate_boundary_risk_score(&self) -> f64 {
        let adaptive_gap = 1.0 - self.adaptive_capacity;
        let monitoring_gap = 1.0 - self.monitoring_capacity;
        let governance_gap = 1.0 - self.governance_capacity;

        0.24 * self.co2_boundary_pressure()
            + 0.24 * self.forcing_boundary_pressure()
            + 0.18 * self.cross_boundary_stress()
            + 0.14 * self.exposure_pressure()
            + 0.12 * self.transition_gap()
            + 0.08 * (0.40 * adaptive_gap + 0.25 * monitoring_gap + 0.35 * governance_gap)
    }
}

fn main() {
    let system = ClimateSystem {
        name: "high_emissions_industrial_system",
        co2_concentration_ppm: 429.8,
        co2_boundary_ppm: 350.0,
        co2_baseline_ppm: 280.0,
        forcing_boundary_wm2: 1.0,
        gross_emissions_pressure: 0.92,
        mitigation_capacity: 0.42,
        carbon_sink_resilience: 0.48,
        biosphere_stress: 0.66,
        land_system_pressure: 0.58,
        freshwater_stress: 0.54,
        ocean_stress: 0.62,
        heat_extreme_exposure: 0.72,
        infrastructure_exposure: 0.78,
        adaptive_capacity: 0.58,
        monitoring_capacity: 0.74,
        governance_capacity: 0.52,
    };

    println!("System: {}", system.name);
    println!("CO2 boundary pressure: {:.4}", system.co2_boundary_pressure());
    println!("CO2 radiative forcing: {:.4}", system.co2_radiative_forcing());
    println!(
        "Climate boundary risk score: {:.4}",
        system.climate_boundary_risk_score()
    );
}
