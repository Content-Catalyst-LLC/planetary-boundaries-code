-- Planetary justice and global inequality schema.
--
-- This schema supports groups, ecological-use indicators,
-- minimum-access indicators, vulnerability, responsibility,
-- capacity, source provenance, scoring runs, and audit trails.

CREATE TABLE IF NOT EXISTS groups (
    group_id INTEGER PRIMARY KEY,
    group_name TEXT NOT NULL UNIQUE,
    group_type TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS justice_indicators (
    indicator_id INTEGER PRIMARY KEY,
    indicator_name TEXT NOT NULL UNIQUE,
    indicator_domain TEXT NOT NULL CHECK (
        indicator_domain IN (
            'ecological_use',
            'minimum_access',
            'vulnerability',
            'historical_contribution',
            'capacity'
        )
    ),
    unit TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS group_observations (
    observation_id INTEGER PRIMARY KEY,
    group_id INTEGER NOT NULL,
    indicator_id INTEGER NOT NULL,
    observed_value REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (group_id) REFERENCES groups(group_id),
    FOREIGN KEY (indicator_id) REFERENCES justice_indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS allocation_assumptions (
    allocation_id INTEGER PRIMARY KEY,
    group_id INTEGER NOT NULL,
    indicator_id INTEGER NOT NULL,
    fair_allocation REAL NOT NULL,
    allocation_method TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (group_id) REFERENCES groups(group_id),
    FOREIGN KEY (indicator_id) REFERENCES justice_indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS justice_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
    ecological_overuse REAL,
    minimum_access_shortfall REAL,
    vulnerability REAL,
    planetary_justice_gap REAL,
    responsibility_adjusted_gap REAL,
    dominant_dimension TEXT,
    justice_priority_class TEXT,
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (group_id) REFERENCES groups(group_id)
);
