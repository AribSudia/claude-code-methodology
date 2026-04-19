# Workflow — Git Flow & Development Pipeline

> **Purpose**: Defines how code moves from idea to production.
> Every developer (human or AI) follows this exact flow.

---

## 1. Branch Strategy

```
main ─────────────────────────────────── production (stable, deployed)
  │
  └── develop ────────────────────────── integration (latest features)
        │
        ├── feature/user-auth ────────── one feature per branch
        ├── feature/payment-flow
        ├── fix/login-timeout
        └── hotfix/security-patch ────── urgent production fixes
```

### Branch Rules

| Branch     | Created From | Merges Into      | Protected | Review Required |
|------------|-------------|------------------|-----------|-----------------|
| main       | —           | —                | Yes       | —               |
| develop    | main        | main (release)   | Yes       | Yes             |
| feature/*  | develop     | develop          | No        | Yes             |
| fix/*      | develop     | develop          | No        | Yes             |
| hotfix/*   | main        | main + develop   | No        | Yes             |
| release/*  | develop     | main + develop   | No        | Yes             |

### Branch Naming

```
feature/[ticket-id]-short-description    → feature/MG-042-user-registration
fix/[ticket-id]-short-description        → fix/MG-105-login-timeout
hotfix/[ticket-id]-short-description     → hotfix/MG-200-xss-vulnerability
release/v[major].[minor].[patch]         → release/v1.2.0
```

---

## 2. Commit Convention

### Format

```
[type]: concise description

Optional body explaining WHY this change was made.

Optional footer: Refs #ticket-id
```

### Allowed Types

| Type       | When to Use                                    | Example                          |
|------------|------------------------------------------------|----------------------------------|
| `feat`     | New feature or capability                      | `[feat]: add user registration`  |
| `fix`      | Bug fix                                        | `[fix]: resolve login timeout`   |
| `refactor` | Code improvement, no behavior change           | `[refactor]: extract auth service`|
| `test`     | Adding or improving tests                      | `[test]: add payment flow tests` |
| `docs`     | Documentation only                             | `[docs]: update API reference`   |
| `chore`    | Tooling, deps, config                          | `[chore]: update dependencies`   |
| `snapshot` | Safety checkpoint before risky changes          | `[snapshot]: before auth refactor`|
| `security` | Security-related changes                       | `[security]: fix XSS in search`  |

### Commit Rules

- One logical change per commit (not "fix everything")
- Present tense ("add feature" not "added feature")
- No period at the end of the subject line
- Subject line max 72 characters
- Body wraps at 80 characters
- Reference ticket IDs in footer

---

## 3. Pull Request Requirements

### Before Opening a PR

- [ ] All tests pass locally
- [ ] Linting passes with zero warnings
- [ ] Type checking passes (if applicable)
- [ ] No secrets in code or config files
- [ ] Documentation updated for any API/behavior changes
- [ ] Memory files updated (change_log, project_status)
- [ ] Self-review completed (read your own diff)

### PR Template

```markdown
## What This PR Does
[One paragraph describing the change and WHY it was needed]

## Changes
- [File/module]: [what changed]

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed
- [ ] Edge cases tested

## Checklist
- [ ] Tests pass
- [ ] No secrets committed
- [ ] Docs updated
- [ ] Memory files updated
```

### Review Requirements

- Minimum 1 approval required
- All CI checks must pass
- No unresolved comments
- Security-sensitive changes require 2 approvals

---

## 4. Definition of Done

A feature is "done" when ALL of these are true:

- [ ] Code is implemented and working
- [ ] Tests are written and passing (meets coverage targets)
- [ ] Code review approved
- [ ] Documentation updated
- [ ] Memory files updated (project_status, change_log)
- [ ] No TODO/FIXME left without a ticket reference
- [ ] Accessibility checked (if UI change)
- [ ] Performance acceptable (no N+1, pagination used)
- [ ] Security checked (input validation, auth, no secrets)
- [ ] Merged to develop branch

---

## 5. CI/CD Pipeline

```
Stage 1: LINT          → ESLint/Prettier (fail-fast)
Stage 2: TYPE CHECK    → TypeScript/C# compiler (fail-fast)
Stage 3: UNIT TEST     → Fast tests, no external deps
Stage 4: BUILD         → Compile/bundle the application
Stage 5: INTEGRATION   → Tests with real DB/services
Stage 6: SECURITY      → Dependency audit, secret scan
Stage 7: E2E           → Playwright/Cypress critical paths
Stage 8: DEPLOY        → Staging first, then production
```

### Pipeline Rules

- Stages 1-3 must complete in under 5 minutes
- Any stage failure stops the pipeline
- E2E tests run on staging environment
- Production deploy requires manual approval

---

## 6. Release Process

### Version Numbering (Semantic Versioning)

```
MAJOR.MINOR.PATCH
  │     │     └── Bug fixes, no API changes
  │     └──────── New features, backward compatible
  └────────────── Breaking changes
```

### Release Steps

1. Create release branch: `release/v1.2.0` from `develop`
2. Update version numbers in package.json / project files
3. Update CHANGELOG with release notes
4. Run full test suite + security audit
5. Merge to `main` with tag: `git tag v1.2.0`
6. Merge back to `develop`
7. Deploy to production
8. Monitor for 30 minutes post-deploy
9. Update memory/project_status.md

### Rollback Procedure

```bash
# If production breaks after deploy:
git revert [commit-hash]           # Revert the problematic commit
git push origin main               # Push the revert
# Re-deploy from main
# Investigate on a separate branch
```

---

## 7. Daily Workflow Pattern

```
$ cd project && claude code

> /session-start                    ← Read context, check status
> Shift+Tab → Tab → Tab            ← Plan Mode
> Describe feature intent           ← Claude plans before coding
> /new-feature [name]              ← Proper feature workflow
> ... build ...                     ← TDD, commit per task
> /review                          ← Before merging
> /session-end                     ← Save memory, push
```

---

> **End of Workflow**
> Consistency is what separates professional teams from chaotic ones.
> Follow this flow every time.
