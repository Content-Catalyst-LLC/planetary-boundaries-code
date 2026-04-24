-- Stratospheric ozone depletion and global environmental governance schema.
--
-- This schema supports ozone monitoring regions, ozone measurements,
-- boundary references, ozone-depleting-substance loading, governance
-- variables, scenario runs, source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS monitoring_regions (
    region_id INTEGER PRIMARY KEY,
    region_name TEXT NOT NULL UNIQUE,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS ozone_observations (
    observation_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    ozone_du REAL NOT NULL,
    boundary_du REAL NOT NULL,
    preindustrial_reference_du REAL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (region_id) REFERENCES monitoring_regions(region_id)
);

CREATE TABLE IF NOT EXISTS ods_pressure_profiles (
    ods_profile_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    ods_loading_index REAL CHECK (ods_loading_index >= 0 AND ods_loading_index <= 1),
    emissions_pressure REAL CHECK (emissions_pressure >= 0 AND emissions_pressure <= 1),
    atmospheric_lifetime_pressure REAL CHECK (atmospheric_lifetime_pressure >= 0 AND atmospheric_lifetime_pressure <= 1),
    illegal_emissions_risk REAL CHECK (illegal_emissions_risk >= 0 AND illegal_emissions_risk <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES monitoring_regions(region_id)
);

CREATE TABLE IF NOT EXISTS governance_capacity (
    governance_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    treaty_compliance REAL CHECK (treaty_compliance >= 0 AND treaty_compliance <= 1),
    substitution_progress REAL CHECK (substitution_progress >= 0 AND substitution_progress <= 1),
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    implementation_support REAL CHECK (implementation_support >= 0 AND implementation_support <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES monitoring_regions(region_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    compliance_delta REAL,
    monitoring_delta REAL,
    substitution_delta REAL,
    illegal_emissions_multiplier REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS ozone_recovery_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    boundary_margin REAL,
    recovery_gap REAL,
    governance_effectiveness REAL,
    residual_pressure REAL,
    recovery_resilience_score REAL,
    status TEXT,
    priority TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (region_id) REFERENCES monitoring_regions(region_id)
);
