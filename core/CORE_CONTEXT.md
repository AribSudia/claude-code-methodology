# Core Project Context

> **This folder is the primary source of truth for your project.**
> Drop your real project files here BEFORE running any bootstrap.
> Claude Code reads everything in this folder to deeply understand your project.

---

## What to Put Here

Put any files that help Claude Code understand your project. The more context you give, the stronger the CLAUDE.md and the smarter Claude Code becomes.

### Documents and Specs
- Business requirements (PRD, BRD, user stories)
- Technical specifications
- Feature lists and roadmaps
- Meeting notes with decisions
- Project proposals or pitches

### Designs
- Wireframes and mockups (PNG, PDF, Figma exports)
- UI/UX flow diagrams
- Screenshots of existing system (if migrating)
- Brand guidelines, color schemes, typography

### Database and API
- Database schema (SQL files, ERD diagrams, schema exports)
- API specifications (OpenAPI/Swagger YAML/JSON)
- Data models or entity-relationship diagrams
- Sample data or seed files

### Architecture
- System architecture diagrams
- Infrastructure diagrams (AWS, GCP, Azure)
- Network topology
- Deployment pipeline diagrams

### Existing Code (for migration/reengineering)
- Key source files from the old system
- Configuration files
- Environment variable templates
- Docker/deployment configs

### References
- Third-party API docs you integrate with
- Compliance requirements (HIPAA, PCI, GDPR docs)
- Style guides or coding standards
- Competitor analysis or market research

---

## How It Works

1. **You drop files here** - any format: PDF, PNG, MD, SQL, YAML, JSON, TXT, DOCX
2. **You run a bootstrap** - bootstrap reads core/ FIRST before asking questions
3. **Bootstrap asks smarter questions** - instead of "what's your database?" it says "I see you have a users table with 12 fields - is this current?"
4. **CLAUDE.md is built from real data** - not just typed answers
5. **core/ stays alive** - Claude Code reads it anytime it needs context during development

---

## Folder Structure (suggested, not required)

You can organize however you want. Claude Code reads all files regardless of structure.

```
core/
  CORE_CONTEXT.md          <- YOU ARE HERE (instructions)
  requirements.pdf         <- Business requirements
  wireframes/              <- UI designs
    home.png
    dashboard.png
  schema.sql               <- Database schema
  api-spec.yaml            <- OpenAPI specification
  architecture.png         <- System diagram
  notes.md                 <- Your own notes about the project
  old-system/              <- Files from previous system (if migrating)
```

---

## Rules

- **This folder is READ by Claude Code, not modified.** Claude Code never writes to core/. Only you add or update files here.
- **Keep it current.** If your schema changes, update schema.sql here. If designs evolve, replace the wireframes. This is a living reference.
- **No secrets.** Don't put .env files with real passwords, API keys, or tokens here. Use .env.example with placeholder values instead.
- **Any format works.** Claude Code can read: MD, TXT, PDF, PNG, JPG, SQL, YAML, JSON, CSV, DOCX, HTML, XML, and most code files.

---

## When to Update core/

| Event | Action |
|-------|--------|
| New design approved | Add wireframes/mockups to core/ |
| Schema changes | Update schema file in core/ |
| New API endpoint planned | Update API spec in core/ |
| Requirements change | Update requirements doc in core/ |
| Architecture decision | Add diagram or decision doc to core/ |
| Phase 2 planning starts | Add Phase 2 specs to core/ |

---

## FAQ

**Q: What if I don't have any documents yet?**
A: That's fine. Bootstrap will ask the 25 questions normally. You can add files to core/ later and Claude Code will read them in future sessions.

**Q: What if my files are in Google Drive / Notion / Figma?**
A: Export them as PDF or PNG and drop them here. Claude Code needs local files.

**Q: Can I put code files here?**
A: Yes. If you're migrating from an old system, put key source files here so Claude Code understands the existing patterns.

**Q: How big can core/ be?**
A: As big as needed. Claude Code reads files on demand, not all at once. Put everything relevant - more context = better results.

**Q: Does Claude Code modify files in core/?**
A: Never. core/ is your territory. Claude Code only reads from it.
