-- Great Acceleration schema.
--
-- This schema supports socio-economic indicators, Earth-system indicators,
-- observations, acceleration rates, coupling coefficients, boundary pressure,
-- governance capacity, justice capacity, mitigation capacity, restoration capacity,
-- lock-in pressure, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS socioeconomic_indicators (
    socioeconomic_indicator_id INTEGER PRIMARY KEY,
    indicator_name TEXT NOT NULL UNIQUE,
    indicator_description TEXT,
    unit TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS earth_system_indicators (
    earth_system_indicator_id INTEGER PRIMARY KEY,
    indicator_name TEXT NOT NULL UNIQUE,
    boundary_process TEXT,
    indicator_description TEXT,
    unit TEXT,
    boundary_value REAL,
    source_name TEXT,
    source_url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS annual_observations (
    observation_id INTEGER PRIMARY KEY,
    indicator_type TEXT CHECK (indicator_type IN ('socioeconomic', 'earth_system')),
    indicator_id INTEGER NOT NULL,
    observation_year INTEGER NOT NULL,
    observed_value REAL NOT NULL,
    source_name TEXT,
    source_url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS coupled_indicator_pairs (
    pair_id INTEGER PRIMARY KEY,
    socioeconomic_indicator_id INTEGER NOT NULL,
    earth_system_indicator_id INTEGER NOT NULL,
    coupling_strength REAL CHECK (coupling_strength >= 0 AND coupling_strength <= 1),
    coupling_description TEXT,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (socioeconomic_indicator_id) REFERENCES socioeconomic_indicators(socioeconomic_indicator_id),
    FOREIGN KEY (earth_system_indicator_id) REFERENCES earth_system_indicators(earth_system_indicator_id)
);

CREATE TABLE IF NOT EXISTS acceleration_risk_scores (
    score_id INTEGER PRIMARY KEY,
    pair_id INTEGER NOT NULL,
    human_activity_pressure REAL,
    earth_system_stress REAL,
    response_capacity REAL,
    coupled_acceleration_risk REAL,
    transformation_urgency REAL,
    risk_class TEXT,
    priority TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pair_id) REFERENCES coupled_indicator_pairs(pair_id)
);
