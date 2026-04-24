// Planetary boundaries framework evolution scoring engine in Rust.

#[derive(Debug)]
struct FrameworkMilestone {
    year: u16,
    milestone: &'static str,
    conceptual_integration: f64,
    measurement_refinement: f64,
    governance_relevance: f64,
    policy_visibility: f64,
    public_legibility: f64,
    justice_integration: f64,
    uncertainty_treatment: f64,
    cross_boundary_logic: f64,
}

impl FrameworkMilestone {
    fn scientific_maturity(&self) -> f64 {
        0.45 * self.conceptual_integration
            + 0.35 * self.measurement_refinement
            + 0.20 * self.uncertainty_treatment
    }

    fn governance_influence(&self) -> f64 {
        0.40 * self.governance_relevance
            + 0.35 * self.policy_visibility
            + 0.25 * self.public_legibility
    }

    fn systems_depth(&self) -> f64 {
        0.60 * self.cross_boundary_logic
            + 0.25 * self.uncertainty_treatment
            + 0.15 * self.conceptual_integration
    }

    fn framework_influence_score(&self) -> f64 {
        0.30 * self.scientific_maturity()
            + 0.28 * self.governance_influence()
            + 0.22 * self.systems_depth()
            + 0.12 * self.measurement_refinement
            + 0.08 * self.justice_integration
    }
}

fn main() {
    let milestone = FrameworkMilestone {
        year: 2009,
        milestone: "safe_operating_space_formalization",
        conceptual_integration: 0.88,
        measurement_refinement: 0.62,
        governance_relevance: 0.72,
        policy_visibility: 0.64,
        public_legibility: 0.82,
        justice_integration: 0.32,
        uncertainty_treatment: 0.68,
        cross_boundary_logic: 0.78,
    };

    println!("Year: {}", milestone.year);
    println!("Milestone: {}", milestone.milestone);
    println!("Scientific maturity: {:.4}", milestone.scientific_maturity());
    println!("Governance influence: {:.4}", milestone.governance_influence());
    println!("Systems depth: {:.4}", milestone.systems_depth());
    println!(
        "Framework influence score: {:.4}",
        milestone.framework_influence_score()
    );
}
