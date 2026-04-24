-- Ocean acidification and carbonate-risk schema.
--
-- This schema supports ocean regions, carbonate chemistry observations,
-- aragonite saturation states, ecological sensitivity, multi-stressor
-- indicators, governance capacity, scenario runs, source provenance,
-- and audit trails.

CREATE TABLE IF NOT EXISTS ocean_regions (
    region_id INTEGER PRIMARY KEY,
    region_name TEXT NOT NULL UNIQUE,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS carbonate_observations (
    observation_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    current_ph REAL NOT NULL,
    preindustrial_ph REAL,
    carbonate_ion_index REAL CHECK (carbonate_ion_index >= 0 AND carbonate_ion_index <= 1),
    aragonite_saturation_state REAL,
    preindustrial_aragonite_state REAL,
    boundary_aragonite_state REAL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (region_id) REFERENCES ocean_regions(region_id)
);

CREATE TABLE IF NOT EXISTS ecosystem_vulnerability (
    vulnerability_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    ecological_sensitivity REAL CHECK (ecological_sensitivity >= 0 AND ecological_sensitivity <= 1),
    exposure REAL CHECK (exposure >= 0 AND exposure <= 1),
    adaptive_capacity REAL CHECK (adaptive_capacity >= 0 AND adaptive_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES ocean_regions(region_id)
);

CREATE TABLE IF NOT EXISTS marine_multistressors (
    stressor_id INTEGER PRIMARY KEY,
    region_id INTEGER NOT NULL,
    warming_stress REAL CHECK (warming_stress >= 0 AND warming_stress <= 1),
    deoxygenation_stress REAL CHECK (deoxygenation_stress >= 0 AND deoxygenation_stress <= 1),
    nutrient_stress REAL CHECK (nutrient_stress >= 0 AND nutrient_stress <= 1),
    monitoring_capacity REAL CHECK (monitoring_capacity >= 0 AND monitoring_capacity <= 1),
    governance_capacity REAL CHECK (governance_capacity >= 0 AND governance_capacity <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (region_id) REFERENCES ocean_regions(region_id)
);

CREATE TABLE IF NOT EXISTS scenario_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    aragonite_gain REAL,
    nutrient_multiplier REAL,
    monitoring_gain REAL,
    governance_gain REAL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS acidification_risk_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    ph_decline REAL,
    hydrogen_ion_increase_index REAL,
    aragonite_boundary_pressure REAL,
    carbonate_deficit REAL,
    ecosystem_vulnerability REAL,
    multi_stressor_pressure REAL,
    marine_chemistry_risk_score REAL,
    risk_class TEXT,
    priority TEXT,
    FOREIGN KEY (run_id) REFERENCES scenario_runs(run_id),
    FOREIGN KEY (region_id) REFERENCES ocean_regions(region_id)
);
