---
name: erics-ability-bdd
description: Use when you need to generate Gherkin acceptance tests from requirements — creates human-readable, AI-generable BDD scenarios as a contract between stakeholders and code.
triggers:
  - gherkin
  - bdd tests
  - acceptance tests
  - 生成验收测试
  - Given When Then
  - cucumber
  - scenario outline
---

# Gherkin Acceptance Test Generator

**Transform natural language requirements into executable BDD scenarios.**

---

## What is Gherkin?

Gherkin is a business-readable DSL for describing software behavior:

```gherkin
Feature: Login authentication

  Scenario: Successful login with valid credentials
    Given a user with email "alice@example.com" and password "Secret123"
    When the user submits the login form
    Then the user should be redirected to the dashboard
    And the session token should be set

  Scenario: Failed login with wrong password
    Given a user with email "alice@example.com" and password "WrongPassword"
    When the user submits the login form
    Then the user should see an error message "Invalid credentials"
    And the user should remain on the login page
```

**Why Gherkin over plain English?**
- Executable — tools like pytest-bdd, Cucumber, Behave can run it
- Structured — `Given` (context), `When` (action), `Then` (assertion)
- Stakeholder-readable — non-programmers can review
- AI-generable — LLMs can produce Gherkin from natural language

---

## AI-Era TDD Workflow

Uncle Bob's AI-Era TDD:

```
1. Human writes requirements (natural language)
   ↓
2. AI generates Gherkin scenarios
   ↓
3. Human reviews/adjusts Gherkin  ← THIS SKILL
   ↓
4. AI generates code from Gherkin
   ↓
5. Run Gherkin tests to verify
   ↓
6. Mutation testing to verify test quality
```

---

## Generating Gherkin from Requirements

### Step 1 — Identify the Feature

A feature is a distinct capability. Ask: "What user-facing behavior are we building?"

Example requirement:
> "Users should be able to reset their password by email. If the email is registered, send a reset link valid for 24 hours. If not registered, show a generic 'check your email' message (don't reveal whether the email exists)."

### Step 2 — Identify Scenarios

For each feature, identify:
- **Happy path** — normal successful behavior
- **Edge cases** — boundary conditions, empty inputs
- **Error paths** — invalid data, timeouts, missing permissions
- **Alternative flows** — what if the email server is down?

### Step 3 — Write Gherkin

Use the `Given-When-Then` pattern:

```
Feature: Password Reset

  Scenario: Reset link sent to registered email
    Given a registered user with email "alice@example.com"
    When the user requests a password reset for "alice@example.com"
    Then a reset email should be sent to "alice@example.com"
    And the reset link should be valid for 24 hours

  Scenario: Generic message shown for unregistered email
    Given no user with email "unknown@example.com"
    When the user requests a password reset for "unknown@example.com"
    Then the user should see the message "If an account exists, a reset email was sent"
    And no email should be sent

  Scenario: Reset link expires after 24 hours
    Given a user with a reset link generated 25 hours ago
    When the user clicks the expired reset link
    Then the user should see the message "This link has expired"
    And the user should be prompted to request a new reset
```

### Step 4 — Use Scenario Outline for Data-Driven Cases

```gherkin
  Scenario Outline: Login attempts with various password states
    Given a user with email "<email>" and password "<password>"
    When the user attempts to log in with password "<attempt>"
    Then the result should be "<result>"

    Examples: Valid credentials
      | email          | password   | attempt    | result              |
      | alice@test.com | Secret123  | Secret123  | login success       |
      | alice@test.com | Secret123  | wrongpass  | invalid credentials |

    Examples: Edge cases
      | email          | password   | attempt    | result              |
      | alice@test.com | Secret123  |            | password required   |
      |                | Secret123  | Secret123  | email required      |
```

---

## Generating Step Definitions

Once you have Gherkin scenarios, generate step definitions:

```python
# Python (behave)
# features/steps/login_steps.py

from behave import given, when, then

@given('a registered user with email "{email}"')
def step_user_exists(context, email):
    context.user = UserFactory(email=email)
    context.user.save()

@when('the user requests a password reset for "{email}"')
def step_request_reset(context, email):
    context.response = context.client.post('/password/reset', {'email': email})

@then('a reset email should be sent to "{email}"')
def step_email_sent(context, email):
    assert len(mail.outbox) == 1
    assert mail.outbox[0].to == [email]
```

---

## Key Principles

### 1. One Assertion Per `Then`

Prefer one assertion per `Then` clause. Multiple assertions make it unclear which one failed.

```gherkin
# ✅ Good — clear which assertion failed
Then the user should be redirected to the dashboard
And the session token should be set

# ⚠️ Acceptable — if assertions are tightly coupled
Then the response should have status 200 and contain "login_token"
```

### 2. No Implementation Details in Gherkin

Gherkin describes **behavior**, not implementation:

```gherkin
# ✅ Good — describes WHAT, not HOW
When the user submits the login form

# ❌ Bad — implementation leaking into behavior
When the user clicks the submit button and waits for the fetch request
```

### 3. Background for Common Context

```gherkin
Feature: Admin dashboard

  Background:
    Given an admin user "admin@example.com" with role "admin"
    And the admin is logged in

  Scenario: Admin can view all users
    When the admin navigates to the users page
    Then all users should be displayed
```

### 4. Tags for Organization

```gherkin
@auth @smoke @critical
Feature: Login authentication
  ...

@auth @regression
Feature: Password reset
  ...
```

---

## Tools

| Tool | Language | Install |
|---|---|---|
| **behave** | Python | `pip install behave` |
| **pytest-bdd** | Python | `pip install pytest-bdd` |
| **cucumber** | Multi | See cucumber.io |
| **jest-cucumber** | JavaScript | `npm install jest-cucumber` |
| **rspec** | Ruby | `gem install rspec` |

---

## Relationship to Other Skills

| Skill | Distinction |
|---|---|
| `erics-ability-spec` | Spec → produces a technical spec. Gherkin gen → produces executable acceptance tests. |
| `erics-process-mutation-testing` | Mutation testing verifies tests are meaningful. Gherkin generates the tests themselves. |
| `erics-process-pre-push-checks` | Pre-push runs tests. Gherkin gen creates the tests first. |

---

## Output Format

For each feature, output:

```
## Feature: [Feature Name]

### Scenarios Generated
N scenarios (M steps total)

| Scenario | Given | When | Then | Tags |
|---|---|---|---|---|
| Happy path login | 1 | 1 | 2 | @auth @smoke |
| Invalid password | 1 | 1 | 1 | @auth |
| ... | ... | ... | ... | ... |

### Step Definitions (Python/behave)
```python
@given('a user with email "{email}"')
def step_user(context, email):
    ...
```

### Coverage Notes
- ✅ Happy path covered
- ✅ Invalid credential edge case
- ⚠️ Rate limiting not tested (requires mock time)
- ❌ Session expiry not tested (requires time travel)

### Recommendation
Ready for human review / Add N more scenarios / Merge and iterate
```
