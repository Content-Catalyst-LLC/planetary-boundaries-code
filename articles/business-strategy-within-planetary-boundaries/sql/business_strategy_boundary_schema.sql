-- Business strategy within planetary boundaries schema.
--
-- This schema supports business units, boundary domains,
-- allocation assumptions, transition capability, supply-chain transparency,
-- scoring runs, and strategic fragility outputs.

CREATE TABLE IF NOT EXISTS business_units (
    business_unit_id INTEGER PRIMARY KEY,
    business_unit_name TEXT NOT NULL UNIQUE,
    sector TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS boundary_domains (
    domain_id INTEGER PRIMARY KEY,
    domain_name TEXT NOT NULL UNIQUE,
    domain_weight REAL NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS allocation_assumptions (
    allocation_id INTEGER PRIMARY KEY,
    domain_id INTEGER NOT NULL,
    allocation_method TEXT NOT NULL,
    allocated_budget REAL NOT NULL,
    source_name TEXT,
    source_url TEXT,
    notes TEXT,
    FOREIGN KEY (domain_id) REFERENCES boundary_domains(domain_id)
);

CREATE TABLE IF NOT EXISTS business_unit_impacts (
    impact_id INTEGER PRIMARY KEY,
    business_unit_id INTEGER NOT NULL,
    domain_id INTEGER NOT NULL,
    absolute_impact REAL NOT NULL,
    revenue_share REAL NOT NULL,
    transition_capability REAL CHECK (transition_capability >= 0 AND transition_capability <= 1),
    overshoot_dependency REAL CHECK (overshoot_dependency >= 0 AND overshoot_dependency <= 1),
    supply_chain_transparency REAL CHECK (supply_chain_transparency >= 0 AND supply_chain_transparency <= 1),
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (business_unit_id) REFERENCES business_units(business_unit_id),
    FOREIGN KEY (domain_id) REFERENCES boundary_domains(domain_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS strategy_scores (
    score_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    business_unit_id INTEGER NOT NULL,
    alignment_ratio REAL NOT NULL,
    boundary_pressure REAL NOT NULL,
    strategic_fragility REAL NOT NULL,
    revenue_weighted_fragility REAL NOT NULL,
    strategic_class TEXT,
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (business_unit_id) REFERENCES business_units(business_unit_id)
);
