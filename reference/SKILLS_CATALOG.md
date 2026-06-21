# /arib-* Skills Catalog

> **Canonical full list of CCM's own 33 `/arib-*` skills** (Skill · Category ·
> Purpose). Loaded **on demand** — moved out of CLAUDE.md §4 in v3.20.0 (ADR-035)
> so the always-on session budget stays lean; CLAUDE.md §4 now holds a one-line
> pointer + the category-count summary.
>
> Related: `reference/COMMAND_PREFIX.md` (the `/arib-` prefix + autocomplete
> convention). **Not** `reference/SKILLS_REGISTRY.md`, which catalogs ~30
> *external/community* ecosystem skills — a different list.
>
> Drift guard: `scripts/validate-coherence.sh` fails CI if this table's row count
> ≠ `VERSION.json` `stats.skills`. Keep them in lockstep when adding a skill.

| Skill                       | Category   | Purpose                                              |
|-----------------------------|------------|------------------------------------------------------|
| /arib-session-start         | Session    | Initialize session, read context                     |
| /arib-session-end           | Session    | Close session, update memory, commit                 |
| /arib-io                    | Session    | Process I/O Channel (Cowork bridge)                  |
| /arib-memory-search         | Session    | Semantic search across memory (claude-mem + grep)    |
| /arib-graph                 | Session    | Code-graph — native import graph; build/refresh/query (on-demand) |
| /arib-dev-feature           | Dev        | New feature with branch + TDD                        |
| /arib-dev-debug             | Dev        | Scientific debugging (3 hypotheses)                  |
| /arib-dev-review            | Dev        | Code review with parallel agent fan-out              |
| /arib-dev-lean              | Dev        | Over-engineering review — delete-list of bloat (advisory) |
| /arib-wave-plan             | Wave       | Pre-wave requirement lock — grill + Codex review; merge-hold if no Codex |
| /arib-wave-start            | Wave       | Start a wave (auto-chains wave-plan; architect + planner) |
| /arib-wave-run              | Wave       | Execute wave steps with auto-advance (pauses only on issue/checkpoint) |
| /arib-wave-end              | Wave       | Close a wave (deep-audit gate + stakeholder report)  |
| /arib-deep-audit            | Audit      | 21-section wave-end audit + IMPLEMENT-FROM-FILE      |
| /arib-check-deploy          | Check      | Pre-deployment 7-phase verification + TestSprite     |
| /arib-check-services        | Check      | Infrastructure health (adaptive)                     |
| /arib-check-reality         | Check      | Scan for mock/fake data                              |
| /arib-check-migrate         | Check      | DB migration safety review                           |
| /arib-check-perf            | Check      | Performance audit                                    |
| /arib-check-deps            | Check      | Dependency audit                                     |
| /arib-check-a11y            | Check      | Accessibility WCAG 2.1 AA                            |
| /arib-check-design          | Check      | Design system contract (tokens, components)          |
| /arib-check-arabic          | Check      | Arabic/RTL audit (typography, mirroring, MENA)       |
| /arib-check-security        | Check      | OWASP Top 10 + supply chain                          |
| /arib-check-compliance      | Check      | Framework alignment (OWASP/GDPR/ISO/SOC2/PDPL)       |
| /arib-ci-audit              | CI         | Audit, init, review, or branch-protection check      |
| /arib-docs-api              | Docs       | API documentation + OpenAPI                          |
| /arib-docs-generate         | Docs       | Generate documentation                               |
| /arib-docs-language         | Docs       | i18n/RTL/LTR compliance (generic)                    |
| /arib-engine                | Engine     | Autonomous campaign — discovers its own backlog; auto-merge gated on reconciliation |
| /arib-build                 | Engine     | Command the team for a KNOWN goal — dispatches engineer-manager (decompose→dispatch→reconcile) |
| /arib-nestjs                | Stack      | NestJS patterns + review (DI, DTO, guards, N+1, security) |
| /arib-postgres              | Stack      | PostgreSQL optimization & safety (indexes, plans, migrations, RLS) |

**Total: 33 skills across 9 categories** — Session 5 · Dev 4 · Wave 4 · Audit 1 ·
Check 11 · CI 1 · Docs 3 · Engine 2 · Stack 2.
