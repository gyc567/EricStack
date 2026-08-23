# Grilling Suite Tutorial | 质询三件套教程

> Three interview skills that turn a loose idea into committable decisions before any code is written. Imported from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted to EricStack.
>
> 三个把"模糊想法"在写代码之前转成"可承诺决策"的访谈技能。从 [mattpocock/skills](https://github.com/mattpocock/skills) 移植并适配到 EricStack。

---

## Why this exists | 为什么存在

Most engineering damage happens before code is written: building the wrong feature, picking the wrong architecture, answering questions that should never have been asked. The grilling suite exists to **make vagueness expensive before code makes it expensive**.

大多数工程损害发生在写代码之前：建错功能、选错架构、回答不该回答的问题。质询三件套的目的是**让"模糊"在代码之前就付出代价**。

The three skills share one technique (ask in **rounds**, each round the whole **frontier**) and differ only in how much they remember and how big the idea is.

三个技能共享同一个技术（**多轮**提问，每轮是整个**前沿**），只在记忆多少和想法大小上不同。

---

## Quick reference | 速查表

| You have… | Reach for | Output |
|---|---|---|
| A loose idea, no code in scope | `erics-ability-grill-me` | Sharper version of the idea, in your head |
| A codebase to align the idea against | `erics-ability-grill-with-docs` | `CONTEXT.md` + ADRs in `docs/adr/` |
| An effort too big to hold in one session | `erics-ability-wayfinder` | `MAP.md` + `tickets/*.md` |

| 你有… | 用这个 | 产出 |
|---|---|---|
| 模糊想法，不涉及代码 | `erics-ability-grill-me` | 脑子里更清晰的版本 |
| 想法要对照代码库 | `erics-ability-grill-with-docs` | `CONTEXT.md` + `docs/adr/` 下 ADR |
| 工作量太大，一节放不下 | `erics-ability-wayfinder` | `MAP.md` + `tickets/*.md` |

---

## The three skills in detail | 三个技能详解

### 1. `erics-ability-grill-me` — Stateless interview

**What it does:** Takes a loose idea, interviews you in rounds, leaves no files behind.

**Invocation:**

```
/grill-me
```

**When to use:**

- You have an idea worth taking seriously but haven't worked out the details.
- The idea is about a feature, a product direction, a business call, or a piece of writing.
- You are NOT in a working directory, or the codebase is irrelevant to the question.
- You can start in a **fresh conversation** (the value is the context you build together).

**When NOT to use:**

- You already know what you want to build — go straight to `erics-ability-spec`.
- The codebase matters — use `grill-with-docs` instead.
- The question can only be answered by running code — stop grilling and prototype.

**Example trigger flow:**

```
> I have an idea for a notification system.

  [grill-me starts]
  ❓ What's the user-facing problem this is solving?
  ➡️ Users miss important updates because they only check email once a day.

  ❓ What happens when a user ignores 5 notifications in a row?
  ➡️ ...

  ❓ Where do notifications live in the user's mental model?
  ➡️ ...

  [round 2 — only the questions whose prerequisites are now settled]
```

**Key principle:** A session with no pushback from you is a session you didn't need. Answer "I don't know" when you don't know.

---

### 2. `erics-ability-grill-with-docs` — Stateful, codebase-aligned

**What it does:** Same interview as `grill-me`, but reads your codebase and writes `CONTEXT.md` + ADRs as it goes.

**Invocation:**

```
/grill-with-docs
```

**When to use:**

- The idea is software-shaped and there's a repo to align with.
- You want the next agent (or future you) to read `CONTEXT.md` and ADRs and pick up where you left off.
- Decisions made during grilling need to be **load-bearing** (architecture, schema, module boundaries).

**Files written:**

| File | Format |
|---|---|
| `CONTEXT.md` | Resolved vocabulary — what terms mean in *this* codebase |
| `docs/adr/NNNN-<slug>.md` | Nygard-style ADRs for hard decisions |

**`CONTEXT.md` example:**

```markdown
# CONTEXT

> Resolved vocabulary for this codebase.

## user

**Meaning in this codebase:** the row in `users` table with `deleted_at IS NULL`
**Where it lives:** `src/models/user.ts`
**Last confirmed:** 2026-08-23

## notification channel

**Meaning in this codebase:** a typed enum {email, push, sms} used in `notifications.channel`
**Where it lives:** `src/types/notification.ts`
**Last confirmed:** 2026-08-23
```

**ADR example (`docs/adr/0001-use-postgres.md`):**

```markdown
# 1. Use Postgres for primary storage

Date: 2026-08-23

## Status

Accepted

## Context

Need durable, relational storage with strong consistency for users, projects, and audit logs.

## Decision

Postgres 16. Single primary, read replicas when traffic warrants.

## Consequences

- Easiest path to ACID transactions on the audit log.
- One DB to back up, one DB to monitor.
- We give up SQLite's zero-ops simplicity — that's a real loss for local dev.
```

**Key principle:** Vocabulary → `CONTEXT.md`. Decisions → ADR. "User means the row in `users`" is vocabulary; "We store users in Postgres" is a decision.

---

### 3. `erics-ability-wayfinder` — Multi-session map

**What it does:** Charts an effort too big for one session as a `MAP.md` tree of decision tickets. Runs grilling sessions inside individual tickets.

**Invocation:**

```
/wayfinder
```

**When to use:**

- The first grilling session ran 30–40+ questions and the context is straining.
- The effort spans multiple subsystems, services, or repositories.
- Different parts need different stakeholders.
- You want to hand the work to a colleague who wasn't in any single session.

**Files written:**

| File | Purpose |
|---|---|
| `MAP.md` (root) | Effort tree — the single source of truth for what's done / open / blocked |
| `tickets/<id>-<slug>.md` | One decision ticket per leaf |
| `CONTEXT.md` (optional) | Vocabulary for the effort |
| `docs/adr/NNNN-<slug>.md` | ADRs for load-bearing decisions |

**`MAP.md` example:**

```markdown
# MAP: Notification system

> Created 2026-08-23.

## Status legend

○ open  ◐ in-progress  ● settled  ✕ cancelled  ↻ superseded

## Tree

● 0. Use Postgres for primary storage           → ADR-0001
├── ◐ 1. Pick notification transport
│   ├── ○ 1a. Email delivery provider
│   └── ○ 1b. Push delivery provider
├── ● 2. Notification model                      → ADR-0002
└── ✕ 3. In-app inbox (cancelled — out of scope)
```

**Ticket example (`tickets/1a-email-provider.md`):**

```markdown
# Ticket 1a: Pick email delivery provider

Status: ○ open
Created: 2026-08-23
Depends on: ticket-0
Blocks: ticket-2

## Question

Which transactional email provider do we use?

## Constraints

- Must support webhooks for delivery status (per ADR-0001, audit log).
- Cost per email < $0.001 at 10k emails/month.

## Session

(to be filled during grilling)

## Outcome

(empty)
```

**Key principle:** Wayfinder does not auto-advance. Each leaf is its own session, owned by a person. The map is a dashboard, not a queue.

---

## How they fit in EricStack | 在 EricStack 中的位置

```
                    loose idea
                        ↓
              ┌─────────────────────┐
              │  erics-ability-     │
              │  grill-me           │ ← no code, no files, fresh session
              └─────────────────────┘
                        ↓ (idea is software-shaped)
              ┌─────────────────────┐
              │  erics-ability-     │
              │  grill-with-docs    │ ← CONTEXT.md + ADRs
              └─────────────────────┘
                        ↓
              ┌─────────────────────┐
              │  erics-ability-     │
              │  spec               │ ← vague intent → executable spec
              └─────────────────────┘
                        ↓
                  implement → code-review

   If the effort is too big at any step:
              ┌─────────────────────┐
              │  erics-ability-     │
              │  wayfinder          │ ← MAP.md + tickets; grilling runs inside
              └─────────────────────┘
```

### Sibling skills (not substitutes) | 同级技能（非替代品）

| Skill | Output | When |
|---|---|---|
| `erics-ability-office-hours` | Design doc | YC-style 6 forcing questions, you already know what the idea is |
| `erics-ability-design-consultation` | Design system | UI/UX system, multiple surfaces |
| `erics-ability-plan-ceo-review` | Review report | You already have a plan, need CEO framing |
| `erics-ability-plan-eng-review` | Review report | You already have a plan, need eng framing |

Grilling produces **decisions** in your head. Office-hours produces a **design doc**. Plan-review produces a **review report**. Spec produces a **spec**. Different artefacts, different points in the chain.

---

## Key principles (apply to all three) | 核心原则（三个都适用）

### Own the scope | 拥有边界

The skill asks the questions, but **you** own the scope. The failure mode is passivity: answering "agreed" for forty questions and coming out with a plan the agent wrote and you nodded at. Nothing was actually decided, and the result carries a certainty it hasn't earned.

技能负责问，**你**负责边界。失败的模式是被动：回答四十次"同意"，出来一个智能体写的、你点头的计划。什么都没真的决定，结论背上了它没挣来的确定性。

### Recognise ungrillable questions | 识别"不可质询"的问题

Some questions can be answered by talking. Others can't.

- "One long form or three pages?" — **ungrillable**, needs a prototype.
- "How should this interaction feel?" — **ungrillable**, needs a prototype.
- "What's the user's goal?" — **grillable**, talk it out.

When you hit one, stop grilling. Build the throwaway version, look at it, then come back and answer in one line.

### Push back, say "I don't know" | 反驳、说"我不知道"

If the question is pitched beneath the fidelity you need, say so. If you don't know the answer, say "I don't know" — that's a real answer, and a question you can't answer is usually a sign to prototype rather than to guess.

如果问题提出的精度不够，就直说。如果不知道答案，就说"我不知道" —— 这是真实答案，回答不了的问题通常意味着该做原型而不是猜。

---

## Common questions | 常见问题

**How many questions should I expect?**

Count rounds, not questions. Forty-six questions across four rounds is an ordinary session. It ends when the frontier is empty: every branch visited, nothing left silently assumed.

数轮数，不要数问题。46 个问题分 4 轮是普通会话。当前沿空了它就结束：每个分支都走到，没有默默假设。

**It asked me 200 questions. What went wrong?**

Usually scope was too large. Break the work into smaller pieces first, then grill each one. If you want the multi-session approach from the start, use `erics-ability-wayfinder`.

通常是范围太大。先拆成小块，再分别质询。如果一开始就想要多会话方案，直接用 `erics-ability-wayfinder`。

**Can I go back to one question at a time?**

Yes. Add to your global `CLAUDE.md`:

```
When grilling, ask one question at a time.
```

可以。在全局 `CLAUDE.md` 加：

```
When grilling, ask one question at a time.
```

**Where do I start if I'm not sure?**

```
erics-ability-grill-me    ← always safe to start here
```

If the interview stalls because of codebase questions, hand the conversation to `erics-ability-grill-with-docs`. If the effort is bigger than one session, `erics-ability-wayfinder`.

不确定时从哪里开始？

```
erics-ability-grill-me   ← 从这里开始总是安全的
```

如果因代码库问题卡住了，把同一段对话交给 `erics-ability-grill-with-docs`。如果工作量超过一节会话，用 `erics-ability-wayfinder`。

---

## What the skills are NOT | 这些技能不是

- **Not code generators.** They sharpen ideas; they don't write code.
- **Not conversation replacers.** Passivity produces hollow plans — you have to steer.
- **Not one-shot.** Wayfinder expects multi-session work; grill-me and grill-with-docs benefit from being able to revisit decisions later.

- **不是代码生成器**。它们锐化想法，不写代码。
- **不是对话替代品**。被动产生空洞计划 —— 你必须主动掌舵。
- **不是一次性**。Wayfinder 期待多会话；grill-me / grill-with-docs 也受益于能日后回访决策。

---

## File reference | 文件参考

| File | Purpose |
|---|---|
| `.loopx/skills/erics-ability/erics-ability-grill-me/SKILL.md` | Stateless interview skill |
| `.loopx/skills/erics-ability/erics-ability-grill-with-docs/SKILL.md` | Stateful codebase-aligned skill |
| `.loopx/skills/erics-ability/erics-ability-wayfinder/SKILL.md` | Multi-session orchestrator |
| `.loopx/wiki/concepts/grilling-family.md` | Wiki concept page covering all three |
| `docs/GRILLING_SUITE.md` | This file |

## Related docs | 相关文档

- `docs/TUTORIAL.md` — General EricStack tutorial
- `docs/APS_INTEGRATION.md` — APS pipeline integration
- `.loopx/wiki/concepts/boil-the-ocean.md` — Completeness principle (why we kept three skills instead of one)
