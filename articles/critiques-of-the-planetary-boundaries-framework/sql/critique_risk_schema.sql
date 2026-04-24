-- Critique-aware planetary boundaries schema.
--
-- This schema stores cases, critique domains, assumptions,
-- provenance, scoring runs, and results.

CREATE TABLE IF NOT EXISTS cases (
    case_id INTEGER PRIMARY KEY,
    case_name TEXT NOT NULL UNIQUE,
    case_type TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS critique_domains (
    domain_id INTEGER PRIMARY KEY,
    domain_name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS domain_scores (
    score_id INTEGER PRIMARY KEY,
    case_id INTEGER NOT NULL,
    domain_id INTEGER NOT NULL,
    risk_score REAL NOT NULL CHECK (risk_score >= 0 AND risk_score <= 1),
    scoring_method TEXT,
    source_name TEXT,
    source_url TEXT,
    uncertainty_note TEXT,
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    FOREIGN KEY (domain_id) REFERENCES critique_domains(domain_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS domain_weights (
    run_id INTEGER NOT NULL,
    domain_id INTEGER NOT NULL,
    weight REAL NOT NULL CHECK (weight >= 0),
    PRIMARY KEY (run_id, domain_id),
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (domain_id) REFERENCES critique_domains(domain_id)
);

CREATE TABLE IF NOT EXISTS aggregate_results (
    result_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    case_id INTEGER NOT NULL,
    total_critique_risk REAL NOT NULL,
    risk_class TEXT,
    dominant_risk_domain TEXT,
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (case_id) REFERENCES cases(case_id)
);
