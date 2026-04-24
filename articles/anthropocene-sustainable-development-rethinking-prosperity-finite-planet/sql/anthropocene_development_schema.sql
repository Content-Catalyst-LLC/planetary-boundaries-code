-- Anthropocene sustainable development schema.
--
-- This schema supports development scenarios, wellbeing, social foundations,
-- ecological pressure, planetary-boundary pressure, governance capacity,
-- justice capacity, resilience capacity, material efficiency, mitigation capacity,
-- restoration capacity, sustainable prosperity scores, transition urgency,
-- source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS development_scenarios (
    scenario_id INTEGER PRIMARY KEY,
    scenario_name TEXT NOT NULL UNIQUE,
    scenario_description TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS development_indicators (
    indicator_id INTEGER PRIMARY KEY,
    scenario_id INTEGER NOT NULL,
    wellbeing REAL CHECK (wellbeing >= 0 AND wellbeing <= 1),
    social_foundation REAL CHECK (social_foundation >= 0 AND social_foundation <= 1),
    ecological_pressure REAL CHECK (ecological_pressure >= 0 AND ecological_pressure <= 1),
    boundary_pressure REAL CHECK (boundary_pressure >= 0 AND boundary_pressure <= 1),
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (scenario_id) REFERENCES development_scenarios(scenario_id)
);

CREATE TABLE IF NOT EXISTS development_response_capacity (
    capacity_id INTEGER PRIMARY KEY,
    scenario_id INTEGER NOT NULL,
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    justice_capacity REAL CHECK (justice_capacity >= 0 AND justice_capacity <= 1),
    resilience_capacity REAL CHECK (resilience_capacity >= 0 AND resilience_capacity <= 1),
    material_efficiency REAL CHECK (material_efficiency >= 0 AND material_efficiency <= 1),
    mitigation_capacity REAL CHECK (mitigation_capacity >= 0 AND mitigation_capacity <= 1),
    restoration_capacity REAL CHECK (restoration_capacity >= 0 AND restoration_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (scenario_id) REFERENCES development_scenarios(scenario_id)
);

CREATE TABLE IF NOT EXISTS sustainable_prosperity_scores (
    score_id INTEGER PRIMARY KEY,
    scenario_id INTEGER NOT NULL,
    response_capacity REAL,
    boundary_adjusted_pressure REAL,
    sustainable_prosperity_score REAL,
    social_foundation_gap REAL,
    overshoot_gap REAL,
    transition_urgency REAL,
    development_class TEXT,
    priority TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (scenario_id) REFERENCES development_scenarios(scenario_id)
);
