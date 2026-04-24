-- Social-ecological resilience schema.
--
-- This schema supports social-ecological systems, resilience indicators,
-- disturbance events, adaptive capacity, learning capacity, governance capacity,
-- justice capacity, boundary pressure, transformation need, source provenance,
-- and audit trails.

CREATE TABLE IF NOT EXISTS social_ecological_systems (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL UNIQUE,
    system_type TEXT,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS resilience_indicators (
    indicator_id INTEGER PRIMARY KEY,
    system_id INTEGER NOT NULL,
    boundary_pressure REAL,
    disturbance_exposure REAL,
    functional_integrity REAL,
    diversity REAL,
    redundancy REAL,
    adaptive_capacity REAL,
    learning_capacity REAL,
    governance_capacity REAL,
    justice_capacity REAL,
    incumbent_lock_in REAL,
    transformation_feasibility REAL,
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (system_id) REFERENCES social_ecological_systems(system_id)
);

CREATE TABLE IF NOT EXISTS disturbance_events (
    event_id INTEGER PRIMARY KEY,
    system_id INTEGER NOT NULL,
    event_name TEXT,
    event_type TEXT,
    event_year INTEGER,
    severity REAL,
    recovery_time REAL,
    affected_functions TEXT,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (system_id) REFERENCES social_ecological_systems(system_id)
);

CREATE TABLE IF NOT EXISTS resilience_scores (
    score_id INTEGER PRIMARY KEY,
    system_id INTEGER NOT NULL,
    threshold_risk REAL,
    ecological_buffering REAL,
    institutional_capacity REAL,
    resilience_capacity REAL,
    lock_in_pressure REAL,
    systemic_resilience_risk REAL,
    transformation_need REAL,
    resilience_class TEXT,
    priority TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (system_id) REFERENCES social_ecological_systems(system_id)
);
