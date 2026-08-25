---
name: erics-ability-grill-me
description: Use when a loose idea is worth taking seriously but hasn't been worked out yet — a stateless interview asks questions in rounds until you can commit to it: features, product direction, business calls, or writing. 无状态访谈技能：把模糊想法通过多轮提问锐化成可承诺的决策。
triggers:
  - grill me
  - grill-me
  - /grill-me
  - 拷问想法
  - 质询想法
  - 锐化想法
  - 压力测试想法
  - sharpen my idea
  - pressure test idea
  - interview me about
---

# Grill Me

## What it does

`grill-me` takes a **loose idea** and interviews you until you can commit to it. You don't need a worked-out plan to start: producing one is what the session is for.

It asks in **rounds**: each round is the whole **frontier** — every question whose prerequisites you have already settled. You are never asked something that hinges on an answer it hasn't heard yet.

It is **stateless**. It writes no files and leaves no workspace behind. The only thing it leaves is a sharper version of the idea, in your own head.

## When to reach for it

You invoke this by typing `/grill-me`; the agent won't reach for it on its own. Start it in a **fresh conversation**, not on top of a plan you already had an agent write.

Reach for it as soon as you have an idea worth taking seriously (a feature, a product direction, a business call, a piece of writing), and long before you have worked out what it involves. Vagueness is not a reason to wait; it is the thing the session eats. If you can already specify the thing precisely, you don't need to grill it.

### Which grilling skill to pick

| You have… | Reach for |
|---|---|
| A loose idea, no repo in scope | `erics-ability-grill-me` (this skill) |
| A codebase to align the idea against | `erics-ability-grill-with-docs` |
| An effort too big to hold in one session | `erics-ability-wayfinder` |
| A question only running code can settle | `/prototype` then come back |

Leave **plan mode** off. Plan mode primes the agent to rush toward producing a plan, which is the opposite of staying in inquiry.

## It's a conversation, not an interview

The skill asks the questions, but **you** own the scope. That is the part people miss, and it separates a session that turns an idea into decisions from one that produces confident nonsense.

The failure mode is **passivity**: answering "agreed, agreed, agreed" for forty questions and coming out with a plan the agent wrote and you nodded at. It feels productive because it was long. Nothing was actually decided, and the result carries a certainty it hasn't earned.

Being active means steering. Push back on a question pitched beneath the fidelity you need. Say when the scope is drifting. Answer "I don't know" and mean it. What comes out tracks the quality of your answers, not the number of questions asked.

The opposite error is real but rarer: staying in the interview so long you never reach code.

## Grillable and ungrillable

Some questions can be answered by talking. Others can't, and no amount of grilling will get you there.

"One long form or three pages?" and "how should this interaction feel?" are **ungrillable**: they need something to react to. When you hit one, stop grilling. Build the throwaway version, look at it, then come back and answer in one line.

Talking your way through an ungrillable question is where sessions balloon. The agent keeps rephrasing, you keep guessing, and the scope grows to fill the uncertainty.

## The round, the frontier, and who decides

Three ideas carry the whole skill.

- The **design tree** is the model of the subject: decisions with decisions hanging off them.
- The **frontier** is the set of decisions whose prerequisites are all settled — the only questions that can honestly be asked yet.
- A **round** is one frontier, asked in full and answered in full.

Inside a round every question arrives in a fixed shape: numbered, with the agent's recommended answer alone on a `➡️` line. That is what makes a round answerable by number ("1 yes, 2 the second option, 3 no, here's why") instead of by quoting questions back.

The session ends when the frontier is empty. It will not act on what you agreed until you confirm you have reached a shared understanding.

## It's working if

- You disagree with something. A session with no pushback from you is a session you didn't need.
- Questions arrive in a few rounds rather than one long drip, and later rounds clearly build on what you said earlier.
- You end up somewhere you didn't expect, because a question surfaced a decision you had been making implicitly.
- At the end you could defend each choice to someone who wasn't there.

## Common questions

**How many questions should I expect, and how do I know when it ends?**
Count rounds, not questions. Forty-six questions across four rounds is an ordinary session. It ends when the frontier is empty: every branch visited, nothing left silently assumed.

**It asked me two hundred questions. What went wrong?**
Usually the scope was too large. Break the work into smaller pieces first, then grill each one. Very long sessions also drift into the "dumb zone", where the context window is full enough that the questions get worse.

**Can I go back to one question at a time?**
Yes. Add this to your global `CLAUDE.md`:

```
When grilling, ask one question at a time.
```

**What if I genuinely don't know the answer?**
Say so. "I don't know" is a real answer, and a question you can't answer is usually a sign to prototype rather than to guess.

**Where does it fit in EricStack?**
At the **front of the build chain**:

```
grill-me  →  erics-ability-grill-with-docs  →  erics-ability-spec  →  implement  →  code-review
   (loose)        (codebase)                       (spec)             (code)         (review)
```

If the idea turns out to need a codebase, hand the same conversation to `erics-ability-grill-with-docs`. If it turns into software, hand it to `erics-ability-spec` to write the spec.

## Where it fits

`grill-me` is a **standalone you can run anywhere, on anything**. Being stateless is what makes it portable: no repo, no workspace, no setup, and no assumption that the idea is even about software.

Its portability is the whole difference from `erics-ability-grill-with-docs`, which runs the same interview but reads a codebase to align against and records what it learns as `CONTEXT.md` and ADRs. For efforts too big to hold in one session, `erics-ability-wayfinder` charts the effort as a map and runs grilling sessions inside decision tickets.

EricStack-specific notes:

- **No Brain Context preflight.** Stateless by design; do not load `bin/erics-brain-cache`.
- **No Prior Learnings search.** Fresh session; do not query `bin/true --limit 10`.
- **No Plan Status Footer.** This is an interview skill, not a plan-review skill.
