// Doughnut boundary scoring engine in Rust.
//
// This is a reliable, strongly typed scoring core that can be extended
// into a CLI, service backend, or WebAssembly module.

#[derive(Debug, Clone, Copy)]
enum Direction {
    Ceiling,
    Floor,
}

#[derive(Debug, Clone)]
struct Indicator {
    name: &'static str,
    observed: f64,
    threshold: f64,
    direction: Direction,
    weight: f64,
}

impl Indicator {
    fn penalty(&self) -> f64 {
        match self.direction {
            Direction::Ceiling => {
                if self.observed > self.threshold {
                    (self.observed - self.threshold) / self.threshold
                } else {
                    0.0
                }
            }
            Direction::Floor => {
                if self.observed < self.threshold {
                    (self.threshold - self.observed) / self.threshold
                } else {
                    0.0
                }
            }
        }
    }
}

fn weighted_mean(indicators: &[Indicator]) -> f64 {
    let weighted_sum: f64 = indicators
        .iter()
        .map(|indicator| indicator.penalty() * indicator.weight)
        .sum();

    let weight_sum: f64 = indicators.iter().map(|indicator| indicator.weight).sum();

    if weight_sum == 0.0 {
        0.0
    } else {
        weighted_sum / weight_sum
    }
}

fn main() {
    let ecological = vec![
        Indicator {
            name: "co2_per_capita",
            observed: 9.8,
            threshold: 3.0,
            direction: Direction::Ceiling,
            weight: 1.4,
        },
        Indicator {
            name: "material_footprint_per_capita",
            observed: 18.0,
            threshold: 8.0,
            direction: Direction::Ceiling,
            weight: 1.2,
        },
    ];

    let social = vec![
        Indicator {
            name: "basic_health_access",
            observed: 0.82,
            threshold: 0.90,
            direction: Direction::Floor,
            weight: 1.3,
        },
        Indicator {
            name: "political_voice_index",
            observed: 0.62,
            threshold: 0.75,
            direction: Direction::Floor,
            weight: 1.0,
        },
    ];

    let ecological_overshoot = weighted_mean(&ecological);
    let social_shortfall = weighted_mean(&social);
    let safe_and_just_score = 1.0 - (0.5 * ecological_overshoot + 0.5 * social_shortfall);

    println!("Ecological overshoot: {:.4}", ecological_overshoot);
    println!("Social shortfall: {:.4}", social_shortfall);
    println!("Safe-and-just score: {:.4}", safe_and_just_score);

    for indicator in ecological.iter().chain(social.iter()) {
        println!("{} penalty: {:.4}", indicator.name, indicator.penalty());
    }
}
