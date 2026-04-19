# Output Styles

Custom output styles for this project. Each .md file here defines a
system-prompt style that can be applied via the `outputStyle` setting.

## Usage

1. Create a style file: `detailed-review.md`
2. Set in settings.json: `"outputStyle": "detailed-review"`
3. Claude adopts that communication style for the session

## Example

```markdown
# Detailed Review Style

When reviewing code:
- Always explain the WHY behind each suggestion
- Rate severity: critical, warning, info
- Include code examples for fixes
- End with a summary score
```

Personal styles go in `~/.claude/output-styles/` instead.
