# RUN — Canonical Invocation Prompts

> Copy-paste one of these to invoke a bootstrap protocol. Each runs
> **autonomously to completion** (PROTOCOL_PRINCIPLES Rule 5) — systematic,
> not interactive. The only pauses are genuine blockers (dirty tree without
> `--force`, missing dependency, unresolvable conflict, a destructive op
> needing a snapshot) and — for a brand-new project with no facts — the
> one-time questionnaire.

---

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

## Legacy migration

```
Read claude-code-methodology/bootstrap/MIGRATION_GUIDE.md and execute the
full migration protocol. Run autonomously per PROTOCOL_PRINCIPLES Rule 5:
identify the source system from file inspection (don't ask what it was),
migrate data into the CCM structure, split AGENTS.md, deploy skills/agents,
and verify. Pause only on a genuine blocker.
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
