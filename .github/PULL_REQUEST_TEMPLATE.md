# Summary

<!-- 2-4 sentences. What changed and why. Lead with the user-visible
outcome, not the commit list. -->

## Type

<!-- Check all that apply -->

- [ ] feat — new user-visible capability
- [ ] fix — bug fix
- [ ] docs — documentation only
- [ ] refactor — internal change, no behavior change
- [ ] test — adds or fixes tests
- [ ] chore — tooling, deps, CI, no code change
- [ ] security — addresses a security finding
- [ ] perf — performance improvement
- [ ] wave — closes a delivery wave (requires audit hash)

## Linked issues / ADRs

<!-- Closes #123, references ADR-007. If the change reflects a
new architectural decision, ADR added in this PR is required. -->

## Test plan

<!-- Concrete steps a reviewer can run. For hook changes:
./scripts/test-hooks.sh must pass. For skill changes: cite the
sections of the skill that exercise the new logic. -->

- [ ] `./scripts/test-hooks.sh` — all green (suite prints its own count)
- [ ] `./scripts/validate-coherence.sh` — COHERENT
- [ ] `./scripts/token-audit.sh` — recorded delta below
- [ ] Manual smoke test of the changed surface

## Token-budget impact

<!-- Required for changes touching context.include or .claude/rules/. -->

- Baseline (main): _____
- This PR: _____
- Delta: _____

## Wave / audit hash (if applicable)

<!-- For PRs that close a wave: paste the audit hash from
io/ledger/audit-*.md. The wave-merge gate enforces this. -->

- Wave name: _____
- Audit hash: _____
- Verdict: PASS / WARN

## Compliance impact

<!-- Required for changes to compliance/, hooks, or auth/data
boundaries. State which framework alignment levels could change
and why. Use the honest framing — never "compliant". -->

- [ ] No compliance impact
- [ ] OWASP — alignment may change: _____
- [ ] GDPR — alignment may change: _____
- [ ] ISO 27001 / SOC 2 — manual evidence required (CONTROLS.md row added)
- [ ] PDPL / NCA / SDAIA — Arabic/RTL/residency change: _____

## Screenshots / logs (optional)

<!-- For UI changes or behavior that's easier shown than described. -->

## Reviewer checklist

- [ ] CI green (hooks regression + JSON validate + token budget + markdown lint).
- [ ] CODEOWNERS-required reviews completed.
- [ ] No new secrets, no `.env*` files, no debug statements (pre-commit hook should block, but eyes verify).
- [ ] If new agents/skills: registered in CLAUDE.md and `Training/03-SKILLS-MANUAL.md`.
- [ ] If breaking change: CHANGELOG entry under the upcoming version.
- [ ] If touching `.github/`: branch protection rules still satisfied.

## Licensing / CLA

<!-- CCM v4.0.0+ is PolyForm Noncommercial (free noncommercial) + paid commercial
licenses. Contributions need the CLA so they can be included in commercial builds. -->

- [ ] I have read and agree to the **Contributor License Agreement** ([`.github/CLA.md`](CLA.md)) — I keep my copyright but grant arib.sa the right to license my contribution under the project's terms, **including commercial licenses**.
- [ ] My commits are **signed off** (`git commit -s` → `Signed-off-by:`, the [DCO](https://developercertificate.org/)).
- [ ] If contributing on behalf of an employer: I am authorized to bind it (Entity path in `.github/CLA.md`).
