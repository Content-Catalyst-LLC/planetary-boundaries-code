-- Planetary-boundary measurement schema.
--
-- This schema supports boundary processes, control variables,
-- observed values, boundary values, uncertainty estimates,
-- monitoring capacity, scoring runs, and audit trails.

CREATE TABLE IF NOT EXISTS boundary_processes (
    boundary_id INTEGER PRIMARY KEY,
    boundary_name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS control_variables (
    control_variable_id INTEGER PRIMARY KEY,
    boundary_id INTEGER NOT NULL,
    variable_name TEXT NOT NULL,
    unit TEXT,
    measurement_logic TEXT,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (boundary_id) REFERENCES boundary_processes(boundary_id)
);

CREATE TABLE IF NOT EXISTS boundary_values (
    boundary_value_id INTEGER PRIMARY KEY,
    control_variable_id INTEGER NOT NULL,
    boundary_value REAL NOT NULL,
    high_risk_value REAL,
    boundary_uncertainty REAL,
    version_label TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (control_variable_id) REFERENCES control_variables(control_variable_id)
);

CREATE TABLE IF NOT EXISTS observations (
    observation_id INTEGER PRIMARY KEY,
    control_variable_id INTEGER NOT NULL,
    observed_value REAL NOT NULL,
    observation_uncertainty REAL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    provenance_note TEXT,
    FOREIGN KEY (control_variable_id) REFERENCES control_variables(control_variable_id)
);

CREATE TABLE IF NOT EXISTS monitoring_capacity (
    capacity_id INTEGER PRIMARY KEY,
    control_variable_id INTEGER NOT NULL,
    monitoring_capacity_score REAL CHECK (
        monitoring_capacity_score >= 0 AND monitoring_capacity_score <= 1
    ),
    observation_maturity TEXT,
    model_dependency TEXT,
    notes TEXT,
    FOREIGN KEY (control_variable_id) REFERENCES control_variables(control_variable_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS measurement_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    control_variable_id INTEGER NOT NULL,
    pressure_ratio REAL,
    combined_uncertainty REAL,
    uncertainty_adjusted_pressure REAL,
    measurement_risk_score REAL,
    risk_zone TEXT,
    measurement_priority TEXT,
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (control_variable_id) REFERENCES control_variables(control_variable_id)
);
