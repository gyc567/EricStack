---
name: erics-process-anti-slop
description: "Use when reviewing or authoring AI-generated code — enforces 15 anti-pattern rules and documentation standards to reject low-evidence, low-signal patterns"
triggers:
  - anti-slop
  - anti-slop review
  - ai 代码规范
  - ai code standard
  - review ai generated
  - ai code quality
---

# Anti-Slop Code Quality Standard

Opinionated rules that reject low-evidence and low-signal TypeScript and JavaScript patterns in AI-generated code. Adapted from [dmmulroy/anti-slop](https://github.com/dmmulroy/anti-slop) and extended with EricStack-specific generation guidance.

## Core Philosophy

**Low-evidence pattern** = code that asserts a type or behavior without providing verifiable proof (e.g., `as object as User` chains type assertions without validation).

**Low-signal pattern** = code that looks reasonable but cannot be statically analyzed, safely extended, or reliably tested (e.g., `Reflect.get`, `unknown` parameters, `vi.mock`).

These rules are not style preferences — they are correctness and maintainability requirements that prevent subtle bugs, undebuggable failures, and test fragility.

---

## 15 Cross-Language Anti-Pattern Rules

### Type Safety (Rules 1–4)

#### 1. no-chained-type-assertions
**Principle**: Chained type assertions fabricate type evidence without validation.

```ts
// ❌ BAD — two assertions with no validation between them
const user = input as object as User;

// ✅ GOOD — explicit validation before assertion
// SAFETY: parseUserId validated the identifier before branding
const userId = raw as UserId;
```

---

#### 2. no-widen-then-assert
**Principle**: Local flows that widen a known value then assert it back discard evidence and add noise without changing the type.

```ts
// ❌ BAD — widen then assert
const loaded: User = loadUser();
const stored: unknown = loaded;
const user = stored as User;

// ✅ GOOD — preserve the known type throughout
const loaded: User = loadUser();
```

---

#### 3. require-safety-comment-for-type-assertion
**Principle**: Every non-const type assertion must document the checked invariant that makes it safe.

```ts
// ❌ BAD — bare assertion with no evidence
const userId = value as UserId;

// ✅ GOOD — invariant is documented
// SAFETY: parseUserId validated the identifier before branding
const userId = value as UserId;
```

---

#### 4. no-known-value-widening
**Principle**: Explicitly widening known literal values into broader types discards the compiler's ability to catch mistakes.

```ts
// ❌ BAD — Record<> annotation discards the known "start" key
const handlers: Record<string, Handler> = { start: startHandler };

// ✅ GOOD — use a mapped type or explicit fields
const handlers = { start: startHandler } satisfies Record<string, Handler>;
// Or use multiple explicit fields if the set is small and known.
```

---

### Reflection / API Misuse (Rules 5–7)

#### 5. no-reflect-apply
**Principle**: `Reflect.apply` is untyped and unanalyzable. Use explicit function calls instead.

```ts
// ❌ BAD
const value = Reflect.apply(operation, owner, args);

// ✅ GOOD
const value = operation.apply(owner, args);
// Or: const value = operation.call(owner, ...args);
```

---

#### 6. no-reflect-get
**Principle**: `Reflect.get` bypasses typed property access. Use explicit member access.

```ts
// ❌ BAD
const value = Reflect.get(owner, key);

// ✅ GOOD
const value = owner[key];
```

---

#### 7. no-runtime-typeof
**Principle**: Ad-hoc `typeof` narrowing cannot be exhaustively checked. Use schema/parser boundary functions instead.

```ts
// ❌ BAD — non-exhaustive, easy to forget cases
if (typeof input === "string" && input) {
  // input is string here but nothing enforced the invariant
}

// ✅ GOOD — schema validation as a boundary
// SAFETY: parseUserId validated the identifier before branding
const userId = parseUserId(raw);
```

Accepts `{ "allowInTypeGuards": true }` in oxlint config to permit `typeof` inside type predicate and assertion functions while rejecting ad hoc checks elsewhere.

---

### Generic Safety (Rules 8–12)

#### 8. no-object-parameters
**Principle**: `object` is the maximally broad type. Functions should accept specific shapes or constrained generics.

```ts
// ❌ BAD
function save(value: object) { ... }

// ✅ GOOD — be specific
function save(value: SaveableEntity) { ... }
// Or: function save<T extends object>(value: T) { ... }
```

---

#### 9. no-unknown-parameters
**Principle**: Reject `unknown` parameters except the explicit `cause: unknown` convention for error handlers.

```ts
// ❌ BAD
function handle(input: unknown) { ... }

// ✅ GOOD — use a specific type or a constrained unknown
function handle(input: Command) { ... }
// Permitted exception:
function handleError(error: unknown, cause: unknown) { ... }
```

---

#### 10. no-unknown-returns
**Principle**: Functions returning `unknown` provide no useful information to callers.

```ts
// ❌ BAD
function loadUser(): unknown { return input; }

// ✅ GOOD — return a specific type
function loadUser(): User { return parseUser(input); }
```

---

#### 11. no-unknown-type-aliases
**Principle**: Type aliases that merely conceal `unknown` provide no semantic value.

```ts
// ❌ BAD — aliases unknown without adding meaning
type ExternalValue = unknown;
type UntypedConfig = Record<string, unknown>;

// ✅ GOOD — be explicit or meaningful
type ExternalValue = string & { __brand: "ExternalId" };
type Config = { timeout: number; retries: number };
```

---

#### 12. no-unsafe-dictionary-type
**Principle**: Dictionary value types based on `unknown`, `any`, `object`, or `{}` cannot constrain what values are legal.

```ts
// ❌ BAD
type Metadata = Record<string, unknown>;
type OtherMetadata = { [key: string]: object };

// ✅ GOOD — constrain the value type
type Metadata = Record<string, string | number | boolean>;
```

---

### Code Structure (Rules 13–14)

#### 13. no-conditional-empty-object-spread
**Principle**: Conditional spreads using `{}` to omit fields are obscure. Use explicit field handling.

```ts
// ❌ BAD — ...{} as a no-op conditional is hard to read
const options = { ...(timeout !== undefined ? { timeout } : {}) };

// ✅ GOOD — explicit field building
const options: Partial<Opts> = {};
if (timeout !== undefined) options.timeout = timeout;
```

---

#### 14. no-shape-in-symbol-names
**Principle**: The word `shape` in symbol names implies a static-struct mental model. Use domain entity names instead.

```ts
// ❌ BAD
interface UserShape { id: string; }

// ✅ GOOD — domain entity name
interface User { id: string; }
```

---

### Testing / Dependency (Rule 15)

#### 15. no-module-mocking
**Principle**: Module-level `vi.mock` / `jest.mock` hides the real dependency graph. Use real dependency seams or explicit dependency injection.

```ts
// ❌ BAD — module mock hides real implementation
vi.mock("./user-store", () => ({ getUser: vi.fn() }));

// ✅ GOOD — use a real seam or DI
// Pass the store as a parameter or use a test-specific layer
const store = new TestUserStore();
const service = new UserService(store);
```

This rule is kept as a **preventive guard** for AI-generated test code, even in non-TypeScript EricStack contexts. When generating test code, prefer real instances over mocked modules.

---

## AI Generation Guidance

When generating code, ensure:

- **Types are explicit** — never omit type annotations on function signatures
- **No reflection APIs** — never use `Reflect.*`, `eval`, or `new Function`
- **Boundary validation is explicit** — use named parse/validate functions, not `typeof` inline
- **Assertions have evidence** — every non-const `as` must have a SAFETY comment
- **Error handling is specific** — `catch(e: unknown)` with typed error handling, not `catch(e: any)`
- **Dictionary values are constrained** — never `Record<string, unknown>`

---

## AI Documentation / Skill File Generation Standards

Inherit the UI/Design checklist from `ai-slop-cleaner`. When generating Markdown or skill files:

| Check | Rule |
|-------|------|
| **Korean readability** | Body text ≥ 14px (Korean requires larger base than Latin scripts) |
| **Shadow restraint** | Use `box-shadow` only where it clarifies elevation or interaction — not as decoration on every surface |
| **Palette rationale** | Avoid default AI blue/purple palettes (e.g., Tailwind `#3B82F6`) without a brand or system rationale |
| **Content hierarchy** | Do not add填充性 eyebrow / description / extra `<p>` when the heading already carries the message |
| **Layout rhythm** | Avoid overly uniform 3- or 4-column grids when the context benefits from asymmetry, bento layout, or varied card weights |
| **Gradient restraint** | Avoid extreme gradients unless the brand deliberately owns that visual language |

---

## Relationship with ai-slop-cleaner

These two skills form a **closed loop** for AI-generated code quality:

```
erics-process-anti-slop          ai-slop-cleaner
(事前规范 · generation-time)      (事后清理 · cleanup-time)
     │                                  │
     │  AI generates code following     │
     │  the 15 rules + doc standards    │
     ▼                                  ▼
  PR review ────────引用────────▶  cleanup pass
  (erics-process-code-review)        (ai-slop-cleaner)
     ▲                                  │
     │                                  │
     └──────违反规则时 flag──────────────┘
```

- **erics-process-anti-slop**: run at generation / review time to enforce rules
- **ai-slop-cleaner**: run post-generation to remove slop patterns that slipped through
- **erics-process-code-review**: references this skill's rules when reviewing AI-generated code in PRs

---

## Automated Enforcement

The 15 rules are implemented as an **oxlint plugin** at `tools/oxlint/anti-slop/src/`. This plugin can be enabled in APS Stage 0 linting via `acceptance.env`:

```env
APS_OXLINT_ENABLED=true
APS_OXLINT_PLUGIN=./tools/oxlint/anti-slop/src/index.ts
```

When enabled, the plugin runs alongside the Gherkin lint stage and reports violations as lint errors, blocking the pipeline until resolved.

**Ignored paths** (agent assets are not checked):
```
.agent/**  .agents/**  .claude/**  .codex/**  .continue/**
.cursor/**  .gemini/**  .opencode/**  .pi/**  .roo/**  .windsurf/**
```

The oxlint plugin is **vendored** from [dmmulroy/anti-slop](https://github.com/dmmulroy/anti-slop) and synced via:
```bash
bash .loopx/bin/sync-anti-slop.sh --check   # check for updates
bash .loopx/bin/sync-anti-slop.sh --execute  # apply sync
```

---

## Rule Index

| # | Rule | Category |
|---|------|----------|
| 1 | no-chained-type-assertions | Type Safety |
| 2 | no-widen-then-assert | Type Safety |
| 3 | require-safety-comment-for-type-assertion | Type Safety |
| 4 | no-known-value-widening | Type Safety |
| 5 | no-reflect-apply | Reflection |
| 6 | no-reflect-get | Reflection |
| 7 | no-runtime-typeof | Reflection |
| 8 | no-object-parameters | Generic Safety |
| 9 | no-unknown-parameters | Generic Safety |
| 10 | no-unknown-returns | Generic Safety |
| 11 | no-unknown-type-aliases | Generic Safety |
| 12 | no-unsafe-dictionary-type | Generic Safety |
| 13 | no-conditional-empty-object-spread | Code Structure |
| 14 | no-shape-in-symbol-names | Code Structure |
| 15 | no-module-mocking | Testing |
