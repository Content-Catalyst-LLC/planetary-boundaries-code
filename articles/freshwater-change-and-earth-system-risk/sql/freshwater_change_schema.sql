-- Freshwater change and hydrological-risk schema.
--
-- This schema supports streamflow observations, soil-moisture observations,
-- groundwater stress, wetland buffering, ecological sensitivity, exposure,
-- governance capacity, scenario runs, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS freshwater_regions (
    region_id INTEGER PRIMARY KEY,
    region_name TEXT NOT NULL UNIQUE,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS blue_water_observations (
    observation_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    streamflow_current REAL NOT NULL,
    streamflow_baseline REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (region_id) REFERENCES freshwater_regions(region_id)
);

CREATE TABLE IF NOT EXISTS green_water_observations (
    observation_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    soil_moisture_current REAL NOT NULL,
    soil_moisture_baseline REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (region_id) REFERENCES freshwater_regions(region_id)
);

CREATE TABLE IF NOT EXISTS hydrological_risk_factors (
    factor_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    groundwater_stress REAL CHECK (groundwater_stress >= 0 AND groundwater_stress <= 1),
    wetland_buffer_capacity REAL CHECK (wetland_buffer_capacity >= 0 AND wetland_buffer_capacity <= 1),
    ecological_sensitivity REAL CHECK (ecological_sensitivity >= 0 AND ecological_sensitivity <= 1),
    exposed_population_index REAL CHECK (exposed_population_index >= 0 AND exposed_population_index <= 1),
    food_system_dependence REAL CHECK (food_system_dependence >= 0 AND food_system_dependence <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES freshwater_regions(region_id)
);

CREATE TABLE IF NOT EXISTS freshwater_governance_capacity (
    governance_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    adaptive_capacity REAL CHECK (adaptive_capacity >= 0 AND adaptive_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES freshwater_regions(region_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    groundwater_multiplier REAL,
    wetland_gain REAL,
    soil_moisture_gain REAL,
    streamflow_rebalance REAL,
    governance_gain REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS freshwater_risk_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    blue_water_deviation REAL,
    green_water_deviation REAL,
    hydrological_boundary_pressure REAL,
    social_ecological_exposure REAL,
    freshwater_system_risk_score REAL,
    risk_class TEXT,
    priority TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (region_id) REFERENCES freshwater_regions(region_id)
);
