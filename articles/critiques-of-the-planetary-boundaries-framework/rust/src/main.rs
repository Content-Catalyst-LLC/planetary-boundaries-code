// Critique-risk scoring engine in Rust.

#[derive(Debug)]
struct DomainScore {
    domain: &'static str,
    score: f64,
    weight: f64,
}

fn weighted_risk(scores: &[DomainScore]) -> f64 {
    let weighted_sum: f64 = scores.iter().map(|s| s.score * s.weight).sum();
    let weight_sum: f64 = scores.iter().map(|s| s.weight).sum();

    if weight_sum == 0.0 {
        0.0
    } else {
        weighted_sum / weight_sum
    }
}

fn classify(score: f64) -> &'static str {
    if score < 0.33 {
        "low"
    } else if score < 0.66 {
        "moderate"
    } else {
        "high"
    }
}

fn main() {
    let scores = vec![
        DomainScore { domain: "biophysical", score: 0.85, weight: 1.0 },
        DomainScore { domain: "justice", score: 0.72, weight: 1.0 },
        DomainScore { domain: "legitimacy", score: 0.76, weight: 1.0 },
        DomainScore { domain: "political_economy", score: 0.82, weight: 1.0 },
        DomainScore { domain: "operationalization", score: 0.60, weight: 1.0 },
    ];

    let total = weighted_risk(&scores);

    println!("Total critique risk: {:.4}", total);
    println!("Risk class: {}", classify(total));

    for score in scores {
        println!("{}: {:.3}", score.domain, score.score);
    }
}
