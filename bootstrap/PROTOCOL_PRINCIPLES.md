# PROTOCOL_PRINCIPLES.md — Decisive Bootstrap Behavior

> **Binding charter for the 5 bootstrap protocols** (`BOOTSTRAP.md`,
> `REVERSE_BOOTSTRAP.md`, `UPGRADE_PROTOCOL.md`, `MIGRATION_GUIDE.md`,
> `REENGINEERING_GUIDE.md`).
>
> All five protocols must obey these rules. When a protocol document
> seems to contradict this file, this file wins.
>
> Scope: how Claude Code behaves while *executing* a protocol. Not
> a substitute for the protocol's content (the steps, the checks,
> the file lists) — a discipline layer on top.

---

## Why this exists

A protocol that stops on matching versions is broken. A protocol that
asks the user "1) Force-reapply, 2) Drift-check, 3) Drop newer release"
is delegating its own job. The user reported a real failure: the
upgrade protocol terminated at Phase 0 because versions matched, then
offered three opt-in alternatives instead of doing the right thing.

The right thing is *almost always* deterministic. Where it isn't, the
protocol must say so explicitly — not punt to the user for every
ambiguous case.

This charter codifies the decisive-protocol discipline introduced in
v3.5.1.

---

## The four rules

### Rule 1 — Same version is not a terminator

When the project's `VERSION.json` matches the template's, **proceed to
drift detection**. Don't stop.

Reason: matching version numbers do not imply matching files. Project
extensions, local edits, and missed earlier merges all produce drift
even when the version is current.

The correct sequence:
1. Read both `VERSION.json` files.
2. **If versions match → run drift detection** (Rule 4).
3. **If template version is newer → run upgrade phases**.
4. **If template version is older → STOP** with an honest error: the
   user has a stale template, not a stale project.

### Rule 2 — No multiple-choice menus when one answer is correct

Forbidden patterns (these literally appeared in the failing run):

> "If you want me to take action anyway, your options are:
> 1. Force-reapply...
> 2. Diff drift check...
> 3. Drop a newer methodology release...
> Tell me which (if any) and I'll proceed."

This is delegation, not collaboration. The protocol owns the decision.
If three actions exist and one is correct, do that one. If three actions
exist and *all* would be reasonable depending on the user's intent,
restate the goal in one sentence and ask one binary question — never a
numbered menu of three.

When in doubt: **do the safest correct action**, log it, and report
what was done. The user can revert; the user cannot un-stop a session
that exited prematurely.

### Rule 3 — Ask only what you cannot determine

Permitted user-input questions (genuinely undeterminable):

- "What is the project name?"
- "What tech stack? (no code yet)"
- "Which compliance frameworks apply to your business?"

Forbidden user-input questions (Claude can determine):

- "Which version is current?" (→ read VERSION.json)
- "Which directories already exist?" (→ `ls`)
- "Which skills are installed?" (→ `ls .claude/skills/`)
- "Has the upgrade run before?" (→ check git log + backup files)
- "Which files have local edits vs are stale templates?" (→ drift detection per Rule 4)

The bootstrap protocols already capture user-input questions in
explicit "Project Questionnaire" sections. Anything outside those
sections must be determined, not asked.

### Rule 4 — Drift detection is automatic and complete

When a protocol reaches drift detection (e.g., upgrade-when-matching,
or post-bootstrap verification), it runs the full sweep without
prompting. The sweep classifies every file under
`claude-code-methodology/` against the corresponding project file:

| Classification | Trigger | Action |
|----------------|---------|--------|
| **Identical** | bytes match | nothing |
| **Project extension** | path NOT in template (e.g. project-specific skill, custom agent) | preserve untouched; record in drift report |
| **Stale template** | bytes differ AND project file matches a known prior template version (or the template is strictly newer per a content header) | refresh from template; record in drift report |
| **Local edit** | bytes differ AND project file does NOT match any prior template (genuine project customization of a template file) | preserve untouched; record in drift report with a `REVIEW` flag so the user knows divergence exists |

Project-state paths are always preserved untouched:
- `memory/*.md` (per-project decisions, change log, notes)
- `core/**` (user's project files dropped in for context)
- `io/ledger/**` (audit trail)
- `io/hook-logs/**` (gitignored anyway)
- `compliance/CONTROLS.md` (project's own controls register)
- `waves/<name>/**` (project's wave artifacts)
- `architecture/CONTEXT_MAP.md` `allowed_write_paths` block (project-specific)

The drift report goes to `operations/OPERATIONS_LOG.md` and
`io/ledger/drift-<date>-<short-hash>.md` with the same YAML-style
header as `/arib-deep-audit` reports.

---

## Decisive flow chart

```
Run protocol
    |
    v
[Determinable?]
    |
    +-- yes --> determine, act, log, report
    |
    +-- no  --> [User-input question is in the explicit Questionnaire?]
                    |
                    +-- yes --> ask the questionnaire (one block, all questions)
                    +-- no  --> ❌ this is a Rule 3 violation; pick the safest correct
                               action and proceed
    |
    v
[Genuine blocker?]
    |
    +-- yes --> STOP with a specific actionable error
    +-- no  --> proceed
    |
    v
Apply changes; log to OPERATIONS_LOG; report what was done.
```

---

## Genuine blockers (the only legitimate STOP conditions)

A protocol may STOP only on:

1. **Working tree dirty AND user did not pass `--force`** (data loss risk).
2. **Required dependency missing** (`jq`, `git`, `curl`, `gh` for
   GitHub-API steps) and not installable in this session.
3. **`claude-code-methodology/` directory not found** at expected location.
4. **Conflict the user must resolve** (e.g., two custom agents
   shadowing the same name; merge conflict in `architecture/DECISIONS.md`).
5. **User explicitly cancelled** mid-flight.
6. **Template version is older than project** — the user has the
   wrong template, not the wrong project.
7. **`gh` API rate-limited** during a step that requires it (e.g.,
   `branch-protection` mode in `/arib-ci-audit`).

Anything else: proceed with the safest correct action and report.

---

## Forbidden phrases (anti-patterns)

These phrases are **never** acceptable output from a protocol:

- "Already up to date." (matching version is not a terminator → Rule 1)
- "Your options are: 1. ... 2. ... 3. ..." (numbered menus → Rule 2)
- "If you want me to take action anyway..." (Rule 2 — the protocol owns the action)
- "Tell me which and I'll proceed." (Rule 2 inverse)
- "Nothing to do." (when drift may exist → Rule 4)

If a protocol document still contains these phrases as quoted rules
(e.g., `UPGRADE_PROTOCOL.md` line 96 prior to v3.5.1), they are
superseded by this file.

---

## Required output shape

Every protocol run produces, at minimum:

```markdown
## <Protocol Name> Run — <YYYY-MM-DD HH:MM UTC>

- mode: <bootstrap | reverse-bootstrap | upgrade | migrate | reengineer>
- target_version: <semver>
- actions_taken:
  - <action 1>
  - <action 2>
- drift_findings: <count> (preserved-extensions: N, refreshed-templates: N, local-edits-flagged: N)
- blockers_hit: <count> (each with specific reason)
- next_step: <one sentence>
```

Append to `operations/OPERATIONS_LOG.md`. Reference the artifact in
`memory/session_notes.md` for the next session's context.

---

## Per-protocol notes

| Protocol | Decisive specifics |
|----------|--------------------|
| `BOOTSTRAP.md` | New project — Questionnaire is the only legitimate user-input phase. After answers received, every subsequent decision is determined. |
| `REVERSE_BOOTSTRAP.md` | Auto-scan first; ask only when the scan returns ambiguous results (e.g., two candidate frameworks detected). Never present a 1-of-3 menu. |
| `UPGRADE_PROTOCOL.md` | Versions match → drift detection (Rule 4), do not STOP (Rule 1). Versions newer → run phases automatically. |
| `MIGRATION_GUIDE.md` | Source-system identification is determinable from file inspection — don't ask "which framework was this?" if the answer is in `package.json`. |
| `REENGINEERING_GUIDE.md` | Overlay sequence is deterministic — the order of operations is documented; don't ask the user to pick the order. |

---

## Related

- `bootstrap/BOOTSTRAP.md` — new project.
- `bootstrap/REVERSE_BOOTSTRAP.md` — existing project.
- `bootstrap/UPGRADE_PROTOCOL.md` — older CCM version → newer.
- `bootstrap/MIGRATION_GUIDE.md` — legacy system → CCM.
- `bootstrap/REENGINEERING_GUIDE.md` — overlay on legacy.
- `architecture/DECISIONS.md` ADR-014 — the binding decision record.
- `architecture/CONSTRAINTS.md` constraint #11 — the binding rule.
- `operations/OPERATIONS_LOG.md` — every protocol run logged here.

---

## Change history

- **2026-05-08 (v3.5.1)** — created in response to the Phase 0
  termination report. Codifies the four decisiveness rules. All 5
  bootstrap protocols updated to reference this file.
