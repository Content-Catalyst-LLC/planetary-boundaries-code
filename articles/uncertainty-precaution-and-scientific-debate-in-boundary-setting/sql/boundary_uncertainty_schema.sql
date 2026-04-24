-- Boundary uncertainty and precaution schema.
--
-- This schema supports boundary definitions, observed pressures,
-- estimated thresholds, uncertainty ranges, precautionary assumptions,
-- governance capacity, scoring runs, and audit trails.

CREATE TABLE IF NOT EXISTS boundaries (
    boundary_id INTEGER PRIMARY KEY,
    boundary_name TEXT NOT NULL UNIQUE,
    description TEXT,
    control_variable TEXT,
    unit TEXT
);

CREATE TABLE IF NOT EXISTS threshold_estimates (
    threshold_id INTEGER PRIMARY KEY,
    boundary_id INTEGER NOT NULL,
    estimated_threshold REAL NOT NULL,
    threshold_uncertainty REAL NOT NULL,
    uncertainty_method TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (boundary_id) REFERENCES boundaries(boundary_id)
);

CREATE TABLE IF NOT EXISTS observed_pressures (
    observation_id INTEGER PRIMARY KEY,
    boundary_id INTEGER NOT NULL,
    observed_pressure REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (boundary_id) REFERENCES boundaries(boundary_id)
);

CREATE TABLE IF NOT EXISTS precautionary_assumptions (
    assumption_id INTEGER PRIMARY KEY,
    boundary_id INTEGER NOT NULL,
    precaution_factor REAL NOT NULL,
    rationale TEXT,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (boundary_id) REFERENCES boundaries(boundary_id)
);

CREATE TABLE IF NOT EXISTS governance_capacity (
    capacity_id INTEGER PRIMARY KEY,
    boundary_id INTEGER NOT NULL,
    governance_capacity_score REAL CHECK (
        governance_capacity_score >= 0 AND governance_capacity_score <= 1
    ),
    monitoring_capacity REAL,
    adaptive_capacity REAL,
    legal_institutional_fit REAL,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (boundary_id) REFERENCES boundaries(boundary_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS uncertainty_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    boundary_id INTEGER NOT NULL,
    precautionary_boundary REAL,
    pressure_ratio REAL,
    uncertainty_adjusted_pressure REAL,
    governance_adjusted_risk REAL,
    risk_zone TEXT,
    dominant_issue TEXT,
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (boundary_id) REFERENCES boundaries(boundary_id)
);
