# Engineering Architecture

This repository treats atmospheric aerosol loading as a regional planetary-risk and monitoring problem.

## Data layer

The SQL schema defines:

- regions
- aerosol observations
- aerosol composition
- exposure and vulnerability
- scenario runs
- regional aerosol scores

This supports provenance, versioning, transparency, and reproducibility.

## Analytics layer

Python and R provide regional aerosol-risk scoring, policy scenario testing, dominant-driver classification, and dashboard-ready exports.

## Systems layer

Rust and Go demonstrate how regional aerosol scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how aerosol signals could be linked to threshold alerts, anomaly detection, scenario simulation, and accelerated preprocessing.

## Interpretation

The architecture preserves the distinction between aerosol pressure, composition, health exposure, hydrological sensitivity, cloud uncertainty, governance capacity, and planetary-boundary interpretation.
