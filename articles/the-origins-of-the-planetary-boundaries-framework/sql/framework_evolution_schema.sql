-- Planetary boundaries framework evolution schema.
--
-- This schema supports framework milestones, source documents, conceptual lineages,
-- boundary revisions, citation records, policy uptake, governance references,
-- justice critiques, uncertainty notes, and audit trails.

CREATE TABLE IF NOT EXISTS framework_milestones (
    milestone_id INTEGER PRIMARY KEY,
    milestone_year INTEGER NOT NULL,
    milestone_name TEXT NOT NULL,
    domain TEXT,
    description TEXT,
    source_name TEXT,
    source_url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS source_documents (
    document_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    authors TEXT,
    publication_year INTEGER,
    publication_type TEXT,
    journal_or_institution TEXT,
    doi TEXT,
    url TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS conceptual_lineages (
    lineage_id INTEGER PRIMARY KEY,
    concept_name TEXT NOT NULL,
    source_discipline TEXT,
    description TEXT,
    related_document_id INTEGER,
    FOREIGN KEY (related_document_id) REFERENCES source_documents(document_id)
);

CREATE TABLE IF NOT EXISTS framework_scores (
    score_id INTEGER PRIMARY KEY,
    milestone_id INTEGER NOT NULL,
    conceptual_integration REAL CHECK (conceptual_integration >= 0 AND conceptual_integration <= 1),
    measurement_refinement REAL CHECK (measurement_refinement >= 0 AND measurement_refinement <= 1),
    governance_relevance REAL CHECK (governance_relevance >= 0 AND governance_relevance <= 1),
    policy_visibility REAL CHECK (policy_visibility >= 0 AND policy_visibility <= 1),
    public_legibility REAL CHECK (public_legibility >= 0 AND public_legibility <= 1),
    justice_integration REAL CHECK (justice_integration >= 0 AND justice_integration <= 1),
    uncertainty_treatment REAL CHECK (uncertainty_treatment >= 0 AND uncertainty_treatment <= 1),
    cross_boundary_logic REAL CHECK (cross_boundary_logic >= 0 AND cross_boundary_logic <= 1),
    scoring_notes TEXT,
    FOREIGN KEY (milestone_id) REFERENCES framework_milestones(milestone_id)
);

CREATE TABLE IF NOT EXISTS governance_uptake (
    uptake_id INTEGER PRIMARY KEY,
    milestone_id INTEGER NOT NULL,
    institution_name TEXT,
    sector TEXT,
    uptake_type TEXT,
    policy_or_document_url TEXT,
    notes TEXT,
    FOREIGN KEY (milestone_id) REFERENCES framework_milestones(milestone_id)
);

CREATE TABLE IF NOT EXISTS critique_and_revision_notes (
    critique_id INTEGER PRIMARY KEY,
    milestone_id INTEGER NOT NULL,
    critique_theme TEXT,
    critique_description TEXT,
    revision_response TEXT,
    source_name TEXT,
    source_url TEXT,
    FOREIGN KEY (milestone_id) REFERENCES framework_milestones(milestone_id)
);
