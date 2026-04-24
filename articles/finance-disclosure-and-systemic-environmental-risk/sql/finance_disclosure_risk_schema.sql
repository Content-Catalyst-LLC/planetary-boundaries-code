-- Finance, disclosure, and systemic environmental risk schema.
--
-- This schema supports issuers, holdings, boundary domains,
-- disclosure quality, transition credibility, source provenance,
-- scoring runs, and portfolio-level results.

CREATE TABLE IF NOT EXISTS issuers (
    issuer_id INTEGER PRIMARY KEY,
    issuer_name TEXT NOT NULL UNIQUE,
    sector TEXT,
    country TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS portfolios (
    portfolio_id INTEGER PRIMARY KEY,
    portfolio_name TEXT NOT NULL UNIQUE,
    owner_type TEXT,
    reporting_date TEXT
);

CREATE TABLE IF NOT EXISTS holdings (
    holding_id INTEGER PRIMARY KEY,
    portfolio_id INTEGER NOT NULL,
    issuer_id INTEGER NOT NULL,
    portfolio_weight REAL NOT NULL CHECK (portfolio_weight >= 0),
    FOREIGN KEY (portfolio_id) REFERENCES portfolios(portfolio_id),
    FOREIGN KEY (issuer_id) REFERENCES issuers(issuer_id)
);

CREATE TABLE IF NOT EXISTS boundary_domains (
    domain_id INTEGER PRIMARY KEY,
    domain_name TEXT NOT NULL UNIQUE,
    threshold_value REAL NOT NULL,
    domain_weight REAL NOT NULL,
    unit TEXT,
    rationale TEXT
);

CREATE TABLE IF NOT EXISTS issuer_domain_scores (
    score_id INTEGER PRIMARY KEY,
    issuer_id INTEGER NOT NULL,
    domain_id INTEGER NOT NULL,
    exposure_pressure REAL NOT NULL,
    disclosure_adequacy REAL CHECK (disclosure_adequacy >= 0 AND disclosure_adequacy <= 1),
    transition_credibility REAL CHECK (transition_credibility >= 0 AND transition_credibility <= 1),
    uncertainty REAL CHECK (uncertainty >= 0 AND uncertainty <= 1),
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (issuer_id) REFERENCES issuers(issuer_id),
    FOREIGN KEY (domain_id) REFERENCES boundary_domains(domain_id)
);

CREATE TABLE IF NOT EXISTS scoring_runs (
    run_id INTEGER PRIMARY KEY,
    run_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS portfolio_results (
    result_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    portfolio_id INTEGER NOT NULL,
    systemic_environmental_risk REAL NOT NULL,
    weighted_disclosure_adequacy REAL,
    weighted_transition_credibility REAL,
    FOREIGN KEY (run_id) REFERENCES scoring_runs(run_id),
    FOREIGN KEY (portfolio_id) REFERENCES portfolios(portfolio_id)
);
