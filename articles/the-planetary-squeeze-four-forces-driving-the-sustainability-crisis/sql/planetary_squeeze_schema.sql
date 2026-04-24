-- Planetary squeeze schema.
--
-- This schema supports scenario definitions, four-force pressure indicators,
-- boundary pressure, governance capacity, adaptive capacity, justice capacity,
-- mitigation capacity, restoration capacity, material efficiency, scenario outputs,
-- source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS squeeze_scenarios (
    scenario_id INTEGER PRIMARY KEY,
    scenario_name TEXT NOT NULL UNIQUE,
    scenario_description TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS squeeze_pressures (
    pressure_id INTEGER PRIMARY KEY,
    scenario_id INTEGER NOT NULL,
    population_pressure REAL CHECK (population_pressure >= 0 AND population_pressure <= 1),
    affluence_pressure REAL CHECK (affluence_pressure >= 0 AND affluence_pressure <= 1),
    climate_stress REAL CHECK (climate_stress >= 0 AND climate_stress <= 1),
    ecosystem_degradation REAL CHECK (ecosystem_degradation >= 0 AND ecosystem_degradation <= 1),
    boundary_pressure REAL CHECK (boundary_pressure >= 0 AND boundary_pressure <= 1),
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (scenario_id) REFERENCES squeeze_scenarios(scenario_id)
);

CREATE TABLE IF NOT EXISTS squeeze_response_capacity (
    capacity_id INTEGER PRIMARY KEY,
    scenario_id INTEGER NOT NULL,
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    adaptive_capacity REAL CHECK (adaptive_capacity >= 0 AND adaptive_capacity <= 1),
    justice_capacity REAL CHECK (justice_capacity >= 0 AND justice_capacity <= 1),
    mitigation_capacity REAL CHECK (mitigation_capacity >= 0 AND mitigation_capacity <= 1),
    restoration_capacity REAL CHECK (restoration_capacity >= 0 AND restoration_capacity <= 1),
    material_efficiency REAL CHECK (material_efficiency >= 0 AND material_efficiency <= 1),
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (scenario_id) REFERENCES squeeze_scenarios(scenario_id)
);

CREATE TABLE IF NOT EXISTS planetary_squeeze_scores (
    score_id INTEGER PRIMARY KEY,
    scenario_id INTEGER NOT NULL,
    core_squeeze_pressure REAL,
    interaction_amplification REAL,
    response_capacity REAL,
    planetary_squeeze_risk REAL,
    transformation_urgency REAL,
    risk_class TEXT,
    priority TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (scenario_id) REFERENCES squeeze_scenarios(scenario_id)
);
