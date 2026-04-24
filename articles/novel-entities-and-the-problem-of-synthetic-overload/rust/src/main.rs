// Synthetic overload scoring engine in Rust.

#[derive(Debug)]
struct NovelEntityRisk {
    entity_class: &'static str,
    annual_production_index: f64,
    environmental_release_fraction: f64,
    persistence: f64,
    mobility: f64,
    hazard: f64,
    exposure: f64,
    monitoring_coverage: f64,
    assessment_gap: f64,
    substitution_feasibility: f64,
    essentiality: f64,
}

impl NovelEntityRisk {
    fn release_index(&self) -> f64 {
        self.annual_production_index * self.environmental_release_fraction
    }

    fn intrinsic_risk(&self) -> f64 {
        self.persistence * self.mobility * self.hazard * self.exposure
    }

    fn monitoring_gap(&self) -> f64 {
        1.0 - self.monitoring_coverage
    }

    fn governance_gap(&self) -> f64 {
        0.55 * self.assessment_gap + 0.45 * self.monitoring_gap()
    }

    fn essential_use_pressure(&self) -> f64 {
        self.essentiality * (1.0 - self.substitution_feasibility)
    }

    fn synthetic_overload_score(&self) -> f64 {
        self.release_index()
            * self.intrinsic_risk()
            * (1.0 + self.governance_gap())
            * (1.0 + self.essential_use_pressure())
    }
}

fn main() {
    let profile = NovelEntityRisk {
        entity_class: "pfas_forever_chemicals",
        annual_production_index: 0.42,
        environmental_release_fraction: 0.28,
        persistence: 0.98,
        mobility: 0.88,
        hazard: 0.82,
        exposure: 0.78,
        monitoring_coverage: 0.34,
        assessment_gap: 0.70,
        substitution_feasibility: 0.44,
        essentiality: 0.36,
    };

    println!("Entity class: {}", profile.entity_class);
    println!("Release index: {:.4}", profile.release_index());
    println!("Intrinsic risk: {:.4}", profile.intrinsic_risk());
    println!("Governance gap: {:.4}", profile.governance_gap());
    println!(
        "Synthetic overload score: {:.4}",
        profile.synthetic_overload_score()
    );
}
