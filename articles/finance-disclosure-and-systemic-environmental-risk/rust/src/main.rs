// Finance boundary-risk scoring engine in Rust.

#[derive(Debug)]
struct IssuerRisk {
    issuer: &'static str,
    portfolio_weight: f64,
    boundary_pressure_ratio: f64,
    disclosure_adequacy: f64,
    transition_credibility: f64,
    uncertainty: f64,
    domain_weight: f64,
}

impl IssuerRisk {
    fn risk_score(&self) -> f64 {
        let disclosure_gap = 1.0 - self.disclosure_adequacy;
        let transition_gap = 1.0 - self.transition_credibility;

        self.boundary_pressure_ratio
            * (1.0 + disclosure_gap)
            * (1.0 + transition_gap)
            * (1.0 + self.uncertainty)
            * self.domain_weight
    }

    fn portfolio_contribution(&self) -> f64 {
        self.portfolio_weight * self.risk_score()
    }
}

fn main() {
    let issuers = vec![
        IssuerRisk {
            issuer: "Utility A",
            portfolio_weight: 0.18,
            boundary_pressure_ratio: 1.45,
            disclosure_adequacy: 0.70,
            transition_credibility: 0.55,
            uncertainty: 0.25,
            domain_weight: 1.5,
        },
        IssuerRisk {
            issuer: "Chemicals C",
            portfolio_weight: 0.14,
            boundary_pressure_ratio: 1.70,
            disclosure_adequacy: 0.35,
            transition_credibility: 0.30,
            uncertainty: 0.50,
            domain_weight: 1.2,
        },
    ];

    let total_risk: f64 = issuers.iter().map(|issuer| issuer.portfolio_contribution()).sum();

    println!("Portfolio systemic environmental risk: {:.4}", total_risk);

    for issuer in issuers {
        println!(
            "{} contribution: {:.4}",
            issuer.issuer,
            issuer.portfolio_contribution()
        );
    }
}
