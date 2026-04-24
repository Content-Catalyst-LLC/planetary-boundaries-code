// Biogeochemical flow risk scoring engine in Rust.

#[derive(Debug)]
struct NutrientRegion {
    region: &'static str,
    nitrogen_input: f64,
    nitrogen_uptake: f64,
    phosphorus_input: f64,
    phosphorus_uptake: f64,
    nitrogen_boundary_reference: f64,
    phosphorus_boundary_reference: f64,
    runoff_sensitivity: f64,
    hydrological_connectivity: f64,
    ecosystem_sensitivity: f64,
    legacy_nutrient_pressure: f64,
    monitoring_capacity: f64,
    governance_capacity: f64,
}

impl NutrientRegion {
    fn nitrogen_surplus(&self) -> f64 {
        self.nitrogen_input - self.nitrogen_uptake
    }

    fn phosphorus_surplus(&self) -> f64 {
        self.phosphorus_input - self.phosphorus_uptake
    }

    fn nitrogen_use_efficiency(&self) -> f64 {
        self.nitrogen_uptake / self.nitrogen_input
    }

    fn phosphorus_use_efficiency(&self) -> f64 {
        self.phosphorus_uptake / self.phosphorus_input
    }

    fn nitrogen_boundary_pressure(&self) -> f64 {
        self.nitrogen_input / self.nitrogen_boundary_reference
    }

    fn phosphorus_boundary_pressure(&self) -> f64 {
        self.phosphorus_input / self.phosphorus_boundary_reference
    }

    fn nutrient_loss_pressure(&self) -> f64 {
        let surplus_pressure =
            0.50 * self.nitrogen_surplus().max(0.0)
                + 0.50 * self.phosphorus_surplus().max(0.0);

        let transport_pressure =
            0.50 * self.runoff_sensitivity
                + 0.50 * self.hydrological_connectivity;

        surplus_pressure * transport_pressure
    }

    fn eutrophication_pressure(&self) -> f64 {
        (
            0.35 * self.nitrogen_boundary_pressure()
                + 0.35 * self.phosphorus_boundary_pressure()
                + 0.30 * self.nutrient_loss_pressure()
        ) * self.ecosystem_sensitivity
    }

    fn planetary_nutrient_risk_score(&self) -> f64 {
        let legacy_adjusted_pressure =
            self.eutrophication_pressure() * (1.0 + self.legacy_nutrient_pressure);

        let monitoring_gap = 1.0 - self.monitoring_capacity;
        let governance_gap = 1.0 - self.governance_capacity;

        legacy_adjusted_pressure * (1.0 + 0.45 * monitoring_gap + 0.55 * governance_gap)
    }
}

fn main() {
    let region = NutrientRegion {
        region: "coastal_dead_zone_drainage",
        nitrogen_input: 1.56,
        nitrogen_uptake: 0.86,
        phosphorus_input: 1.40,
        phosphorus_uptake: 0.62,
        nitrogen_boundary_reference: 1.00,
        phosphorus_boundary_reference: 1.00,
        runoff_sensitivity: 0.78,
        hydrological_connectivity: 0.92,
        ecosystem_sensitivity: 0.84,
        legacy_nutrient_pressure: 0.68,
        monitoring_capacity: 0.66,
        governance_capacity: 0.44,
    };

    println!("Region: {}", region.region);
    println!("Nitrogen use efficiency: {:.4}", region.nitrogen_use_efficiency());
    println!("Phosphorus use efficiency: {:.4}", region.phosphorus_use_efficiency());
    println!("Eutrophication pressure: {:.4}", region.eutrophication_pressure());
    println!(
        "Planetary nutrient risk score: {:.4}",
        region.planetary_nutrient_risk_score()
    );
}
