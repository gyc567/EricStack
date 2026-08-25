# Prose Calibration Examples

Use these examples only after applying the complete-proposition rule in the parent skill. Preserve actors, conditions, obligations, failure behavior, and consequences.

## Trim repetition without weakening the contract

**Before**

> The caller must always close the stream after every successful read. It is very important that the caller closes it because otherwise the descriptor remains allocated.

**After**

> After a successful read, the caller must close the stream or the descriptor remains allocated.

The rewrite keeps the actor, timing, obligation, and consequence.

## Keep non-obvious rationale

**Keep**

> Serialize writes through the coordinator so a retry cannot overtake the original commit.

Removing the reason would make a direct write look like a harmless simplification.

## Delete narration that adds no contract

**Before**

> First we check whether the cache contains the value. Then we return it when present.

**After**

Delete the comment when the code already states this control flow.

## Restore a missing failure mode

**Incomplete**

> Returns the current snapshot.

**Complete**

> Returns the current snapshot, or `None` until the first successful refresh.

## Borderline rewrite

When two versions preserve the same propositions, prefer the one using concrete domain terms over abstract words such as “surface”, “shape”, or “seam”. Record a new example only when it resolves a genuinely reusable ambiguity.
