---
name: Boil the Ocean
created: 2026-08-15
tags: [principle, completeness]
---

# Boil the Ocean

## Origin

EricStack follows the **Boil the Ocean** principle from the [LLM Wiki integration guide](../../llm-wiki-integration.md):

> AI makes completeness cheap, so the complete thing is the goal. Do the full thing when marginal cost approaches zero.

## What It Means in Practice

- Write all tests, not just happy-path ones
- Cover all edge cases when the cost of missing them is high
- Don't ship partial features that require future cleanup
- When doing a review, do it completely — don't skip files because they're boring

## When NOT to Boil the Ocean

- Early exploration where the right direction is unknown
- POCs that are explicitly temporary
- When the user explicitly asks for a quick-and-dirty answer

## See Also

- [[concepts/loop-engineering]]
- [[erics-process-pre-push-checks]]
