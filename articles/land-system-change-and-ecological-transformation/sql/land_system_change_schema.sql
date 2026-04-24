-- Land-system change and biome-risk schema.
--
-- This schema supports biome records, forest-cover observations,
-- boundary thresholds, fragmentation indicators, ecological quality,
-- land-conversion pressure, climate stress, hydrological disruption,
-- regulatory importance, restoration potential, governance capacity,
-- scenario runs, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS land_biomes (
    biome_id INTEGER PRIMARY KEY,
    biome_name TEXT NOT NULL UNIQUE,
    biome_type TEXT,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS forest_cover_observations (
    observation_id INTEGER PRIMARY KEY,
    biome_id INTEGER NOT NULL,
    remaining_forest_ratio REAL NOT NULL,
    biome_boundary_threshold REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (biome_id) REFERENCES land_biomes(biome_id)
);

CREATE TABLE IF NOT EXISTS land_system_risk_factors (
    factor_id INTEGER PRIMARY KEY,
    biome_id INTEGER NOT NULL,
    fragmentation_risk REAL CHECK (fragmentation_risk >= 0 AND fragmentation_risk <= 1),
    ecological_quality REAL CHECK (ecological_quality >= 0 AND ecological_quality <= 1),
    land_conversion_pressure REAL CHECK (land_conversion_pressure >= 0 AND land_conversion_pressure <= 1),
    climate_stress REAL CHECK (climate_stress >= 0 AND climate_stress <= 1),
    hydrological_disruption REAL CHECK (hydrological_disruption >= 0 AND hydrological_disruption <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (biome_id) REFERENCES land_biomes(biome_id)
);

CREATE TABLE IF NOT EXISTS land_regulatory_functions (
    function_id INTEGER PRIMARY KEY,
    biome_id INTEGER NOT NULL,
    carbon_storage_importance REAL CHECK (carbon_storage_importance >= 0 AND carbon_storage_importance <= 1),
    moisture_recycling_importance REAL CHECK (moisture_recycling_importance >= 0 AND moisture_recycling_importance <= 1),
    biodiversity_sensitivity REAL CHECK (biodiversity_sensitivity >= 0 AND biodiversity_sensitivity <= 1),
    restoration_potential REAL CHECK (restoration_potential >= 0 AND restoration_potential <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (biome_id) REFERENCES land_biomes(biome_id)
);

CREATE TABLE IF NOT EXISTS land_governance_capacity (
    governance_id INTEGER PRIMARY KEY,
    biome_id INTEGER NOT NULL,
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (biome_id) REFERENCES land_biomes(biome_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    conversion_multiplier REAL,
    fragmentation_multiplier REAL,
    forest_gain REAL,
    quality_gain REAL,
    governance_gain REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS land_system_risk_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    biome_id INTEGER NOT NULL,
    forest_boundary_pressure REAL,
    forest_boundary_deficit REAL,
    biome_integrity_index REAL,
    regulatory_importance REAL,
    land_system_pressure REAL,
    land_system_risk_score REAL,
    risk_class TEXT,
    priority TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (biome_id) REFERENCES land_biomes(biome_id)
);
