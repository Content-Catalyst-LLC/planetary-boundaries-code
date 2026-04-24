# Engineering Architecture

This repository treats critiques of the planetary boundaries framework as a systems-design challenge.

## Data layer

The SQL schema defines:

- cases
- critique domains
- domain scores
- scoring runs
- domain weights
- aggregate results

This supports provenance, transparency, and auditability.

## Analytics layer

Python and R provide reproducible scoring, dashboard preparation, dominant-risk identification, and sensitivity analysis.

## Systems layer

Rust and Go demonstrate how critique-aware scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how boundary-relevant monitoring could be linked to alerting, anomaly detection, and edge preprocessing.

## Interpretation

The architecture is intentionally modular. It preserves the distinction between measurement, scoring, interpretation, and governance judgment.
