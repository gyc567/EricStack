# Engineering Plan Review Sections

Run these sections only after the parent skill resolves scope and completes Step 0. Review the plan that actually exists. Do not invent missing implementation details to make it pass.

## 1. Architecture

Check:

- component ownership and dependency direction;
- public interfaces, versioning, and migration order;
- data flow from input through persistence and output;
- trust, process, network, and storage boundaries;
- concurrency, idempotency, ordering, retries, and cancellation;
- failure isolation, rollback, and partial-success behavior;
- compatibility with the repository's existing architecture.

For each problem, cite the affected plan section, explain the failure scenario, and propose the smallest complete correction. Mark a finding blocking when an implementer would otherwise need to choose architecture during coding.

## 2. Code Quality and Maintainability

Check:

- reuse of existing modules and framework capabilities;
- unnecessary abstractions, dependencies, services, or configuration;
- ownership and lifecycle of every new resource;
- error types, diagnostics, and recovery policy;
- configuration defaults and invalid-state handling;
- naming and module placement;
- generated artifacts and their source of truth;
- documentation that must change with the implementation.

Reject placeholders such as “handle errors”, “add validation”, or “update docs” unless the plan names the errors, rules, and owning files.

## 3. Tests and Verification

Build a requirement-to-check matrix. Every acceptance criterion and changed public output needs an observable check.

Cover:

- unit tests for domain rules and edge cases;
- integration tests at process, network, persistence, or tool boundaries;
- migration and backward-compatibility tests;
- failure injection, retries, timeouts, cancellation, and cleanup;
- security and permission boundaries;
- user-visible output, CLI exit codes, API shapes, and diagnostics;
- the real acceptance workflow, not only mocks or copied fixtures.

State which checks run locally, in CI, or after deployment. If an acceptance path is externally blocked, require an explicit blocker and do not label the substitute acceptance-aligned.

## 4. Performance and Operability

Check:

- expected volume, latency, throughput, and memory bounds;
- algorithmic complexity and fan-out;
- cache keys, invalidation, eviction, and stampede behavior;
- database query shape, indexes, and transaction scope;
- backpressure and bounded queues;
- logs, metrics, traces, alerts, and health checks;
- rollout, rollback, feature flags, and incident diagnosis.

Do not require speculative optimization. Require a measurement plan where the change can plausibly affect a user-facing or operational budget.

## Outside Voice

After the four sections, review the plan from one external perspective appropriate to the change, such as:

- an operator responding to a failure;
- a new maintainer implementing the plan;
- an API consumer upgrading from the previous version;
- a security reviewer crossing each trust boundary;
- a user completing the primary workflow.

Name one concern the internal architecture review could miss.

## Required Output

Append the following to the plan file:

```markdown
## REVIEW REPORT

### Verdict
PASS | REVISE | BLOCKED

### Blocking Findings
- [plan section] Failure scenario → required correction

### Non-Blocking Improvements
- [plan section] Improvement and rationale

### Requirement-to-Check Matrix
| Requirement / public output | Planned check | Boundary | Acceptance relevance |
|---|---|---|---|

### Outside Voice
- Perspective: ...
- Concern: ...

### Remaining Assumptions
- ...
```

`PASS` requires no blocking findings, complete requirement-to-check mapping, and an implementable rollback/failure strategy. `BLOCKED` means evidence or a decision outside the reviewer’s authority is required. Otherwise use `REVISE`.
