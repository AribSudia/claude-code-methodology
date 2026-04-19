# Claude Code Skills Registry

**Version:** 1.0  
**Last Updated:** April 2026  
**Purpose:** Comprehensive catalog of all skills available in the Claude Code ecosystem, organized by domain with activation triggers, installation commands, and priority levels.

---

## CATEGORY A: World-Class Coding Skills

These are production-grade skills for building robust, secure, and maintainable software systems.

### 1. frontend-design (Anthropic Official)

**Source:** Anthropic official skill  
**Description:** Master distinctive UI design that escapes "AI slop" aesthetics. Implements design principles for visual hierarchy, typography, spacing, color theory, and component patterns. Focuses on Anthropic design standards and modern frontend best practices.

**Auto-Activation Triggers:**
- File types: `.jsx`, `.tsx`, `.css`, `.html`, UI component files
- Keywords: "design", "UI", "component", "layout", "styles", "visual", "aesthetic"
- Context: When designing new components or refactoring visual systems

**Installation Command:**
```bash
claude code install frontend-design
```

**Priority:** Critical  
**Tags:** Design, Frontend, Anthropic Official  
**Typical Workflow:**
1. Design component structure and layout
2. Implement Anthropic design standards
3. Create component variants for different states
4. Ensure accessibility and responsive design
5. Review visual hierarchy and typography

---

### 2. systematic-debugging

**Source:** Claude Code Official Skill  
**Description:** Scientific method debugging protocol. Implements structured debugging workflow: observe symptoms, form hypotheses, design experiments, gather evidence, and draw conclusions. Eliminates guesswork from bug fixing.

**Auto-Activation Triggers:**
- Keywords: "bug", "debug", "error", "issue", "not working", "broken"
- File types: Error logs, stack traces, test failures
- Context: When troubleshooting unexpected behavior

**Installation Command:**
```bash
claude code install systematic-debugging
```

**Priority:** Critical  
**Tags:** Debugging, Problem-Solving, Testing  
**Typical Workflow:**
1. Document reproducible steps
2. Gather stack traces and logs
3. Isolate the minimum reproducible case
4. Form testable hypotheses
5. Implement targeted experiments
6. Verify fix with regression tests

---

### 3. superpowers (obra/superpowers)

**Source:** https://github.com/obra/superpowers  
**Description:** Multi-agent development workflow with test-driven development (TDD) integration. Enables complex feature development through agent coordination, automated testing, and continuous validation.

**Auto-Activation Triggers:**
- Keywords: "multi-agent", "feature development", "complex task", "breakdown"
- Context: Large features requiring multiple steps or coordinated changes
- File types: Test files, feature branches

**Installation Command:**
```bash
claude code install obra/superpowers
```

**Priority:** High  
**Tags:** Multi-Agent, TDD, Workflow Automation  
**Typical Workflow:**
1. Break feature into agent-compatible subtasks
2. Define acceptance criteria with tests
3. Coordinate agents for implementation
4. Run automated verification
5. Integrate and validate

---

### 4. webapp-testing

**Source:** Claude Code Official Skill  
**Description:** Complete Playwright E2E testing framework integration. Covers test creation, assertion patterns, visual regression testing, accessibility testing, and CI/CD pipeline integration.

**Auto-Activation Triggers:**
- File types: `.test.ts`, `.spec.ts`, `playwright.config.ts`
- Keywords: "E2E", "end-to-end", "test", "browser", "playwright", "integration test"
- Context: When writing or fixing web application tests

**Installation Command:**
```bash
claude code install webapp-testing
```

**Priority:** Critical  
**Tags:** Testing, Playwright, QA  
**Typical Workflow:**
1. Define test scenarios
2. Write Playwright test code
3. Implement assertions and matchers
4. Handle async operations and waits
5. Configure CI/CD integration
6. Monitor flakiness and performance

---

### 5. owasp-security

**Source:** Claude Code Official Skill  
**Description:** OWASP Top 10:2025 security audit and remediation. Covers authentication, authorization, injection attacks, XSS, CSRF, security misconfiguration, sensitive data exposure, and more.

**Auto-Activation Triggers:**
- Keywords: "security", "vulnerability", "auth", "XSS", "injection", "CSRF", "encrypt"
- File types: Any code files during security audit
- Context: Before production deployment, during code review, security incident investigation

**Installation Command:**
```bash
claude code install owasp-security
```

**Priority:** Critical  
**Tags:** Security, Compliance, OWASP  
**Typical Workflow:**
1. Identify security context and data flows
2. Check against OWASP Top 10:2025
3. Scan for common vulnerability patterns
4. Provide remediation recommendations
5. Implement and verify fixes
6. Document security decisions

---

### 6. varlock

**Source:** Claude Code Official Skill  
**Description:** Secrets management and environment variable security. Prevents accidental exposure of API keys, database credentials, and sensitive configuration data in code and version control.

**Auto-Activation Triggers:**
- Keywords: "secret", "API key", "password", "token", "credential", "env var"
- Patterns: Detecting hardcoded secrets, API keys, database URLs
- File types: `.env`, `.env.example`, `config.ts`, `settings.py`
- Context: Pre-commit hooks, code review, security audit

**Installation Command:**
```bash
claude code install varlock
```

**Priority:** Critical  
**Tags:** Secrets, Security, Environment Configuration  
**Typical Workflow:**
1. Scan codebase for exposed secrets
2. Validate .env file structure
3. Check git history for leaked credentials
4. Implement secure configuration patterns
5. Integrate with CI/CD secret scanning
6. Document secret rotation procedures

---

### 7. test-driven-development

**Source:** Claude Code Official Skill  
**Description:** RED-GREEN-REFACTOR enforcement. Implements strict TDD workflow where tests drive design, ensuring comprehensive test coverage and maintainable code architecture.

**Auto-Activation Triggers:**
- Keywords: "TDD", "test-driven", "RED-GREEN", "unit test", "write test first"
- Context: New feature development, refactoring
- File types: Test files, feature files

**Installation Command:**
```bash
claude code install test-driven-development
```

**Priority:** High  
**Tags:** Testing, TDD, Development Process  
**Typical Workflow:**
1. Write failing test (RED)
2. Implement minimal code to pass (GREEN)
3. Refactor for clarity and performance (REFACTOR)
4. Repeat until feature complete
5. Achieve high code coverage
6. Document test intent

---

### 8. software-architecture

**Source:** Claude Code Official Skill  
**Description:** System design patterns, scalability considerations, and architectural decision records. Covers layering, dependency management, coupling/cohesion, performance optimization, and cloud-native patterns.

**Auto-Activation Triggers:**
- Keywords: "architecture", "design pattern", "scalability", "performance", "structure", "refactor"
- Context: Large system design, performance issues, technical debt
- File types: Architecture documentation, core service files

**Installation Command:**
```bash
claude code install software-architecture
```

**Priority:** High  
**Tags:** Architecture, Design Patterns, Scalability  
**Typical Workflow:**
1. Analyze current system structure
2. Identify architectural issues and bottlenecks
3. Propose pattern-based solutions
4. Document architectural decisions (ADR)
5. Implement refactoring in phases
6. Validate performance and maintainability

---

### 9. code-review

**Source:** Claude Code Official Skill  
**Description:** Automated PR review checklist covering correctness, performance, security, style, documentation, and testing. Provides consistent review standards across teams.

**Auto-Activation Triggers:**
- Keywords: "review", "PR", "pull request", "merge", "code quality"
- Context: Before merging pull requests
- File types: Any changed files in PR context

**Installation Command:**
```bash
claude code install code-review
```

**Priority:** High  
**Tags:** Code Quality, Review, Standards  
**Typical Review Checklist:**
- Correctness: Does code do what it claims?
- Performance: Are there optimization opportunities?
- Security: Are there vulnerability patterns?
- Style: Does it follow project conventions?
- Testing: Is coverage adequate?
- Documentation: Are changes documented?
- Dependencies: Are new dependencies justified?

---

### 10. playwright-skill

**Source:** Claude Code Official Skill  
**Description:** Advanced browser automation with Playwright. Covers complex interactions, visual testing, performance profiling, and handling of edge cases in web application testing.

**Auto-Activation Triggers:**
- Keywords: "browser automation", "playwright", "visual test", "screenshot", "DOM"
- File types: `.test.ts`, `.spec.ts` files
- Context: Advanced E2E testing, visual regression, browser profiling

**Installation Command:**
```bash
claude code install playwright-skill
```

**Priority:** High  
**Tags:** Testing, Automation, Playwright  
**Typical Workflow:**
1. Set up Playwright environment
2. Define test scenarios
3. Implement page objects and helpers
4. Handle async browser operations
5. Capture screenshots and videos
6. Analyze performance metrics
7. Configure visual regression testing

---

### 11. subagent-driven-development

**Source:** Claude Code Official Skill  
**Description:** Multi-agent task decomposition and coordination. Breaks complex features into sub-tasks that independent agents can execute in parallel, with automatic integration and validation.

**Auto-Activation Triggers:**
- Keywords: "subagent", "multi-agent", "parallel development", "task breakdown", "coordination"
- Context: Large features, performance-sensitive work
- File types: Task definition files, integration tests

**Installation Command:**
```bash
claude code install subagent-driven-development
```

**Priority:** High  
**Tags:** Multi-Agent, Workflow, Automation  
**Typical Workflow:**
1. Decompose feature into independent tasks
2. Define interfaces and contracts
3. Assign tasks to agents
4. Monitor parallel execution
5. Integrate results
6. Run full validation

---

### 12. changelog-generator

**Source:** Claude Code Official Skill  
**Description:** Automatic changelog generation from Git commit messages. Parses conventional commits, semantic versioning, and categories to maintain human-readable change logs.

**Auto-Activation Triggers:**
- Keywords: "changelog", "release notes", "version", "CHANGELOG.md"
- Context: Before release, as part of CI/CD
- File types: Git history, CHANGELOG.md

**Installation Command:**
```bash
claude code install changelog-generator
```

**Priority:** Medium  
**Tags:** Release Management, Documentation, Automation  
**Typical Workflow:**
1. Ensure conventional commit format
2. Run changelog generator
3. Review and categorize entries
4. Update version numbers
5. Create release notes
6. Tag release in Git

---

### 13. using-git-worktrees

**Source:** Claude Code Official Skill  
**Description:** Parallel feature development using Git worktrees. Enables isolated working directories for different branches without context switching in a single directory.

**Auto-Activation Triggers:**
- Keywords: "worktree", "parallel branch", "context switch", "isolation"
- Context: Managing multiple features or fixes simultaneously
- File types: Git configuration, branch-related files

**Installation Command:**
```bash
claude code install using-git-worktrees
```

**Priority:** Medium  
**Tags:** Git, Workflow, Productivity  
**Typical Workflow:**
1. Create worktree for new feature
2. Develop in isolated directory
3. Test and commit changes
4. Create PR from worktree
5. Clean up worktree after merge
6. Maintain multiple worktrees concurrently

---

### 14. finishing-branch

**Source:** Claude Code Official Skill  
**Description:** Comprehensive branch completion checklist. Ensures all work is done before merging: tests pass, documentation complete, no TODOs, security checks passed, code reviewed.

**Auto-Activation Triggers:**
- Keywords: "merge", "ready to merge", "complete", "finish branch", "cleanup"
- Context: Before creating pull request
- File types: Any changed files

**Installation Command:**
```bash
claude code install finishing-branch
```

**Priority:** Medium  
**Tags:** Workflow, Quality Assurance, Git  
**Pre-Merge Checklist:**
- All tests passing locally and in CI
- Code review completed
- Security audit passed
- Documentation updated
- TODOs resolved or documented
- No console errors or warnings
- Performance benchmarks acceptable
- Accessibility checks passed
- Branch up-to-date with main

---

### 15. supermemory

**Source:** Claude Code Official Skill  
**Description:** Enhanced persistent memory across sessions. Maintains context between coding sessions, remembering architectural decisions, known issues, and project-specific knowledge.

**Auto-Activation Triggers:**
- Keywords: "remember", "context", "previous session", "decision", "known issue"
- Context: Starting new session, resuming work
- File types: Memory files, project documentation

**Installation Command:**
```bash
claude code install supermemory
```

**Priority:** High  
**Tags:** Productivity, Context Management, Memory  
**Typical Workflow:**
1. Load session memory at startup
2. Review architectural decisions
3. Check known issues and workarounds
4. Access previous debugging notes
5. Update memory with new findings
6. Persist context for next session

---

## CATEGORY B: Design, Marketing, Automation & Enhanced Tools

Skills for workflow automation, research, marketing, and extended Claude capabilities.

### 1. autoresearch

**Source:** Claude Code Official Skill  
**Description:** Automated research and summarization. Searches multiple sources, synthesizes findings, and generates comprehensive research reports without human intervention.

**Auto-Activation Triggers:**
- Keywords: "research", "investigate", "survey", "benchmark", "market analysis"
- Context: Competitive analysis, technology evaluation, market research
- File types: Research requests, analysis documents

**Installation Command:**
```bash
claude code install autoresearch
```

**Priority:** Medium  
**Tags:** Research, Automation, Analysis  
**Typical Workflow:**
1. Define research question
2. Search multiple sources automatically
3. Evaluate source credibility
4. Synthesize findings
5. Generate report with citations
6. Create actionable recommendations

---

### 2. SuperClaude

**Source:** Claude Code Official Skill  
**Description:** Enhanced Claude capabilities harness. Provides meta-prompting, instruction amplification, and advanced reasoning patterns to unlock additional capabilities.

**Auto-Activation Triggers:**
- Keywords: "SuperClaude", "enhanced", "advanced reasoning", "complex problem"
- Context: Complex problem solving, multi-step reasoning
- File types: Complex prompts, strategy files

**Installation Command:**
```bash
claude code install SuperClaude
```

**Priority:** Medium  
**Tags:** Enhancement, Reasoning, Productivity  
**Typical Workflow:**
1. Activate SuperClaude mode
2. Provide complex problem statement
3. Enable advanced reasoning
4. Execute multi-step analysis
5. Synthesize results
6. Validate reasoning quality

---

### 3. marketing-skills

**Source:** Claude Code Official Skill  
**Description:** Content marketing automation. Generates marketing copy, social content, email campaigns, and promotional materials with brand consistency and audience targeting.

**Auto-Activation Triggers:**
- Keywords: "marketing", "content", "email", "social", "copy", "campaign", "promotion"
- Context: Marketing initiatives, content calendar, email campaigns
- File types: Marketing briefs, email templates, social posts

**Installation Command:**
```bash
claude code install marketing-skills
```

**Priority:** Medium  
**Tags:** Marketing, Content, Automation  
**Typical Workflow:**
1. Define marketing objective and audience
2. Generate content ideas
3. Create marketing copy variants
4. Schedule posts and campaigns
5. Track engagement and performance
6. Optimize based on metrics

---

### 4. ui-ux-pro-max

**Source:** Claude Code Official Skill  
**Description:** Comprehensive UI/UX toolkit with 50+ design styles, 161 color palettes, and 99 UX guidelines. Provides instant access to design patterns and visual systems.

**Auto-Activation Triggers:**
- Keywords: "UI", "UX", "design system", "color palette", "component", "style"
- File types: `.css`, `.tsx`, `.jsx`, design tokens
- Context: UI implementation, design system work

**Installation Command:**
```bash
claude code install ui-ux-pro-max
```

**Priority:** High  
**Tags:** Design, UI/UX, Visual Systems  
**Resources:**
- 50+ pre-built design styles
- 161 color palette combinations
- 99 documented UX guidelines
- Component pattern library
- Accessibility checklist

---

### 5. claude-mem (thedotmack/claude-mem)

**Source:** https://github.com/thedotmack/claude-mem  
**Description:** Persistent memory across sessions with automatic context preservation. Maintains session history, learning, and discoveries between Claude Code sessions.

**Auto-Activation Triggers:**
- Keywords: "remember", "memory", "session history", "context"
- Context: Session start and end
- File types: Memory/knowledge base files

**Installation Command:**
```bash
claude code install thedotmack/claude-mem
```

**Priority:** High  
**Tags:** Memory, Context, Persistence  
**Typical Workflow:**
1. Initialize memory database
2. Store session discoveries
3. Save architectural decisions
4. Log debugging insights
5. Retrieve context on session start
6. Update memory before session end

---

### 6. everything-claude-code

**Source:** Claude Code Official Skill  
**Description:** Complete Claude Code agent harness with integrated security scanning, linting, testing, and deployment verification. Provides comprehensive project management and safety gates.

**Auto-Activation Triggers:**
- Keywords: "full harness", "complete workflow", "end-to-end", "project setup"
- Context: Project initialization, comprehensive analysis
- File types: All project files

**Installation Command:**
```bash
claude code install everything-claude-code
```

**Priority:** Critical  
**Tags:** Framework, Comprehensive, Integration  
**Integrated Features:**
- Security vulnerability scanning
- Code quality linting
- Automated testing
- Performance profiling
- Deployment verification
- Documentation generation
- Dependency analysis
- Git integration

---

## CATEGORY C: Community Marketplace Skills (npx Install)

These skills are installed via `npx skills add` from the community marketplace.
They extend Claude Code with specialized capabilities.

### 1. UI-UX-Pro-Max

**Source:** https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
**Description:** 50+ design styles, 161 color palettes, 57 font pairings, 99 UX guidelines.
Transforms Claude Code from a code generator into a design-aware builder.

**Installation:**
```bash
npx skills add nextlevelbuilder/ui-ux-pro-max-skill@ui-ux-pro-max
```

**Priority:** High
**Tags:** UI, UX, Design System, Color, Typography

---

### 2. shadcn-ui

**Source:** Community skill
**Description:** Full shadcn/ui component library integration. Generates correct
imports, props, variants, and composition patterns for shadcn components.

**Installation:**
```bash
npx skills add giuseppe-trisciuoglio/developer-kit@shadcn-ui
```

**Priority:** High
**Tags:** UI Components, React, Tailwind, shadcn

---

### 3. web-accessibility

**Source:** Community skill
**Description:** WCAG 2.2 compliance, ARIA patterns, keyboard navigation,
screen reader optimization. Ensures every component is accessible.

**Installation:**
```bash
npx skills add supercent-io/skills-template@web-accessibility
```

**Priority:** High
**Tags:** Accessibility, WCAG, ARIA, A11y

---

### 4. web-design-guidelines

**Source:** Vercel Labs
**Description:** Modern web design guidelines — layout systems, responsive design,
typography scales, color systems, animation, and performance patterns.

**Installation:**
```bash
npx skills add vercel-labs/agent-skills@web-design-guidelines
```

**Priority:** High
**Tags:** Design, Responsive, Layout, Vercel

---

### 5. frontend-design (Anthropic Official)

**Source:** https://github.com/anthropics/skills
**Description:** Anthropic's official frontend design skill. Escapes "AI slop"
aesthetics with bold visual direction, intentional typography, purposeful color.

**Installation:**
```bash
npx skills add anthropics/skills@frontend-design
```

**Priority:** Critical
**Tags:** Frontend, Design, Anthropic Official

---

## CATEGORY D: Community Tools & Repositories

These are not individual skills but comprehensive tool collections and MCP
servers that enhance Claude Code's capabilities.

### 1. Claude Mem

**Source:** https://github.com/thedotmack/claude-mem
**Description:** Persistent memory across sessions — stop re-teaching Claude
your codebase. Maintains context, decisions, and discoveries automatically.

**Installation:**
```bash
git clone https://github.com/thedotmack/claude-mem.git
# Follow repo setup instructions
```

**Note:** The CCM methodology already includes a built-in Memory Protocol
(`memory/MEMORY_PROTOCOL.md`). Claude Mem can complement it with additional
persistence features.

**Priority:** High
**Tags:** Memory, Context, Persistence

---

### 2. LightRAG

**Source:** https://github.com/hkuds/lightrag
**Description:** Graph + vector RAG — lets Claude understand large codebases
structurally. Combines knowledge graph with vector search for deep code understanding.

**Installation:**
```bash
git clone https://github.com/hkuds/lightrag.git
pip install lightrag-hku
```

**Priority:** Medium
**Tags:** RAG, Knowledge Graph, Code Understanding

---

### 3. Everything Claude Code

**Source:** https://github.com/affaan-m/everything-claude-code
**Description:** Skills, instincts, security scanning, multi-language coverage —
full agent harness. A comprehensive collection of skills and configurations.

**Installation:**
```bash
git clone https://github.com/affaan-m/everything-claude-code.git
# Copy desired skills to ~/.claude/skills/
```

**Priority:** High
**Tags:** Framework, Multi-language, Security, Comprehensive

---

### 4. Awesome Claude Code

**Source:** https://github.com/hesreallyhim/awesome-claude-code
**Description:** Community bible — curated skills, hooks, slash commands,
orchestrators. The most comprehensive collection of Claude Code resources.

**Use as:** Reference guide for discovering new skills, hooks, and patterns.

**Priority:** Reference
**Tags:** Collection, Community, Curated

---

## Quick Reference Table

### Category A — World-Class Coding Skills (15)

| # | Skill Name | Priority | Keywords | Install Command |
|---|---|---|---|---|
| A1 | frontend-design | Critical | design, UI, component | `npx skills add anthropics/skills@frontend-design` |
| A2 | systematic-debugging | Critical | bug, debug, error | `claude code install systematic-debugging` |
| A3 | superpowers | High | multi-agent, feature | `claude code install obra/superpowers` |
| A4 | webapp-testing | Critical | E2E, playwright, test | `claude code install webapp-testing` |
| A5 | owasp-security | Critical | security, vulnerability | `claude code install owasp-security` |
| A6 | varlock | Critical | secret, API key | `claude code install varlock` |
| A7 | test-driven-development | High | TDD, test-first | `claude code install test-driven-development` |
| A8 | software-architecture | High | architecture, design | `claude code install software-architecture` |
| A9 | code-review | High | review, PR | `claude code install code-review` |
| A10 | playwright-skill | High | browser automation | `claude code install playwright-skill` |
| A11 | subagent-driven-dev | High | subagent, parallel | `claude code install subagent-driven-development` |
| A12 | changelog-generator | Medium | changelog, release | `claude code install changelog-generator` |
| A13 | using-git-worktrees | Medium | worktree, parallel | `claude code install using-git-worktrees` |
| A14 | finishing-branch | Medium | merge, finish | `claude code install finishing-branch` |
| A15 | supermemory | High | remember, context | `claude code install supermemory` |

### Category B — Design, Marketing & Automation (6)

| # | Skill Name | Priority | Keywords | Install Command |
|---|---|---|---|---|
| B1 | autoresearch | Medium | research, investigate | `claude code install autoresearch` |
| B2 | SuperClaude | Medium | enhanced, reasoning | `claude code install SuperClaude` |
| B3 | marketing-skills | Medium | marketing, content | `claude code install marketing-skills` |
| B4 | ui-ux-pro-max | High | UI, design system | `claude code install ui-ux-pro-max` |
| B5 | claude-mem | High | memory, session | `claude code install thedotmack/claude-mem` |
| B6 | everything-claude-code | Critical | full harness | `claude code install everything-claude-code` |

### Category C — Community Marketplace (npx) (5)

| # | Skill Name | Priority | Keywords | Install Command |
|---|---|---|---|---|
| C1 | UI-UX-Pro-Max | High | UI, design, palette | `npx skills add nextlevelbuilder/ui-ux-pro-max-skill@ui-ux-pro-max` |
| C2 | shadcn-ui | High | shadcn, components | `npx skills add giuseppe-trisciuoglio/developer-kit@shadcn-ui` |
| C3 | web-accessibility | High | a11y, WCAG, ARIA | `npx skills add supercent-io/skills-template@web-accessibility` |
| C4 | web-design-guidelines | High | design, responsive | `npx skills add vercel-labs/agent-skills@web-design-guidelines` |
| C5 | frontend-design (npx) | Critical | frontend, Anthropic | `npx skills add anthropics/skills@frontend-design` |

### Category D — Community Tools & Repos (4)

| # | Tool Name | Priority | Purpose | Source |
|---|---|---|---|---|
| D1 | Claude Mem | High | Persistent memory | github.com/thedotmack/claude-mem |
| D2 | LightRAG | Medium | Graph+vector RAG | github.com/hkuds/lightrag |
| D3 | Everything Claude Code | High | Full agent harness | github.com/affaan-m/everything-claude-code |
| D4 | Awesome Claude Code | Reference | Community bible | github.com/hesreallyhim/awesome-claude-code |

**Total: 30 skills and tools across 4 categories.**

---

## Installation Methods

### Method 1: Master Install Script (Recommended)

The methodology includes a comprehensive install script that installs
all Category A and B skills automatically with fallback stubs:

```bash
bash scripts/install-claude-skills-v2.sh
```

This script:
- Checks prerequisites (git, node, npm, bun, python3)
- Creates a full backup of `~/.claude/` before changes
- Installs all 15 Category A skills (from GitHub repos or creates stubs)
- Installs all 6 Category B skills
- Configures MCP servers (21st.dev Magic, Nano Banana 2, Google Stitch)
- Reports installation results (installed/skipped/failed)

### Method 2: Individual npx Install (Category C)

```bash
# Install one skill at a time
npx skills add nextlevelbuilder/ui-ux-pro-max-skill@ui-ux-pro-max
npx skills add giuseppe-trisciuoglio/developer-kit@shadcn-ui
npx skills add supercent-io/skills-template@web-accessibility
npx skills add vercel-labs/agent-skills@web-design-guidelines
npx skills add anthropics/skills@frontend-design
```

### Method 3: Claude Code Install (Category A & B)

```bash
# Install critical skills only
claude code install frontend-design systematic-debugging webapp-testing owasp-security varlock

# Install complete development kit
claude code install frontend-design systematic-debugging superpowers webapp-testing owasp-security varlock test-driven-development software-architecture code-review playwright-skill subagent-driven-development changelog-generator supermemory ui-ux-pro-max claude-mem
```

### Method 4: Manual Git Clone (Category D)

```bash
# Clone community tools
git clone --depth=1 https://github.com/thedotmack/claude-mem.git
git clone --depth=1 https://github.com/hkuds/lightrag.git
git clone --depth=1 https://github.com/affaan-m/everything-claude-code.git
git clone --depth=1 https://github.com/hesreallyhim/awesome-claude-code.git
```

---

## Skill Auto-Activation

Skills activate automatically based on their `description` field. Configure
priority in `.claude/settings.json`:

```json
{
  "skills": {
    "auto_activate": true,
    "priority_order": [
      "varlock",
      "owasp-security",
      "systematic-debugging",
      "test-driven-development",
      "webapp-testing",
      "code-review"
    ]
  }
}
```

---

## Skill Dependencies & Compatibility

**frontend-design** requires: Node.js 18+, modern browser
**webapp-testing** requires: Playwright 1.40+, Node.js 18+
**superpowers** requires: Git, test framework
**owasp-security** requires: Project structure analysis
**varlock** requires: Git hooks integration
**ui-ux-pro-max** requires: CSS support, design token system
**shadcn-ui** requires: React 18+, Tailwind CSS, shadcn/ui installed
**web-accessibility** requires: HTML/JSX files, ARIA support
**LightRAG** requires: Python 3.10+, pip

---

## Best Practices

1. **Run the master install script first** — it handles all Category A+B with backups
2. **Add Category C skills** for your specific needs (UI-heavy? Add shadcn-ui + web-design)
3. **Chain strategically**: TDD → superpowers → finishing-branch workflow
4. **Security first**: varlock before commits, owasp-security before deployment
5. **Maintain memory**: supermemory + CCM's built-in memory protocol work together
6. **Review systematically**: code-review checklist on all PRs
7. **Test comprehensively**: webapp-testing + playwright-skill for robust coverage

---

## Troubleshooting

**Skill not activating?**
- Check auto-activation is enabled in settings
- Verify file type matches activation triggers
- Check skill is installed: `ls ~/.claude/skills/`

**npx install fails?**
- Ensure Node.js 18+ and npm are installed
- Try with `--force` flag: `npx skills add --force [package]`
- Fall back to git clone method

**Master script fails?**
- Script creates stubs for any skill that fails to clone
- Check the install log: `~/.claude/install-v2-*.log`
- Re-run individual skills that failed

---

**Last Updated:** April 2026
**Total Skills & Tools:** 30 (15 Cat A + 6 Cat B + 5 Cat C + 4 Cat D)
**Maintainer:** Abdullah × Claude Code Methodology
