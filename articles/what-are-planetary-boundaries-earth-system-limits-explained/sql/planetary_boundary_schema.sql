-- Planetary boundary risk schema.
--
-- This schema supports boundary definitions, observed control-variable values,
-- uncertainty bands, risk zones, pressure trends, cross-boundary interactions,
-- monitoring capacity, governance capacity, reversibility capacity,
-- social exposure, scenario runs, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS boundary_definitions (
    boundary_id INTEGER PRIMARY KEY,
    boundary_name TEXT NOT NULL UNIQUE,
    boundary_description TEXT,
    boundary_value REAL NOT NULL,
    uncertainty_band REAL NOT NULL,
    unit TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS boundary_observations (
    observation_id INTEGER PRIMARY KEY,
    boundary_id INTEGER NOT NULL,
    observed_value REAL NOT NULL,
    observation_year INTEGER,
    annual_pressure_trend REAL,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (boundary_id) REFERENCES boundary_definitions(boundary_id)
);

CREATE TABLE IF NOT EXISTS boundary_capacity (
    capacity_id INTEGER PRIMARY KEY,
    boundary_id INTEGER NOT NULL,
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    reversibility_capacity REAL CHECK (reversibility_capacity >= 0 AND reversibility_capacity <= 1),
    social_exposure REAL CHECK (social_exposure >= 0 AND social_exposure <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (boundary_id) REFERENCES boundary_definitions(boundary_id)
);

CREATE TABLE IF NOT EXISTS boundary_interactions (
    interaction_id INTEGER PRIMARY KEY,
    source_boundary_id INTEGER NOT NULL,
    target_boundary_id INTEGER NOT NULL,
    interaction_weight REAL CHECK (interaction_weight >= 0 AND interaction_weight <= 1),
    interaction_description TEXT,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (source_boundary_id) REFERENCES boundary_definitions(boundary_id),
    FOREIGN KEY (target_boundary_id) REFERENCES boundary_definitions(boundary_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    pressure_multiplier REAL,
    trend_multiplier REAL,
    monitoring_gain REAL,
    governance_gain REAL,
    reversibility_gain REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS planetary_boundary_risk_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    boundary_id INTEGER NOT NULL,
    boundary_pressure_ratio REAL,
    uncertainty_margin REAL,
    threshold_risk_score REAL,
    cross_boundary_amplification REAL,
    systemic_boundary_risk REAL,
    risk_zone TEXT,
    response_urgency TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (boundary_id) REFERENCES boundary_definitions(boundary_id)
);
