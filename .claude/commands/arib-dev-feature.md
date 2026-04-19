---
argument-hint: "<feature-name>"
description: Dev | Start a new feature with branch, planning, TDD workflow, and safety snapshot
---

# /arib-dev-feature Command

## Purpose
Start implementing a new feature with proper workflow, ensuring planning, safety, and test-driven development practices.

## Trigger
User types `/arib-dev-feature [feature-name]`

Example: `/arib-dev-feature user-authentication`

## Instructions

### Step 1: Read API Documentation
Read `API_ENDPOINTS.md` (or relevant API docs) to understand:
- What endpoints this feature will use or expose
- Request/response formats
- Authentication requirements
- Rate limiting or constraints
- Related features that might be impacted

### Step 2: Create Feature Branch
Create and checkout a new feature branch from develop:
```
git checkout develop
git pull origin develop
git checkout -b feature/[feature-name]
git push -u origin feature/[feature-name]
```

### Step 3: Create Safety Snapshot
Create a snapshot of the current state for rollback safety:
```
git tag -a feature/[feature-name]/snapshot -m "Safety snapshot before implementing [feature-name]"
git push origin feature/[feature-name]/snapshot
```

### Step 4: Plan Implementation
Document a detailed implementation plan including:
- **Files to Create**: New files needed (with paths and purposes)
- **Files to Modify**: Existing files that will be changed (with specific changes)
- **Tests Needed**: Unit tests, integration tests, E2E tests required
- **Dependencies**: Any new libraries or modifications to package.json
- **Documentation**: What docs need to be created or updated
- **Risk Assessment**: Any identified risks or complexity

### Step 5: Get User Approval
Present the implementation plan and wait for explicit user approval before proceeding. Ask specifically:
- "Does this plan align with your vision for [feature-name]?"
- "Are there any changes you'd like to the implementation approach?"

### Step 6: Implement with TDD
Follow Test-Driven Development:
1. Write tests first for each component/function
2. Run tests (they should fail initially)
3. Implement code to make tests pass
4. Refactor for clarity and efficiency
5. Commit with meaningful messages after each complete unit of work

### Step 7: Update Documentation
After implementation is complete:
- Update README.md with feature description
- Add API documentation if new endpoints were created
- Update CHANGELOG.md
- Add inline code comments for complex logic
- Update project_status.md with completion status

## Notes
- Always branch from develop, never directly from main
- Never skip the safety snapshot
- Tests must be written before implementation code
- Get explicit approval on the plan before starting
- Each commit should be a logical, testable unit
- Feature branches should be pushed to remote immediately
