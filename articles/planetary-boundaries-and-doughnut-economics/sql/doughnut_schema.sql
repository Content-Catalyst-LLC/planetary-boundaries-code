-- Doughnut diagnostic schema.
-- This schema stores ecological ceilings, social foundations,
-- observations, provenance, and diagnostic scores.

CREATE TABLE IF NOT EXISTS entities (
    entity_id INTEGER PRIMARY KEY,
    entity_name TEXT NOT NULL UNIQUE,
    entity_type TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS indicators (
    indicator_id INTEGER PRIMARY KEY,
    indicator_name TEXT NOT NULL UNIQUE,
    indicator_domain TEXT NOT NULL CHECK (
        indicator_domain IN ('ecological_ceiling', 'social_foundation')
    ),
    unit TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS thresholds (
    threshold_id INTEGER PRIMARY KEY,
    indicator_id INTEGER NOT NULL,
    threshold_value REAL NOT NULL,
    threshold_type TEXT NOT NULL CHECK (
        threshold_type IN ('ceiling', 'floor')
    ),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (indicator_id) REFERENCES indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS observations (
    observation_id INTEGER PRIMARY KEY,
    entity_id INTEGER NOT NULL,
    indicator_id INTEGER NOT NULL,
    observed_value REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id),
    FOREIGN KEY (indicator_id) REFERENCES indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS diagnostic_scores (
    score_id INTEGER PRIMARY KEY,
    entity_id INTEGER NOT NULL,
    mean_ecological_overshoot REAL,
    mean_social_shortfall REAL,
    safe_and_just_score REAL,
    diagnostic_label TEXT,
    calculation_date TEXT DEFAULT CURRENT_DATE,
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id)
);
