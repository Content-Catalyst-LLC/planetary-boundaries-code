-- Holocene stability and baseline schema.
--
-- This schema supports Holocene reference values, observed values,
-- paleoclimate archive metadata, anomalies, standardized departure,
-- boundary pressure, response capacity, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS holocene_reference_indicators (
    indicator_id INTEGER PRIMARY KEY,
    indicator_name TEXT NOT NULL UNIQUE,
    holocene_reference_value REAL NOT NULL,
    holocene_variability REAL NOT NULL,
    unit TEXT,
    archive_type TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS observed_indicators (
    observation_id INTEGER PRIMARY KEY,
    indicator_id INTEGER NOT NULL,
    observed_value REAL NOT NULL,
    observation_year INTEGER,
    scenario_name TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (indicator_id) REFERENCES holocene_reference_indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS boundary_context (
    boundary_context_id INTEGER PRIMARY KEY,
    indicator_id INTEGER NOT NULL,
    boundary_value REAL,
    interaction_weight REAL CHECK (interaction_weight >= 0 AND interaction_weight <= 1),
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    adaptive_capacity REAL CHECK (adaptive_capacity >= 0 AND adaptive_capacity <= 1),
    development_exposure REAL CHECK (development_exposure >= 0 AND development_exposure <= 1),
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (indicator_id) REFERENCES holocene_reference_indicators(indicator_id)
);

CREATE TABLE IF NOT EXISTS holocene_departure_scores (
    score_id INTEGER PRIMARY KEY,
    indicator_id INTEGER NOT NULL,
    holocene_anomaly REAL,
    standardized_departure REAL,
    boundary_pressure_ratio REAL,
    cross_system_amplification REAL,
    response_capacity REAL,
    holocene_departure_risk REAL,
    risk_class TEXT,
    priority TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (indicator_id) REFERENCES holocene_reference_indicators(indicator_id)
);
