# Engineering Architecture

This repository treats uncertainty-aware boundary setting as a systems-design problem.

## Data layer

The SQL schema defines:

- boundaries
- threshold estimates
- observed pressures
- precautionary assumptions
- governance capacity
- scoring runs
- uncertainty scores

This supports provenance, transparency, versioning, and reproducibility.

## Analytics layer

Python and R provide uncertainty-aware scoring, risk-zone classification, dashboard preparation, and sensitivity analysis.

## Systems layer

Rust and Go demonstrate how uncertainty-aware boundary scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how boundary-relevant monitoring could be linked to threshold alerts, anomaly detection, scenario simulation, and accelerated preprocessing.

## Interpretation

The architecture preserves the distinction between measurement, threshold estimation, uncertainty, precautionary judgment, and governance response.
