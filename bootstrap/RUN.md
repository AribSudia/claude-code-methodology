# RUN — How to invoke CCM

> Every protocol runs **autonomously to completion** (PROTOCOL_PRINCIPLES
> Rule 5) — systematic, not interactive. The only pauses are genuine
> blockers (dirty tree without `--force`, missing dependency, unresolvable
> conflict, a destructive op needing a snapshot) and — for a brand-new
> project with no facts — the one-time questionnaire.

---

## ⭐ The one-prompt method (recommended — works in ALL situations)

You don't need to know which protocol applies. Paste this and CCM detects
your situation from the filesystem and runs the right one:

```
Read claude-code-methodology/bootstrap/RUN.md and set up (or upgrade) CCM
for this project. Detect my situation from the filesystem per the Situation
Router and execute the matching protocol autonomously to completion
(PROTOCOL_PRINCIPLES Rule 5). Finish with ./scripts/install-hooks.sh and
./scripts/validate-coherence.sh, and report what you did.
```

### Situation Router (how the one-prompt method decides)

| Detected on disk | Situation | Protocol |
|------------------|-----------|----------|
| `.claude/` + `VERSION.json` with a CCM version | CCM already installed | **UPGRADE_PROTOCOL.md** (Phase 0 detects version → upgrade phases, or drift detection if versions match — never "already up to date / stop") |
| Other-tool markers (`.cursor/`, `.windsurfrules`, `.github/copilot-instructions.md`, `.kiro/`, or a bare `CLAUDE.md`) and no CCM structure | Coming from another AI-coding tool | **MIGRATION_GUIDE.md** (From Any System) |
| Flat `AGENTS.md` + `docs/` + root architecture files | Legacy claude-code-system | **MIGRATION_GUIDE.md Appendix A** (retired path) |
| Substantial existing code, no CCM, no tool markers | Existing codebase to overlay | **REVERSE_BOOTSTRAP.md** |
| Empty / near-empty project | Brand-new project | **BOOTSTRAP.md** (greenfield) |

If multiple apply (e.g. Cursor markers *and* existing code), do both: migrate
the tool config AND reverse-bootstrap the code. Report which matched.

**Why this is the most user-friendly method:** one prompt, zero protocol
selection, no wrong choice possible — the filesystem is the source of truth,
and the router is deterministic (Rule 2: no menus when one answer is correct).

---

## Explicit invocations (advanced — when you want to force a specific protocol)

Use these only if you want to override the router.

## New project (greenfield)

```
Read claude-code-methodology/bootstrap/BOOTSTRAP.md and execute the full
bootstrap protocol for this new project. Run autonomously to completion
per PROTOCOL_PRINCIPLES Rule 5. If core/ or this prompt already contains the
project facts (name, stack, domain, schema), use them and ask nothing —
scaffold end-to-end. Only if there are genuinely no project facts, ask the
25-question questionnaire ONCE as a single batch, then run to completion.
Finish by running ./scripts/install-hooks.sh and ./scripts/validate-coherence.sh.
```

## Existing project (reverse bootstrap)

```
Read claude-code-methodology/bootstrap/REVERSE_BOOTSTRAP.md and execute the
full reverse bootstrap protocol on this existing codebase. Run autonomously
to completion per PROTOCOL_PRINCIPLES Rule 5: scan → synthesize → scaffold →
verify, reporting findings inline. Do not stop to ask for approval; pause
only on a genuine blocker. Finish with ./scripts/install-hooks.sh and
./scripts/validate-coherence.sh.
```

## Version upgrade

```
Read claude-code-methodology/bootstrap/UPGRADE_PROTOCOL.md and execute the
full upgrade protocol. Run autonomously per PROTOCOL_PRINCIPLES Rule 1 + 5:
if versions match, run Phase 1.5 drift detection (do NOT stop with "already
up to date"); if the template is newer, run the upgrade phases; if older,
stop with the honest error. Apply changes and report — no options menus.
```

> **Migration has no standalone prompt (v3.8.3).** The one-prompt method
> above auto-detects tool markers (Cursor / Windsurf / Copilot / Kiro /
> unstructured CLAUDE.md / legacy claude-code-system) and invokes
> `MIGRATION_GUIDE.md` itself — you never have to choose "migrate." The
> guide still exists as the protocol the router calls.

## Reengineer / overlay on a legacy codebase (non-destructive)

```
Read claude-code-methodology/bootstrap/REENGINEERING_GUIDE.md and execute
the full reengineering protocol. Run autonomously per PROTOCOL_PRINCIPLES
Rule 5: overlay CCM onto this existing codebase in the documented order
without restructuring my code, reporting each step. Pause only on a genuine
blocker. (Use this instead of reverse-bootstrap when CCM must coexist with
the code as-is rather than reorganize it.)
```

---

## What "autonomous to completion" means (and doesn't)

**Does mean:** no "should I continue?" between phases; no "here's what I
found, approve before I scaffold" gate; no numbered option menus; no asking
about anything determinable from the filesystem.

**Does NOT mean:** bypassing safety. A destructive/irreversible step (force-
push, dropping data, overwriting a file that diverges from the template)
still creates a snapshot and surfaces the risk first. The greenfield
questionnaire still runs when a new project has no facts — that is input,
not intervention.

See `bootstrap/PROTOCOL_PRINCIPLES.md` for the binding rules and the full
list of genuine blockers.
