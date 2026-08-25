# Chain-of-Thought Leakage Examples

These examples calibrate the taxonomy in the parent skill. Preserve durable facts and remove only the session-bound vantage.

## Dead session citation

**Before:** `Use the coordinator because audit C4 required it.`

**After:** `Use the coordinator so concurrent retries cannot reorder durable writes.`

The audit label is removed; the invariant survives.

## Change narration

**Before:** `This used to retry forever, but now it stops after three attempts.`

**After:** `The operation stops after three failed attempts.`

## Review choreography

**Before:** `The reviewer confirmed that this cast is safe.`

**After:** The cast is safe because the validated length is bounded by `u32::MAX`.

## Planning residue

**Before:** `This is probably enough for now.`

**After:** State the measurable bound, create an owned `TODO`, or delete the sentence when it carries no fact.

## Sanctioned evidence to keep

Keep resolvable issue references, standards citations, measured bounds, suppression reasons, and evidence links in Agent Notes or postmortems.

## Overcorrection traps

Do not:

- delete a citation together with the only surviving invariant;
- rewrite a proposed design as shipped behavior;
- turn “must not” into a recommendation;
- remove issue ownership from an explicit deferred task;
- erase a measured bound because its collection happened in the past.

For every edit, enumerate the original propositions and confirm the final text preserves each durable one.
