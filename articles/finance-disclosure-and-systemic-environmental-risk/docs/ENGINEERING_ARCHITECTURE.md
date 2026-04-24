# Engineering Architecture

This repository treats finance, disclosure, and systemic environmental risk as a data-infrastructure problem.

## Data layer

The SQL schema defines:

- issuers
- portfolios
- holdings
- boundary domains
- issuer-domain scores
- scoring runs
- portfolio results

This supports provenance, transparency, and auditability.

## Analytics layer

Python and R provide reproducible scoring, dashboard preparation, domain summaries, and sensitivity analysis.

## Systems layer

Rust and Go demonstrate how systemic environmental risk scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how environmental monitoring signals could be linked to alerting, anomaly detection, scenario simulation, and edge preprocessing.

## Interpretation

The architecture is intentionally modular. It preserves the distinction between measurement, scoring, disclosure, interpretation, and governance judgment.
