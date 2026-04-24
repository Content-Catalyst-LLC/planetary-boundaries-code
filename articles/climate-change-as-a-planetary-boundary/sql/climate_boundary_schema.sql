-- Climate change planetary-boundary schema.
--
-- This schema supports atmospheric CO2 observations, radiative forcing,
-- emissions pressure, mitigation capacity, carbon sink resilience,
-- cross-boundary stress, exposure, adaptive capacity, governance capacity,
-- scenario runs, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS climate_systems (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL UNIQUE,
    system_type TEXT,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS atmospheric_observations (
    observation_id INTEGER PRIMARY KEY,
    system_id INTEGER NOT NULL,
    co2_concentration_ppm REAL NOT NULL,
    co2_boundary_ppm REAL NOT NULL,
    co2_baseline_ppm REAL NOT NULL,
    forcing_boundary_wm2 REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (system_id) REFERENCES climate_systems(system_id)
);

CREATE TABLE IF NOT EXISTS emissions_transition_indicators (
    indicator_id INTEGER PRIMARY KEY,
    system_id INTEGER NOT NULL,
    gross_emissions_pressure REAL CHECK (gross_emissions_pressure >= 0 AND gross_emissions_pressure <= 1),
    mitigation_capacity REAL CHECK (mitigation_capacity >= 0 AND mitigation_capacity <= 1),
    carbon_sink_resilience REAL CHECK (carbon_sink_resilience >= 0 AND carbon_sink_resilience <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (system_id) REFERENCES climate_systems(system_id)
);

CREATE TABLE IF NOT EXISTS cross_boundary_climate_pressures (
    pressure_id INTEGER PRIMARY KEY,
    system_id INTEGER NOT NULL,
    biosphere_stress REAL CHECK (biosphere_stress >= 0 AND biosphere_stress <= 1),
    land_system_pressure REAL CHECK (land_system_pressure >= 0 AND land_system_pressure <= 1),
    freshwater_stress REAL CHECK (freshwater_stress >= 0 AND freshwater_stress <= 1),
    ocean_stress REAL CHECK (ocean_stress >= 0 AND ocean_stress <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (system_id) REFERENCES climate_systems(system_id)
);

CREATE TABLE IF NOT EXISTS climate_exposure_capacity (
    capacity_id INTEGER PRIMARY KEY,
    system_id INTEGER NOT NULL,
    heat_extreme_exposure REAL CHECK (heat_extreme_exposure >= 0 AND heat_extreme_exposure <= 1),
    infrastructure_exposure REAL CHECK (infrastructure_exposure >= 0 AND infrastructure_exposure <= 1),
    adaptive_capacity REAL CHECK (adaptive_capacity >= 0 AND adaptive_capacity <= 1),
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (system_id) REFERENCES climate_systems(system_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    emissions_multiplier REAL,
    mitigation_gain REAL,
    sink_gain REAL,
    adaptive_gain REAL,
    governance_gain REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS climate_boundary_risk_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    system_id INTEGER NOT NULL,
    co2_boundary_pressure REAL,
    co2_radiative_forcing_wm2 REAL,
    forcing_boundary_pressure REAL,
    cross_boundary_stress REAL,
    exposure_pressure REAL,
    transition_gap REAL,
    climate_boundary_risk_score REAL,
    risk_class TEXT,
    priority TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (system_id) REFERENCES climate_systems(system_id)
);
