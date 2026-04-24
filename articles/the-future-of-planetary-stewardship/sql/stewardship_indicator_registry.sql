CREATE TABLE stewardship_indicator_registry (
    record_id VARCHAR(100) PRIMARY KEY,
    territory_name VARCHAR(255) NOT NULL,
    country_or_region VARCHAR(255) NOT NULL,
    territory_type VARCHAR(100) NOT NULL,
    governance_coherence_index DECIMAL(10,4),
    justice_legitimacy_index DECIMAL(10,4),
    restoration_regeneration_index DECIMAL(10,4),
    boundary_pressure_index DECIMAL(10,4),
    urban_transformation_index DECIMAL(10,4),
    community_stewardship_index DECIMAL(10,4),
    reporting_year INTEGER NOT NULL
);
