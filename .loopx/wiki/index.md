---
name: EricStack Knowledge Base Index
created: 2026-08-15
---

# EricStack Knowledge Base Index

> Last updated: 2026-08-15

## Skills (33 total)

### Process Discipline (11)
| Skill | Description |
|---|---|
| [[erics-process-archive-agent-notes]] | Use when adding, auditing, pruning, archiving, restoring, or reviewing Agent Notes in EricStack; checks every new note for superseded active records, classifies implemented notes by future decision value, deletes rejected notes that no longer prevent a tempting fallacy, and applies the frozen archived/{kind} triplet and manifest rules. |
| [[erics-process-code-review]] | Use when reviewing a pull request in the EricStack project — orients the reviewer to this codebase's standards (AGENTS.md conventions, defensive patterns, ADRs, quality gates) and the review-specific checks that code alone can't show |
| [[erics-process-doc-site-sync]] | Use when syncing documentation to the VitePress site, adding/removing/renaming pages, updating the docs manifest, or changing site navigation structure |
| [[erics-process-doc-standards]] | 'Use when writing, moving, reviewing, or auditing documentation in the EricStack project — choosing hierarchy and detail, separating tutorials from references, checking tutorial progression, trimming doc slop, responding to a verify-doc-budgets failure, or requests like "improve the docs", "audit the docs", "where should this be documented", or "this doc is too long".' |
| [[erics-process-find-simplifications]] | 'Use when working in the EricStack project to find non-obvious simplification candidates, write proposed Agent Notes or inline TODO/FIXME/XXX notes, audit or coalesce superseded Agent Notes, or fold worthwhile simplification ideas from another PR; especially for dead, duplicated, speculative, over-built, added-then-removed, or hand-rolled-where-a-dependency-exists surfaces.' |
| [[erics-process-merging-stacked-prs]] | Use when landing a stack of dependent GitHub PRs (A ← B ← C, where each bases on the one below) onto master, merging a PR whose base is another open PR's branch, or whenever a request mentions "stacked PRs", "PR stack", "dependent PRs", or merging several related PRs in sequence. Requires every same-repository dependency chain to use GitHub's official stacked-PR feature before landing so GitHub owns stack-wide rules, CI, ordering, retargeting, and merge state. |
| [[erics-process-pre-push-checks]] | Use before pushing, force-pushing, marking ready for review, or claiming checks pass on a EricStack branch, and immediately after gh stack sync publishes rewritten branches, to select the smallest tests and checks that cover the outgoing or just-published diff without reflexively running the full repository suite. |
| [[erics-process-prose-standard]] | Use when reviewing or editing prose in the EricStack project — comments, docs, JSDoc, prompts, visible strings, READMEs, Agent Notes, postmortems, cookbooks, or any human-facing text. Owns editorial judgment and required prose coverage; erics-process-doc-standards owns placement and budgets. Guidance, not a script. |
| [[erics-process-record-browser-gif]] | Use when recording a UI demonstration GIF for a pull request — stages the application, captures frames through browser automation, encodes a looping GIF, and publishes it through the assets-branch workflow |
| [[erics-process-translate-docs]] | Manually run the extended DeepSeek Harness bilingual-document workflow, including generated briefings, delegated prose translation, whole-document translation, and scoped pairing verification. |
| [[erics-process-trim-cot-leakage]] | Use when auditing or fixing prose that reads like a leaked reasoning transcript — dead design-session citations such as (decision N), audit item codes, or §N of uncommitted drafts; change narration such as "used to", "no longer", "this cut"; stack or review vantage ("a later PR in this stack", "rejected in review"); reviewer-addressed justifications; control-flow narration; or hedged planning residue in comments, JSDoc, docs, or Agent Notes. |

### Engineering Abilities (22)
| Skill | Description |
|---|---|
| [[autoplan]] | Run CEO→design→eng→DX full-chain review in one command. |
| [[benchmark]] | Performance regression detection — page load, Core Web Vitals. |
| [[benchmark-models]] | Cross-model benchmark for skills — Claude, GPT, Gemini side-by-side. |
| [[context-restore]] | Resume from a saved context, even across workspaces. |
| [[context-save]] | Save working context — git state, decisions, remaining work. |
| [[design-consultation]] | Build a complete design system from scratch. |
| [[devex-review]] | Live developer experience audit — TTHW, friction points, persona traces. |
| [[erics-ability-cso]] | OWASP Top 10 + STRIDE security audit and threat modeling. |
| [[erics-ability-estack]] | EricStack main entry point — displays interactive banner and routes to the correct skill. Start here for anything in EricStack. |
| [[erics-ability-graft]] | Use when you need to understand code structure, trace call chains, or navigate a large codebase — wraps Graft for fast codebase orientation. |
| [[erics-ability-investigate]] | Four-phase debugging: investigate, analyze, hypothesize, implement. No fixes without root cause. |
| [[erics-ability-plan-ceo-review]] | CEO-level product review — find the 10-star product in the request. |
| [[erics-ability-plan-eng-review]] | Engineering plan review — lock architecture, data flow, edge cases, and tests. |
| [[erics-ability-pr-ask]] | Use when you have a question about a PR — answers free-text questions about PR changes, behavior, or impact. |
| [[erics-ability-pr-changelog]] | Use when preparing a release — generates or updates CHANGELOG.md entries based on PR changes and conventional commits. |
| [[erics-ability-pr-describe]] | Use after completing a PR to generate a complete, accurate PR description — title, type, summary, walkthrough, labels, and breaking changes. |
| [[erics-ability-pr-improve]] | Use when you want actionable code improvement suggestions for a PR — analyzes the diff and produces prioritized, self-reviewed recommendations. |
| [[erics-ability-upgrade]] | Check for EricStack updates and upstream skill sync status. |
| [[health]] | Code quality dashboard — type checker, linter, tests, dead code. |
| [[office-hours]] | YC Office Hours — six forcing questions + design thinking brainstorm. |
| [[retro]] | Weekly retrospective with per-person breakdowns and shipping streaks. |
| [[spec]] | Turn vague intent into a precise, executable spec in five phases. |

## Key Decisions

- [[decision/loopx-architecture]] — LoopX goal lifecycle design
- [[decision/skill-naming]] — erics-process vs erics-ability 分类原则
- [[decision/brand-unification]] — EricStack 品牌统一方案

## Concepts

- [[concepts/agent-notes]] — Agent Note 是什么、何时写、如何维护
- [[concepts/loop-engineering]] — Loop Engineering 核心理念
- [[concepts/Boil-the-ocean]] — 完整性原则
- [[concepts/graft]] — Graft 代码理解工具

## Sources

- [[sources/INTEGRATION.md]] — 双库整合方案完整文档
- [[sources/erics-skills-index]] — 技能索引

## Queries

- [[queries/when-to-use-process-vs-ability]] — 何时用 process skill vs ability skill
- [[queries/how-to-add-new-skill]] — 如何新增一个 skill
