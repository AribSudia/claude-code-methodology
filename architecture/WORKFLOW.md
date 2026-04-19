# WORKFLOW — Git Workflow and Dev Pipeline for [PROJECT]

This document defines the branch strategy, commit conventions, PR requirements, and CI/CD pipeline for [PROJECT].

---

## Branch Strategy

### Branch Naming and Hierarchy

```
main (production)
  ├── release/x.y.z (release prep)
  └── hotfix/xxx (production bugs)

develop (integration)
  └── feature/xxx (new features)
      ├── feature/user-auth
      ├── feature/payment-integration
      └── ...
```

### Main
- **Protection:** Requires PR review, all CI checks pass, no force-push.
- **Access:** Deployers only; developers cannot push directly.
- **Contents:** Stable, tested, production-ready code.
- **Tagging:** Every merge to main creates a semantic version tag (v1.2.3).
- **Deployment:** Automatically deployed to production (or manual gate if needed).

### Develop
- **Protection:** Requires PR review, all CI checks pass, no force-push.
- **Access:** Developers via PR only.
- **Contents:** Integrated features, ready for next release.
- **Deployment:** Deployed to staging environment for QA.

### Feature Branches
- **Naming:** `feature/short-description` (kebab-case, no slashes beyond prefix).
  - Examples: `feature/user-authentication`, `feature/payment-processor`
- **Base:** Off `develop` only.
- **Rebase:** Rebase on develop before PR to keep history clean.
- **Deletion:** Delete after merge (keep repository clean).
- **Lifespan:** Max 2 weeks; if longer, break into smaller features.

### Hotfix Branches
- **Naming:** `hotfix/issue-description` (kebab-case).
  - Example: `hotfix/critical-payment-bug`
- **Base:** Off `main` only.
- **Merge:** Back into both `main` and `develop`.
- **Urgency:** Deploy within 24 hours.
- **PR:** Expedited review (1 reviewer minimum).

### Release Branches
- **Naming:** `release/x.y.z` (semantic versioning).
  - Example: `release/1.2.0`
- **Base:** Off `develop`.
- **Purpose:** Final testing, version bumps, release notes.
- **Duration:** No feature work; bug fixes and doc updates only.
- **Merge:** Into `main` (creates tag) and back into `develop`.

---

## Commit Convention

### Format
```
[type]: description
```

### Allowed Types
- **feat** — New feature or capability.
- **fix** — Bug fix.
- **refactor** — Code restructuring without behavior change.
- **test** — Test additions or fixes.
- **docs** — Documentation changes.
- **chore** — Tooling, dependency updates, config.
- **snapshot** — Point-in-time snapshot (intermediate; don't commit to main).
- **security** — Security patch or hardening.

### Description Rules
- Lowercase, imperative mood, no period.
- One line; if more detail needed, add blank line + body (optional).
- Reference ticket: `feat: add user pagination (PROJ-123)`
- Max 72 characters for the subject line.

### Examples
```
feat: add two-factor authentication for admin users
fix: correct timezone calculation in billing report
refactor: extract database query logic into service layer
test: add unit tests for payment processor
docs: update API authentication guide
chore: upgrade Express to 4.18.0
security: sanitize SQL queries in user search (CVE-2024-1234)
```

### Enforcement
- Git commit-msg hook rejects non-conforming commits.
- Linter in CI checks commit history on PR.
- Force-push to `main` and `develop` is blocked.

---

## Pull Request Requirements

### Checklist Before Opening PR
- [ ] Branch rebased on latest `develop` (or `main` for hotfix).
- [ ] All tests pass locally: `npm test` or `./gradlew test`.
- [ ] Code follows linter rules: `npm run lint -- --fix`.
- [ ] No debugging code (`console.log`, `debugger`, prints).
- [ ] No secrets in code (run secret scanner).
- [ ] Commits follow convention: `[type]: description`.

### PR Title and Description
- **Title:** Same as first commit message, or summarized feature name.
- **Description:** Include:
  - What this PR does (1-2 sentences).
  - Why it's needed (business context or ticket link).
  - How to test it (steps or test command).
  - Screenshots/video if UI change.
  - Anything reviewers should know (breaking changes, database migration, dependencies).

### Review Requirements
- **Minimum reviewers:** 1 (or 2 for security/critical changes).
- **Approvals:** All reviewers must approve before merge.
- **Time:** Allow 24 hours for review unless urgent hotfix.
- **Address feedback:** Don't dismiss; reply or commit fixes. Amend commits if needed.
- **Re-review:** Ping reviewer after addressing all comments.

### CI/CD Gates
- ✓ All tests pass (unit, integration, E2E).
- ✓ Code coverage meets threshold (70% minimum).
- ✓ Linter/formatter checks pass.
- ✓ No high-severity security vulnerabilities.
- ✓ No force-push history.
- ✓ Branch is up-to-date with base (no conflicts).

### Merge Policy
- **Method:** Squash or rebase (depending on [PROJECT] preference).
  - Squash: 1 commit per PR to `develop`/`main` (cleaner history).
  - Rebase: Preserve individual commits (better for blame/bisect).
- **Delete branch:** Always delete feature branch after merge.
- **No merge commits:** Use squash or rebase, not merge commit.

---

## Definition of Done

A PR is "done" when it satisfies ALL of:

- [ ] Code is written and reviewed.
- [ ] All tests pass (unit, integration, E2E).
- [ ] Code coverage is 70%+.
- [ ] Linter/formatter passes without warnings.
- [ ] No merge conflicts.
- [ ] Documentation is updated (README, API docs, wiki).
- [ ] Commit messages follow convention.
- [ ] No secrets or sensitive data in code.
- [ ] Database migrations are tested (if applicable).
- [ ] Breaking changes are documented.
- [ ] Browser compatibility tested (if frontend).
- [ ] Accessibility (a11y) checked (if UI).
- [ ] Performance impact assessed (queries, bundle size).
- [ ] Security review completed (if security-related).
- [ ] Approved by at least 1 reviewer.
- [ ] Merged to target branch.
- [ ] Feature branch deleted.

---

## CI/CD Pipeline Stages

### Stage 1: Code Lint & Format
**Trigger:** Push to any branch.  
**Actions:**
- Run linter (ESLint, Prettier, etc.).
- Check commit message format.
- Scan for secrets (git-secrets, TruffleHog).
- **Fail condition:** Linter errors, secret detected, bad commits.

### Stage 2: Build
**Trigger:** Lint passes.  
**Actions:**
- Compile/bundle application.
- Verify no build errors.
- Generate artifact (JAR, Docker image, static assets).
- **Fail condition:** Build errors, missing dependencies.

### Stage 3: Unit & Integration Tests
**Trigger:** Build succeeds.  
**Actions:**
- Run unit tests.
- Run integration tests.
- Calculate code coverage.
- **Fail condition:** Test failures, coverage < 70%.

### Stage 4: Security Scanning
**Trigger:** Tests pass.  
**Actions:**
- Dependency vulnerability check (npm audit, OWASP Dependency-Check).
- Static application security testing (SAST) if applicable.
- Container image scan (if using Docker).
- **Fail condition:** High-severity vulnerability detected.

### Stage 5: E2E Tests (Feature Branches Only)
**Trigger:** All above pass.  
**Actions:**
- Spin up staging environment.
- Run end-to-end tests against staging.
- Tear down environment.
- **Fail condition:** E2E test failures.

### Stage 6: Code Review Gate
**Trigger:** All automated checks pass.  
**Actions:**
- Send notification to reviewers.
- Block merge until approved.
- **Fail condition:** Review rejected, changes requested.

### Stage 7: Deploy to Staging
**Trigger:** PR merged to `develop`.  
**Actions:**
- Build artifact.
- Deploy to staging environment.
- Run smoke tests.
- **Fail condition:** Deployment error, smoke test failure.

### Stage 8: Deploy to Production
**Trigger:** PR merged to `main` OR manually triggered.  
**Actions:**
- Build artifact.
- Blue-green deploy (or canary).
- Run health checks.
- Monitor error rates for 10 minutes.
- Rollback if error rate spikes.
- **Fail condition:** Deployment error, health check failure, high error rate.

---

## Release Process

### Version Numbering
Use Semantic Versioning (MAJOR.MINOR.PATCH):
- **MAJOR:** Breaking changes to API or data model.
- **MINOR:** New features, backward-compatible.
- **PATCH:** Bug fixes, no new features.

Example: `v1.2.3`

### Release Steps
1. **Create release branch** off `develop`: `release/1.2.0`
2. **Bump version** in package.json, build config, etc.
3. **Update CHANGELOG.md** with new features, fixes, breaking changes.
4. **PR from release branch to main.**
5. **Review and approve** (same as feature PR).
6. **Merge to main** → creates tag v1.2.0 → triggers deployment.
7. **Merge release branch back to develop** (to sync version numbers).
8. **Delete release branch.**

### Release Notes Template
```markdown
# v1.2.0 (2024-04-15)

## Features
- Add user pagination to list endpoint (#PROJ-123)
- Support JWT expiration configuration (#PROJ-124)

## Bug Fixes
- Fix timezone calculation in billing report (#PROJ-125)
- Correct race condition in payment processor (#PROJ-126)

## Breaking Changes
- Deprecated `/api/v1/users` endpoint; use `/api/v2/users` instead.

## Migration Guide
- Update client calls from `/api/v1/users?page=1` to `/api/v2/users?offset=0&limit=20`.
```

### Rollback Procedure
If production deployment is unstable:
1. Notify team on Slack/Discord.
2. Switch traffic to previous version (blue-green) or deploy previous tag.
3. Trigger incident post-mortem.
4. Create hotfix branch from failed commit.

---

## [PROJECT]-Specific Workflow Customizations

**TODO: Add project-specific workflow rules here.**

Examples:
- Multi-team workflows (frontend, backend, data science teams).
- Environment-specific deployment gates (QA approval, compliance review).
- On-call rotation and incident response.
- Feature flag strategy for safe deployments.
- Database migration strategy (backward compatibility, zero-downtime).

---

## Tools and Automation

### Git Hooks
- **pre-commit:** Run linter, format check.
- **commit-msg:** Validate commit message format.
- **pre-push:** Run tests locally before push (optional; can slow workflow).

Install: `npm run setup-hooks` or `husky install`

### CI/CD Platform
- **GitHub Actions** (if using GitHub)
- **GitLab CI** (if using GitLab)
- **Jenkins** (if self-hosted)
- **CircleCI** or **Travis CI** (if third-party)

### Monitoring & Alerts
- **Deployment notifications:** Slack channel `#deployments`
- **Build failure alerts:** Email to team
- **Production error alerts:** PagerDuty (if applicable)

---

## Troubleshooting

### "My branch has conflicts with develop"
```bash
git fetch origin
git rebase origin/develop
# Fix conflicts in your editor
git add .
git rebase --continue
git push origin feature/xxx --force-with-lease
```

### "I force-pushed to a shared branch by mistake"
Contact the tech lead; they can revert the branch state from backup.

### "CI is failing on my PR"
1. Check the CI logs (click "Details" on the PR).
2. Run the failing step locally to reproduce.
3. Commit a fix and push (don't amend, unless draft PR).

### "I need to merge my PR but a reviewer is on vacation"
Request a second reviewer or escalate to tech lead. Never merge without approval.

---

## Review Schedule

Last updated: [DATE]  
Next review: [DATE + 6 months]  
Owner: [PROJECT] Tech Lead
