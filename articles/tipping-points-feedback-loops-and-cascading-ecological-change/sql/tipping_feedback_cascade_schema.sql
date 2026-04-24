-- Tipping points, feedback loops, and cascading ecological change schema.
--
-- This schema supports tipping elements, thresholds, feedback strengths,
-- resilience indicators, monitoring capacity, interaction edges,
-- scenario runs, and audit trails.

CREATE TABLE IF NOT EXISTS tipping_elements (
    element_id INTEGER PRIMARY KEY,
    element_name TEXT NOT NULL UNIQUE,
    element_type TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS tipping_thresholds (
    threshold_id INTEGER PRIMARY KEY,
    element_id INTEGER NOT NULL,
    threshold_value REAL NOT NULL,
    threshold_uncertainty REAL,
    precaution_factor REAL,
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (element_id) REFERENCES tipping_elements(element_id)
);

CREATE TABLE IF NOT EXISTS element_states (
    state_id INTEGER PRIMARY KEY,
    element_id INTEGER NOT NULL,
    observed_pressure REAL NOT NULL,
    feedback_strength REAL,
    resilience_capacity REAL CHECK (resilience_capacity >= 0 AND resilience_capacity <= 1),
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (element_id) REFERENCES tipping_elements(element_id)
);

CREATE TABLE IF NOT EXISTS interaction_edges (
    edge_id INTEGER PRIMARY KEY,
    source_element_id INTEGER NOT NULL,
    target_element_id INTEGER NOT NULL,
    interaction_weight REAL NOT NULL,
    interaction_type TEXT,
    evidence_note TEXT,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (source_element_id) REFERENCES tipping_elements(element_id),
    FOREIGN KEY (target_element_id) REFERENCES tipping_elements(element_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    pressure_multiplier REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS tipping_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    element_id INTEGER NOT NULL,
    pressure_ratio REAL,
    cascade_pressure REAL,
    tipping_probability REAL,
    cascade_adjusted_risk REAL,
    risk_class TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (element_id) REFERENCES tipping_elements(element_id)
);
