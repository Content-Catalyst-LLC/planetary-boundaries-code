-- Doughnut engineering schema
--
-- This schema supports ecological ceilings, social foundations,
-- indicator observations, provenance, scoring runs, and results.
-- It is intentionally database-neutral SQL and can be adapted for
-- SQLite, PostgreSQL, DuckDB, or analytical warehouses.

CREATE TABLE IF NOT EXISTS entities (
    entity_id INTEGER PRIMARY KEY,
    entity_name TEXT NOT NULL UNIQUE,
    entity_type TEXT NOT NULL,
    iso_code TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS indicators (
    indicator_id INTEGER PRIMARY KEY,
    indicator_name TEXT NOT NULL UNIQUE,
    domain TEXT NOT NULL CHECK (domain IN ('ecological', 'social')),
    direction TEXT NOT NULL CHECK (direction IN ('ceiling', 'floor')),
    unit TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS thresholds (
    threshold_id INTEGER PRIMARY KEY,
    indicator_id INTEGER NOT NULL,
    threshold_value REAL NOT NULL,
    threshold_rationale TEXT,
    source_name TEXT,
    source_url TEXT,
    valid_from_year INTEGER,
    valid_to_year INTEGER,
    FOREIGN KEY (indicator_id) REFERENCES indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS observations (
    observation_id INTEGER PRIMARY KEY,
    entity_id INTEGER NOT NULL,
    indicator_id INTEGER NOT NULL,
    observed_value REAL NOT NULL,
    observation_year INTEGER NOT NULL,
    source_name TEXT,
    source_url TEXT,
    collection_method TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id),
    FOREIGN KEY (indicator_id) REFERENCES indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    ecological_weight REAL NOT NULL,
    social_weight REAL NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS diagnostic_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    entity_id INTEGER NOT NULL,
    weighted_ecological_overshoot REAL NOT NULL,
    weighted_social_shortfall REAL NOT NULL,
    safe_and_just_score REAL NOT NULL,
    diagnostic_class TEXT NOT NULL,
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id)
);

CREATE VIEW IF NOT EXISTS latest_entity_scores AS
SELECT
    e.entity_name,
    s.run_id,
    s.weighted_ecological_overshoot,
    s.weighted_social_shortfall,
    s.safe_and_just_score,
    s.diagnostic_class
FROM diagnostic_scores s
JOIN entities e ON s.entity_id = e.entity_id;
