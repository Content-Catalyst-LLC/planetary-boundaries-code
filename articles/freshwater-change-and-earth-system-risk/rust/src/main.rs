// Freshwater change risk scoring engine in Rust.

#[derive(Debug)]
struct FreshwaterRegion {
    region: &'static str,
    streamflow_current: f64,
    streamflow_baseline: f64,
    soil_moisture_current: f64,
    soil_moisture_baseline: f64,
    groundwater_stress: f64,
    wetland_buffer_capacity: f64,
    ecological_sensitivity: f64,
    exposed_population_index: f64,
    food_system_dependence: f64,
    monitoring_capacity: f64,
    governance_capacity: f64,
    adaptive_capacity: f64,
}

impl FreshwaterRegion {
    fn blue_water_deviation(&self) -> f64 {
        (self.streamflow_current - self.streamflow_baseline) / self.streamflow_baseline
    }

    fn green_water_deviation(&self) -> f64 {
        (self.soil_moisture_current - self.soil_moisture_baseline) / self.soil_moisture_baseline
    }

    fn hydrological_boundary_pressure(&self) -> f64 {
        0.38 * self.blue_water_deviation().abs()
            + 0.42 * self.green_water_deviation().abs()
            + 0.20 * self.groundwater_stress
    }

    fn social_ecological_exposure(&self) -> f64 {
        0.50 * self.exposed_population_index + 0.50 * self.food_system_dependence
    }

    fn freshwater_system_risk_score(&self) -> f64 {
        let buffer_gap = 1.0 - self.wetland_buffer_capacity;
        let monitoring_gap = 1.0 - self.monitoring_capacity;
        let governance_gap = 1.0 - self.governance_capacity;
        let adaptive_gap = 1.0 - self.adaptive_capacity;

        self.hydrological_boundary_pressure()
            * self.ecological_sensitivity
            * self.social_ecological_exposure()
            * (
                1.0
                    + 0.25 * buffer_gap
                    + 0.25 * monitoring_gap
                    + 0.30 * governance_gap
                    + 0.20 * adaptive_gap
            )
    }
}

fn main() {
    let region = FreshwaterRegion {
        region: "semi_arid_irrigation_basin",
        streamflow_current: 0.68,
        streamflow_baseline: 1.00,
        soil_moisture_current: 0.62,
        soil_moisture_baseline: 1.00,
        groundwater_stress: 0.82,
        wetland_buffer_capacity: 0.28,
        ecological_sensitivity: 0.78,
        exposed_population_index: 0.72,
        food_system_dependence: 0.86,
        monitoring_capacity: 0.52,
        governance_capacity: 0.40,
        adaptive_capacity: 0.38,
    };

    println!("Region: {}", region.region);
    println!("Blue-water deviation: {:.4}", region.blue_water_deviation());
    println!("Green-water deviation: {:.4}", region.green_water_deviation());
    println!(
        "Hydrological boundary pressure: {:.4}",
        region.hydrological_boundary_pressure()
    );
    println!(
        "Freshwater system risk score: {:.4}",
        region.freshwater_system_risk_score()
    );
}
