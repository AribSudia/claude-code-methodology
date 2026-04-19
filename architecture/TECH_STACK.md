# Tech Stack — Approved Technologies

> **Rule**: Only technologies listed here may be used in this project.
> Adding a new technology requires an ADR in architecture/DECISIONS.md.

---

## [PROJECT] Tech Stack

> Fill this table when instantiating for a specific project.
> Remove rows for technologies not used. Add project-specific libraries.

| Layer         | Technology       | Version   | Purpose                   | Notes              |
|---------------|------------------|-----------|---------------------------|---------------------|
| Language      | [Language]       | [Version] | Primary language          |                     |
| Backend       | [Framework]      | [Version] | API server                |                     |
| Frontend      | [Framework]      | [Version] | Web UI                    |                     |
| Mobile        | [Framework]      | [Version] | Mobile app (if applicable)|                     |
| Database      | [Database]       | [Version] | Primary data store        |                     |
| Cache         | [Cache]          | [Version] | Session/data caching      |                     |
| ORM           | [ORM]            | [Version] | Database abstraction      |                     |
| Auth          | [Strategy]       | —         | Authentication            | See SECURITY.md     |
| Payments      | [Provider]       | —         | Payment processing        | If applicable       |
| Storage       | [Provider]       | —         | File/media storage        | If applicable       |
| Queue         | [System]         | [Version] | Async messaging           | If applicable       |
| Search        | [Engine]         | [Version] | Full-text search          | If applicable       |
| Email         | [Provider]       | —         | Transactional email       | If applicable       |
| SMS           | [Provider]       | —         | SMS notifications         | If applicable       |
| Monitoring    | [Tool]           | —         | Application monitoring    |                     |
| CI/CD         | [Platform]       | —         | Build and deploy pipeline |                     |
| Hosting       | [Provider]       | —         | Production hosting        |                     |

---

## Common Stack Presets

### Preset A: Node.js Full-Stack
| Layer    | Technology              | Version  |
|----------|-------------------------|----------|
| Backend  | Node.js + Express       | 20 LTS   |
| Frontend | React + Vite            | 18 / 5   |
| Database | PostgreSQL              | 16       |
| ORM      | Prisma                  | 5.x      |
| Cache    | Redis                   | 7        |
| Auth     | JWT + bcrypt            | —        |
| Testing  | Vitest + Playwright     | —        |
| Styling  | Tailwind CSS            | 3.x      |

### Preset B: .NET + Flutter
| Layer    | Technology              | Version  |
|----------|-------------------------|----------|
| Backend  | .NET                    | 9        |
| Frontend | Flutter (Web)           | 3.x      |
| Mobile   | Flutter (iOS/Android)   | 3.x      |
| Database | PostgreSQL              | 16       |
| ORM      | Entity Framework Core   | 9.x      |
| Cache    | Redis                   | 7        |
| Auth     | ASP.NET Identity + JWT  | —        |
| Testing  | xUnit + Playwright      | —        |

### Preset C: Next.js Full-Stack
| Layer    | Technology              | Version  |
|----------|-------------------------|----------|
| Full     | Next.js                 | 14+      |
| Language | TypeScript              | 5.x      |
| Database | PostgreSQL              | 16       |
| ORM      | Prisma / Drizzle        | latest   |
| Cache    | Redis / Upstash         | —        |
| Auth     | NextAuth.js / Auth.js   | 5.x      |
| Testing  | Vitest + Playwright     | —        |
| Styling  | Tailwind CSS            | 3.x      |
| Deploy   | Vercel                  | —        |

### Preset D: Python FastAPI
| Layer    | Technology              | Version  |
|----------|-------------------------|----------|
| Backend  | FastAPI                 | 0.110+   |
| Frontend | React + Vite            | 18 / 5   |
| Database | PostgreSQL              | 16       |
| ORM      | SQLAlchemy              | 2.x      |
| Cache    | Redis                   | 7        |
| Auth     | JWT + passlib           | —        |
| Testing  | pytest + Playwright     | —        |
| Styling  | Tailwind CSS            | 3.x      |

---

## Dependency Rules

1. **No new dependency without justification** — check if existing libs can handle it
2. **Pin exact versions** in lock files (package-lock.json, poetry.lock, etc.)
3. **Security audit monthly** — `npm audit` / `pip audit` / `dotnet list package --vulnerable`
4. **No deprecated packages** — check last publish date, maintainer activity
5. **Prefer well-maintained packages** — 1000+ GitHub stars, recent commits, active issues

---

## Forbidden Technologies

| Technology         | Why Forbidden                                    |
|--------------------|--------------------------------------------------|
| jQuery             | Use modern framework instead                     |
| Moment.js          | Deprecated — use date-fns or dayjs               |
| Request (npm)      | Deprecated — use axios or fetch                  |
| Sequelize          | Use Prisma or Drizzle instead (better types)     |
| Any pre-1.0 ORM    | Too unstable for production                      |
| PHP (new projects) | Not in approved stack — use Node, .NET, or Python|

> Add project-specific forbidden technologies when instantiated.

---

> **End of Tech Stack**
> When in doubt, check this file. If it's not listed here, don't use it.
