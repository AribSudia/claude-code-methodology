# Claude Code Methodology v2.6.0
## Skills Manual: Complete User Guide

---

## Table of Contents

1. [What Are Skills?](#what-are-skills)
2. [How Auto-Activation Works](#how-auto-activation-works)
3. [Skill Architecture](#skill-architecture)
4. [The Skill Priority Chain](#the-skill-priority-chain)
5. [Complete Skill Catalog](#complete-skill-catalog)
6. [Installing Skills](#installing-skills)
7. [Creating Custom Skills](#creating-custom-skills)
8. [Skills in Action](#skills-in-action)
9. [Best Practices & Tips](#best-practices--tips)

---

## What Are Skills?

**Skills are auto-invoked knowledge packs** that Claude reads and applies when detecting specific task types during a session. Think of them as intelligent playbooks that provide domain-specific guidance, strategies, and templates without you having to explicitly request them.

### Key Characteristics

- **Automatic**: Skills activate based on keyword matching in your task description
- **Contextual**: When Claude detects a matching task, it reads the skill file and applies that knowledge
- **Non-intrusive**: Skills enhance your workflow without interrupting it
- **Composable**: Multiple skills can activate together to address complex tasks
- **Customizable**: You can create your own skills or modify existing ones

### What Skills Contain

Skills are markdown guides that typically include:
- Best practices and patterns for the skill's domain
- Step-by-step workflows
- Code examples and templates
- Common pitfalls and how to avoid them
- Tool recommendations and configurations

---

## How Auto-Activation Works

### The Matching Algorithm

When you describe a task, Claude's skill matcher examines your input and compares it against the **description field** of all available skills. If keywords in your task description match the skill's trigger terms, that skill auto-activates.

### Example

**Your Input:**
```
"I need to set up unit tests for my React components and follow TDD principles."
```

**Matching Process:**
- Claude detects keywords: "unit tests", "TDD", "test-driven development"
- Checks all skill descriptions for matching keywords
- Finds: `tdd-workflow` skill (description contains "test-driven", "unit tests")
- **Skill activates automatically**
- Claude reads the TDD skill guide and applies its methodology

### How Matching Works

1. **Keyword extraction** from your task description
2. **Multi-skill matching** - multiple skills can activate if all their keywords are present
3. **Priority evaluation** - if conflicts exist, the priority chain determines which skills take precedence
4. **Context awareness** - Claude considers the full context of your request, not just isolated words

### Activation Examples

| Task Description | Triggered Skills | Why |
|---|---|---|
| "Add security headers to my Node API" | `security-hardening`, `api-design` | Keywords: security, headers, API |
| "Refactor this legacy code into smaller functions" | `refactoring-patterns`, `code-review` | Keywords: refactor, code quality |
| "Set up error handling for async operations" | `error-handling`, `backend-patterns` | Keywords: error, async, patterns |
| "Debug memory leaks in production" | `debugging-focused`, `performance-tuning` | Keywords: memory, debug, performance |

---

## Skill Architecture

### Directory Structure

Each skill follows a consistent structure in `.claude/skills/`:

```
.claude/skills/
├── [skill-name]/
│   ├── SKILL.md                 # Main skill guide (required)
│   ├── helpers.py              # Optional: utility functions
│   └── templates/              # Optional: code templates
│       ├── example-template.py
│       ├── config-template.json
│       └── ...
├── tdd-workflow/
│   ├── SKILL.md
│   ├── helpers.py
│   └── templates/
│       ├── test-template.js
│       └── test-config.json
└── security-hardening/
    ├── SKILL.md
    └── templates/
        ├── secure-headers.json
        └── csp-policy.json
```

### The SKILL.md Format

Every skill is defined by a markdown file with this structure:

```markdown
# Skill Name

## Description
Brief one-sentence description used for keyword matching.
Keywords: unit-testing, tdd, test-driven-development

## When This Activates
Explain when Claude should use this skill (what task types trigger it).

## Quick Start
1. Step one
2. Step two
3. Step three

## Key Concepts
Explain important patterns or principles.

## Best Practices
- Practice one
- Practice two
- Practice three

## Code Examples
Provide practical examples.

## Common Mistakes
What to avoid and why.

## Tools & Resources
Links, tool names, configuration examples.

## Advanced Topics
Deeper dives for power users.

## Troubleshooting
Solutions for common problems.
```

### Helper Files (Optional)

**helpers.py** - Python utilities that Claude can import and use:

```python
# .claude/skills/tdd-workflow/helpers.py

def generate_test_template(framework="pytest", async_mode=False):
    """Generate a test template based on framework."""
    if framework == "pytest":
        return """
import pytest

@pytest.fixture
def sample_data():
    return {"id": 1, "name": "test"}

def test_example(sample_data):
    assert sample_data["id"] == 1
"""
    return ""

def validate_test_coverage(coverage_percent, threshold=80):
    """Check if test coverage meets threshold."""
    if coverage_percent >= threshold:
        return True, f"✓ Coverage {coverage_percent}% meets {threshold}% threshold"
    return False, f"✗ Coverage {coverage_percent}% below {threshold}% threshold"
```

### Template Files (Optional)

**templates/** - Reusable code templates:

```javascript
// .claude/skills/tdd-workflow/templates/react-component.test.js
import { render, screen, fireEvent } from '@testing-library/react';
import MyComponent from './MyComponent';

describe('MyComponent', () => {
  test('renders without crashing', () => {
    render(<MyComponent />);
  });

  test('updates state on button click', () => {
    render(<MyComponent />);
    const button = screen.getByRole('button');
    fireEvent.click(button);
    // Assert expected behavior
  });
});
```

---

## The Skill Priority Chain

### Resolution Order

When multiple skills could apply, Claude follows this priority chain:

1. **Project-Specific Skills** (highest priority)
   - Location: `.claude/skills/` in your project root
   - Use case: Custom skills tailored to your codebase
   - Example: A `my-api-patterns` skill for your specific backend architecture

2. **User Global Skills** (medium priority)
   - Location: `~/.claude/skills/` in your home directory
   - Use case: Personal skills you use across multiple projects
   - Example: Your preferred refactoring style or deployment process

3. **Third-Party Skills** (lowest priority)
   - Location: Skills installed via `npm` or package managers
   - Use case: Community skills and published best practices
   - Example: Industry-standard frameworks or methodologies

### Priority Resolution Example

**Scenario:** You're working on API error handling, and three skills could activate:
- `error-handling` (project-specific) - matches perfectly
- `error-handling` (global) - also matches
- `backend-patterns` (third-party) - matches partially

**Resolution:** The project-specific `error-handling` skill wins. Claude uses it and ignores the global and third-party versions with the same name.

### Conflict Avoidance

To prevent conflicts:
- Use unique, descriptive skill names
- Document your skill's scope in the description
- Use skill tagging for categorization (coding, design, automation)

---

## Complete Skill Catalog

### Category A: Coding Skills (15 skills)

These skills focus on code development, architecture, and technical excellence.

#### 1. **frontend-focused**
- **What it does**: Guides you through modern frontend development patterns, component architecture, and performance optimization
- **Activates when**: You mention building UIs, React components, frontend performance, component libraries, or browser optimization
- **Example use case**: "I need to build a reusable button component library with accessibility"
- **Key topics**: Component composition, state management, performance, accessibility, testing strategies

#### 2. **backend-patterns**
- **What it does**: Provides backend architecture patterns, API design, middleware, and server-side best practices
- **Activates when**: You discuss server architecture, database interactions, API endpoints, or scaling backend systems
- **Example use case**: "Design a scalable API that handles 100k concurrent users"
- **Key topics**: Architecture patterns, database design, caching, load balancing, security patterns

#### 3. **debugging-focused**
- **What it does**: Systematic approach to finding and fixing bugs, including debugging tools, strategies, and techniques
- **Activates when**: You need to find bugs, trace issues, analyze logs, or troubleshoot problems
- **Example use case**: "This async function is silently failing and I can't figure out why"
- **Key topics**: Debugging tools, logging strategies, error tracing, performance profiling, root cause analysis

#### 4. **tdd-workflow**
- **What it does**: Test-driven development methodology, testing frameworks, and test organization patterns
- **Activates when**: You're setting up tests, writing test suites, or following TDD principles
- **Example use case**: "Set up unit tests for my Express API using Jest and follow TDD"
- **Key topics**: Test frameworks, test organization, mocking, fixtures, test coverage, CI/CD integration

#### 5. **security-hardening**
- **What it does**: Security best practices, vulnerability prevention, and secure coding patterns
- **Activates when**: You're implementing authentication, handling secrets, preventing attacks, or reviewing security
- **Example use case**: "Add CSRF protection and input validation to my web form"
- **Key topics**: Authentication, authorization, encryption, input validation, secret management, compliance

#### 6. **code-review**
- **What it does**: Systematic code review process, quality standards, and constructive feedback patterns
- **Activates when**: You're reviewing code, assessing quality, or providing feedback on PRs
- **Example use case**: "Review this pull request for code quality and best practices"
- **Key topics**: Code quality metrics, review checklists, performance considerations, maintainability assessment

#### 7. **architecture-patterns**
- **What it does**: System design patterns, architectural decisions, and large-scale system organization
- **Activates when**: You're designing systems, discussing architecture, or planning large refactors
- **Example use case**: "Design a microservices architecture for a multi-tenant SaaS platform"
- **Key topics**: Design patterns, system design, scaling, technical debt management, architectural decisions

#### 8. **api-design**
- **What it does**: RESTful API design, GraphQL, API versioning, and contract-first development
- **Activates when**: You're building APIs, designing endpoints, or defining API contracts
- **Example use case**: "Design a RESTful API for an e-commerce platform"
- **Key topics**: REST principles, API documentation, versioning, rate limiting, pagination, error handling

#### 9. **database-optimization**
- **What it does**: Query optimization, indexing strategies, and database performance tuning
- **Activates when**: You're optimizing database queries, designing schemas, or improving database performance
- **Example use case**: "Optimize slow SQL queries in a high-volume reporting system"
- **Key topics**: Query optimization, indexing, schema design, caching strategies, database profiling

#### 10. **git-worktrees**
- **What it does**: Advanced Git workflows using worktrees, branch management, and complex version control scenarios
- **Activates when**: You're managing multiple branches, working on features in parallel, or using worktrees
- **Example use case**: "Manage three parallel features using Git worktrees without context switching"
- **Key topics**: Worktree management, branch strategies, merge conflicts, collaborative workflows

#### 11. **error-handling**
- **What it does**: Comprehensive error handling patterns, custom error types, and graceful degradation
- **Activates when**: You're handling errors, designing error flows, or improving error messages
- **Example use case**: "Add proper error handling and user-friendly messages to async operations"
- **Key topics**: Error types, try-catch patterns, error boundaries, logging, user feedback, recovery strategies

#### 12. **performance-tuning**
- **What it does**: Performance optimization techniques, profiling, and benchmarking
- **Activates when**: You're improving performance, profiling code, or reducing latency
- **Example use case**: "My app's load time is 3 seconds, reduce it to under 1 second"
- **Key topics**: Profiling, caching, optimization techniques, bundling, memory management, monitoring

#### 13. **documentation-gen**
- **What it does**: Auto-documentation, API documentation tools, and documentation best practices
- **Activates when**: You're creating docs, generating API documentation, or improving code comments
- **Example use case**: "Generate comprehensive API documentation from our code comments"
- **Key topics**: Doc generation tools, documentation patterns, API specs, markdown conventions, examples

#### 14. **refactoring-patterns**
- **What it does**: Code refactoring strategies, safe refactoring techniques, and architectural improvements
- **Activates when**: You're refactoring code, improving structure, or modernizing legacy code
- **Example use case**: "Refactor this monolithic function into smaller, testable units"
- **Key topics**: Refactoring patterns, safe refactoring, code smells, automated testing during refactors

#### 15. **devops-essentials**
- **What it does**: Deployment, CI/CD pipelines, containerization, and infrastructure as code
- **Activates when**: You're setting up deployments, building CI/CD, or managing infrastructure
- **Example use case**: "Set up a GitHub Actions CI/CD pipeline for automated testing and deployment"
- **Key topics**: CI/CD tools, containerization (Docker), orchestration (Kubernetes), IaC, monitoring

---

### Category B: Design & Automation Skills (6 skills)

These skills focus on design, analysis, and workflow automation.

#### 16. **research-assistant**
- **What it does**: Research methodologies, information gathering, and analysis frameworks
- **Activates when**: You're researching technologies, gathering requirements, or analyzing options
- **Example use case**: "Research the best Node.js web frameworks for 2026"
- **Key topics**: Research methods, source evaluation, competitive analysis, trend analysis

#### 17. **marketing-copy**
- **What it does**: Copywriting techniques, messaging strategies, and persuasive communication
- **Activates when**: You're writing marketing content, sales messages, or product descriptions
- **Example use case**: "Write compelling copy for our SaaS product landing page"
- **Key topics**: Copywriting, messaging, positioning, persuasion techniques, A/B testing concepts

#### 18. **ui-ux-design**
- **What it does**: UX principles, design systems, accessibility, and user-centered design
- **Activates when**: You're designing UIs, improving UX, or creating design systems
- **Example use case**: "Design an accessible form component with proper error handling"
- **Key topics**: UX principles, design systems, accessibility (WCAG), user research, prototyping

#### 19. **data-analysis**
- **What it does**: Data analysis techniques, visualization, and statistical interpretation
- **Activates when**: You're analyzing data, creating reports, or interpreting statistics
- **Example use case**: "Analyze user engagement metrics and identify trends"
- **Key topics**: Statistical analysis, data visualization, SQL, data transformation, interpretation

#### 20. **project-management**
- **What it does**: Project planning, task management, timeline estimation, and risk management
- **Activates when**: You're planning projects, managing timelines, or organizing work
- **Example use case**: "Plan a 3-month project to migrate our legacy system to microservices"
- **Key topics**: Project planning, estimation, risk management, stakeholder communication, agile practices

#### 21. **persistent-memory**
- **What it does**: Session memory management, context preservation, and information retrieval
- **Activates when**: You're managing session context, organizing information, or referencing past work
- **Example use case**: "Keep track of important decisions and context across sessions"
- **Key topics**: Memory organization, context management, information retrieval, session continuity

---

## Installing Skills

### Method 1: Command Line Installation

Install official skills from the registry:

```bash
# Install a single skill
npx @anthropic/claude-code skills install tdd-workflow

# Install multiple skills
npx @anthropic/claude-code skills install tdd-workflow security-hardening database-optimization

# List available skills
npx @anthropic/claude-code skills list

# View skill details
npx @anthropic/claude-code skills info tdd-workflow
```

### Method 2: Manual Installation

For custom or local skills:

```bash
# Create skill directory
mkdir -p .claude/skills/my-custom-skill

# Copy SKILL.md into it
cp my-skill-template.md .claude/skills/my-custom-skill/SKILL.md

# Optionally add helpers and templates
mkdir -p .claude/skills/my-custom-skill/templates
cp my-templates/* .claude/skills/my-custom-skill/templates/
```

### Method 3: Global Skills

Install skills in your home directory for use across projects:

```bash
# Create global skills directory
mkdir -p ~/.claude/skills/my-global-skill

# Add your skill files
cp SKILL.md ~/.claude/skills/my-global-skill/
```

### Verifying Installation

```bash
# Check that skills are installed and recognized
npx @anthropic/claude-code skills list

# Output should show:
# ✓ tdd-workflow (project-specific)
# ✓ security-hardening (project-specific)
# ✓ my-custom-skill (global)
# ✓ debugging-focused (third-party)
```

---

## Creating Custom Skills

### Step 1: Define Your Skill

Create a `.claude/skills/[skill-name]/SKILL.md` file:

```markdown
# My Custom Skill Name

## Description
One-sentence description. Keywords: keyword1, keyword2, keyword3

## When This Activates
Explain the task types that trigger this skill automatically.

## Quick Start
Step-by-step quick start guide.

## Key Concepts
Important patterns and principles.

## Best Practices
- Practice one
- Practice two

## Code Examples
Practical code examples.

## Common Mistakes
What to avoid and why.

## Tools & Resources
Relevant tools and links.

## Advanced Topics
Deeper dives for experienced users.
```

### Step 2: Optimize the Description Field

The description field is crucial for auto-activation. Write it to match the keywords users will naturally use:

```markdown
## Description
Guide to building scalable APIs with proper error handling, validation, and testing.
Keywords: api-design, rest, graphql, api-testing, validation, error-responses, api-versioning

## When This Activates
- Designing a new API endpoint
- Building RESTful or GraphQL APIs
- Improving API error handling
- Setting up API validation and documentation
```

**Good keyword choices:**
- Task names: "api-design", "rest", "graphql"
- Technical terms: "validation", "error-handling", "versioning"
- Problem descriptions: "api-testing", "rate-limiting", "pagination"

**Poor keyword choices:**
- Generic terms: "code", "build", "create" (too broad)
- Acronyms alone: "REST" (use "RESTful" for better matching)
- Vague phrases: "make it better"

### Step 3: Add Helper Files (Optional)

Create `.claude/skills/[skill-name]/helpers.py`:

```python
# Utility functions that Claude can use

def analyze_code_quality(code_snippet):
    """Analyze code quality and suggest improvements."""
    issues = []
    if len(code_snippet) > 500:
        issues.append("Function is too long, consider breaking it down")
    if code_snippet.count("TODO") > 0:
        issues.append("Unresolved TODOs found")
    return issues

def generate_test_template(language="python"):
    """Generate a test template based on language."""
    templates = {
        "python": """
import pytest

def test_example():
    assert True
""",
        "javascript": """
describe('Example', () => {
  test('should pass', () => {
    expect(true).toBe(true);
  });
});
"""
    }
    return templates.get(language, "")
```

### Step 4: Add Templates (Optional)

Create templates in `.claude/skills/[skill-name]/templates/`:

```
templates/
├── api-endpoint-template.js
├── test-template.js
├── config-template.json
└── README.md
```

**Example template: `api-endpoint-template.js`**

```javascript
/**
 * API Endpoint Template
 * Usage: Copy this template when creating new endpoints
 */

const express = require('express');
const router = express.Router();

/**
 * GET /api/[resource]
 * Description: Fetch a single resource
 * 
 * @query id {string} - Resource ID
 * @returns {object} - The resource object
 * @throws 400 - Invalid input
 * @throws 404 - Resource not found
 */
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    
    // Validate input
    if (!id) {
      return res.status(400).json({ error: 'ID is required' });
    }
    
    // Fetch resource
    const resource = fetchResource(id);
    if (!resource) {
      return res.status(404).json({ error: 'Resource not found' });
    }
    
    // Return success
    res.json(resource);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
```

### Step 5: Test Your Skill

Trigger it naturally in a session:

```bash
# In Claude Code, describe a task that should trigger your skill:
"I need to design an API endpoint for managing user profiles"

# If your api-design skill is properly configured, Claude will:
# 1. Recognize the keywords "API endpoint", "design"
# 2. Read your SKILL.md file
# 3. Apply the patterns and best practices from your skill
```

---

## Skills in Action

### Example 1: TDD Workflow Skill

**Your Input:**
```
I need to set up unit tests for my React components using Jest and follow test-driven development.
```

**What Happens:**

1. Claude detects keywords: "unit tests", "Jest", "test-driven development"
2. Finds and activates the `tdd-workflow` skill
3. Reads the SKILL.md which includes:
   - Best practices for TDD: Red-Green-Refactor cycle
   - Jest configuration examples
   - React testing patterns
   - Common testing mistakes
4. Claude then:
   - Helps you set up Jest configuration
   - Creates test templates for your components
   - Guides you through the Red-Green-Refactor cycle
   - Suggests testing strategies for async operations

**Result:** You get not just test setup, but a complete TDD methodology applied to your project.

---

### Example 2: Security-Hardening Skill

**Your Input:**
```
I need to add authentication and protect against common web vulnerabilities.
```

**What Happens:**

1. Claude detects keywords: "authentication", "vulnerabilities", "security"
2. Activates the `security-hardening` skill
3. The skill guide includes:
   - OWASP Top 10 mitigations
   - Authentication patterns (JWT, sessions, OAuth)
   - Input validation techniques
   - Security headers configuration
   - Secret management best practices
4. Claude provides:
   - Implementation examples for each vulnerability type
   - Configuration templates for security headers
   - Code review checklist for security issues
   - Testing strategies for security features

**Result:** Your application is built with security as a first-class concern from the start.

---

### Example 3: Multiple Skills Activated

**Your Input:**
```
I need to refactor this 500-line monolithic function into smaller, well-tested components
following the single responsibility principle.
```

**What Happens:**

1. Claude detects keywords triggering multiple skills:
   - `refactoring-patterns` (keywords: "refactor", "monolithic")
   - `tdd-workflow` (keywords: "well-tested", "components")
   - `code-review` (keywords: "single responsibility principle")

2. All three skills activate and work together:
   - **Refactoring-patterns**: Provides safe refactoring techniques
   - **TDD-workflow**: Guides writing tests before refactoring
   - **Code-review**: Applies quality standards during refactoring

3. Claude provides an integrated workflow:
   - Write tests for the current behavior first (TDD)
   - Systematically extract smaller functions (refactoring patterns)
   - Review each step against quality standards (code review)

**Result:** A safe, well-tested refactoring that improves both code quality and test coverage.

---

## Best Practices & Tips

### 1. Craft Clear Task Descriptions

**Poor description:**
```
"Make my code better"
```

**Good description:**
```
"Refactor this 300-line function into smaller, testable units following the single responsibility principle"
```

The second activates the right skills and gives Claude better context.

### 2. Combine Skills for Powerful Workflows

Stack skills that complement each other:
- `tdd-workflow` + `debugging-focused` = Develop with tests, debug with precision
- `security-hardening` + `code-review` = Security-first code review
- `performance-tuning` + `database-optimization` = Full stack performance improvement

### 3. Customize Skills for Your Team

Create project-specific skills that encode your team's standards:

```markdown
# Our Company's API Design Standards

## Description
Our specific API design patterns and standards.
Keywords: api-endpoint, rest-design, validation, error-handling

## Our Principles
1. Always return consistent error responses
2. Version APIs from day one
3. Require authentication for all endpoints
4. Document with OpenAPI/Swagger

## Templates
[Company-specific templates and examples]
```

### 4. Use Helper Functions for Complex Logic

If your skill involves complex analysis or code generation, use helpers.py:

```python
def validate_skill_trigger(task_description):
    """Ensure this skill is appropriate for the task."""
    required_keywords = ['api', 'design']
    return all(kw in task_description.lower() for kw in required_keywords)
```

### 5. Update Skills Based on Lessons Learned

Track what works in your team:
- After completing a task with a skill, note what worked well
- Update the skill to include new patterns
- Share learnings with the team

### 6. Document Your Custom Skills Well

Good documentation helps your team and your future self:

```markdown
## When to Use This Skill
✓ Designing new API endpoints
✓ Reviewing existing API implementations
✗ NOT for GraphQL (use our graphql-design skill)
✗ NOT for internal services (use our internal-api skill)
```

### 7. Monitor Skill Activation

Keep track of which skills activate and when:

```bash
# View activation logs (if available)
npx @anthropic/claude-code skills stats

# Manually track: Save task descriptions that trigger each skill
# to improve your keyword understanding
```

### 8. Version Your Skills

As your team evolves, version skills to maintain backward compatibility:

```
skills/
├── tdd-workflow-v1/         # Original version
├── tdd-workflow-v2/         # Updated with new patterns
└── tdd-workflow/            # Points to current version
```

### 9. Create Skill Collections for Workflows

Group related skills for specific job roles:

```markdown
# Frontend Developer Collection

Includes:
- frontend-focused
- tdd-workflow
- debugging-focused
- ui-ux-design
- performance-tuning

Install all: npx @anthropic/claude-code skills install frontend-collection
```

### 10. Measure Skill Effectiveness

Track the impact of your skills:
- Did it reduce time spent on setup?
- Did it prevent common mistakes?
- Did team members learn from it?

Iterate based on feedback.

---

## Advanced: Skill Interaction Patterns

### Pattern 1: Sequential Skills

Skills that naturally follow one another:

```
User Input: "I need to design and implement an API"
    ↓
1. api-design skill activates
2. User follows API design recommendations
3. User provides: "Now implement this API with proper error handling"
4. error-handling skill activates
5. Implementation follows both design and error patterns
```

### Pattern 2: Concurrent Skills

Skills that work simultaneously:

```
User Input: "Build a high-performance, security-hardened backend"
    ↓
Activates simultaneously:
  - backend-patterns (guides overall architecture)
  - security-hardening (guides security implementation)
  - performance-tuning (guides optimization)
    ↓
All three guide the same implementation
```

### Pattern 3: Skill Overrides

When specific skills should take precedence:

```
General: backend-patterns (third-party)
Project: our-api-patterns (project-specific)
    ↓
Project skill takes precedence
Our-api-patterns is applied instead of backend-patterns
```

---

## Troubleshooting

### Skill Not Activating

**Problem:** You expect a skill to activate but it doesn't.

**Solutions:**
1. Check keywords match exactly (case-insensitive)
2. Verify skill file exists: `.claude/skills/[skill-name]/SKILL.md`
3. Restart Claude Code: Changes to SKILL.md require session restart
4. Test manually: Quote key phrases from your task description

**Example:**
```
# If you write: "I need to write tests"
# But skill expects: "test-driven development"
# → Add "test-driven" to your task description
# Or add "test-writing" to the skill's keywords
```

### Multiple Conflicting Skills

**Problem:** Two skills activate but give conflicting guidance.

**Solution:** Check the priority chain:
```
.claude/skills/  →  ~/.claude/skills/  →  npm/registry
Project wins over global, global wins over third-party
```

Create a project-specific version of the conflicting skill to override.

### Skill Information Is Stale

**Problem:** Skill contains outdated information.

**Solution:** Update the SKILL.md file:
```bash
# Edit the skill
nano .claude/skills/[skill-name]/SKILL.md

# Restart Claude Code to reload
```

### Custom Skill Not Found

**Problem:** You created a skill but Claude doesn't find it.

**Solution:** Verify installation:
```bash
# Check file exists
ls -la .claude/skills/my-skill/SKILL.md

# Verify directory structure
tree .claude/skills/

# List skills (requires session restart after creating new skill)
npx @anthropic/claude-code skills list
```

---

## Summary

Skills transform Claude Code into a context-aware development partner that:

- **Understands your needs** through keyword matching
- **Provides guidance** automatically when relevant
- **Maintains consistency** through team-wide patterns
- **Evolves with your team** through custom skills

By mastering skills, you unlock a powerful layer of intelligence that makes your development workflow smarter, faster, and more consistent.

---

**Next Steps:**
1. Install a few foundational skills: `npx @anthropic/claude-code skills install tdd-workflow security-hardening code-review`
2. Use them in a real project
3. Create your first custom skill for something your team does repeatedly
4. Share it with your team

---

*This manual covers Claude Code Methodology v2.6.0. For updates and additional resources, visit the CCM training portal.*
