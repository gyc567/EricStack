---
name: EricStack Wiki Schema
created: 2026-08-15
---

# EricStack Wiki Schema

## Directory Structure

```
.loopx/wiki/
├── purpose.md         # Project goals and key questions
├── schema.md          # This file — structure conventions
├── index.md           # Content catalog (skills + decisions + docs)
├── log.md             # Chronological operation log
├── overview.md        # Auto-updated project summary
├── entities/          # Named things: decisions, people, features, bugs
├── concepts/          # Concepts, patterns, and practices
├── sources/           # Primary sources: docs, specs, meeting notes
├── queries/           # Q&A pairs from knowledge base queries
└── comparisons/      # Technology comparisons and trade-offs
```

## Naming Conventions

### Wiki Pages
- `kebab-case.md` — all wiki pages use kebab-case filenames
- `YYYY-MM-DD-topic.md` — Agent Notes follow date-prefixed naming
- `index.md` and `log.md` are special files — never rename

### Wikilinks
- Use `[[page-name]]` for internal links (Obsidian-compatible)
- Use full path `[[concepts/pattern-name]]` when ambiguous
- External links: use descriptive text, not bare URLs

### Frontmatter
Every page must include:
```yaml
---
name: Short Name
created: YYYY-MM-DD
updated: YYYY-MM-DD  # add on edits
tags: [tag1, tag2]
---
```

## Content Rules

### Entities
- One entity per file
- Start with a one-line definition
- Include provenance (where the information came from)
- Link to related entities and concepts

### Concepts
- One concept per file
- Explain the pattern, not just the term
- Include examples from the project
- Link to relevant skills

### Queries
- Store the question, not just the answer
- Include the context in which the question was asked
- Mark answers as `verified` or `tentative`
- Update when new information changes the answer

### Log Entries
Format: `## [YYYY-MM-DD] operation | brief description`
- `operation` is one of: `ingest`, `query`, `lint`, `update`, `decision`
- Never delete from log — append corrections as new entries
- Keep entries parseable with unix tools (grep, awk)

## LLM Operations

### Ingest
When ingesting new content:
1. Read the source fully
2. Create or update the relevant entity/concept page
3. Update `index.md` if adding a new top-level entry
4. Append to `log.md`

### Query
When answering from the knowledge base:
1. Search relevant wiki pages
2. Synthesize an answer with citations
3. If the answer reveals a knowledge gap, file it as a new page

### Lint
Run periodically to check:
1. Orphan pages (no incoming links)
2. Broken wikilinks
3. Stale content (not updated in > 90 days)
4. Duplicate topics
