# Engineering Architecture

This repository treats ocean acidification as a carbonate-chemistry, marine-risk, and monitoring problem.

## Data layer

The SQL schema defines:

- ocean regions
- carbonate observations
- ecosystem vulnerability
- marine multi-stressors
- scenario runs
- acidification risk scores

This supports provenance, versioning, transparency, and reproducibility.

## Analytics layer

Python and R provide pH decline diagnostics, hydrogen-ion increase indexes, aragonite boundary pressure, ecosystem vulnerability, multi-stressor risk scoring, scenario testing, and dashboard-ready exports.

## Systems layer

Rust and Go demonstrate how ocean acidification scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how marine chemistry signals could be linked to threshold alerts, anomaly detection, scenario simulation, and accelerated preprocessing.

## Interpretation

The architecture preserves the distinction between pH, carbonate availability, saturation state, boundary pressure, ecosystem vulnerability, monitoring capacity, governance capacity, and planetary-boundary interpretation.
