// High-integrity boundary scoring scaffold in Rust.

fn overshoot(observed: f64, boundary: f64) -> f64 {
    if observed > boundary {
        (observed - boundary) / boundary
    } else {
        0.0
    }
}

fn shortfall(observed: f64, foundation: f64) -> f64 {
    if observed < foundation {
        (foundation - observed) / foundation
    } else {
        0.0
    }
}

fn main() {
    let ecological_pressure = 9.8;
    let ecological_boundary = 3.0;
    let social_achievement = 0.82;
    let social_foundation = 0.90;

    let o = overshoot(ecological_pressure, ecological_boundary);
    let q = shortfall(social_achievement, social_foundation);
    let score = 1.0 - (0.5 * o + 0.5 * q);

    println!("Ecological overshoot: {:.3}", o);
    println!("Social shortfall: {:.3}", q);
    println!("Safe-and-just score: {:.3}", score);
}
