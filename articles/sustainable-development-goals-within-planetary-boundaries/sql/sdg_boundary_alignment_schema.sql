-- SDG-boundary alignment schema.
--
-- This schema supports regions, SDG indicators, ecological-pressure indicators,
-- thresholds, observations, vulnerability, capacity, scoring runs, and audit trails.

CREATE TABLE IF NOT EXISTS regions (
    region_id INTEGER PRIMARY KEY,
    region_name TEXT NOT NULL UNIQUE,
    region_type TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS indicators (
    indicator_id INTEGER PRIMARY KEY,
    indicator_name TEXT NOT NULL UNIQUE,
    indicator_domain TEXT NOT NULL CHECK (
        indicator_domain IN ('social', 'ecological', 'vulnerability', 'capacity')
    ),
    direction TEXT CHECK (direction IN ('floor', 'ceiling', 'none')),
    unit TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS thresholds (
    threshold_id INTEGER PRIMARY KEY,
    indicator_id INTEGER NOT NULL,
    threshold_value REAL NOT NULL,
    threshold_type TEXT NOT NULL CHECK (threshold_type IN ('floor', 'ceiling')),
    allocation_method TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (indicator_id) REFERENCES indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS observations (
    observation_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    indicator_id INTEGER NOT NULL,
    observed_value REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (region_id) REFERENCES regions(region_id),
    FOREIGN KEY (indicator_id) REFERENCES indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS alignment_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    weighted_sdg_shortfall REAL,
    weighted_boundary_overshoot REAL,
    vulnerability REAL,
    capacity_to_act REAL,
    sdg_boundary_alignment_score REAL,
    justice_adjusted_risk REAL,
    diagnostic_class TEXT,
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);
