# EricStack

AI-native engineering loop system with 46 skills for planning, review, simplification, documentation, and knowledge accumulation.

## Project Structure

```
EricStack/
├── .loopx/
│   ├── skills/
│   │   ├── erics-loop-router/     # Routes tasks to correct skill
│   │   ├── erics-process-* (×13)  # Discipline/standards skills
│   │   └── erics-ability-* (×27)  # Action/productivity skills
│   ├── wiki/                      # LLM Wiki knowledge base
│   ├── bin/                       # Installation & sync scripts
│   ├── acceptance-pipeline/       # APS tools & features
│   └── cache/                     # Incremental caching
├── docs/                          # Integration & tutorial docs
└── src/main.rs                    # Placeholder (skills are the product)
```

## Key Commands

```bash
/estack                 # Main entry point - shows banner and routes
/erics-loop-router      # View all 46 skills and routing rules
```

## Skills Categories

**Process (Discipline):** Code review, prose standards, docs, simplification, mutation testing, pre-push checks

**Ability (Action):** Planning reviews, debugging, benchmarking, health checks, context save/restore, retro, office hours

## Architecture Notes

- Skills are markdown files with YAML frontmatter + markdown body
- LoopX skill system loads skills from `~/.claude/skills/` (symlinked here)
- Upstream sync via `.loopx/sync-state.json` tracking deepseek-harness and gstack sources
- APS integration in `.loopx/acceptance-pipeline/` for BDD acceptance testing

## Development

- Run install script: `bash .loopx/bin/install-ericsstack.sh`
- Check updates: `bash .loopx/bin/sync-skills.sh --check`
- Skills follow naming: `erics-process-*` or `erics-ability-*`
