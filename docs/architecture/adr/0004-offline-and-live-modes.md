# ADR-0004: Offline and live run modes

## Status
Accepted

## Context
The framework must demo reliably to clients (no dependency on a live ALM being up or licensed) while also working against a real Azure DevOps org in production use.

## Decision
Every agent supports **two modes**, selected automatically by the presence of `ADO_PAT` / `ADO_ORG_URL` / `ADO_PROJECT`:

- **Offline (default):** story and test cases come from `examples/`; outputs are written locally. No ADO calls.
- **Live:** the `ado-skill` reads/writes the real ADO org.

The target application under test is **always live** in both modes — only the ALM source/sink changes.

## Consequences
- Demos are robust: the offline path never fails due to network, credentials, or licensing.
- The same agent logic serves both modes; only the I/O boundary (the `ado-skill`) differs.
- The current phase of this project runs **offline only**; live is wired and documented but dormant until credentials are supplied.
- A seed script (`scripts/ado-seed-example.ps1`) reproduces the worked-example story in a live org when the time comes.
