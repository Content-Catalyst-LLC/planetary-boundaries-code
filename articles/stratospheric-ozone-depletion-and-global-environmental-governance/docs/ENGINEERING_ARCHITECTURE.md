# Engineering Architecture

This repository treats stratospheric ozone depletion as an atmospheric-monitoring and governance-diagnostics problem.

## Data layer

The SQL schema defines:

- monitoring regions
- ozone observations
- ozone-depleting-substance pressure profiles
- governance capacity
- scenario runs
- ozone recovery scores

This supports provenance, versioning, transparency, and reproducibility.

## Analytics layer

Python and R provide boundary-margin scoring, recovery-gap analysis, governance-effectiveness scoring, residual-pressure modeling, scenario testing, and dashboard-ready exports.

## Systems layer

Rust and Go demonstrate how ozone recovery scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how ozone or UV-proxy signals could be linked to threshold alerts, anomaly detection, scenario simulation, and accelerated preprocessing.

## Interpretation

The architecture preserves the distinction between ozone concentration, boundary margin, recovery gap, residual pressure, governance effectiveness, treaty integrity, and planetary-boundary interpretation.
