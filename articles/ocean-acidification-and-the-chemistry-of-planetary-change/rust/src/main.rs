// Ocean acidification and marine chemistry scoring engine in Rust.

#[derive(Debug)]
struct OceanRegion {
    region: &'static str,
    current_ph: f64,
    preindustrial_ph: f64,
    carbonate_ion_index: f64,
    aragonite_saturation_state: f64,
    preindustrial_aragonite_state: f64,
    boundary_aragonite_state: f64,
    ecological_sensitivity: f64,
    exposure: f64,
    adaptive_capacity: f64,
    warming_stress: f64,
    deoxygenation_stress: f64,
    nutrient_stress: f64,
    monitoring_capacity: f64,
    governance_capacity: f64,
}

impl OceanRegion {
    fn ph_decline(&self) -> f64 {
        self.preindustrial_ph - self.current_ph
    }

    fn hydrogen_ion_increase_index(&self) -> f64 {
        10f64.powf(-self.current_ph) / 10f64.powf(-self.preindustrial_ph)
    }

    fn aragonite_boundary_pressure(&self) -> f64 {
        let numerator = self.preindustrial_aragonite_state - self.aragonite_saturation_state;
        let denominator = self.preindustrial_aragonite_state - self.boundary_aragonite_state;

        (numerator / denominator).max(0.0)
    }

    fn carbonate_deficit(&self) -> f64 {
        1.0 - self.carbonate_ion_index
    }

    fn ecosystem_vulnerability(&self) -> f64 {
        self.aragonite_boundary_pressure()
            * self.ecological_sensitivity
            * self.exposure
            * (1.0 - self.adaptive_capacity)
    }

    fn multi_stressor_pressure(&self) -> f64 {
        0.40 * self.aragonite_boundary_pressure()
            + 0.25 * self.warming_stress
            + 0.20 * self.deoxygenation_stress
            + 0.15 * self.nutrient_stress
    }

    fn marine_chemistry_risk_score(&self) -> f64 {
        let monitoring_gap = 1.0 - self.monitoring_capacity;
        let governance_gap = 1.0 - self.governance_capacity;

        (
            0.45 * self.ecosystem_vulnerability()
                + 0.35 * self.multi_stressor_pressure()
                + 0.20 * self.carbonate_deficit()
        ) * (1.0 + 0.5 * monitoring_gap + 0.5 * governance_gap)
    }
}

fn main() {
    let region = OceanRegion {
        region: "tropical_coral_reef_belt",
        current_ph: 8.06,
        preindustrial_ph: 8.18,
        carbonate_ion_index: 0.74,
        aragonite_saturation_state: 2.65,
        preindustrial_aragonite_state: 3.65,
        boundary_aragonite_state: 3.00,
        ecological_sensitivity: 0.90,
        exposure: 0.86,
        adaptive_capacity: 0.34,
        warming_stress: 0.88,
        deoxygenation_stress: 0.40,
        nutrient_stress: 0.54,
        monitoring_capacity: 0.58,
        governance_capacity: 0.38,
    };

    println!("Region: {}", region.region);
    println!("pH decline: {:.4}", region.ph_decline());
    println!(
        "Hydrogen ion increase index: {:.4}",
        region.hydrogen_ion_increase_index()
    );
    println!(
        "Aragonite boundary pressure: {:.4}",
        region.aragonite_boundary_pressure()
    );
    println!(
        "Marine chemistry risk score: {:.4}",
        region.marine_chemistry_risk_score()
    );
}
