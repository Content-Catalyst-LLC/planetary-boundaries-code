# Engineering Architecture

This repository treats freshwater change as a blue-water, green-water, groundwater, and hydrological-governance problem.

## Data layer

The SQL schema defines:

- freshwater regions
- blue-water observations
- green-water observations
- hydrological risk factors
- governance capacity
- scenario runs
- freshwater risk scores

This supports provenance, versioning, transparency, and reproducibility.

## Analytics layer

Python and R provide streamflow deviation, soil-moisture deviation, groundwater stress, hydrological boundary pressure, social-ecological exposure, scenario testing, and dashboard-ready exports.

## Systems layer

Rust and Go demonstrate how freshwater-change scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how streamflow, soil-moisture, and groundwater signals could be linked to threshold alerts, anomaly detection, scenario simulation, and accelerated preprocessing.

## Interpretation

The architecture preserves the distinction between blue water, green water, groundwater, ecological sensitivity, natural buffers, monitoring capacity, governance capacity, adaptive capacity, and planetary-boundary interpretation.
