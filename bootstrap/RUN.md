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
| Other-tool markers (`.cursor/rules/` or `.cursorrules`, `.windsurfrules` or `.windsurf/`, `.github/copilot-instructions.md`, `.kiro/`, or a bare `CLAUDE.md`) and no CCM structure | Coming from another AI-coding tool | **MIGRATION_GUIDE.md** (From Any System) |
| Flat `AGENTS.md` + `docs/` + root architecture files | Legacy claude-code-system | **MIGRATION_GUIDE.md Appendix A** (retired path) |
| Substantial existing code, no CCM, no tool markers | Existing codebase to overlay | **REVERSE_BOOTSTRAP.md** |
| Empty / near-empty project | Brand-new project | **BOOTSTRAP.md** (greenfield) |

If multiple apply (e.g. Cursor markers *and* existing code), do both: migrate
the tool config AND reverse-bootstrap the code. Report which matched.

**Why this is the most user-friendly method:** one prompt, zero protocol
selection, no wrong choice possible — the filesystem is the source of truth,
and the router is deterministic (Rule 2: no menus when one answer is correct).

---

## ⚡ Update direct from GitHub (no manual download)

You no longer have to download a fresh `claude-code-methodology/` folder by
hand every release. One line pulls the latest source straight from GitHub.

### Use this in EVERY situation (install **and** update)

Run from your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/AribSudia/claude-code-methodology/main/scripts/ccm-fetch.sh | bash
```

This one line works **whether or not CCM is already in your project**,
because it downloads the fetch script fresh from GitHub each time — it
depends on **nothing** already installed:

| Your situation | What the one-liner does |
|----------------|-------------------------|
| No CCM yet | Creates `./claude-code-methodology/` with the latest version |
| **Old CCM, no `ccm-fetch.sh`** (the common upgrade case) | Fetches the new source, moves your old copy to `claude-code-methodology.prev` |
| Recent CCM | Same — refreshes the source, keeps `.prev` for rollback |

> **Upgrading from an older CCM?** Use the line above. Older versions don't
> ship `ccm-fetch.sh`, so there's no local script to run — the curl one-liner
> is how you get it. You don't need to find or download anything first.

### Shortcut (only once you already have a recent CCM)

If `claude-code-methodology/scripts/ccm-fetch.sh` already exists in your
project, you can call it directly instead of curling — same result:

```bash
./claude-code-methodology/scripts/ccm-fetch.sh
```

Either form accepts `--ref v3.9.0` (or any branch / tag / commit) to pin a
specific version.

`ccm-fetch.sh` does **only** the download: it refreshes
`./claude-code-methodology/` (keeping the prior copy at
`claude-code-methodology.prev` for rollback) and **never touches your
project data**. It then prints the one-prompt above. Paste that into Claude
Code and CCM detects "already installed" → runs **UPGRADE_PROTOCOL.md**
(drift detection + Phase 1.6 re-verification), merging the new framework
while preserving your `memory/`, decisions, and project-specific files.

> **Why a fetch + a separate merge?** The download is mechanical (a shell
> script). The merge is *intelligent* — it has to keep your data, reconcile
> diverged files, and re-verify changed skills. That's Claude's job via the
> protocol, not a blind `cp -r`. See `architecture/DECISIONS.md` ADR-024.

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
