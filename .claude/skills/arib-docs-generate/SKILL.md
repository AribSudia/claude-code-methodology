---
name: arib-docs-generate
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

## Purpose (per documentation target)
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

## Decision Tree: Choosing the Right Documentation Type

```
User/reader needs to:
├─ Understand what a function/method does?
│  ├─ Single function → JSDoc/docstring (inline)
│  ├─ Multiple functions → Docstring + API table in module README
│  └─ Complex logic → Docstring + architecture doc
├─ Know how to use a class/module?
│  ├─ Simple public API → JSDoc for class + methods
│  ├─ Multiple features → README in module folder
│  └─ Complex workflow → Architecture + tutorials
├─ Set up a new feature/component?
│  └─ Feature README + examples + FAQs
├─ Understand system design?
│  ├─ One component → Component architecture doc
│  ├─ Multiple components → System architecture + diagrams
│  └─ Data model → Schema docs + migrations guide
├─ Deploy or configure?
│  └─ Deployment/Operations guide
└─ Run tests or contribute?
   └─ CONTRIBUTING.md + testing guide
```

## JSDoc/Docstring Templates by Language

### JavaScript/TypeScript (JSDoc)
```javascript
/**
 * Brief one-line description.
 * 
 * Longer description explaining the purpose, behavior, important context,
 * and any caveats. Mention what this function does and why it exists.
 * 
 * @param {Type} paramName - Description of parameter. Include constraints:
 *   - "required", "optional", "nullable"
 *   - Valid values or ranges
 *   - Default value if applicable
 * @param {Object} options - Configuration object
 * @param {boolean} options.verbose - Enable debug output (default: false)
 * @param {number} [options.timeout=3000] - Request timeout in ms
 * 
 * @returns {Promise<Type>} Description of return value
 * @returns {string} Resolves with the user ID on success
 * 
 * @throws {TypeError} If paramName is not a string
 * @throws {ValidationError} If paramName fails validation
 * @throws {TimeoutError} If options.timeout exceeded
 * 
 * @example
 * const result = await functionName("alice", { verbose: true });
 * console.log(result); // "user-123"
 * 
 * @see relatedFunction() - See this for alternative approach
 * @see {@link https://example.com/docs} - External reference
 * 
 * @deprecated Since v2.0. Use newFunction() instead.
 */
async function functionName(paramName, options = {}) {
  // implementation
}
```

### Python (docstring)
```python
def function_name(param_name: str, options: Optional[dict] = None) -> str:
    """Brief one-line description.
    
    Longer description explaining the purpose, behavior, important context,
    and any caveats. Mention what this function does and why it exists.
    
    Args:
        param_name (str): Description of parameter. Include constraints:
            - Valid values
            - Default value if applicable
        options (dict, optional): Configuration object. Defaults to None.
            - verbose (bool): Enable debug output. Defaults to False.
            - timeout (int): Request timeout in ms. Defaults to 3000.
    
    Returns:
        str: Description of return value. Example: "The user ID on success"
    
    Raises:
        TypeError: If param_name is not a string.
        ValidationError: If param_name fails validation.
        TimeoutError: If timeout exceeded.
    
    Example:
        >>> result = function_name("alice", {"verbose": True})
        >>> print(result)
        user-123
    
    See Also:
        related_function(): Alternative approach
        https://example.com/docs: External reference
    
    Deprecated:
        Since v2.0. Use new_function() instead.
    """
    pass
```

### Go (comment style)
```go
// FunctionName describes what the function does in one sentence.
//
// Longer description explaining the purpose, behavior, and important context.
// Mention what this function does and why it exists. Describe any important
// behavior or side effects.
//
// Parameters:
//  - paramName: Description. Include constraints: valid values, required/optional, defaults.
//  - options: Configuration struct with these fields:
//    - Verbose: Enable debug output (default: false)
//    - Timeout: Request timeout in milliseconds (default: 3000)
//
// Returns:
//  - result: The result on success
//  - error: Non-nil error if validation failed, timeout exceeded, etc.
//
// Example:
//
//	result, err := FunctionName("alice", Options{Verbose: true})
//	if err != nil {
//		log.Fatal(err)
//	}
//	fmt.Println(result) // user-123
//
// See Also:
//  - RelatedFunction: Alternative approach
//  - https://example.com/docs: External reference
//
// Deprecated: Since v2.0. Use NewFunction instead.
func FunctionName(paramName string, options Options) (string, error) {
	// implementation
}
```

## README Structure Template

### For a Module/Package
```markdown
# [Module Name]

Brief description: what does this module do, why exist, who uses it.

## Features
- Feature 1
- Feature 2
- Feature 3

## Installation/Setup
Step-by-step instructions to use this module.

## Quick Start
Minimal example to get working immediately.

## API Reference
### FunctionName(params)
Description. Parameters. Returns. Throws.

### ClassName
Description. Constructor. Public methods.

## Usage Examples
1. Common case: Code example + expected output
2. Advanced case: Code example + expected output
3. Error handling: Code example + how to handle errors

## Configuration
What can be configured, defaults, constraints.

## Performance Considerations
- Complexity/speed notes
- Memory usage notes
- When to use vs when to avoid

## Troubleshooting
Common issues and solutions.

## Related
- Link to other modules
- Link to tutorials
- Link to reference docs
```

### For an API/Service
```markdown
# [API Name] API

Description: what endpoints, what operations, what data.

## Authentication
How to authenticate. API keys, tokens, OAuth, etc.

## Endpoints

### GET /resource
Retrieve resource(s).

**Parameters:**
- param1 (string, required): Description

**Response:**
- 200 OK: Returns array of resources
- 404 Not Found: Resource not found
- 401 Unauthorized: Missing or invalid auth

**Example:**
```
GET /api/users/123
Response: { "id": "123", "name": "Alice" }
```

## Error Handling
Error codes, error format, how to handle each error type.

## Rate Limiting
If applicable: limits, reset time, headers.

## Webhooks (if applicable)
What webhooks are available, payload structure, how to handle.

## Examples
Complete working examples (cURL, JavaScript, Python).

## SDK Reference
If SDK exists, link to SDK docs.
```

## Architecture Document Template

```markdown
# [System/Component] Architecture

## Overview
High-level purpose. Problem it solves. Key design decisions.

## Architecture Diagram
```
[ASCII diagram or link to Figma/Draw.io]

Components:
- Component A: Role
- Component B: Role
- Component C: Role
```

## Components

### Component A
**Purpose:** What does this component do?
**Responsibility:** What are its specific duties?
**Dependencies:** What does it depend on?
**Data:** What data does it own?

### Component B
...

## Data Flow

Describe how data moves through the system:
1. User action
2. Data validation
3. Processing
4. Persistence
5. Response

Include sequence diagram or flow chart.

## Technology Choices
| Choice | Alternatives | Why Chosen | Trade-offs |
|--------|--------------|-----------|-----------|
| [Tech A] | [Alt 1], [Alt 2] | [Reason] | [Cost/limitation] |

## Scalability Considerations
- How does this scale with data size?
- How does this scale with user count?
- Bottlenecks and solutions?
- Future growth plans?

## Security Considerations
- Authentication/authorization
- Data protection
- Input validation
- Known vulnerabilities

## Testing Strategy
- Unit test approach
- Integration test approach
- E2E test approach
- Performance test approach

## Deployment
- How is this deployed?
- Staging vs. production differences?
- Rollback procedure?
- Monitoring and alerts?

## Future Improvements
- Known limitations
- Planned enhancements
- Research needed
```

## Documentation Quality Checklist

Before marking documentation complete, verify:

### Content Quality
- [ ] Clear purpose statement (what, why, who)
- [ ] All parameters/inputs documented with type and constraints
- [ ] All outputs/returns documented with type and structure
- [ ] At least one working example provided
- [ ] Edge cases and limitations mentioned
- [ ] Error conditions and how to handle documented
- [ ] Links to related documentation
- [ ] Consistent tone and terminology
- [ ] No outdated references or version numbers

### Completeness
- [ ] Functions documented: all public functions have JSDoc/docstrings
- [ ] Classes documented: all public classes with constructors, methods
- [ ] Configuration documented: all config options listed with defaults
- [ ] API documented: all endpoints with methods, params, responses
- [ ] Examples work: tested and actually runnable
- [ ] Related files updated: README, API_ENDPOINTS.md, architecture docs

### Accessibility
- [ ] Written for beginner-level understanding
- [ ] Technical terms explained on first use
- [ ] Code examples use realistic variable names
- [ ] No assumptions about prior knowledge
- [ ] Screenshots or diagrams for complex concepts
- [ ] Table of contents for long docs

### Style & Format
- [ ] Follows project style guide
- [ ] Consistent markdown formatting
- [ ] Proper indentation and code block syntax
- [ ] Links are active and target correct section
- [ ] All formatting applied consistently
- [ ] No trailing whitespace or broken lists

### Maintenance
- [ ] Last updated date current
- [ ] Version number accurate
- [ ] Deprecation notices clear (if applicable)
- [ ] Checklist for when to update docs
- [ ] Responsible person/team identified

## Cross-Reference Verification Checklist

When documentation references other docs, verify:
- [ ] Links are valid and not broken
- [ ] Cross-referenced docs exist
- [ ] Cross-references are reciprocal (if A -> B, then B should reference A)
- [ ] External links include domain (full URL, not relative)
- [ ] Version numbers match (don't reference v1.0 docs from v2.0 code)
- [ ] Code examples match actual function signatures
- [ ] Parameter types match actual types in code
- [ ] Response examples match actual response format
- [ ] Error codes documented match actual error codes thrown

## Common Documentation Mistakes

| Mistake | Example | Fix |
|---------|---------|-----|
| **Incomplete params** | No mention of optional params | Document all params, mark optional, provide defaults |
| **Wrong example** | Docs show POST, code actually GET | Test examples by running them |
| **Outdated reference** | Docs link to deleted API endpoint | Search repo for references, update all |
| **Missing error docs** | Doesn't mention ValidationError thrown | Document every error type with when thrown |
| **Unclear usage** | "Pass an options object" without structure | Show actual structure: { key: value } |
| **No defaults** | Docs say "optional timeout" without default | State: "default: 3000ms" |
| **Version mismatch** | Docs say method signature different from code | Keep docs and code in sync, update immediately |
| **Broken links** | Links to /docs/foo that doesn't exist | Test all links before committing |
| **Duplicate docs** | Same info in README and JSDoc | Pick one source of truth, reference from other |

## Related Skills
- `/arib-docs-api` - Generate API documentation
- `/arib-docs-language` - Check i18n compliance
- `review` - Review documentation in PRs
- `security-review` - Audit docs for security issues

## Notes
- Documentation is code - treat it with same care and attention
- Examples are essential - include them liberally
- Keep documentation close to the code it describes
- Consistency matters - follow established patterns
- Update documentation immediately when code changes
- Poor documentation is worse than no documentation
- Assume the reader has no prior context
- Always use concrete examples over abstract descriptions
- Version documentation alongside code changes
- Regularly audit docs for staleness (>30 days old = review)
