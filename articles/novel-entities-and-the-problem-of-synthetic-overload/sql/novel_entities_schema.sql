-- Novel entities and synthetic overload schema.
--
-- This schema supports entity classes, substances, production,
-- releases, persistence, mobility, hazard, exposure, monitoring,
-- assessment status, substitution feasibility, essentiality,
-- scoring runs, and audit trails.

CREATE TABLE IF NOT EXISTS entity_classes (
    entity_class_id INTEGER PRIMARY KEY,
    entity_class_name TEXT NOT NULL UNIQUE,
    description TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS substances (
    substance_id INTEGER PRIMARY KEY,
    entity_class_id INTEGER NOT NULL,
    substance_name TEXT NOT NULL,
    cas_number TEXT,
    product_or_use_category TEXT,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (entity_class_id) REFERENCES entity_classes(entity_class_id)
);

CREATE TABLE IF NOT EXISTS production_release_profiles (
    profile_id INTEGER PRIMARY KEY,
    entity_class_id INTEGER NOT NULL,
    annual_production_index REAL NOT NULL,
    environmental_release_fraction REAL NOT NULL,
    observation_year INTEGER,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (entity_class_id) REFERENCES entity_classes(entity_class_id)
);

CREATE TABLE IF NOT EXISTS risk_properties (
    property_id INTEGER PRIMARY KEY,
    entity_class_id INTEGER NOT NULL,
    persistence REAL CHECK (persistence >= 0 AND persistence <= 1),
    mobility REAL CHECK (mobility >= 0 AND mobility <= 1),
    hazard REAL CHECK (hazard >= 0 AND hazard <= 1),
    exposure REAL CHECK (exposure >= 0 AND exposure <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (entity_class_id) REFERENCES entity_classes(entity_class_id)
);

CREATE TABLE IF NOT EXISTS governance_capacity (
    capacity_id INTEGER PRIMARY KEY,
    entity_class_id INTEGER NOT NULL,
    monitoring_coverage REAL CHECK (monitoring_coverage >= 0 AND monitoring_coverage <= 1),
    assessment_status TEXT CHECK (
        assessment_status IN (
            'adequately_assessed',
            'partially_assessed',
            'poorly_assessed',
            'not_assessed'
        )
    ),
    substitution_feasibility REAL CHECK (substitution_feasibility >= 0 AND substitution_feasibility <= 1),
    essentiality REAL CHECK (essentiality >= 0 AND essentiality <= 1),
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (entity_class_id) REFERENCES entity_classes(entity_class_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS synthetic_overload_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    entity_class_id INTEGER NOT NULL,
    release_index REAL,
    intrinsic_risk REAL,
    assessment_gap REAL,
    monitoring_gap REAL,
    governance_gap REAL,
    essential_use_pressure REAL,
    synthetic_overload_score REAL,
    priority_class TEXT,
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (entity_class_id) REFERENCES entity_classes(entity_class_id)
);
