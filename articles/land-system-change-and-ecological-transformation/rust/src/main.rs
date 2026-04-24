// Land-system change risk scoring engine in Rust.

#[derive(Debug)]
struct LandBiome {
    biome: &'static str,
    remaining_forest_ratio: f64,
    biome_boundary_threshold: f64,
    fragmentation_risk: f64,
    ecological_quality: f64,
    land_conversion_pressure: f64,
    climate_stress: f64,
    hydrological_disruption: f64,
    carbon_storage_importance: f64,
    moisture_recycling_importance: f64,
    biodiversity_sensitivity: f64,
    restoration_potential: f64,
    monitoring_capacity: f64,
    governance_capacity: f64,
}

impl LandBiome {
    fn forest_boundary_pressure(&self) -> f64 {
        self.biome_boundary_threshold / self.remaining_forest_ratio
    }

    fn biome_integrity_index(&self) -> f64 {
        self.remaining_forest_ratio * (1.0 - self.fragmentation_risk) * self.ecological_quality
    }

    fn regulatory_importance(&self) -> f64 {
        0.34 * self.carbon_storage_importance
            + 0.33 * self.moisture_recycling_importance
            + 0.33 * self.biodiversity_sensitivity
    }

    fn land_system_pressure(&self) -> f64 {
        0.35 * self.forest_boundary_pressure()
            + 0.20 * self.land_conversion_pressure
            + 0.18 * self.climate_stress
            + 0.17 * self.hydrological_disruption
            + 0.10 * self.fragmentation_risk
    }

    fn land_system_risk_score(&self) -> f64 {
        let monitoring_gap = 1.0 - self.monitoring_capacity;
        let governance_gap = 1.0 - self.governance_capacity;

        let restoration_credit =
            self.restoration_potential * self.governance_capacity * 0.30;

        self.land_system_pressure()
            * self.regulatory_importance()
            * (1.0 + 0.35 * monitoring_gap + 0.45 * governance_gap)
            - restoration_credit
    }
}

fn main() {
    let biome = LandBiome {
        biome: "tropical_forest_frontier",
        remaining_forest_ratio: 0.72,
        biome_boundary_threshold: 0.85,
        fragmentation_risk: 0.68,
        ecological_quality: 0.58,
        land_conversion_pressure: 0.82,
        climate_stress: 0.66,
        hydrological_disruption: 0.72,
        carbon_storage_importance: 0.92,
        moisture_recycling_importance: 0.94,
        biodiversity_sensitivity: 0.96,
        restoration_potential: 0.62,
        monitoring_capacity: 0.60,
        governance_capacity: 0.42,
    };

    println!("Biome: {}", biome.biome);
    println!(
        "Forest boundary pressure: {:.4}",
        biome.forest_boundary_pressure()
    );
    println!("Biome integrity index: {:.4}", biome.biome_integrity_index());
    println!("Land-system pressure: {:.4}", biome.land_system_pressure());
    println!(
        "Land-system risk score: {:.4}",
        biome.land_system_risk_score()
    );
}
