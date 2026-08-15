---
name: erics-ability-pr-ask
description: Use when you have a question about a PR — answers free-text questions about PR changes, behavior, or impact.
triggers:
  - pr ask
  - ask about this pr
  - question about pr
  - PR 问题
  - pr question
  - what does this pr do
---

# PR Question & Answer

**Answer any question about a PR based on its diff, commit messages, and project context.**

---

## Gather context

```bash
git diff base..head --stat
git diff base..head
git log --oneline base..head
cat AGENTS.md 2>/dev/null || echo "No AGENTS.md"
```

---

## Answer structure

For every question:

```
## Question
<user's question>

## Answer
<direct answer — no preamble needed>

## Evidence
- [file:line](code reference or quote from diff)
- [file:line](another reference)

## Confidence
- **High** — answer is clearly supported by the PR diff
- **Medium** — answer is inferred from the diff, not explicitly stated
- **Low** — cannot fully answer from PR content alone

## If answer is unknown
"If the PR doesn't contain enough information to answer this question,
say so directly: 'I can't determine this from the PR. You may need to
ask the PR author or check the linked ticket.'"
```

---

## Question types & examples

| Question type | Example | Focus |
|---|---|---|
| **What** | "What does this PR change?" | Summary of changes |
| **Why** | "Why was this approach chosen?" | Motivation from commit messages |
| **Impact** | "What's the performance impact?" | Performance-sensitive paths |
| **Security** | "Are there security implications?" | Auth, input validation, data exposure |
| **Compatibility** | "Will this break existing users?" | Breaking changes, API changes |
| **Testing** | "Is the test coverage adequate?" | Coverage analysis |
| **Architecture** | "Does this fit the existing architecture?" | Design consistency |

---

## Rules

1. Answer in the same language as the question
2. Cite specific files and line numbers as evidence
3. Flag when you're inferring vs. explicitly seeing in the diff
4. Do not suggest code changes — use `pr-improve` for that
5. Do not answer questions about unrelated parts of the codebase

---

## Relationship to other skills

| Related Skill | Distinction |
|---|---|
| `erics-ability-pr-improve` | Answers "what's wrong?" with suggestions. `pr-ask` answers any question. |
| `erics-ability-investigate` | `investigate` is for debugging bugs. `pr-ask` is for understanding PR intent. |
