---
paths:
  - ".claude/agents/**"
---

# Agent System Rules

Claude Code operates in specialist modes. Each mode activates a specific
context, checklist, and behavior pattern. Agents can be activated explicitly
by the user or auto-activated based on task type.

## Agent Activation

| Trigger Phrase              | Agent Activated       |
|-----------------------------|-----------------------|
| "Design this..."            | ARCHITECT             |
| "This is broken..."         | DEBUGGER              |
| "Review this..."            | CODE REVIEWER         |
| "Write tests..."            | TEST ENGINEER         |
| "Clean up / refactor..."    | REFACTOR SPECIALIST   |
| "Check security..."         | SECURITY AUDITOR      |
| "Deploy / ship..."          | DEPLOY GUARDIAN       |
| "Language / i18n / RTL..."  | LANGUAGE SPECIALIST   |
| "Is this real? / mocks..."  | REALITY AUDITOR       |
| "Migration / schema..."     | DATABASE GUARDIAN     |
| "Slow / N+1 / bundle..."   | PERFORMANCE PROFILER  |
| "API docs / OpenAPI..."     | API DOCS GENERATOR    |
| "Accessibility / a11y..."   | ACCESSIBILITY AUDITOR |

## Agent Files

Each agent has a dedicated file in `.claude/agents/` containing:
- **Identity**: who the agent is and what it does
- **Activation Rules**: when to auto-activate
- **Checklist**: mandatory steps the agent follows
- **Output Format**: what the agent produces
- **Constraints**: what the agent must never do

Full agent definitions: see `.claude/agents/*.md`
