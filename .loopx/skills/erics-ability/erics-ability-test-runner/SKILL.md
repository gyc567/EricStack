---
name: erics-ability-test-runner
description: Use when you need to execute APS-generated acceptance tests against a real test framework — adapts the framework-agnostic JSON IR to JUnit 5, Pytest, Behave, Go testing, Jest, or RSpec, with per-scenario world isolation, sandboxed step handlers, and structured run reports.
triggers:
  - test runner
  - run acceptance tests
  - run gherkin
  - 验收测试运行
  - aps runner
  - framework adapter
  - test framework adapter
  - junit 5 acceptance
  - pytest bdd runner
  - jest gherkin
  - go test acceptance
  - rspec gherkin
  - behave runner
  - test adapter
  - acceptance test execution
---

# APS Test Runner Adapter Layer

**Bridge the framework-agnostic Acceptance Pipeline Specification (APS) JSON IR to a concrete test framework, then execute the scenarios with proper isolation.**

The Acceptance Pipeline Specification produces a JSON IR (Intermediate Representation) that is deliberately framework-agnostic. This skill is the *adapter layer* — it takes that IR, generates framework-specific entrypoint code (or invokes a BDD-native runner like Behave), wires step handlers, and runs the acceptance suite against the project's actual test framework.

---

## When to Use

| Task | Use This Skill |
|---|---|
| "Run the `.feature` file against JUnit 5" | Yes |
| "Generate Pytest entrypoint from IR and execute" | Yes |
| "Run Behave on `features/auth/login.feature`" | Yes |
| "Adapter does not exist for my framework (vitest, Kotest, …)" | Yes — see *Implementing a New Adapter* |
| "Write step handlers in Python" | No — write them directly in `features/steps/` |
| "Only need to inspect IR / dry-check" | No — use `erics-ability-bdd` (Stage 1-2) |

This skill assumes `erics-process-acceptance-pipeline` Stage 1 (parse) and Stage 2 (DRY) have already run; you receive a valid JSON IR.

---

## Step Handler Contract

Every framework adapter MUST implement the same contract. The contract comes straight from the APS specification — the adapter is a thin shim around it.

### World Object

Each **scenario execution** receives a fresh `world` (a.k.a. `state`, `context`) object:

```yaml
world:
  lifecycle: fresh_instance_per_scenario
  disposal: must_be_called_after_scenario
  serialization: required_for_trace_and_debug
  scope: scenario_only (Background steps share this instance)
```

### Handler Signature

```yaml
step_handler:
  inputs:
    - world:     mutable per-scenario state object
    - step_text: the raw matched step string (e.g., "the user enters username \"alice\"")
    - example_values:
        - key:  name of placeholder, derived from regex group name OR cucumber-expression `{name}`
        - value: bound value from the Examples table (or literal)
  outputs:
    - world_mutation: handler may mutate world freely
    - result:
        success: true                          # step passed
        success: false
        error:
          diagnostic: "<message>"
          expected:   "<value>"                # optional, for assertion failures
          actual:     "<value>"                # optional
          file:       "<handler.py:42>"        # optional
          stack:      "<traceback>"            # optional
```

### Worked Example

```python
# Python step handler (matches any BDD framework)
def step_user_enters_credentials(world, username, password):
    world.last_response = world.http_client.post(
        "/login",
        json={"username": username, "password": password},
    )
    if world.last_response.status_code != 200:
        return {
            "success": False,
            "error": {
                "diagnostic": "Login request did not return 200",
                "expected": "200",
                "actual": str(world.last_response.status_code),
                "file": "features/steps/auth.py:27",
            },
        }
    return {"success": True}
```

The Gherkin `When the user enters username "<username>" and password "<password>"` matches the handler with `example_values = {"username": "alice", "password": "secret123"}`.

### Requirements

| Requirement | Reason | Adapter Implementation Hint |
|---|---|---|
| Fresh world per scenario execution | Avoid state leakage between tests | Fixture scoped to function/test (not module/class) |
| Background steps share world with the scenario they precede | Background is pre-state for the scenario | Background runs in same scope, before the first step |
| Regex matching with placeholder-name capture | Type-safe parameter binding | Use named groups (`(?P<username>...)`) — Behave, Pytest-BDD, Godog support this directly |
| Cucumber-expression support `{string}` / `{int}` | Cross-language portability | Pre-process IR; convert `{x}` → `(?P<x>...)` before binding |
| Unmatched placeholder | Fail-fast | Adapter MUST raise, not silently pass |
| Unsupported step (no matching handler) | Fail-fast | Adapter MUST raise with a list of registered handlers in the error |

---

## Framework Adapters

Each adapter takes the JSON IR and either (a) generates framework-specific entrypoint code, or (b) invokes a BDD-native runner directly.

| Framework | Language | Adapter Output | Sandbox Mechanism | Notes |
|---|---|---|---|---|
| **JUnit 5** | Java | `*Test.java` | `@TempDir` + JUnit 5 Extension | Standard `@Test` methods; `@BeforeEach` / `@AfterEach` for world lifecycle |
| **Pytest** | Python | `test_*.py` | `tmp_path` fixture + autouse fixture | Most common APS target; works with pytest-bdd handlers |
| **Behave** | Python BDD | none — runs `.feature` directly | `environment.py` hooks | Native BDD runner; adapter is a thin wrapper |
| **Go testing** | Go | `*_test.go` | `t.TempDir()` + per-test setup | Generated entrypoint uses `testing.T`; handlers in same package |
| **Jest** | JS/TS | `*.test.ts` | `beforeEach` / `afterEach` | Use `jest-cucumber` style or generated wrappers |
| **RSpec** | Ruby | `*_spec.rb` | `around` hooks | Works with `cucumber-ruby` step defs via shared handler registration |
| **vitest** | JS/TS (optional) | `*.test.ts` | `vi.resetAll()` | Modern Vite ecosystem |
| **Kotest** | Kotlin (optional) | `*Test.kt` | `autoClose` | Kotlin-first testing |

### Adapter Selection

The active adapter is chosen by `.loopx/acceptance-pipeline/acceptance.env`:

```bash
APS_FRAMEWORK=auto   # auto-detect from project (package.json, pyproject.toml, go.mod, …)
APS_FRAMEWORK=junit5 # or: pytest, behave, gotest, jest, rspec, vitest, kotest
```

`auto` resolution order:
1. `pom.xml` / `build.gradle` with junit-jupiter → `junit5`
2. `pyproject.toml` with behave dependency → `behave` (else → `pytest`)
3. `go.mod` → `gotest`
4. `package.json` with `jest` → `jest` (with vitest → `vitest`)
5. `Gemfile` with rspec → `rspec`
6. Fallback: error — require explicit `APS_FRAMEWORK`

---

## Implementing a New Adapter

If your target framework is not in the table above (e.g., Kotest, vitest, Cypress, Mocha), create a new adapter. Every adapter follows the same shape.

### 1. Define the Adapter Interface

```yaml
# skills/erics-ability-test-runner/adapters/<framework>.yaml
framework: <name>
language:  <language>
entrypoint_generator: <path-to-template>
native_bdd: false                # true if framework runs .feature directly (Behave)
sandbox:
  before_scenario: <hook-name>
  after_scenario:  <hook-name>
  dispose_strategy: <description>
example_values_binding: <regex|cucumber-expression|both>
report_format: junit-xml|json   # what the runner emits
exit_code_map:                  # framework exit code → APS exit code
  0: 0
  1: 1
  ...
```

### 2. Implement Step Handler Registration

Step handlers must be registered with a unique ID matching the IR step text. Two binding styles are supported:

```yaml
# Regex style (preferred for type safety)
- handler_id: "user_enters_credentials"
  pattern: 'the user enters username "(?P<username>[^"]+)" and password "(?P<password>[^"]+)"'
  framework_binding: "regex_named_groups"

# Cucumber-expression style (more portable)
- handler_id: "user_enters_credentials"
  pattern: 'the user enters username {string} and password {string}'
  framework_binding: "cucumber_expression"
```

The adapter MUST resolve both styles — generate framework-specific glue code that maps IR steps to handlers.

### 3. Wire Sandbox Hooks

Every adapter must implement three hooks:

```python
# Pseudocode — the adapter generates this for the target framework
def before_scenario(world):
    """Fresh world, reset DB transaction, clear HTTP mocks, fresh tmp dir."""
    pass

def execute_step(world, step_text, example_values):
    """Resolve handler by matching step_text; bind example_values; invoke."""
    pass

def after_scenario(world):
    """Assert world.dispose() was called; emit trace span; release resources."""
    pass
```

### 4. Register the Adapter

Add to `.loopx/acceptance-pipeline/acceptance.env`:

```bash
APS_FRAMEWORK=<framework>
APS_ADAPTER_PATH=.loopx/skills/erics-ability-test-runner/adapters/<framework>.yaml
```

Validate with `loopx acceptance-pipeline run --dry-run`.

### 5. Add to the Supported Frameworks Table

Update this SKILL.md so future users can find your adapter. Include a short worked example of a generated entrypoint.

---

## Acceptance Runtime Contract

The adapter layer wraps the **Acceptance Runtime** — a thin process that:

1. Loads the JSON IR (from `.loopx/acceptance-pipeline/ir/*.ir.json`).
2. Iterates over `Feature → Background → Scenario → Steps`.
3. For each scenario:
   - Creates a fresh `world`.
   - Runs Background steps (they mutate the world).
   - Runs Scenario steps in order.
   - On exception: capture diagnostic, mark step `failed`, continue with `--no-fail-fast`.
   - Calls `world.dispose()`; verifies it ran.
4. Emits a JUnit XML report to `.loopx/acceptance-pipeline/reports/run/`.
5. Returns a structured `RunResult`:

```yaml
run_result:
  feature:       "auth/login.feature"
  scenario:      "Successful login with valid credentials"
  status:        passed | failed | error | skipped
  duration_ms:   1240
  steps:
    - index: 0
      text: "the user is on the login page"
      status: passed
      duration_ms: 50
    - index: 1
      text: 'the user enters username "alice" and password "secret123"'
      status: failed
      duration_ms: 800
      error:
        diagnostic: "Login request did not return 200"
        expected: "200"
        actual: "401"
        file: "features/steps/auth.py:27"
  world_state:   { last_response: { status: 401, body: "..." } }   # only on failure
  trace_span_id: "otel://aps/run/<uuid>"
```

### Sandboxing Strategy

The adapter enforces isolation at three levels:

| Level | Mechanism | What It Prevents |
|---|---|---|
| **Per-scenario world** | Fresh object per scenario; no module-level mutable state | State leakage between scenarios |
| **Filesystem** | `tmp_path` / `@TempDir` / `t.TempDir()` per scenario | Filesystem pollution, accidental git diffs |
| **Database** | Transaction rollback / savepoint per scenario (`begin; ... rollback;`) | Dirty rows, test interference |
| **Network** | HTTP mock server (e.g., `responses`, `httpretty`, `wiremock`) | Real external calls, rate-limit burn, mail send |
| **Side-effect monitor** | Detect unexpected writes (network, filesystem, mail) during handler execution | Production-touching tests |

**Default policies:**

- Each scenario: rollback any open transaction; clear HTTP mocks; remove tmp dir.
- Each scenario: verify `world.dispose()` was called (warn if not).
- Side-effect detector: alert on outbound HTTP write, file write outside tmp, SMTP send.

### Step Handler Fail-Fast Contract

| Condition | Behavior |
|---|---|
| Step text matches no handler | **FAIL** — error lists all registered handlers |
| Placeholder in step has no Examples binding | **FAIL** — error names the placeholder |
| Handler raises unexpected exception | **FAIL** — error captures traceback, marks scenario `error` |
| `world.dispose()` was not called | **WARN** — does not fail, but reported in run summary |
| Side-effect detected (mail send, file write outside tmp) | **WARN** by default; **FAIL** with `--strict-side-effects` |
| Flaky step (passes on retry within 3 attempts) | Mark `flaky`; do not fail unless `--no-flaky-tolerance` |

---

## CLI Interface

```bash
# Run all features against detected framework
loopx test-runner run

# Run specific feature
loopx test-runner run features/auth/login.feature

# Force a framework (overrides auto-detection)
loopx test-runner run --framework=junit5

# Run only changed scenarios (uses git diff against base branch)
loopx test-runner run --changed-only

# CI mode (JUnit XML + strict gates + side-effect detection)
loopx test-runner run --ci --strict-side-effects

# Sandbox policy
loopx test-runner run --sandbox=strict     # transaction rollback + side-effect monitor
loopx test-runner run --sandbox=lax        # only world isolation, no DB/FS guard
loopx test-runner run --sandbox=off        # dangerous; CI only with explicit approval

# Failure handling
loopx test-runner run --fail-fast          # stop on first failure
loopx test-runner run --no-fail-fast       # default; collect all failures

# Flaky tolerance
loopx test-runner run --flaky-retries=3    # default
loopx test-runner run --no-flaky-tolerance # CI mode

# Diagnostics
loopx test-runner run --explain-failure    # emit Stage-6-style diagnose report per failure
loopx test-runner run --trace              # OpenTelemetry spans

# Dry-run (no actual test execution; just print plan)
loopx test-runner run --dry-run
```

---

## Exit Code Meanings

| Exit Code | Meaning | Typical Cause |
|---|---|---|
| `0` | All scenarios passed | — |
| `1` | Scenario failure / handler error / missing handler | Assertion failed, exception in handler, no match for step |
| `2` | Step coverage gap (no handler for IR step) | Stage 3 fail-fast; IR has step text with no registered handler |
| `3` | User interrupted (SIGINT) | Ctrl-C |
| `4` | Environment error | Framework binary missing, sandbox setup failed, tmp dir not writable |
| `5` | Side-effect detected under strict mode | Test wrote to network/filesystem/mail when it should not have |
| `130` | SIGKILL — process forcibly terminated | Watchdog timeout (e.g., scenario ran > 60s) |

---

## Sandbox Hook Recipes

### Pytest

```python
@pytest.fixture(autouse=True)
def scenario_world(tmp_path):
    """Fresh world per scenario; auto-cleaned."""
    world = World(tmp_path=tmp_path)
    with db_transaction() as tx:
        world.tx = tx
        yield world
        tx.rollback()  # always rollback, even on failure
    world.dispose()
```

### JUnit 5

```java
@ExtendWith(ScenarioWorldExtension.class)
class LoginFeatureTest {
    @TempDir Path tmp;

    @BeforeEach
    void setupWorld(TestInfo info) {
        world = new World(tmp);
        tx = db.beginTransaction();
    }

    @AfterEach
    void teardownWorld() {
        tx.rollback();
        world.dispose();
    }
}
```

### Go testing

```go
func TestScenario(t *testing.T) {
    tmp := t.TempDir()
    world := NewWorld(tmp)
    tx := db.Begin()
    defer tx.Rollback()
    defer world.Dispose()

    // Given/When/Then generated calls
}
```

### Jest

```typescript
beforeEach(() => {
  world = new World();
  return db.transaction(async (tx) => {
    world.tx = tx;
  });
});

afterEach(async () => {
  await world.tx.rollback();
  await world.dispose();
});
```

### RSpec

```ruby
around(:each) do |example|
  world = World.new
  ActiveRecord::Base.transaction do
    example.run
    raise ActiveRecord::Rollback
  end
  world.dispose
end
```

---

## Diagnostic Report Format

When `--explain-failure` is set, each failure emits a markdown report to `.loopx/acceptance-pipeline/reports/diagnose/<scenario>.md`:

```yaml
scenario: features/auth/login.feature:42 "valid login"
stage: 4 (Run)
status: FAILED
duration: 1.2s

failure:
  step: "Then the user should be redirected to the dashboard"
  error: AssertionError: expected 'login' page, got 'dashboard'
  world_state:
    current_user: { id: 1, role: 'admin' }
    last_navigation: '/login'

suggestions:
  - 1. Check Whether "they login with valid credentials" actually redirected
  - 2. Verify world.user has role set before the Then step
  - 3. Reference: src/auth/step_handlers.py:78 — similar scenario

similar_passing:
  - "admin login bypass" (features/auth/admin.feature:15)

trace_span: otel://aps/run/<uuid>
```

---

## Relationship to Other Skills

| Skill | Distinction |
|---|---|
| `erics-ability-bdd` | Generates Gherkin + IR (Stage 1-2). Test-runner executes IR (Stage 4). |
| `erics-process-acceptance-pipeline` | Orchestrates all 7 stages. Test-runner is invoked as Stage 4. |
| `erics-process-mutation` | Verifies tests are meaningful (Stage 5). Test-runner just runs them. |
| `erics-ability-spec` | Spec → requirements. Test-runner assumes requirements already in `.feature` form. |

---

## Quick Reference

```bash
# Common one-liners
loopx test-runner run                              # default: auto-detect framework, run all
loopx test-runner run features/auth/login.feature  # specific feature
loopx test-runner run --framework=pytest --ci      # CI with explicit framework
loopx test-runner run --changed-only --explain-failure  # PR-friendly diff mode

# Inspect
loopx test-runner adapters                         # list installed adapters
loopx test-runner adapters --supported             # list built-in adapters
loopx test-runner coverage --ir <ir.json>          # which steps have handlers?

# Debug
loopx test-runner run --dry-run                    # show plan, no execution
loopx test-runner run --trace --verbose            # full OpenTelemetry trace
loopx test-runner run --no-fail-fast               # collect all failures
```

For end-to-end pipeline orchestration including IR generation, DRY checks, generation, mutation testing, and reporting, see `erics-process-acceptance-pipeline`.
