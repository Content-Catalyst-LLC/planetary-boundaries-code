// Biosphere integrity risk scoring engine in Rust.

#[derive(Debug)]
struct BiosphereRegion {
    region: &'static str,
    observed_extinction_pressure: f64,
    genetic_boundary_reference: f64,
    functional_integrity_index: f64,
    functional_integrity_threshold: f64,
    habitat_intactness: f64,
    fragmentation_risk: f64,
    appropriation_pressure: f64,
    ecological_sensitivity: f64,
    climate_stress: f64,
    land_system_pressure: f64,
    freshwater_stress: f64,
    nutrient_pollution_pressure: f64,
    novel_entity_pressure: f64,
    restoration_potential: f64,
    monitoring_capacity: f64,
    governance_capacity: f64,
}

impl BiosphereRegion {
    fn genetic_diversity_pressure(&self) -> f64 {
        self.observed_extinction_pressure / self.genetic_boundary_reference
    }

    fn functional_integrity_deficit(&self) -> f64 {
        (self.functional_integrity_threshold - self.functional_integrity_index).max(0.0)
    }

    fn habitat_loss_pressure(&self) -> f64 {
        1.0 - self.habitat_intactness
    }

    fn cross_boundary_stress(&self) -> f64 {
        0.24 * self.climate_stress
            + 0.24 * self.land_system_pressure
            + 0.18 * self.freshwater_stress
            + 0.18 * self.nutrient_pollution_pressure
            + 0.16 * self.novel_entity_pressure
    }

    fn biosphere_pressure(&self) -> f64 {
        0.26 * self.genetic_diversity_pressure()
            + 0.22 * self.functional_integrity_deficit()
            + 0.16 * self.habitat_loss_pressure()
            + 0.14 * self.fragmentation_risk
            + 0.12 * self.appropriation_pressure
            + 0.10 * self.cross_boundary_stress()
    }

    fn biosphere_integrity_risk_score(&self) -> f64 {
        let monitoring_gap = 1.0 - self.monitoring_capacity;
        let governance_gap = 1.0 - self.governance_capacity;
        let restoration_credit = 0.35 * self.restoration_potential * self.governance_capacity;

        self.biosphere_pressure()
            * self.ecological_sensitivity
            * (1.0 + 0.30 * monitoring_gap + 0.45 * governance_gap)
            - restoration_credit
    }
}

fn main() {
    let region = BiosphereRegion {
        region: "tropical_forest_biodiversity_frontier",
        observed_extinction_pressure: 9.2,
        genetic_boundary_reference: 1.0,
        functional_integrity_index: 0.52,
        functional_integrity_threshold: 0.80,
        habitat_intactness: 0.58,
        fragmentation_risk: 0.72,
        appropriation_pressure: 0.76,
        ecological_sensitivity: 0.94,
        climate_stress: 0.62,
        land_system_pressure: 0.84,
        freshwater_stress: 0.60,
        nutrient_pollution_pressure: 0.44,
        novel_entity_pressure: 0.52,
        restoration_potential: 0.68,
        monitoring_capacity: 0.58,
        governance_capacity: 0.40,
    };

    println!("Region: {}", region.region);
    println!(
        "Genetic diversity pressure: {:.4}",
        region.genetic_diversity_pressure()
    );
    println!(
        "Functional integrity deficit: {:.4}",
        region.functional_integrity_deficit()
    );
    println!("Biosphere pressure: {:.4}", region.biosphere_pressure());
    println!(
        "Biosphere integrity risk score: {:.4}",
        region.biosphere_integrity_risk_score()
    );
}
