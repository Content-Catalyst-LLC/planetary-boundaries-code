# How Planetary Boundaries Are Measured

This article folder supports the Planetary Boundaries knowledge-series article on measurement, control variables, thresholds, uncertainty, risk zones, and planetary-boundary monitoring.

The article body includes Python and R workflows for readability and reproducible analytics. This repository extends the implementation into a broader engineering scaffold for auditability, APIs, systems programming, embedded monitoring, TinyML, and PYNQ-oriented edge workflows.

## Structure

- `python/` — control-variable and risk-zone scoring
- `r/` — boundary-measurement dashboarding
- `sql/` — schema for boundary processes, control variables, observations, uncertainty, and audit trails
- `rust/` — reliable measurement scoring-core scaffold
- `go/` — lightweight diagnostic API scaffold
- `c/` — embedded-style boundary threshold alert scaffold
- `cpp/` — measurement scenario simulation scaffold
- `tinyml/` — edge anomaly detection scaffold
- `pynq/` — accelerator-oriented monitoring scaffold
- `docs/` — methodological and engineering notes
- `data/raw/` — raw input data
- `data/processed/` — cleaned and transformed data
- `outputs/` — exported diagnostic scores and dashboard-ready files

## Methodological Note

The sample workflows use illustrative data. Replace placeholder values with documented control variables, observed values, boundary values, uncertainty estimates, monitoring systems, and transparent measurement assumptions before applied use.
