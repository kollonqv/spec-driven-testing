# ADR-0001: Start the automated pipeline at User Stories

## Status
Accepted

## Context
The full value chain is Requirements → User Stories → Test Scenarios → Test Cases → Test Steps → Automation. Requirements and user-story authoring are collaborative BA activities that depend heavily on business context and stakeholder conversation.

## Decision
The framework's agents begin at the **User Story** (with acceptance criteria already authored in ADO). Requirements → User Story remains a human/BA activity, documented but not automated.

## Consequences
- Agents can assume a structured story with ACs as input, keeping their prompts focused and reliable.
- Traceability still spans the whole chain conceptually (ACs trace up to requirements), but generation starts where the input is structured enough to be dependable.
- If requirement-level automation is wanted later, a new front-end agent can be added without disturbing the existing phases.
