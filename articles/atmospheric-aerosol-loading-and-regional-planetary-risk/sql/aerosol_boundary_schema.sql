-- Atmospheric aerosol loading and regional planetary-risk schema.
--
-- This schema supports regional aerosol indicators, exposure metrics,
-- composition profiles, governance capacity, scenario runs,
-- source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS regions (
    region_id INTEGER PRIMARY KEY,
    region_name TEXT NOT NULL UNIQUE,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS aerosol_observations (
    observation_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    aerosol_optical_depth REAL,
    regional_boundary_reference REAL,
    pm25_exposure REAL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

CREATE TABLE IF NOT EXISTS aerosol_composition (
    composition_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    black_carbon_share REAL CHECK (black_carbon_share >= 0 AND black_carbon_share <= 1),
    sulfate_share REAL CHECK (sulfate_share >= 0 AND sulfate_share <= 1),
    dust_share REAL CHECK (dust_share >= 0 AND dust_share <= 1),
    organic_carbon_share REAL,
    nitrate_ammonium_share REAL,
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

CREATE TABLE IF NOT EXISTS exposure_vulnerability (
    exposure_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    exposed_population_index REAL CHECK (exposed_population_index >= 0 AND exposed_population_index <= 1),
    vulnerability_index REAL CHECK (vulnerability_index >= 0 AND vulnerability_index <= 1),
    hydrological_sensitivity REAL CHECK (hydrological_sensitivity >= 0 AND hydrological_sensitivity <= 1),
    cloud_uncertainty REAL CHECK (cloud_uncertainty >= 0 AND cloud_uncertainty <= 1),
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    aod_multiplier REAL,
    pm25_multiplier REAL,
    black_carbon_multiplier REAL,
    governance_gain REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS regional_aerosol_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    aod_pressure_ratio REAL,
    composition_weight REAL,
    health_exposure_score REAL,
    climate_hydrology_score REAL,
    governance_gap REAL,
    regional_planetary_risk_score REAL,
    risk_class TEXT,
    dominant_driver TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);
