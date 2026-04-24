-- Anthropocene 3-6-9 risk schema.
--
-- This schema supports scenario definitions, climate pressure, biosphere pressure,
-- development demand, boundary transgression, governance capacity, adaptive capacity,
-- justice capacity, mitigation capacity, restoration capacity, institutional learning,
-- scenario outputs, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS anthropocene_scenarios (
    scenario_id INTEGER PRIMARY KEY,
    scenario_name TEXT NOT NULL UNIQUE,
    scenario_description TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS scenario_pressures (
    pressure_id INTEGER PRIMARY KEY,
    scenario_id INTEGER NOT NULL,
    warming_pressure REAL CHECK (warming_pressure >= 0 AND warming_pressure <= 1),
    biosphere_pressure REAL CHECK (biosphere_pressure >= 0 AND biosphere_pressure <= 1),
    development_demand REAL CHECK (development_demand >= 0 AND development_demand <= 1),
    boundary_transgression_count INTEGER CHECK (boundary_transgression_count >= 0 AND boundary_transgression_count <= 9),
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (scenario_id) REFERENCES anthropocene_scenarios(scenario_id)
);

CREATE TABLE IF NOT EXISTS governance_capacity (
    capacity_id INTEGER PRIMARY KEY,
    scenario_id INTEGER NOT NULL,
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    adaptive_capacity REAL CHECK (adaptive_capacity >= 0 AND adaptive_capacity <= 1),
    justice_capacity REAL CHECK (justice_capacity >= 0 AND justice_capacity <= 1),
    mitigation_capacity REAL CHECK (mitigation_capacity >= 0 AND mitigation_capacity <= 1),
    restoration_capacity REAL CHECK (restoration_capacity >= 0 AND restoration_capacity <= 1),
    institutional_learning REAL CHECK (institutional_learning >= 0 AND institutional_learning <= 1),
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (scenario_id) REFERENCES anthropocene_scenarios(scenario_id)
);

CREATE TABLE IF NOT EXISTS anthropocene_risk_scores (
    score_id INTEGER PRIMARY KEY,
    scenario_id INTEGER NOT NULL,
    core_369_pressure REAL,
    cross_pressure_amplification REAL,
    governance_resilience_capacity REAL,
    anthropocene_risk_score REAL,
    transformation_urgency REAL,
    risk_class TEXT,
    priority TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (scenario_id) REFERENCES anthropocene_scenarios(scenario_id)
);
