-- Biosphere integrity and life-system-risk schema.
--
-- This schema supports extinction pressure, functional integrity,
-- habitat intactness, fragmentation, appropriation pressure,
-- cross-boundary stress, restoration potential, governance capacity,
-- scenario runs, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS biosphere_regions (
    region_id INTEGER PRIMARY KEY,
    region_name TEXT NOT NULL UNIQUE,
    biome_type TEXT,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS genetic_diversity_indicators (
    indicator_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    observed_extinction_pressure REAL NOT NULL,
    genetic_boundary_reference REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (region_id) REFERENCES biosphere_regions(region_id)
);

CREATE TABLE IF NOT EXISTS functional_integrity_indicators (
    indicator_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    functional_integrity_index REAL CHECK (functional_integrity_index >= 0 AND functional_integrity_index <= 1),
    functional_integrity_threshold REAL CHECK (functional_integrity_threshold >= 0 AND functional_integrity_threshold <= 1),
    habitat_intactness REAL CHECK (habitat_intactness >= 0 AND habitat_intactness <= 1),
    fragmentation_risk REAL CHECK (fragmentation_risk >= 0 AND fragmentation_risk <= 1),
    appropriation_pressure REAL CHECK (appropriation_pressure >= 0 AND appropriation_pressure <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES biosphere_regions(region_id)
);

CREATE TABLE IF NOT EXISTS cross_boundary_pressures (
    pressure_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    climate_stress REAL CHECK (climate_stress >= 0 AND climate_stress <= 1),
    land_system_pressure REAL CHECK (land_system_pressure >= 0 AND land_system_pressure <= 1),
    freshwater_stress REAL CHECK (freshwater_stress >= 0 AND freshwater_stress <= 1),
    nutrient_pollution_pressure REAL CHECK (nutrient_pollution_pressure >= 0 AND nutrient_pollution_pressure <= 1),
    novel_entity_pressure REAL CHECK (novel_entity_pressure >= 0 AND novel_entity_pressure <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES biosphere_regions(region_id)
);

CREATE TABLE IF NOT EXISTS biosphere_governance_capacity (
    governance_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    restoration_potential REAL CHECK (restoration_potential >= 0 AND restoration_potential <= 1),
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES biosphere_regions(region_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    extinction_multiplier REAL,
    functional_gain REAL,
    intactness_gain REAL,
    fragmentation_multiplier REAL,
    appropriation_multiplier REAL,
    governance_gain REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS biosphere_integrity_risk_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    genetic_diversity_pressure REAL,
    functional_integrity_deficit REAL,
    habitat_loss_pressure REAL,
    cross_boundary_stress REAL,
    biosphere_pressure REAL,
    biosphere_integrity_risk_score REAL,
    risk_class TEXT,
    priority TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (region_id) REFERENCES biosphere_regions(region_id)
);
