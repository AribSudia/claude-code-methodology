CLAUDE CODE METHODOLOGY: AGENT DEFINITIONS
===========================================

This directory contains 8 comprehensive agent definition files that implement
the Claude Code methodology for software development. Each agent enforces
specific quality gates and best practices.

AGENTS DEFINED:

1. architect.md (1,864 words)
   - Senior software architect
   - Activates on: design, plan, schema, architecture
   - Output: PROPOSED DESIGN → TRADE-OFFS → ALTERNATIVES → AWAITING APPROVAL
   - Constraint: Never codes before plan approval
   - Real-world examples: API design, database schema, microservices architecture

2. security-auditor.md (3,437 words)
   - OWASP Top 10:2025 & ASVS 5.0 expert
   - Activates on: auth, payments, user data, file uploads, API keys
   - Output: SECURITY AUDIT REPORT with pass/fail per item
   - Coverage: All 10 OWASP categories + ASVS Level 2
   - Real-world examples: Authentication review, file upload security

3. code-reviewer.md (2,757 words)
   - Senior code reviewer
   - Activates on: review, PR reviews, before merge
   - Checks: functions <30 lines, files <300 lines, no duplication, no secrets, tests written
   - Output: APPROVED or NEEDS CHANGES with specific feedback
   - Coverage targets: Services 80%, API 70%, Utils 60%, UI 50%

4. test-engineer.md (2,466 words)
   - TDD specialist
   - Activates on: test, coverage, spec
   - Enforces: RED-GREEN-REFACTOR cycle
   - Coverage targets: Services 80%, API 70%, Utils 60%
   - Real-world examples: Unit test TDD cycle, integration tests

5. debugger.md (3,584 words)
   - Scientific debugging methodology
   - Activates on: bug, broken, error, failing
   - Protocol: Read error → 3 hypotheses → test one at a time → fix → verify → document
   - Constraint: Never guesses, never changes multiple things at once
   - Real-world examples: Race conditions, database connection exhaustion

6. refactor-specialist.md (2,406 words)
   - Refactoring expert
   - Activates on: refactor, cleanup, improve
   - Rules: tests pass before AND after, one refactor type at a time, separate commits
   - Constraint: Never changes behavior during refactoring
   - Real-world examples: Extract functions, consolidate duplication

7. language.md (~4,000 words)
   - Universal Language & Localization specialist
   - Activates on: any language name, script name, locale code, i18n, l10n, RTL, LTR, CJK
   - Rules: zero hardcoded strings, CSS logical properties, Intl APIs, proper dir attributes
   - Covers: RTL (Arabic, Hebrew, Persian, Urdu), LTR (Latin, Cyrillic), CJK (Chinese, Japanese, Korean), Indic (Hindi, Bengali, Tamil, Thai), Bidirectional
   - Includes: Script Direction Registry, Font Family Map, Locale Config Map for 18+ locales

8. deploy-guardian.md (2,861 words)
   - Deployment gatekeeper
   - Activates on: deploy, ship, release, production
   - Runs: lint → type-check → test → build → security scan → env check → migration check
   - All checks must pass before deployment
   - Output: CLEARED FOR DEPLOY or BLOCKED with reasons
   - Real-world examples: Low-risk feature, high-risk database migration

TOTAL: 21,881 words across 8 comprehensive agent definitions

USAGE:
------
Each agent file defines:
- Identity & expertise
- Auto-activation rules
- Mandatory checklist
- Output format
- Constraints
- Real-world examples

These files serve as:
1. Training material for team onboarding
2. Reference guides for quality standards
3. Templates for automated agents/CI rules
4. Documentation of methodology and best practices

PROJECT-AGNOSTIC DESIGN:
All agents use [PROJECT] placeholders where domain-specific examples are needed,
making them applicable across codebases and technologies.

Created: 2026-04-15
