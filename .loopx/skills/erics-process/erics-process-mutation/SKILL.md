---
name: erics-process-mutation
description: Use when running or reviewing mutation tests — proves your test suite is meaningful by verifying it catches injected faults.
triggers:
  - mutation testing
  - mutation tests
  - verify test quality
  - 测试有效性
  - 突变测试
  - mutmut
  - cosmic ray testing
---

# Mutation Testing — Prove Your Tests Are Real

**Core principle: "Don't trust the code — trust the test suite passing mutation tests."**

> If a test suite passes even after the code under test is deliberately broken, the tests are useless. Mutation testing injects faults to verify your tests catch them.

---

## What is Mutation Testing?

Mutation testing deliberately mutates your source code:
- Boundary changes: `age > 18` → `age > 17`
- Condition reversals: `&&` → `||`
- Return value changes: `return true` → `return false`
- Operation changes: `count + 1` → `count - 1`

Each mutation is a "mutant." If your test suite catches the mutant (test fails), the mutant is "killed." If tests still pass, the mutant "survives" — indicating a weak test.

**Goal:** Mutation survival rate < 5%

---

## When to Run

| Scenario | When |
|---|---|
| After writing new tests | Verify tests are meaningful, not just passing |
| Before PR merge | As a quality gate alongside coverage |
| During code review | When reviewing test quality, not just coverage |
| After adding new dependencies | Verify existing tests still hold |

---

## Tools by Language

| Language | Tool | Install |
|---|---|---|
| Python | `mutmut` | `pip install mutmut` |
| JavaScript/TS | `stryker-js` | `npx @stryker-mutator/stryker-js` |
| Go | `go-mutesting` | `go install github.com/mdempsky/gomutesting@latest` |
| Rust | `mutant` | `cargo install cargo-mutant` |
| Ruby | `mutant` | `gem install mutant` |
| Java | | `pitest` |

---

## Running Mutation Testing

### Python (mutmut)

```bash
# Install
pip install mutmut

# Run (from project root)
mutmut run

# Show results
mutmut results

# Show surviving mutants
mutmut show

# Run with coverage (required)
mutmut run --with-coverate

# Disable timeout detection for slow tests
mutmut run --no-timeout
```

### JavaScript (stryker-js)

```bash
npx @stryker-mutator/stryker-js init
npx @stryker-mutator/stryker-js run
```

### Go

```bash
go install github.com/mdempsky/gomutesting@latest
gomutesting ./...
```

---

## Interpreting Results

### Survival Rate

| Survival Rate | Interpretation | Action |
|---|---|---|
| < 5% | ✅ Excellent | Ready to merge |
| 5-15% | ⚠️ Acceptable | Review surviving mutants |
| 15-30% | ❌ Problematic | Add or improve tests |
| > 30% | ❌ Dangerous | Tests are not catching real bugs |

### Reading Surviving Mutants

For each surviving mutant, ask:
1. **Is the mutant semantically equivalent to the original?** (sometimes mutations are benign)
2. **Is there a test that should catch this but doesn't?**
3. **Is the test assertion too weak?**

```bash
# For each surviving mutant, see the diff
mutmut show <mutant-id>
```

---

## Quality Gate Integration

Add to your CI/CD pipeline:

```bash
# Python example (GitHub Actions)
- name: Mutation Testing
  run: |
    pip install mutmut
    mutmut run --with-coverate
    mutmut junitxml > mutmut.xml

# Gate: survival rate must be < 15%
- name: Check Mutation Score
  run: |
    score=$(mutmut last-run --no-progress 2>/dev/null | grep "survived" | awk '{print $4}')
    echo "Survival rate: $score"
    if (( $(echo "$score > 15" | bc -l) )); then
      echo "FAIL: mutation survival rate too high"
      exit 1
    fi
```

---

## Relationship to Other Skills

| Skill | Distinction |
|---|---|
| `erics-ability-health` | Health checks coverage and lint. Mutation testing proves tests are meaningful. |
| `erics-process-pre-push-checks` | Pre-push checks run tests. Mutation testing verifies the tests are worth running. |
| `erics-process-code-review` | Code review checks code quality. Mutation testing checks test quality. |

---

## Output Format

When mutation testing is complete, report:

```
## Mutation Testing Report

### Summary
- Mutants: N total
- Killed: N (X%)
- Survived: N (X%) ← target: <5%
- Timeout: N
- Incompetent: N (benign mutations)

### Surviving Mutants (Review Required)
| File | Line | Mutation | Suggested Fix |
|---|---|---|---|
| auth.py | 42 | `age > 18` → `age > 17` | Add boundary test for age=17 |
| ... | ... | ... | ... |

### Recommendation
✅ Ready to merge / ⚠️ Add N tests / ❌ Fix N surviving mutants
```

---

## Limitations

- **Slow:** Mutation testing is expensive. Run on CI, not locally for every change.
- **Equivalent mutants:** Some mutations don't change behavior (e.g., `x + 0` → `x - 0`). These are "incompetent" and don't count against you.
- **Not for all code:** 100% mutation coverage is unrealistic. Target critical paths first.
