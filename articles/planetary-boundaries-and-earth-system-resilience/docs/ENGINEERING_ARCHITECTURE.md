# Engineering Architecture

This repository treats Earth system resilience as an interaction-aware monitoring and decision-support problem.

## Data layer

The SQL schema defines:

- boundary processes
- boundary observations
- resilience indicators
- boundary interactions
- scenario runs
- resilience scores

This supports provenance, versioning, transparency, and reproducibility.

## Analytics layer

Python and R provide resilience-capacity scoring, cross-boundary interaction modeling, risk-class assignment, scenario analysis, and dashboard-ready exports.

## Systems layer

Rust and Go demonstrate how resilience scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how environmental signals could be linked to threshold alerts, anomaly detection, scenario simulation, and accelerated preprocessing.

## Interpretation

The architecture preserves the distinction between direct pressure, resilience capacity, resilience gap, interaction pressure, structural importance, and governance interpretation.
