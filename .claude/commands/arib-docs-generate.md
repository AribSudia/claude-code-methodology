---
argument-hint: "<target>"
description: Docs | Generate documentation - analyze target, extract interfaces, create docs, commit
---

# /arib-docs-generate Command

## Purpose
Generate or update comprehensive documentation ensuring consistency and clarity across the project.

## Trigger
User types `/arib-docs-generate [target]`

Examples:
- `/arib-docs-generate UserService`
- `/arib-docs-generate API`
- `/arib-docs-generate database-schema`
- `/arib-docs-generate deployment-process`

## Instructions

### Step 1: Identify Documentation Type
Determine what needs documenting:

**Function/Method Documentation:**
- Purpose and responsibility
- Parameters and return types
- Usage examples
- Thrown exceptions
- Related functions

**Module/Class Documentation:**
- Overall purpose and responsibility
- Public interface/API
- Internal structure
- Dependencies
- Usage examples

**API Documentation:**
- Endpoints (GET, POST, etc.)
- Request/response formats
- Authentication requirements
- Rate limits
- Error codes and messages
- Code examples

**Architecture Documentation:**
- System overview
- Component relationships
- Data flow
- Technology choices and rationale
- Scalability considerations

**Process Documentation:**
- Step-by-step procedures
- Prerequisites
- Decision points
- Troubleshooting
- Related processes

### Step 2: Read Existing Documentation
Before writing new docs:
- Read `DOCUMENTATION_STYLE.md` (if exists) for project conventions
- Review similar existing documentation in the project
- Check for naming conventions and examples
- Identify preferred tools/formats (JSDoc, Markdown, etc.)
- Note any existing documentation standards

### Step 3: Gather Source Information
Collect information about the target:
- Read the source code carefully
- Understand the full context
- Identify all key behaviors
- Note any edge cases
- Document assumptions made

### Step 4: Generate Documentation
Create documentation following project conventions:

**For Functions (JSDoc style):**
```javascript
/**
 * Brief description of what the function does.
 * 
 * Longer description explaining the purpose, behavior, and any important
 * context about this function.
 * 
 * @param {Type} paramName - Description of parameter
 * @param {Type} anotherParam - Description of another parameter
 * @returns {Type} Description of what is returned
 * @throws {ErrorType} Description of when this error is thrown
 * 
 * @example
 * const result = functionName(param1, param2);
 * // Result: expected output
 */
```

**For APIs (Markdown style):**
```markdown
## GET /api/users/:id

Retrieve user information by ID.

### Parameters
- `id` (string, required): User ID

### Response
- **200 OK**: Returns user object
- **404 Not Found**: User not found
- **401 Unauthorized**: Authentication required

### Example
```

**For Modules (Markdown style):**
```markdown
# UserService

## Purpose
Handles all user-related business logic and data operations.

## Public API
- `createUser(data)` - Creates new user
- `getUser(id)` - Retrieves user by ID
- `updateUser(id, data)` - Updates user

## Usage Example
```

### Step 5: Update Related Documentation
After documenting the target, update:
- **README.md**: Add/update references if this is a public API or major component
- **CONTEXT_MAP.md**: Update if this clarifies project structure
- **API_ENDPOINTS.md**: Update if new API was documented
- **project_status.md**: Note documentation completion

### Step 6: Commit Documentation Changes
Separate documentation commits from code changes:
```
git add docs/ [documentation files]
git commit -m "Docs: Add documentation for [target]

Documented:
- [What was documented]
- [What was explained]

Related files:
- [Path to documented component/function]"
```

### Step 7: Verification Checklist
Before considering documentation complete, verify:
- [ ] Clear and concise description of purpose
- [ ] All parameters/inputs documented
- [ ] All outputs/returns documented
- [ ] At least one usage example provided
- [ ] Edge cases mentioned if applicable
- [ ] Error conditions documented
- [ ] Links to related documentation
- [ ] Consistent with project style
- [ ] No outdated references
- [ ] Related files updated

### Step 8: Summary
Provide a summary of documentation completed:
```
Documentation Complete: [target]

Added/Updated:
- [File path]: [What was documented]
- [File path]: [What was documented]

Coverage:
- [Component X]: Fully documented
- [Component Y]: Updated with examples

Ready for: [PR/Merge/Review]
```

## Notes
- Documentation is code - treat it with same care and attention
- Examples are essential - include them liberally
- Keep documentation close to the code it describes
- Consistency matters - follow established patterns
- Update documentation immediately when code changes
- Poor documentation is worse than no documentation
- Assume the reader has no prior context
