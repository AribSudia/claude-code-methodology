# CI / PR rules

> **Scope:** loads when working in `.github/**`, `CONTRIBUTING.md`,
> `SECURITY.md` (repo-root), `CODE_OF_CONDUCT.md`, or any file path
> matching `*workflow*.yml` / `*workflow*.yaml`.

When working with CI/PR governance:

1. **Workflows are user-facing contracts.** A failing workflow blocks
   merges. Don't add a workflow that fails on the current main —
   verify it passes on a representative branch first.

2. **Required status checks must exist before they're required.** If
   you rename a workflow job, update branch protection settings the
   same PR. A "required check" that doesn't run is a permanent block.

3. **PR template is binding.** Every section that's not "(if
   applicable)" must be filled. Empty PR descriptions get bounced
   automatically by the maintainer; CODEOWNERS reviews wait until
   the description is complete.

4. **CODEOWNERS auto-requests review.** Adding a path to CODEOWNERS
   means every PR touching it waits on the listed owner. Don't add
   paths casually; review-fatigue is real.

5. **Token-budget regression is a real check.** If you touch
   `context.include` files or `.claude/rules/*.md`, the
   `token-budget` workflow comments a delta on the PR. Justify
   regressions of >5K tokens in the PR description; ≥10K fails CI.

6. **Branch protection settings are documented in CONTRIBUTING.md.**
   They are applied once in the GitHub web UI by the repo owner.
   Changes to those settings should be announced in CHANGELOG.

7. **Direct push to main is for emergencies only.** Document any
   direct push in `operations/OPERATIONS_LOG.md` with reason and
   rollback plan. The maintainer reserves direct-push for hotfixes
   and CI-broken-on-main scenarios.

8. **CI must run on macOS too if a hook uses BSD-only syntax.** The
   `autonomy-guard.sh` hook uses `date -j -f` (BSD) with a
   `date -d` fallback (GNU). If you add similar OS-specific code,
   add a matrix run to the workflow.

9. **Dependabot PRs are still PRs.** They go through the same review.
   Group security patches; auto-merge is OK after CI passes for
   patch-level updates only.

10. **Conventional Commits are enforced by convention, not by
    bot.** `commitlint` is not installed. The PR template's "Type"
    section catches most drift. If you want stricter enforcement,
    add a workflow.

The PR template, CODEOWNERS, CONTRIBUTING.md, and SECURITY.md are the
written contract; this rules file is the path-scoped guidance Claude
loads when editing them.

## Related

- `CONTRIBUTING.md` — full contribution workflow.
- `SECURITY.md` — vulnerability disclosure.
- `.github/PULL_REQUEST_TEMPLATE.md` — what every PR includes.
- `.github/CODEOWNERS` — review routing.
- `.github/workflows/` — the actual CI surface.
- `Training/11-CI-PR-MANUAL.md` — user-facing manual.
- `architecture/DECISIONS.md` ADR-012 — the decision record.
