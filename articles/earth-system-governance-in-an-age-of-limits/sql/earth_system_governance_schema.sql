-- Earth system governance schema.
--
-- This schema supports governance cases, boundary domains,
-- institutional capacity dimensions, scoring runs, and audit trails.

CREATE TABLE IF NOT EXISTS governance_cases (
    case_id INTEGER PRIMARY KEY,
    case_name TEXT NOT NULL UNIQUE,
    jurisdiction_scale TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS boundary_domains (
    domain_id INTEGER PRIMARY KEY,
    domain_name TEXT NOT NULL UNIQUE,
    domain_weight REAL NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS governance_capacity_dimensions (
    dimension_id INTEGER PRIMARY KEY,
    dimension_name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS governance_scores (
    score_id INTEGER PRIMARY KEY,
    case_id INTEGER NOT NULL,
    domain_id INTEGER NOT NULL,
    boundary_pressure REAL NOT NULL,
    boundary_level REAL NOT NULL,
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    legal_institutional_fit REAL CHECK (legal_institutional_fit >= 0 AND legal_institutional_fit <= 1),
    justice_legitimacy REAL CHECK (justice_legitimacy >= 0 AND justice_legitimacy <= 1),
    adaptive_capacity REAL CHECK (adaptive_capacity >= 0 AND adaptive_capacity <= 1),
    cross_scale_coordination REAL CHECK (cross_scale_coordination >= 0 AND cross_scale_coordination <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (case_id) REFERENCES governance_cases(case_id),
    FOREIGN KEY (domain_id) REFERENCES boundary_domains(domain_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);
