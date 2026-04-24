# Engineering Architecture

This repository treats planetary-boundary measurement as a data-infrastructure problem.

## Data layer

The SQL schema defines:

- boundary processes
- control variables
- boundary values
- observations
- monitoring capacity
- scoring runs
- measurement scores

This supports provenance, versioning, transparency, and reproducibility.

## Analytics layer

Python and R provide control-variable scoring, risk-zone classification, dashboard preparation, and uncertainty-aware summaries.

## Systems layer

Rust and Go demonstrate how boundary-measurement scoring could become:

- a typed scoring core
- a command-line tool
- a JSON API
- a dashboard backend

## Edge layer

C, C++, TinyML, and PYNQ scaffolds show how boundary-relevant monitoring could be linked to threshold alerts, anomaly detection, scenario simulation, and accelerated preprocessing.

## Interpretation

The architecture preserves the distinction between boundary process, control variable, observation, boundary value, uncertainty, monitoring capacity, and governance interpretation.
