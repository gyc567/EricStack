# Recall Batteries

Run these probes read-only with `rg --hidden`. Exclude generated, vendored, archived, and VCS content. A hit is a review candidate, not an automatic deletion.

```bash
rg --hidden -n \
  --glob '!.git/**' \
  --glob '!vendor/**' \
  --glob '!node_modules/**' \
  --glob '!target/**' \
  --glob '!.agents/notes/archived/**' \
  '(decision [A-Z0-9-]+|audit [A-Z][0-9]+|design §[0-9]|this PR|later PR|rejected in review|reviewer confirmed)' \
  <scope>
```

```bash
rg --hidden -n \
  --glob '!.git/**' \
  --glob '!vendor/**' \
  --glob '!node_modules/**' \
  --glob '!target/**' \
  '(used to|no longer|the old [A-Za-z]|this cut|for now|probably|should be enough|first we .* then we)' \
  <scope>
```

```bash
rg --hidden -n \
  --glob '!.git/**' \
  --glob '!vendor/**' \
  --glob '!node_modules/**' \
  '(TODO|FIXME|XXX|HACK)' \
  <scope>
```

## Review procedure

1. Confirm each reference resolves from the repository at `HEAD`.
2. Classify the hit using the parent skill taxonomy.
3. Keep sanctioned evidence and measured bounds.
4. Restate durable facts before deleting transcript-like language.
5. Re-run the same commands and inspect remaining hits manually.

Pattern coverage is intentionally incomplete. Also read the densest prose in scope without a search pattern.
