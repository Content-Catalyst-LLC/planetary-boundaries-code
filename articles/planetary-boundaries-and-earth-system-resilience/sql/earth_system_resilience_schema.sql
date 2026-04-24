-- Earth system resilience and planetary-boundary interaction schema.
--
-- This schema supports boundary processes, resilience indicators,
-- observed pressure, boundary values, interaction edges,
-- scenario runs, scoring outputs, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS boundary_processes (
    boundary_id INTEGER PRIMARY KEY,
    boundary_name TEXT NOT NULL UNIQUE,
    description TEXT,
    structural_role TEXT
);

CREATE TABLE IF NOT EXISTS boundary_observations (
    observation_id INTEGER PRIMARY KEY,
    boundary_id INTEGER NOT NULL,
    observed_pressure REAL NOT NULL,
    boundary_value REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (boundary_id) REFERENCES boundary_processes(boundary_id)
);

CREATE TABLE IF NOT EXISTS resilience_indicators (
    indicator_id INTEGER PRIMARY KEY,
    boundary_id INTEGER NOT NULL,
    diversity REAL CHECK (diversity >= 0 AND diversity <= 1),
    redundancy REAL CHECK (redundancy >= 0 AND redundancy <= 1),
    adaptive_capacity REAL CHECK (adaptive_capacity >= 0 AND adaptive_capacity <= 1),
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (boundary_id) REFERENCES boundary_processes(boundary_id)
);

CREATE TABLE IF NOT EXISTS boundary_interactions (
    edge_id INTEGER PRIMARY KEY,
    source_boundary_id INTEGER NOT NULL,
    target_boundary_id INTEGER NOT NULL,
    interaction_weight REAL NOT NULL,
    interaction_type TEXT,
    evidence_note TEXT,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (source_boundary_id) REFERENCES boundary_processes(boundary_id),
    FOREIGN KEY (target_boundary_id) REFERENCES boundary_processes(boundary_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    interaction_lambda REAL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS resilience_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    boundary_id INTEGER NOT NULL,
    pressure_ratio REAL,
    resilience_capacity REAL,
    resilience_gap REAL,
    interaction_pressure REAL,
    resilience_adjusted_risk REAL,
    risk_class TEXT,
    dominant_resilience_gap TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (boundary_id) REFERENCES boundary_processes(boundary_id)
);
