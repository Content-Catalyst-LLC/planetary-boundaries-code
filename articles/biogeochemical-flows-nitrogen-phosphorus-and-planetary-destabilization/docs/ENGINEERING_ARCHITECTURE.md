# Engineering Architecture

This repository treats biogeochemical flows as a nutrient-accounting, watershed-risk, and monitoring problem.

## Data layer

The SQL schema defines:

- nutrient regions
- nutrient accounts
- watershed risk factors
- governance capacity
- scenario runs
- nutrient risk scores

This supports provenance, versioning, transparency, and reproducibility.

## Analytics layer

Python and R provide nutrient-use efficiency, nutrient surplus, boundary pressure, eutrophication risk, legacy nutrient pressure, scenario testing, and dashboard-ready exports.

## Systems layer

Rust and Go demonstrate how nutrient-risk scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how nitrate, phosphate, or dissolved-oxygen signals could be linked to threshold alerts, anomaly detection, scenario simulation, and accelerated preprocessing.

## Interpretation

The architecture preserves the distinction between nutrient access, nutrient surplus, nutrient-use efficiency, runoff sensitivity, hydrological connectivity, ecosystem sensitivity, legacy nutrient pressure, governance capacity, and planetary-boundary interpretation.
