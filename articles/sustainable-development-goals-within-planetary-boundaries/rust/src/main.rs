// SDG-boundary alignment scoring engine in Rust.

#[derive(Debug)]
struct RegionDiagnostic {
    region: &'static str,
    sdg_shortfall: f64,
    boundary_overshoot: f64,
    vulnerability: f64,
    capacity_to_act: f64,
}

impl RegionDiagnostic {
    fn alignment_score(&self) -> f64 {
        1.0 - (0.5 * self.sdg_shortfall + 0.5 * self.boundary_overshoot)
    }

    fn justice_adjusted_risk(&self) -> f64 {
        (self.sdg_shortfall + self.boundary_overshoot + self.vulnerability)
            * (1.0 + (1.0 - self.capacity_to_act))
    }
}

fn main() {
    let region = RegionDiagnostic {
        region: "Region D",
        sdg_shortfall: 0.22,
        boundary_overshoot: 0.28,
        vulnerability: 0.72,
        capacity_to_act: 0.38,
    };

    println!("Region: {}", region.region);
    println!("Alignment score: {:.4}", region.alignment_score());
    println!("Justice-adjusted risk: {:.4}", region.justice_adjusted_risk());
}
