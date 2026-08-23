---
name: grilling-family
created: 2026-08-23
tags: [interview, ideation, stateless, grilling, pre-spec, mattpocock]
---

# The Grilling Family — Three Skills, One Technique

The grilling family is a set of three interview skills that turn a loose idea into committable decisions before any code is written. They share one technique — ask in **rounds**, each round the whole **frontier** — and differ only in how much they remember and how big the idea is.

Imported from [mattpocock/skills](https://github.com/mattpocock/skills), adapted to EricStack's bilingual triggers and routing.

## The three skills

| Skill | Stateful? | Repo needed? | Best for |
|---|---|---|---|
| [[erics-ability-grill-me]] | No | No | Loose idea, anywhere, on anything |
| [[erics-ability-grill-with-docs]] | Yes (`CONTEXT.md` + ADRs) | Yes | Idea aligned with an existing codebase |
| [[erics-ability-wayfinder]] | Yes (`MAP.md` + tickets) | Optional | Effort too big to hold in one session |

## The shared technique

Three ideas carry the whole family:

- **Design tree** — decisions with decisions hanging off them.
- **Frontier** — the set of decisions whose prerequisites are all settled; the only questions that can honestly be asked yet.
- **Round** — one frontier, asked in full and answered in full.

Each round arrives as a numbered list with recommendations on `➡️` lines. The user answers by number ("1 yes, 2 the second option, 3 no, here's why"). The next round is recomputed from the answers, not pre-written.

The session ends when the frontier is empty AND the user confirms shared understanding — never before.

## Where they sit in EricStack

```
grill-me  →  grill-with-docs  →  erics-ability-spec  →  implement  →  erics-process-code-review
   (loose)    (codebase)            (spec)              (code)            (review)

        ↑ wayfinder wraps any of these when the effort is too big
```

- **Before grilling:** nothing — the looser the idea, the better the grilling works.
- **After grilling:** the conversation flows naturally to [[erics-ability-spec]] for software-shaped outcomes.
- **Sibling skills** that are *not* substitutes: [[erics-ability-office-hours]] (YC six forcing questions, output is a design doc), [[erics-ability-design-consultation]] (full design system), [[erics-ability-plan-ceo-review]] / [[erics-ability-plan-eng-review]] (review an existing plan).

## Key principles (from mattpocock, kept verbatim)

**Own the scope.** Answering "agreed" for forty questions produces a plan the agent wrote, not decisions you made. Push back, say "I don't know", and steer when needed.

**Recognise ungrillable questions.** "How should this interaction feel?" needs something to react to. Stop grilling and prototype, then come back and answer in one line.

**Passivity is the failure mode.** A session with no pushback from you is a session you didn't need.

## EricStack design choices

These three skills were imported with one deliberate constraint: **strictly follow mattpocock's stateless design**.

- **No Brain Context preflight.** Stateless by design; do not load `bin/erics-brain-cache`.
- **No Prior Learnings search.** Fresh session; do not query `bin/true --limit 10`.
- **No Plan Status Footer.** These are interview skills, not plan-review skills.

The bilingual triggers (Chinese + English) follow EricStack convention. Everything else — file formats, the round/frontier technique, the file paths (`CONTEXT.md`, `docs/adr/`, `MAP.md`, `tickets/`) — is mattpocock's design preserved.

## Related concepts

- [[concepts/boil-the-ocean]] — explains why we kept three skills instead of consolidating to one.
- [[erics-ability-spec]] — the typical downstream skill after grilling.
- [[erics-ability-office-hours]] — a sibling that ends in a design doc rather than in your head.
