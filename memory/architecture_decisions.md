# Architecture Decision Records

## ADR-001: Universal Project-Agnostic Methodology
- **Date**: 2026-04-15
- **Status**: Accepted
- **Context**: Need a Claude Code methodology that works across multiple projects (MotorGate, ARIB, شبكة الكهرباء) without rebuilding from scratch each time.
- **Decision**: Build a universal methodology with [PROJECT] placeholders that gets instantiated per project via a Bootstrap Protocol.
- **Alternatives Considered**:
  1. Build separate methodology per project — rejected: too much duplication, maintenance burden
  2. Build for one project, adapt later — rejected: creates bias toward first project's patterns
- **Consequences**: Every new project requires running the Bootstrap Protocol, but gains the full system immediately. Methodology improvements benefit all projects.

## ADR-002: 4-Layer Architecture (L1-L4)
- **Date**: 2026-04-15
- **Status**: Accepted
- **Context**: Claude Code needs a structured way to organize context, skills, safety gates, and autonomous agents.
- **Decision**: Adopt 4-layer architecture: L1 (CLAUDE.md) → L2 (Skills) → L3 (Hooks) → L4 (Agents). L1 overrides all. Hooks are mandatory. Agents inherit L1.
- **Alternatives Considered**:
  1. Flat file structure — rejected: no hierarchy means no override rules
  2. 2-layer (docs + code) — rejected: missing safety gates and autonomous capability
- **Consequences**: More files to maintain but clear separation of concerns. Each layer can evolve independently.

## ADR-003: Full Agent Arsenal (8 Agents)
- **Date**: 2026-04-15
- **Status**: Accepted
- **Context**: Deciding how many specialized agents to define — minimal (3), core (5), or full (8).
- **Decision**: Full arsenal of 8 agents covering all development phases: Architect, Security Auditor, Code Reviewer, Test Engineer, Debugger, Refactor Specialist, Arabic-RTL, Deploy Guardian.
- **Alternatives Considered**:
  1. Minimal (Architect, Debug, Review) — rejected: leaves security and testing gaps
  2. Core + Custom (5 agents) — rejected: missing Arabic-RTL and Deploy Guardian
- **Consequences**: More agent files to maintain, but complete coverage of the development lifecycle. Unused agents can be deactivated per project.

---

## v3.3 — Override of v3.2 "Honest" counter-proposal — 2026-05-08

- **Status**: Accepted
- **Context**: v3.2 "Honest" (commits f5a28ee → 86cd9f0) shipped a counter-proposal that explicitly deferred items #3, #4, #5, #6, #7, #8, #9, #10 of `CCM-v3.2-Enforced-Proposal.md`. The maintainer subsequently reversed the deferral and asked for the full proposal scope, with Item #7 expanded to include ISO 27001, SOC 2, GDPR, and OWASP enforcement.
- **Decision**: Honor the override. Ship all 8 deferred items as v3.3.0 "Operating" (commits c48d9ee → 709baa7) with the counter-proposal's safeguards preserved: every new MCP stays opt-in via env var; ISO 27001 and SOC 2 docs frame as alignment-only (never "compliant"); compliance/README.md states the honesty principle explicitly; OWASP enforcement ships as real hooks.
- **Why this matters in memory**: Future sessions reading the counter-proposal file alone might think items 3-10 were skipped. They were not. The override happened, was deliberate, and shipped with safeguards. See `architecture/DECISIONS.md` ADR-011 for the full record.
- **Audit trail**: A 20-agent parallel review verified the implementation against the proposal post-shipment. Phase 1-6 cleanup commits (6b0b5f1+) closed the gaps the audit surfaced.

---

> New ADRs are added above this line.
> ADR numbering is sequential and never reused.
