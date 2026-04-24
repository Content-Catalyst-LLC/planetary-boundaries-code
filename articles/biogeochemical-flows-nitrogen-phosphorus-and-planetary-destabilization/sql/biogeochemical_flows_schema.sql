-- Biogeochemical flows and nutrient-boundary schema.
--
-- This schema supports nutrient inputs, nutrient uptake, boundary references,
-- runoff sensitivity, hydrological connectivity, ecosystem sensitivity,
-- legacy nutrient pressure, governance capacity, scenario runs,
-- source provenance, and audit trails.

CREATE TABLE IF NOT EXISTS nutrient_regions (
    region_id INTEGER PRIMARY KEY,
    region_name TEXT NOT NULL UNIQUE,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS nutrient_accounts (
    account_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    nitrogen_input REAL NOT NULL,
    nitrogen_uptake REAL NOT NULL,
    phosphorus_input REAL NOT NULL,
    phosphorus_uptake REAL NOT NULL,
    nitrogen_boundary_reference REAL NOT NULL,
    phosphorus_boundary_reference REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (region_id) REFERENCES nutrient_regions(region_id)
);

CREATE TABLE IF NOT EXISTS watershed_risk_factors (
    factor_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    runoff_sensitivity REAL CHECK (runoff_sensitivity >= 0 AND runoff_sensitivity <= 1),
    hydrological_connectivity REAL CHECK (hydrological_connectivity >= 0 AND hydrological_connectivity <= 1),
    ecosystem_sensitivity REAL CHECK (ecosystem_sensitivity >= 0 AND ecosystem_sensitivity <= 1),
    legacy_nutrient_pressure REAL CHECK (legacy_nutrient_pressure >= 0 AND legacy_nutrient_pressure <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES nutrient_regions(region_id)
);

CREATE TABLE IF NOT EXISTS nutrient_governance_capacity (
    governance_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES nutrient_regions(region_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    input_multiplier REAL,
    uptake_gain REAL,
    runoff_multiplier REAL,
    legacy_multiplier REAL,
    governance_gain REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS nutrient_risk_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    nitrogen_surplus REAL,
    phosphorus_surplus REAL,
    nitrogen_use_efficiency REAL,
    phosphorus_use_efficiency REAL,
    nitrogen_boundary_pressure REAL,
    phosphorus_boundary_pressure REAL,
    nutrient_loss_pressure REAL,
    eutrophication_pressure REAL,
    legacy_adjusted_pressure REAL,
    planetary_nutrient_risk_score REAL,
    risk_class TEXT,
    priority TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (region_id) REFERENCES nutrient_regions(region_id)
);
