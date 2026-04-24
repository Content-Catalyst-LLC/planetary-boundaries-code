# Engineering Architecture

This repository treats the Doughnut framework as a diagnostic system rather than a static diagram.

## Data layer

The SQL schema defines:

- entities
- indicators
- thresholds
- observations
- scoring runs
- diagnostic scores

This supports provenance, auditability, and reproducible reporting.

## Analytics layer

Python and R provide reproducible scoring, dashboard preparation, and sensitivity analysis.

## Systems layer

Rust and Go demonstrate how the same scoring logic could become:

- a typed scoring library
- a command-line tool
- a JSON API
- a service behind a dashboard

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how boundary-relevant indicators could be monitored closer to the source:

- embedded threshold checks
- high-performance simulations
- anomaly detection at the edge
- accelerated preprocessing on hardware-aware platforms

## Interpretation

The architecture is intentionally modular. A real deployment should preserve the distinction between measurement, scoring, interpretation, and governance judgment.
