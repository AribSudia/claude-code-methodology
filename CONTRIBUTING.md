# Contributing to CCM

Thanks for considering a contribution. This document is the contract:
how to propose, build, test, and ship changes against the Claude Code
Methodology repository.

If you're integrating CCM into your own project (the common case),
nothing here applies — read `bootstrap/BOOTSTRAP.md` instead.

---

## What CCM is, what it isn't

- **CCM is** an opinionated methodology and skill pack for Claude Code.
- **CCM is not** a runtime, a framework, or a service. The bash hooks
  are the only executable code; everything else is documentation and
  data.

Contributions that respect this scope land faster.

---

## Before you start

1. **Read `CLAUDE.md`.** It's the master brain. Anything that contradicts
   it gets reverted, no matter how clever.
2. **Read `architecture/CONSTRAINTS.md` v3.3 section.** Nine binding
   methodology-level rules. Hooks fail closed. MCPs stay opt-in.
   Compliance never claims certification. And so on.
3. **Search `architecture/DECISIONS.md`** to see if your idea is already
   ADR'd. Cite the ADR in your PR if so.
4. **Search `proposals/archive/`** for prior proposal context.

---

## Workflow

### 1. Pick the right entry point

| You want to... | Open as |
|----------------|---------|
| Report a bug | Issue with the bug template |
| Propose a non-trivial feature | Issue with the feature template, then ADR draft |
| Fix a small bug or doc typo | PR directly |
| Disclose a security issue | Private security advisory (see `SECURITY.md`) |

Non-trivial features without an ADR get bounced back. ADRs are short
(~50 lines) and force the questions worth asking before code lands.

### 2. Branch naming

```
feat/<short-name>          new capability
fix/<short-name>           bug fix
docs/<short-name>          docs only
refactor/<short-name>      internal change
chore/<short-name>         tooling, deps, CI
security/<short-name>      security finding
wave/<wave-name>           multi-session delivery (uses arib-wave-start)
```

`wave/*` branches are special — see `waves/README.md`. The wave-merge
gate refuses `git push` to main from a `wave/*` branch without an audit
hash from `/arib-deep-audit`.

### 3. Commit messages

Conventional Commits. Format:

```
<type>(<scope>): <subject under 72 chars>

<optional body — wrap at 72>

<optional footer — Closes #123, Refs ADR-007>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `security`,
`perf`, `wave`. Scope is optional but helpful (`hooks`, `compliance`,
`waves`, `agents`, `skills`, `bootstrap`, etc.).

Co-authored-by trailers for AI-assisted commits are welcome and honest:

```
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

### 4. Test before pushing

```bash
./scripts/test-hooks.sh          # hook regression suite, must pass
./scripts/validate-coherence.sh  # counts/frontmatter/version/refs, must pass (CI-enforced)
./scripts/token-audit.sh         # always-on token-budget impact
bash -n .claude/hooks/*.sh       # syntax check (suite already does this)
```

If you touched `.github/workflows/`, the workflow itself runs on the PR;
spot a failure there and fix before merge.

### 5. Open the PR

Use the PR template (`.github/PULL_REQUEST_TEMPLATE.md`). Fill in:

- Summary (lead with user-visible outcome)
- Type (check all that apply)
- Linked issues / ADRs
- Test plan
- Token-budget impact (if context.include or rules changed)
- Wave audit hash (if closing a wave)
- Compliance impact (if hooks, auth, data, or compliance/ changed)

CI must be green. CODEOWNERS-required reviews must complete.

### 6. Branch protection (repo settings, applied once)

For repository owners: configure the following at
`Settings → Branches → Branch protection rules` for `main`:

- ✅ Require a pull request before merging
- ✅ Require approvals (1 minimum; 2 for security-sensitive areas via CODEOWNERS)
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require review from Code Owners
- ✅ Require status checks to pass before merging:
  - `Hooks regression / test-hooks`
  - `JSON validation / validate-json`
  - `Token budget / measure`
  - `Markdown lint / lint`
- ✅ Require branches to be up to date before merging
- ✅ Require conversation resolution before merging
- ✅ Require linear history (squash or rebase merge only — no merge commits)
- ✅ Restrict who can push to matching branches: maintainer only (emergency)
- ✅ Do not allow bypassing the above settings

**Direct pushes to `main` should be reserved for emergencies** (broken
CI, security hotfix). Document any direct push in `operations/OPERATIONS_LOG.md`.

---

## What gets reviewed extra carefully

CODEOWNERS auto-routes review for:

- `.claude/hooks/**` — kernel-level enforcement; one bug here breaks
  every project using CCM.
- `architecture/{CONSTRAINTS,DECISIONS,SECURITY,AGENT_ARCHITECTURE}.md`
  — load-bearing decisions.
- `compliance/**` — the honesty principle is load-bearing. PRs here that
  drift toward "compliant" claims will be reverted.
- `.claude/skills/{arib-deep-audit,arib-wave-start,arib-wave-end}/`
  + `arib-check-compliance/` — gate behavior.
- `CLAUDE.md`, `SYSTEM.md`, `VERSION.json`, `CHANGELOG.md` — methodology
  brain.
- `.github/**`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`
  — the meta-discipline this file describes.

---

## Adding a new hook

1. Author `.claude/hooks/<name>.sh`. Source `lib/common.sh`.
2. Use `block "reason"` to deny, `allow "reason"` to permit. Fail closed.
3. Wire into `.claude/settings.json` under the relevant event.
4. Add at least one positive and one negative fixture under
   `tests/fixtures/payloads/`.
5. Add an assertion to `scripts/test-hooks.sh`.
6. Document in `Training/04-HOOKS-MANUAL.md`.
7. Re-run `./scripts/install-hooks.sh`.

CI runs `bash -n` on every shell script and the regression suite on
every PR touching `.claude/hooks/**` or `scripts/**`.

---

## Adding a new skill

1. Create `.claude/skills/arib-<name>/SKILL.md`.
2. Frontmatter: `argument-hint`, `description`. Required.
3. Sections: Overview, When to Use, Usage, Protocol, Examples, Decision
   tree, Edge cases, Failure modes, Related. Aim for v3.1-grade depth
   (250-800 lines).
4. Register in:
   - `CLAUDE.md` §4 skills table
   - `Training/03-SKILLS-MANUAL.md`
   - `architecture/AGENT_ARCHITECTURE.md` (if it dispatches agents)

---

## Adding a new agent

1. Create `.claude/agents/<name>.md`.
2. Sections: Identity, When this agent activates, What this agent reads,
   What this agent writes, Protocol, Failure modes, Related,
   Parallel-safety.
3. Register in `architecture/AGENT_ARCHITECTURE.md` agent inventory
   table with read/write surface and parallel-safety.
4. Update CLAUDE.md §5 agent count if you added one.

---

## Adding to the compliance layer

Read `compliance/README.md` first. The honesty principle is binding:
new framework docs distinguish code-checkable rules from operational
rules. The string "compliant" / "certified" / "attested" must not
appear as a CCM claim.

Hooks for code-checkable rules go in `pre-tool-use.sh` or
`pre-commit.sh`. Add fixtures and tests.

---

## Releasing

CCM follows Semantic Versioning.

- **Patch (3.4.x)** — bug fixes, doc cleanups, no new capability.
- **Minor (3.x.0)** — new opt-in capability, no breaking change.
- **Major (x.0.0)** — breaking change to bootstrap, hooks contract,
  or skill API.

To cut a release:

1. Bump `VERSION.json`, `CLAUDE.md`, `SYSTEM.md`, `Training/01`, `README`.
2. Add CHANGELOG entry under the new version.
3. Add ADR for non-trivial decisions.
4. Tag: `git tag -a v3.x.0 -m "v3.x.0 \"Codename\""`.
5. Push tag: `git push origin v3.x.0`.

---

## Code of Conduct

See `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1). Be kind. Disagree
with ideas, not people. Maintainer reserves the right to remove or edit
contributions that violate the code.

---

## License & Contributor Agreement

CCM **v4.0.0 and later** is licensed under the
[PolyForm Noncommercial License 1.0.0](LICENSE) — free for noncommercial use —
with paid **commercial** licenses available ([COMMERCIAL.md](COMMERCIAL.md)).
Versions **3.20.0 and earlier remain MIT**.

By submitting a contribution you agree to the **Contributor License Agreement**
in [`.github/CLA.md`](.github/CLA.md): you keep your copyright, but you grant
arib.sa a broad license to your contribution **including the right to include it
in commercially-licensed versions**. This is what makes the dual model possible.

How to accept (do both):

1. Sign off your commits — `git commit -s` adds a
   `Signed-off-by: Name <email>` trailer (the
   [DCO](https://developercertificate.org/)).
2. Check the **CLA** box in the pull-request template.

Contributing on behalf of an employer? Use the **Entity** path in `.github/CLA.md`.
If you can't agree to the CLA, please don't contribute.

> **Maintainer — CLA enforcement.** CLA sign-off can be auto-enforced by
> `.github/workflows/cla.yml`, but it is **dormant until you opt in** (set repo
> variable `CLA_ENABLED=true` + optionally a `CLA_SIGNATURES_TOKEN` PAT; see the
> workflow header). **Until the bot is enabled, you MUST manually confirm the CLA
> sign-off / checkbox on every *external* PR before merging — un-CLA'd external
> contributions must be reverted**, because the commercial relicensing model
> depends on every v4.0.0+ contribution being CLA-covered. (Contributions made at
> v3.20.0 or earlier were MIT and are not affected.) Brand usage is governed by
> [`TRADEMARK.md`](TRADEMARK.md).
