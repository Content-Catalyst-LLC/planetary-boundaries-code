// Regional aerosol-risk scoring engine in Rust.

#[derive(Debug)]
struct AerosolRegion {
    region: &'static str,
    aerosol_optical_depth: f64,
    regional_boundary_reference: f64,
    pm25_exposure: f64,
    black_carbon_share: f64,
    sulfate_share: f64,
    dust_share: f64,
    exposed_population_index: f64,
    vulnerability_index: f64,
    hydrological_sensitivity: f64,
    cloud_uncertainty: f64,
    governance_capacity: f64,
}

impl AerosolRegion {
    fn aod_pressure_ratio(&self) -> f64 {
        self.aerosol_optical_depth / self.regional_boundary_reference
    }

    fn composition_weight(&self) -> f64 {
        1.30 * self.black_carbon_share
            + 0.85 * self.sulfate_share
            + 0.70 * self.dust_share
    }

    fn health_exposure_score(&self) -> f64 {
        self.pm25_exposure * self.exposed_population_index * self.vulnerability_index
    }

    fn climate_hydrology_score(&self) -> f64 {
        self.aod_pressure_ratio()
            * (1.0 + self.cloud_uncertainty)
            * self.hydrological_sensitivity
            * (1.0 + self.composition_weight())
    }

    fn regional_planetary_risk_score(&self) -> f64 {
        let governance_gap = 1.0 - self.governance_capacity;

        (
            0.35 * self.aod_pressure_ratio()
                + 0.35 * self.health_exposure_score()
                + 0.30 * self.climate_hydrology_score()
        ) * (1.0 + governance_gap)
    }
}

fn main() {
    let region = AerosolRegion {
        region: "south_asia_monsoon_region",
        aerosol_optical_depth: 0.42,
        regional_boundary_reference: 0.25,
        pm25_exposure: 0.86,
        black_carbon_share: 0.28,
        sulfate_share: 0.34,
        dust_share: 0.12,
        exposed_population_index: 0.92,
        vulnerability_index: 0.78,
        hydrological_sensitivity: 0.88,
        cloud_uncertainty: 0.32,
        governance_capacity: 0.42,
    };

    println!("Region: {}", region.region);
    println!("AOD pressure ratio: {:.4}", region.aod_pressure_ratio());
    println!("Health exposure score: {:.4}", region.health_exposure_score());
    println!("Climate-hydrology score: {:.4}", region.climate_hydrology_score());
    println!(
        "Regional planetary risk score: {:.4}",
        region.regional_planetary_risk_score()
    );
}
